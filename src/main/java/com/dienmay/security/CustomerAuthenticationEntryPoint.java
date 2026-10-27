package com.dienmay.security;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class CustomerAuthenticationEntryPoint implements AuthenticationEntryPoint {
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
            AuthenticationException exception) throws IOException {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        String destination = path;
        if (path.startsWith("/api/account/")) {
            destination = "/account/profile";
        } else if (path.startsWith("/api/checkout/")) {
            destination = "/checkout";
        } else if (path.endsWith("/status-snapshot")) {
            destination = "/orders";
        } else if (!"GET".equals(request.getMethod())) {
            destination = path.startsWith("/account") ? "/account/profile"
                    : path.startsWith("/checkout") || path.startsWith("/api/checkout") ? "/checkout" : "/orders";
        } else if (request.getQueryString() != null) {
            destination += "?" + request.getQueryString();
        }
        String loginUrl = request.getContextPath() + "/login-required?redirect="
                + URLEncoder.encode(destination, StandardCharsets.UTF_8);
        response.setHeader("Cache-Control", "no-store");
        if (path.startsWith("/api/") || path.endsWith("/status-snapshot")
                || !"GET".equals(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để tiếp tục.\","
                    + "\"loginUrl\":\"" + loginUrl + "\"}");
        } else {
            response.sendRedirect(loginUrl);
        }
    }
}
