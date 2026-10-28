package com.dienmay.controller.client;

import java.security.Principal;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.dienmay.service.notification.CustomerNotificationService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class CustomerNotificationApiController {
    private final CustomerNotificationService notifications;

    @GetMapping
    public CustomerNotificationService.NotificationFeed list(Principal principal) {
        return notifications.listFor(requireEmail(principal));
    }

    @PostMapping("/{id}/read")
    public Map<String, Boolean> markRead(@PathVariable Long id, Principal principal) {
        if (!notifications.markRead(requireEmail(principal), id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy thông báo.");
        }
        return Map.of("success", true);
    }

    @PostMapping("/read-all")
    public Map<String, Object> markAllRead(Principal principal) {
        return Map.of("success", true, "updated", notifications.markAllRead(requireEmail(principal)));
    }

    private String requireEmail(Principal principal) {
        if (principal == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập.");
        return principal.getName();
    }
}
