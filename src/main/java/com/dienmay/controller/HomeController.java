package com.dienmay.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String homePage() {
        return "client/home"; // Trỏ đến src/main/webapp/WEB-INF/views/client/home.jsp
    }
}