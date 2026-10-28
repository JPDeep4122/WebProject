package com.dienmay.controller.client;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CustomerNotificationPageController {
    @GetMapping("/notifications")
    public String page() {
        return "client/notifications";
    }
}
