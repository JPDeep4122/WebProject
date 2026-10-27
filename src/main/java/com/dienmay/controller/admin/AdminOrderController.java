package com.dienmay.controller.admin;

import java.security.Principal;
import java.util.Arrays;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.dienmay.dto.order.OrderStatusSnapshot;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.service.order.OrderService;
import com.dienmay.service.order.OrderStatusWebSocketNotifier;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
public class AdminOrderController {

    private final OrderService orderService;
    private final UserRepository userRepository;
    private final BranchRepository branchRepository;
    private final OrderRepository orderRepository;
    private final com.dienmay.service.order.OrderConfirmationService confirmationService;
    private final com.dienmay.service.order.OrderPickingService pickingService;
    private final com.dienmay.service.order.OrderFulfillmentService fulfillmentService;
    private final com.dienmay.service.order.DeliveryAssignmentService deliveryAssignmentService;

    @org.springframework.web.bind.annotation.PostMapping("/{id}/confirm")
    public String confirm(@org.springframework.web.bind.annotation.PathVariable Long id,
            Principal principal, org.springframework.web.servlet.mvc.support.RedirectAttributes flash) {
        try {
            confirmationService.confirm(id, principal.getName());
            flash.addFlashAttribute("success", "Đã xác nhận đơn hàng và trừ tồn kho chi nhánh.");
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @org.springframework.web.bind.annotation.PostMapping("/{id}/start-picking")
    public String startPicking(@org.springframework.web.bind.annotation.PathVariable Long id,
            Principal principal, org.springframework.web.servlet.mvc.support.RedirectAttributes flash) {
        try {
            pickingService.startPicking(id, principal.getName());
            flash.addFlashAttribute("success", "Đã chuyển đơn sang bước lấy và chuẩn bị hàng.");
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @org.springframework.web.bind.annotation.PostMapping("/{id}/start-shipping")
    public String startShipping(@org.springframework.web.bind.annotation.PathVariable Long id,
            Principal principal, org.springframework.web.servlet.mvc.support.RedirectAttributes flash) {
        return execute(id, principal, flash, fulfillmentService::startShipping,
                "Đã chuyển đơn sang trạng thái đang giao.");
    }

    @org.springframework.web.bind.annotation.PostMapping("/{id}/assign")
    public String assign(@org.springframework.web.bind.annotation.PathVariable Long id,
            @RequestParam Long shipperId, Principal principal,
            org.springframework.web.servlet.mvc.support.RedirectAttributes flash) {
        try {
            deliveryAssignmentService.assign(id, shipperId, principal.getName());
            flash.addFlashAttribute("success", "Đã phân công đơn hàng cho shipper.");
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @org.springframework.web.bind.annotation.PostMapping("/{id}/deliver")
    public String deliver(@org.springframework.web.bind.annotation.PathVariable Long id,
            Principal principal, org.springframework.web.servlet.mvc.support.RedirectAttributes flash) {
        return execute(id, principal, flash, fulfillmentService::markDelivered,
                "Đã xác nhận giao hàng thành công.");
    }

    @org.springframework.web.bind.annotation.PostMapping("/{id}/cancel")
    public String cancel(@org.springframework.web.bind.annotation.PathVariable Long id,
            Principal principal, org.springframework.web.servlet.mvc.support.RedirectAttributes flash) {
        return execute(id, principal, flash, fulfillmentService::cancel,
                "Đã hủy đơn hàng.");
    }

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
        var shippers = userRepository
                .findDistinctByRoles_NameAndActiveTrueOrderByFullNameAsc("ROLE_SHIPPER");
        if (effectiveBranchId != null) {
            shippers = shippers.stream()
                    .filter(shipper -> shipper.getBranch() != null
                            && java.util.Objects.equals(shipper.getBranch().getId(), effectiveBranchId))
                    .toList();
        }
        model.addAttribute("shippers", shippers);
        model.addAttribute("canChooseBranch", admin);
        model.addAttribute("pageSize", safeSize);
        model.addAttribute("orderRealtimeDestination",
                admin && effectiveBranchId == null
                        ? OrderStatusWebSocketNotifier.ADMIN_DESTINATION
                        : effectiveBranchId == null ? ""
                        : OrderStatusWebSocketNotifier.branchDestination(effectiveBranchId));
        return "admin/orders";
    }

    @GetMapping("/{id}")
    public String orderDetail(@org.springframework.web.bind.annotation.PathVariable Long id, Model model) {
        Order order = orderRepository.findDetailedById(id)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng."));
        model.addAttribute("order", order);
        return "admin/order-detail";
    }

    @GetMapping("/status-snapshot")
    @ResponseBody
    public List<OrderStatusSnapshot> statusSnapshot(
            @RequestParam(required = false) Long branchId,
            Principal principal) {
        if (principal == null) {
            throw new org.springframework.web.server.ResponseStatusException(
                    org.springframework.http.HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập.");
        }
        User currentUser = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.UNAUTHORIZED,
                        "Không tìm thấy tài khoản đang đăng nhập."));
        boolean admin = currentUser.getRoles().stream()
                .anyMatch(role -> role.getName() != null
                        && role.getName().toUpperCase().endsWith("ADMIN"));
        Long effectiveBranchId = admin ? branchId
                : currentUser.getBranch() == null ? null : currentUser.getBranch().getId();
        if (!admin && effectiveBranchId == null) return List.of();
        var pageable = PageRequest.of(0, 500, Sort.by(Sort.Direction.DESC, "updatedAt"));
        return orderService.getOrdersForBranch(effectiveBranchId, null, pageable).stream()
                .map(OrderStatusSnapshot::from).toList();
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

    private String execute(Long id, Principal principal,
            org.springframework.web.servlet.mvc.support.RedirectAttributes flash,
            OrderAction action, String successMessage) {
        try {
            action.run(id, principal.getName());
            flash.addFlashAttribute("success", successMessage);
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @FunctionalInterface
    private interface OrderAction {
        void run(Long orderId, String email);
    }
}
