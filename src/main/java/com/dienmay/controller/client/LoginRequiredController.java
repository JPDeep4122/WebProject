package com.dienmay.controller.client;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.Principal;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller
public class LoginRequiredController {
    @GetMapping("/login-required")
    public String show(@RequestParam(defaultValue = "/orders") String redirect,
            Principal principal, Model model, HttpServletRequest request, HttpServletResponse response) {
        String destination = safeDestination(redirect);
        response.setHeader("Cache-Control", "no-store");
        if (principal != null) return "redirect:" + destination;
        model.addAttribute("loginUrl", request.getContextPath() + "/login?redirect="
                + URLEncoder.encode(destination, StandardCharsets.UTF_8));
        model.addAttribute("loginRequiredTitle", destination.startsWith("/checkout")
                ? "Đăng nhập để mua hàng" : destination.startsWith("/account")
                ? "Đăng nhập để xem hồ sơ" : "Đăng nhập để xem đơn hàng");
        return "client/login-required";
    }

    static String safeDestination(String value) {
        try {
            if (value.contains("\\") || value.contains("\r") || value.contains("\n")) return "/orders";
            URI uri = URI.create(value);
            if (uri.isAbsolute() || uri.getRawAuthority() != null || uri.getFragment() != null) return "/orders";
            String path = uri.getPath();
            if (path != null && (path.equals("/checkout") || path.startsWith("/checkout/")
                    || path.equals("/orders") || path.startsWith("/orders/")
                    || path.equals("/account") || path.startsWith("/account/")
                    || path.startsWith("/order-success/") || path.equals("/payment/vnpay-return"))) return value;
        } catch (IllegalArgumentException ignored) { }
        return "/orders";
    }
}
