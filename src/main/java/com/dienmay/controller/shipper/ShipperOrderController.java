package com.dienmay.controller.shipper;

import java.security.Principal;
import java.util.Arrays;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.DeliveryAssignmentRepository;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/shipper")
@RequiredArgsConstructor
public class ShipperOrderController {
    private final DeliveryAssignmentRepository assignments;
    private final UserRepository users;

    @GetMapping
    public String home() {
        return "redirect:/shipper/orders";
    }

    @GetMapping("/orders")
    public String list(@RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Principal principal, Model model) {
        var shipper = users.findByEmail(principal.getName())
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy tài khoản shipper."));
        DeliveryStatus selectedStatus = parseStatus(status);
        int safePage = Math.max(page, 0);
        int safeSize = Arrays.asList(10, 20, 50).contains(size) ? size : 20;
        var pageable = PageRequest.of(safePage, safeSize,
                Sort.by(Sort.Direction.DESC, "assignedAt"));

        var result = selectedStatus == null
                ? assignments.findAssignedTo(shipper.getEmail(), pageable)
                : assignments.findAssignedToByStatus(shipper.getEmail(), selectedStatus, pageable);

        model.addAttribute("assignmentsPage", result);
        model.addAttribute("shipper", shipper);
        model.addAttribute("statuses", DeliveryStatus.values());
        model.addAttribute("selectedStatus", selectedStatus == null ? "" : selectedStatus.name());
        model.addAttribute("pageSize", safeSize);
        return "shipper/orders";
    }

    private DeliveryStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        try {
            return DeliveryStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException ignored) {
            return null;
        }
    }
}
