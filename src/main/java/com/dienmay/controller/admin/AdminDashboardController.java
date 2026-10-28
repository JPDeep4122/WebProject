package com.dienmay.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.PaymentStatus;
import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;
import java.security.Principal;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import com.dienmay.service.order.OrderStatusWebSocketNotifier;

@Controller
public class AdminDashboardController {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final BranchRepository branchRepository;

    public AdminDashboardController(UserRepository userRepository, OrderRepository orderRepository,
                                    BranchRepository branchRepository) {
        this.userRepository = userRepository;
        this.orderRepository = orderRepository;
        this.branchRepository = branchRepository;
    }

    @GetMapping("/admin")
    public String adminDashboard(Model model, Principal principal) {
        var currentUser = userRepository.findByEmail(principal.getName()).orElse(null);
        boolean admin = currentUser != null && currentUser.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));
        boolean branchManager = currentUser != null && currentUser.getRoles().stream()
                .anyMatch(role -> "ROLE_BRANCH_MANAGER".equals(role.getName()));
        boolean canViewRevenue = admin || branchManager;

        Long branchId = admin || currentUser == null || currentUser.getBranch() == null
                ? null : currentUser.getBranch().getId();

        model.addAttribute("canViewRevenue", canViewRevenue);
        model.addAttribute("isAdmin", admin);
        model.addAttribute("currentBranchName",
                currentUser != null && currentUser.getBranch() != null
                        ? currentUser.getBranch().getName() : "Toàn chuỗi chi nhánh");

        var top5Pageable = PageRequest.of(0, 5, Sort.by(Sort.Direction.DESC, "createdAt"));

        if (admin) {
            model.addAttribute("customerCount", orderRepository.countUniqueCustomersWithPurchases());
            model.addAttribute("totalRevenue", orderRepository.sumSuccessfulRevenue());
            model.addAttribute("branches", branchRepository.findAll().stream().map(branch -> {
                var revenue = orderRepository.sumSuccessfulRevenueByBranch(branch.getId());
                return new BranchRevenue(branch.getName(), revenue == null ? BigDecimal.ZERO : revenue);
            }).toList());
            model.addAttribute("successfulOrders", orderRepository.findSuccessfulPaidOrders(
                    PaymentStatus.SUCCESS, OrderStatus.CANCELLED, top5Pageable).getContent());
        } else if (branchManager && branchId != null) {
            BigDecimal branchRev = orderRepository.sumSuccessfulRevenueByBranch(branchId);
            BigDecimal safeRev = branchRev == null ? BigDecimal.ZERO : branchRev;
            model.addAttribute("customerCount", orderRepository.countUniqueCustomersWithPurchasesByBranch(branchId));
            model.addAttribute("totalRevenue", safeRev);
            model.addAttribute("branches", List.of(new BranchRevenue(currentUser.getBranch().getName(), safeRev)));
            model.addAttribute("successfulOrders", orderRepository.findSuccessfulPaidOrdersByBranch(
                    branchId, PaymentStatus.SUCCESS, OrderStatus.CANCELLED, top5Pageable).getContent());
        } else {
            model.addAttribute("customerCount", 0L);
            model.addAttribute("totalRevenue", BigDecimal.ZERO);
            model.addAttribute("branches", List.of());
            model.addAttribute("successfulOrders", List.of());
        }

        model.addAttribute("orderRealtimeDestination", admin
                ? OrderStatusWebSocketNotifier.ADMIN_DESTINATION
                : branchId == null ? "" : OrderStatusWebSocketNotifier.branchDestination(branchId));
        model.addAttribute("orderStatusPollUrl", "/admin/orders/status-snapshot"
                + (branchId == null ? "" : "?branchId=" + branchId));
        return "admin/dashboard";
    }

    public record BranchRevenue(String name, BigDecimal revenue) {
        public String formattedRevenue() {
            return String.format(Locale.forLanguageTag("vi-VN"), "%,.0f đ", revenue);
        }
    }
}