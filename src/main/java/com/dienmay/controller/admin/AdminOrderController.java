package com.dienmay.controller.admin;

import java.security.Principal;
import java.util.Arrays;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.service.order.OrderService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
public class AdminOrderController {

    private final OrderService orderService;
    private final UserRepository userRepository;
    private final BranchRepository branchRepository;

    @GetMapping
    public String listOrders(
            @RequestParam(required = false) Long branchId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Principal principal,
            Model model) {
        User currentUser = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy tài khoản đang đăng nhập."));
        boolean admin = currentUser.getRoles().stream()
                .anyMatch(role -> role.getName() != null && role.getName().toUpperCase().endsWith("ADMIN"));

        Long effectiveBranchId = admin ? branchId
                : currentUser.getBranch() == null ? null : currentUser.getBranch().getId();
        OrderStatus selectedStatus = parseStatus(status);
        int safePage = Math.max(page, 0);
        int safeSize = Arrays.asList(10, 20, 50).contains(size) ? size : 20;
        var pageable = PageRequest.of(safePage, safeSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<Order> orders;
        if (!admin && effectiveBranchId == null) {
            orders = Page.empty(pageable);
            model.addAttribute("error", "Tài khoản nhân viên chưa được gán chi nhánh.");
        } else {
            orders = orderService.getOrdersForBranch(effectiveBranchId, selectedStatus, pageable);
        }

        model.addAttribute("ordersPage", orders);
        model.addAttribute("statuses", OrderStatus.values());
        model.addAttribute("selectedStatus", selectedStatus == null ? "" : selectedStatus.name());
        model.addAttribute("selectedBranchId", effectiveBranchId);
        model.addAttribute("branches", admin ? branchRepository.findByActiveTrue()
                : currentUser.getBranch() == null ? java.util.List.of() : java.util.List.of(currentUser.getBranch()));
        model.addAttribute("canChooseBranch", admin);
        model.addAttribute("pageSize", safeSize);
        return "admin/orders";
    }

    private OrderStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        try {
            return OrderStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException ignored) {
            return null;
        }
    }
}
