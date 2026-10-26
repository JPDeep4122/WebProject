package com.dienmay.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.branch.BranchRepository;
import java.math.BigDecimal;
import java.util.Locale;

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
    public String adminDashboard(Model model) {
        model.addAttribute("customerCount", userRepository.countCustomers());
        model.addAttribute("totalRevenue", orderRepository.sumSuccessfulRevenue());
        model.addAttribute("branches", branchRepository.findAll().stream().map(branch -> {
            var revenue = orderRepository.sumSuccessfulRevenueByBranch(branch.getId());
            return new BranchRevenue(branch.getName(), revenue == null ? BigDecimal.ZERO : revenue);
        }).toList());
        return "admin/dashboard"; // Trỏ đến src/main/webapp/WEB-INF/views/admin/dashboard.jsp
    }

    public record BranchRevenue(String name, BigDecimal revenue) {
        public String formattedRevenue() {
            return String.format(Locale.forLanguageTag("vi-VN"), "%,.0f đ", revenue);
        }
    }
}
