package com.dienmay.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.PaymentStatus;
import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.EnumMap;
import java.util.ArrayList;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.security.Principal;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import com.dienmay.service.order.OrderStatusWebSocketNotifier;

@Controller
public class AdminDashboardController {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final BranchRepository branchRepository;
    private final ProductRepository productRepository;

    public AdminDashboardController(UserRepository userRepository, OrderRepository orderRepository,
                                    BranchRepository branchRepository, ProductRepository productRepository) {
        this.userRepository = userRepository;
        this.orderRepository = orderRepository;
        this.branchRepository = branchRepository;
        this.productRepository = productRepository;
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

        // Đếm đơn theo trạng thái theo phạm vi quyền hạn
        Map<OrderStatus, Long> statusCounts = new EnumMap<>(OrderStatus.class);
        long statusChartTotal = 0;
        for (OrderStatus status : OrderStatus.values()) {
            long count = canViewRevenue ? orderRepository.countDashboardOrdersByStatus(branchId, status) : 0;
            statusCounts.put(status, count);
            statusChartTotal += count;
        }
        model.addAttribute("pendingOrderCount", statusCounts.getOrDefault(OrderStatus.PENDING, 0L));
        model.addAttribute("processingOrderCount", statusCounts.getOrDefault(OrderStatus.PROCESSING, 0L));
        model.addAttribute("shippingOrderCount", statusCounts.getOrDefault(OrderStatus.SHIPPING, 0L));
        model.addAttribute("deliveredOrderCount", statusCounts.getOrDefault(OrderStatus.DELIVERED, 0L));
        model.addAttribute("statusChartTotal", statusChartTotal);
        model.addAttribute("orderStatusChart", buildOrderStatusChart(statusCounts, statusChartTotal));

        var top5Pageable = PageRequest.of(0, 5, Sort.by(Sort.Direction.DESC, "createdAt"));

        if (admin) {
            long successfulOrdersCount = orderRepository.countSuccessfulOrders();
            BigDecimal totalRevenue = orderRepository.sumSuccessfulRevenue();
            BigDecimal safeRevenue = totalRevenue == null ? BigDecimal.ZERO : totalRevenue;
            BigDecimal aov = successfulOrdersCount > 0
                    ? safeRevenue.divide(BigDecimal.valueOf(successfulOrdersCount), 0, java.math.RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            model.addAttribute("customerCount", orderRepository.countUniqueCustomersWithPurchases());
            model.addAttribute("totalRevenue", safeRevenue);
            model.addAttribute("successfulOrdersCount", successfulOrdersCount);
            model.addAttribute("aov", aov);

            var branchRevenues = branchRepository.findAll().stream().map(branch -> {
                var revenue = orderRepository.sumSuccessfulRevenueByBranch(branch.getId());
                return new BranchRevenue(branch.getName(), revenue == null ? BigDecimal.ZERO : revenue, 0);
            }).toList();
            BigDecimal revenueTotal = branchRevenues.stream().map(BranchRevenue::revenue)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            model.addAttribute("branches", branchRevenues.stream().map(branch -> {
                int share = revenueTotal.signum() == 0 ? 0 : branch.revenue()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(revenueTotal, 0, java.math.RoundingMode.HALF_UP).intValue();
                return new BranchRevenue(branch.name(), branch.revenue(), Math.min(share, 100));
            }).toList());
            model.addAttribute("successfulOrders", orderRepository.findSuccessfulPaidOrders(
                    PaymentStatus.SUCCESS, OrderStatus.CANCELLED, top5Pageable).getContent());
            model.addAttribute("topSellingProducts", productRepository.findTop5ByActiveTrueOrderBySoldQuantityDesc());
        } else if (branchManager && branchId != null) {
            long successfulOrdersCount = orderRepository.countSuccessfulOrdersByBranch(branchId);
            BigDecimal branchRev = orderRepository.sumSuccessfulRevenueByBranch(branchId);
            BigDecimal safeRev = branchRev == null ? BigDecimal.ZERO : branchRev;
            BigDecimal aov = successfulOrdersCount > 0
                    ? safeRev.divide(BigDecimal.valueOf(successfulOrdersCount), 0, java.math.RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            model.addAttribute("customerCount", orderRepository.countUniqueCustomersWithPurchasesByBranch(branchId));
            model.addAttribute("totalRevenue", safeRev);
            model.addAttribute("successfulOrdersCount", successfulOrdersCount);
            model.addAttribute("aov", aov);
            model.addAttribute("branches", List.of(new BranchRevenue(currentUser.getBranch().getName(), safeRev,
                    safeRev.signum() == 0 ? 0 : 100)));
            model.addAttribute("successfulOrders", orderRepository.findSuccessfulPaidOrdersByBranch(
                    branchId, PaymentStatus.SUCCESS, OrderStatus.CANCELLED, top5Pageable).getContent());
            model.addAttribute("topSellingProducts", productRepository.findTop5ByActiveTrueOrderBySoldQuantityDesc());
        } else {
            model.addAttribute("customerCount", 0L);
            model.addAttribute("totalRevenue", BigDecimal.ZERO);
            model.addAttribute("successfulOrdersCount", 0L);
            model.addAttribute("aov", BigDecimal.ZERO);
            model.addAttribute("branches", List.of());
            model.addAttribute("successfulOrders", List.of());
            model.addAttribute("topSellingProducts", List.of());
        }

        if (canViewRevenue) {
            LocalDate today = LocalDate.now();
            LocalDateTime from = today.minusDays(6).atStartOfDay();
            LocalDateTime to = today.plusDays(1).atStartOfDay();
            model.addAttribute("revenueTrend", buildRevenueTrend(branchId, from, to));
        }

        model.addAttribute("orderRealtimeDestination", admin
                ? OrderStatusWebSocketNotifier.ADMIN_DESTINATION
                : branchId == null ? "" : OrderStatusWebSocketNotifier.branchDestination(branchId));
        model.addAttribute("orderStatusPollUrl", "/admin/orders/status-snapshot"
                + (branchId == null ? "" : "?branchId=" + branchId));
        return "admin/dashboard";
    }

    public record BranchRevenue(String name, BigDecimal revenue, int sharePercent) {
        public String formattedRevenue() {
            return String.format(Locale.forLanguageTag("vi-VN"), "%,.0f đ", revenue);
        }
    }

    public record RevenueDay(String dayLabel, String dateLabel, BigDecimal revenue, int barPercent) { }

    public record OrderStatusSlice(String label, long count, double percent, String color) { }

    private List<RevenueDay> buildRevenueTrend(Long branchId, LocalDateTime from, LocalDateTime to) {
        Map<LocalDate, BigDecimal> values = new java.util.HashMap<>();
        for (Object[] row : orderRepository.summarizeDailyRevenue(branchId, from, to)) {
            LocalDate day = toLocalDate(row[0]);
            BigDecimal revenue = row[1] instanceof BigDecimal amount ? amount : new BigDecimal(row[1].toString());
            values.put(day, revenue);
        }

        List<LocalDate> days = new ArrayList<>();
        BigDecimal max = BigDecimal.ZERO;
        for (int offset = 0; offset < 7; offset++) {
            LocalDate day = from.toLocalDate().plusDays(offset);
            days.add(day);
            BigDecimal amount = values.getOrDefault(day, BigDecimal.ZERO);
            if (amount.compareTo(max) > 0) max = amount;
        }
        DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd/MM");
        List<RevenueDay> chart = new ArrayList<>();
        for (LocalDate day : days) {
            BigDecimal amount = values.getOrDefault(day, BigDecimal.ZERO);
            int percent = max.signum() == 0 ? 0 : amount.multiply(BigDecimal.valueOf(100))
                    .divide(max, 0, java.math.RoundingMode.HALF_UP).intValue();
            chart.add(new RevenueDay(day.getDayOfWeek().getDisplayName(java.time.format.TextStyle.SHORT,
                    Locale.forLanguageTag("vi-VN")), day.format(dateFormat), amount, percent));
        }
        return chart;
    }

    private LocalDate toLocalDate(Object value) {
        if (value instanceof java.sql.Date date) return date.toLocalDate();
        if (value instanceof LocalDate date) return date;
        if (value instanceof java.sql.Timestamp timestamp) return timestamp.toLocalDateTime().toLocalDate();
        return LocalDate.parse(value.toString());
    }

    private List<OrderStatusSlice> buildOrderStatusChart(Map<OrderStatus, Long> counts, long total) {
        Map<OrderStatus, String> labels = new java.util.LinkedHashMap<>();
        labels.put(OrderStatus.PENDING, "Chờ xác nhận");
        labels.put(OrderStatus.CONFIRMED, "Đã xác nhận");
        labels.put(OrderStatus.PROCESSING, "Đang chuẩn bị");
        labels.put(OrderStatus.SHIPPING, "Đang giao");
        labels.put(OrderStatus.DELIVERED, "Đã giao thành công");
        labels.put(OrderStatus.CANCELLED, "Đã hủy");
        labels.put(OrderStatus.RETURN_REQUESTED, "Yêu cầu trả hàng");
        labels.put(OrderStatus.RETURNED, "Đã trả hàng");
        Map<OrderStatus, String> colors = Map.of(
                OrderStatus.PENDING, "#f4b400", OrderStatus.CONFIRMED, "#5b8def",
                OrderStatus.PROCESSING, "#16a6c9", OrderStatus.SHIPPING, "#718096",
                OrderStatus.DELIVERED, "#198754", OrderStatus.CANCELLED, "#dc3545",
                OrderStatus.RETURN_REQUESTED, "#9b59b6", OrderStatus.RETURNED, "#7952b3");
        return labels.entrySet().stream().map(entry -> {
            long count = counts.getOrDefault(entry.getKey(), 0L);
            double percent = total == 0 ? 0 : count * 100.0 / total;
            return new OrderStatusSlice(entry.getValue(), count, percent, colors.get(entry.getKey()));
        }).toList();
    }
}