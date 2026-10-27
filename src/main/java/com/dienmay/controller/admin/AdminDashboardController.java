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
        model.addAttribute("customerCount", userRepository.countCustomers());
        model.addAttribute("totalRevenue", orderRepository.sumSuccessfulRevenue());
        model.addAttribute("branches", branchRepository.findAll().stream().map(branch -> {
            var revenue = orderRepository.sumSuccessfulRevenueByBranch(branch.getId());
            return new BranchRevenue(branch.getName(), revenue == null ? BigDecimal.ZERO : revenue);
        }).toList());
        model.addAttribute("successfulOrders", orderRepository.findSuccessfulPaidOrders(
                PaymentStatus.SUCCESS, OrderStatus.CANCELLED,
                PageRequest.of(0, 5, Sort.by(Sort.Direction.DESC, "createdAt"))).getContent());
        var currentUser = userRepository.findByEmail(principal.getName()).orElse(null);
        boolean admin = currentUser != null && currentUser.getRoles().stream()
                .anyMatch(role -> role.getName() != null && role.getName().toUpperCase().endsWith("ADMIN"));
        Long branchId = admin || currentUser == null || currentUser.getBranch() == null
                ? null : currentUser.getBranch().getId();
        model.addAttribute("orderRealtimeDestination", admin
                ? OrderStatusWebSocketNotifier.ADMIN_DESTINATION
                : branchId == null ? "" : OrderStatusWebSocketNotifier.branchDestination(branchId));
        model.addAttribute("orderStatusPollUrl", "/admin/orders/status-snapshot"
                + (branchId == null ? "" : "?branchId=" + branchId));
        return "admin/dashboard"; // Trỏ đến src/main/webapp/WEB-INF/views/admin/dashboard.jsp
    }

    public record BranchRevenue(String name, BigDecimal revenue) {
        public String formattedRevenue() {
            return String.format(Locale.forLanguageTag("vi-VN"), "%,.0f đ", revenue);
        }
    }
}
