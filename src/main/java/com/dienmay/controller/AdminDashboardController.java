package com.dienmay.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AdminDashboardController {

    @GetMapping("/admin")
    public String adminDashboard() {
        return "admin/dashboard"; // Trỏ đến src/main/webapp/WEB-INF/views/admin/dashboard.jsp
    }
}