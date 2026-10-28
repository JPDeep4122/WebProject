package com.dienmay.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
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
    public String adminDashboard(@RequestParam(required = false) Long branchId,
                                Model model, Principal principal) {
        var currentUser = userRepository.findByEmail(principal.getName()).orElse(null);
        boolean admin = currentUser != null && currentUser.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));
        boolean branchManager = currentUser != null && currentUser.getRoles().stream()
                .anyMatch(role -> "ROLE_BRANCH_MANAGER".equals(role.getName()));
        boolean canViewRevenue = admin || branchManager;

        Long effectiveBranchId = admin ? branchId : (currentUser != null && currentUser.getBranch() != null ? currentUser.getBranch().getId() : null);

        String currentBranchName = "Toàn chuỗi chi nhánh";
        if (effectiveBranchId != null) {
            currentBranchName = branchRepository.findById(effectiveBranchId)
                    .map(com.dienmay.entity.branch.Branch::getName)
                    .orElse("Toàn chuỗi chi nhánh");
        }

        model.addAttribute("canViewRevenue", canViewRevenue);
        model.addAttribute("isAdmin", admin);
        model.addAttribute("selectedBranchId", effectiveBranchId);
        model.addAttribute("currentBranchName", currentBranchName);
        model.addAttribute("allBranches", branchRepository.findAll(Sort.by("name")));

        Map<OrderStatus, Long> statusCounts = new EnumMap<>(OrderStatus.class);
        long statusChartTotal = 0;
        for (OrderStatus status : OrderStatus.values()) {
            long count = canViewRevenue ? orderRepository.countDashboardOrdersByStatus(effectiveBranchId, status) : 0;
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
            long successfulOrdersCount = effectiveBranchId == null
                    ? orderRepository.countSuccessfulOrders()
                    : orderRepository.countSuccessfulOrdersByBranch(effectiveBranchId);

            BigDecimal totalRevenue = effectiveBranchId == null
                    ? orderRepository.sumSuccessfulRevenue()
                    : orderRepository.sumSuccessfulRevenueByBranch(effectiveBranchId);
            BigDecimal safeRevenue = totalRevenue == null ? BigDecimal.ZERO : totalRevenue;

            BigDecimal aov = successfulOrdersCount > 0
                    ? safeRevenue.divide(BigDecimal.valueOf(successfulOrdersCount), 0, java.math.RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            long customerCount = effectiveBranchId == null
                    ? orderRepository.countUniqueCustomersWithPurchases()
                    : orderRepository.countUniqueCustomersWithPurchasesByBranch(effectiveBranchId);

            model.addAttribute("customerCount", customerCount);
            model.addAttribute("totalRevenue", safeRevenue);
            model.addAttribute("successfulOrdersCount", successfulOrdersCount);
            model.addAttribute("aov", aov);

            var branchRevenues = branchRepository.findAll(Sort.by("name")).stream().map(branch -> {
                var revenue = orderRepository.sumSuccessfulRevenueByBranch(branch.getId());
                return new BranchRevenue(branch.getId(), branch.getName(), revenue == null ? BigDecimal.ZERO : revenue, 0);
            }).toList();
            BigDecimal revenueTotal = branchRevenues.stream().map(BranchRevenue::revenue)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            model.addAttribute("branches", branchRevenues.stream().map(branch -> {
                int share = revenueTotal.signum() == 0 ? 0 : branch.revenue()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(revenueTotal, 0, java.math.RoundingMode.HALF_UP).intValue();
                return new BranchRevenue(branch.id(), branch.name(), branch.revenue(), Math.min(share, 100));
            }).toList());

            model.addAttribute("successfulOrders", effectiveBranchId == null
                    ? orderRepository.findSuccessfulPaidOrders(PaymentStatus.SUCCESS, OrderStatus.CANCELLED, top5Pageable).getContent()
                    : orderRepository.findSuccessfulPaidOrdersByBranch(effectiveBranchId, PaymentStatus.SUCCESS, OrderStatus.CANCELLED, top5Pageable).getContent());
            model.addAttribute("topSellingProducts", productRepository.findTop5ByActiveTrueOrderBySoldQuantityDesc());
        } else if (branchManager && effectiveBranchId != null) {
            long successfulOrdersCount = orderRepository.countSuccessfulOrdersByBranch(effectiveBranchId);
            BigDecimal branchRev = orderRepository.sumSuccessfulRevenueByBranch(effectiveBranchId);
            BigDecimal safeRev = branchRev == null ? BigDecimal.ZERO : branchRev;
            BigDecimal aov = successfulOrdersCount > 0
                    ? safeRev.divide(BigDecimal.valueOf(successfulOrdersCount), 0, java.math.RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            model.addAttribute("customerCount", orderRepository.countUniqueCustomersWithPurchasesByBranch(effectiveBranchId));
            model.addAttribute("totalRevenue", safeRev);
            model.addAttribute("successfulOrdersCount", successfulOrdersCount);
            model.addAttribute("aov", aov);
            model.addAttribute("branches", List.of(new BranchRevenue(currentUser.getBranch().getId(), currentUser.getBranch().getName(), safeRev,
                    safeRev.signum() == 0 ? 0 : 100)));
            model.addAttribute("successfulOrders", orderRepository.findSuccessfulPaidOrdersByBranch(
                    effectiveBranchId, PaymentStatus.SUCCESS, OrderStatus.CANCELLED, top5Pageable).getContent());
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
            model.addAttribute("revenueTrend", buildRevenueTrend(effectiveBranchId, from, to));
        }

        model.addAttribute("orderRealtimeDestination", admin
                ? OrderStatusWebSocketNotifier.ADMIN_DESTINATION
                : effectiveBranchId == null ? "" : OrderStatusWebSocketNotifier.branchDestination(effectiveBranchId));
        model.addAttribute("orderStatusPollUrl", "/admin/orders/status-snapshot"
                + (effectiveBranchId == null ? "" : "?branchId=" + effectiveBranchId));
        return "admin/dashboard";
    }

    public record BranchRevenue(Long id, String name, BigDecimal revenue, int sharePercent) {
        public String formattedRevenue() {
            return String.format(Locale.forLanguageTag("vi-VN"), "%,.0f đ", revenue);
        }
    }

    public record RevenueDay(String dayLabel, String dateLabel, BigDecimal revenue, int barPercent, long orderCount) { }

    public record OrderStatusSlice(String label, long count, double percent, String color) { }

    private List<RevenueDay> buildRevenueTrend(Long branchId, LocalDateTime from, LocalDateTime to) {
        Map<LocalDate, BigDecimal> values = new java.util.HashMap<>();
        Map<LocalDate, Long> orderCounts = new java.util.HashMap<>();

        for (Object[] row : orderRepository.summarizeDailyRevenue(branchId, from, to)) {
            LocalDate day = toLocalDate(row[0]);
            BigDecimal revenue = row[1] instanceof BigDecimal amount ? amount : new BigDecimal(row[1].toString());
            long orders = row.length > 2 && row[2] != null ? ((Number) row[2]).longValue() : 0L;
            values.put(day, revenue);
            orderCounts.put(day, orders);
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
            long orders = orderCounts.getOrDefault(day, 0L);
            int percent = max.signum() == 0 ? 0 : amount.multiply(BigDecimal.valueOf(100))
                    .divide(max, 0, java.math.RoundingMode.HALF_UP).intValue();
            chart.add(new RevenueDay(day.getDayOfWeek().getDisplayName(java.time.format.TextStyle.SHORT,
                    Locale.forLanguageTag("vi-VN")), day.format(dateFormat), amount, percent, orders));
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
                OrderStatus.PENDING, "#3b82f6", OrderStatus.CONFIRMED, "#5b8def",
                OrderStatus.PROCESSING, "#06b6d4", OrderStatus.SHIPPING, "#718096",
                OrderStatus.DELIVERED, "#10b981", OrderStatus.CANCELLED, "#dc3545",
                OrderStatus.RETURN_REQUESTED, "#9b59b6", OrderStatus.RETURNED, "#7952b3");
        return labels.entrySet().stream().map(entry -> {
            long count = counts.getOrDefault(entry.getKey(), 0L);
            double percent = total == 0 ? 0 : count * 100.0 / total;
            return new OrderStatusSlice(entry.getValue(), count, percent, colors.get(entry.getKey()));
        }).toList();
    }
}