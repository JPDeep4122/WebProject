package com.dienmay.config;

import java.io.IOException;
import java.util.Arrays;
import java.util.Set;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.context.event.ApplicationStartedEvent;
import org.springframework.boot.info.BuildProperties;
import org.springframework.context.event.EventListener;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.annotation.PreDestroy;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class DeploymentDiagnostics extends OncePerRequestFilter {
    private static final Logger log = LoggerFactory.getLogger(DeploymentDiagnostics.class);
    private static final Set<String> PAGE_PATHS = Set.of("/", "/login", "/products");
    private final AtomicLong sequence = new AtomicLong();
    private final ScheduledThreadPoolExecutor watchdog;
    private final Environment environment;
    private final String revision;
    private final long slowRequestMs;

    public DeploymentDiagnostics(ObjectProvider<BuildProperties> builds, Environment environment) {
        this.environment = environment;
        BuildProperties build = builds.getIfAvailable();
        String builtRevision = build == null ? null : build.get("revision");
        revision = builtRevision != null && builtRevision.matches("[0-9a-f]{7,40}")
                ? builtRevision : "diagnostics-v2";
        slowRequestMs = Math.max(1, environment.getProperty(
                "app.diagnostics.slow-request-ms", Long.class, 15000L));
        watchdog = new ScheduledThreadPoolExecutor(1, task -> {
            Thread thread = new Thread(task, "slow-page-watchdog");
            thread.setDaemon(true);
            return thread;
        });
        watchdog.setRemoveOnCancelPolicy(true);
    }

    @EventListener(ApplicationStartedEvent.class)
    public void logDeployment() {
        log.info("Deployment diagnostics-v2 revision={} instance={} profiles={} warmup={} maxHeapMiB={}",
                revision, environment.getProperty("RENDER_INSTANCE_ID", "local"),
                String.join(",", environment.getActiveProfiles()),
                environment.getProperty("app.warmup.enabled", "false"),
                Runtime.getRuntime().maxMemory() / (1024 * 1024));
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        response.setHeader("X-App-Revision", revision);
        String path = request.getRequestURI().substring(request.getContextPath().length());
        if (!"GET".equals(request.getMethod()) || !PAGE_PATHS.contains(path)) {
            filterChain.doFilter(request, response);
            return;
        }

        long id = sequence.incrementAndGet();
        long started = System.nanoTime();
        Thread requestThread = Thread.currentThread();
        AtomicBoolean finished = new AtomicBoolean();
        var warning = watchdog.schedule(() -> {
            StackTraceElement[] stack = requestThread.getStackTrace();
            if (!finished.get()) {
                String frames = Arrays.stream(stack).limit(40).map(Object::toString)
                        .collect(Collectors.joining("\n    at "));
                // Only fixed public paths and stack frames: never log cookies,
                // authorization headers, query strings or request bodies.
                log.warn("Slow page request id={} path={} revision={} waitingMs={} thread={}\n    at {}",
                        id, path, revision, elapsedMs(started), requestThread.getName(), frames);
            }
        }, slowRequestMs, TimeUnit.MILLISECONDS);
        try {
            filterChain.doFilter(request, response);
        } finally {
            finished.set(true);
            warning.cancel(false);
            long elapsed = elapsedMs(started);
            if (elapsed >= slowRequestMs) {
                log.warn("Slow page completed id={} path={} status={} elapsedMs={}",
                        id, path, response.getStatus(), elapsed);
            }
        }
    }

    private static long elapsedMs(long started) {
        return TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - started);
    }

    @PreDestroy
    public void shutdown() {
        watchdog.shutdownNow();
    }
}
