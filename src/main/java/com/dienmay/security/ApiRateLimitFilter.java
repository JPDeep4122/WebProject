package com.dienmay.security;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

import org.springframework.http.MediaType;
import org.springframework.web.filter.OncePerRequestFilter;

import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/** In-process request throttling for API endpoints, with stricter policies for authentication. */
public final class ApiRateLimitFilter extends OncePerRequestFilter {
    private static final long GENERAL_WINDOW_MS = Duration.ofMinutes(1).toMillis();
    private static final long AUTH_WINDOW_MS = Duration.ofMinutes(15).toMillis();
    private static final int GENERAL_LIMIT = 120;
    private static final Map<String, Integer> AUTH_LIMITS = Map.of(
            "login", 10,
            "register", 5,
            "verify-otp", 10,
            "resend-otp", 3,
            "forgot-password", 5,
            "reset-password", 10,
            "google", 20,
            "logout", 20);

    private final ConcurrentHashMap<String, Window> windows = new ConcurrentHashMap<>();
    private final AtomicLong requestCounter = new AtomicLong();
    private final ObjectMapper objectMapper;

    public ApiRateLimitFilter(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().substring(request.getContextPath().length()).startsWith("/api/");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        long now = System.currentTimeMillis();
        String path = request.getRequestURI().substring(request.getContextPath().length());
        Policy policy = policyFor(path);
        String key = clientAddress(request) + ':' + policy.key;
        Window window = windows.computeIfAbsent(key, ignored -> new Window(now));
        long retryAfterMs = window.tryAcquire(now, policy.windowMs, policy.limit);

        // Keep memory bounded even if an API is hit by many one-off client addresses.
        if ((requestCounter.incrementAndGet() & 1023) == 0) {
            windows.entrySet().removeIf(entry -> entry.getValue().expired(now, AUTH_WINDOW_MS * 2));
        }

        if (retryAfterMs > 0) {
            long retryAfterSeconds = Math.max(1, (retryAfterMs + 999) / 1000);
            response.setStatus(429);
            response.setHeader("Retry-After", Long.toString(retryAfterSeconds));
            response.setHeader("Cache-Control", "no-store");
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");
            objectMapper.writeValue(response.getOutputStream(), Map.of(
                    "status", 429,
                    "error", "Too Many Requests",
                    "message", "Bạn gửi yêu cầu quá nhanh. Vui lòng thử lại sau.",
                    "retryAfterSeconds", retryAfterSeconds));
            return;
        }

        response.setHeader("X-RateLimit-Limit", Integer.toString(policy.limit));
        response.setHeader("X-RateLimit-Remaining", Integer.toString(window.remaining(policy.limit)));
        chain.doFilter(request, response);
    }

    private Policy policyFor(String path) {
        if (path.startsWith("/api/auth/")) {
            String operation = path.substring("/api/auth/".length()).split("/", 2)[0];
            int limit = AUTH_LIMITS.getOrDefault(operation, 10);
            return new Policy("auth:" + operation, AUTH_WINDOW_MS, limit);
        }
        return new Policy("api", GENERAL_WINDOW_MS, GENERAL_LIMIT);
    }

    private String clientAddress(HttpServletRequest request) {
        // The ingress proxy must overwrite X-Forwarded-For before forwarding the request.
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null) {
            String candidate = forwardedFor.split(",", 2)[0].trim();
            if (candidate.length() <= 64 && candidate.matches("[0-9a-fA-F:.]+")) {
                return candidate;
            }
        }
        String remote = request.getRemoteAddr();
        return remote == null || remote.isBlank() ? "unknown" : remote;
    }

    private record Policy(String key, long windowMs, int limit) {}

    private static final class Window {
        private long startedAt;
        private int count;

        private Window(long startedAt) {
            this.startedAt = startedAt;
        }

        private synchronized long tryAcquire(long now, long durationMs, int limit) {
            if (now - startedAt >= durationMs || now < startedAt) {
                startedAt = now;
                count = 0;
            }
            if (count >= limit) {
                return Math.max(1, durationMs - (now - startedAt));
            }
            count++;
            return 0;
        }

        private synchronized int remaining(int limit) {
            return Math.max(0, limit - count);
        }

        private synchronized boolean expired(long now, long maxAgeMs) {
            return now - startedAt > maxAgeMs;
        }
    }
}
