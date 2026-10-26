package com.dienmay.controller.shipper;

import java.security.Principal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Arrays;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.DeliveryAssignmentRepository;
import com.dienmay.service.order.DeliveryStatusService;
import com.dienmay.service.order.DeliveryStatisticsPeriod;
import com.dienmay.service.order.DeliveryStatisticsService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/shipper")
@RequiredArgsConstructor
public class ShipperOrderController {
    private final DeliveryAssignmentRepository assignments;
    private final UserRepository users;
    private final DeliveryStatusService deliveryStatusService;
    private final DeliveryStatisticsService deliveryStatisticsService;

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

    @PostMapping("/orders/{id}/status")
    public String updateStatus(@PathVariable Long id,
            @RequestParam DeliveryStatus status,
            @RequestParam(required = false) String failureReason,
            Principal principal, RedirectAttributes flash) {
        try {
            deliveryStatusService.update(id, status, failureReason, principal.getName());
            flash.addFlashAttribute("success", successMessage(status));
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/shipper/orders";
    }

    @GetMapping("/statistics")
    public String statistics(@RequestParam(required = false) String period,
            @RequestParam(required = false) String date,
            Principal principal, Model model) {
        DeliveryStatisticsPeriod selectedPeriod = DeliveryStatisticsPeriod.parse(period);
        LocalDate anchor = parseDate(date);
        var report = deliveryStatisticsService.summarize(
                principal.getName(), selectedPeriod, anchor);
        var shipper = users.findByEmail(principal.getName())
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy tài khoản shipper."));
        model.addAttribute("report", report);
        model.addAttribute("shipper", shipper);
        return "shipper/statistics";
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

    private String successMessage(DeliveryStatus status) {
        return switch (status) {
            case DELIVERING -> "Đã chuyển đơn sang trạng thái đang giao.";
            case DELIVERED_SUCCESS -> "Đã xác nhận giao hàng thành công.";
            case DELIVERED_FAILED -> "Đã ghi nhận giao hàng thất bại.";
            default -> "Đã cập nhật trạng thái giao hàng.";
        };
    }

    private LocalDate parseDate(String date) {
        if (date == null || date.isBlank()) {
            return LocalDate.now();
        }
        try {
            return LocalDate.parse(date.trim());
        } catch (DateTimeParseException ignored) {
            return LocalDate.now();
        }
    }
}
