package com.dienmay.service.order;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.order.DeliveryStatisticsPoint;
import com.dienmay.dto.order.DeliveryStatisticsReport;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.DeliveryAssignmentRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DeliveryStatisticsService {
    private static final DateTimeFormatter POINT_FORMAT = DateTimeFormatter.ofPattern("dd/MM");
    private static final DateTimeFormatter FULL_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter MONTH_FORMAT = DateTimeFormatter.ofPattern("MM/yyyy");

    private final DeliveryAssignmentRepository assignments;
    private final UserRepository users;

    @Transactional(readOnly = true)
    public DeliveryStatisticsReport summarize(String shipperEmail,
            DeliveryStatisticsPeriod period, LocalDate anchor) {
        validateShipper(shipperEmail);
        DeliveryStatisticsPeriod selectedPeriod = period == null ? DeliveryStatisticsPeriod.WEEK : period;
        LocalDate selectedAnchor = anchor == null ? LocalDate.now() : anchor;
        LocalDate start = selectedPeriod.start(selectedAnchor);
        LocalDate endExclusive = selectedPeriod.endExclusive(selectedAnchor);

        var completed = assignments.findCompletedInPeriod(shipperEmail,
                DeliveryStatus.DELIVERED_SUCCESS, start.atStartOfDay(), endExclusive.atStartOfDay());
        var dailyValues = new LinkedHashMap<LocalDate, DailyValue>();
        for (LocalDate date = start; date.isBefore(endExclusive); date = date.plusDays(1)) {
            dailyValues.put(date, new DailyValue());
        }
        completed.forEach(assignment -> {
            LocalDate date = assignment.getCompletedAt().toLocalDate();
            DailyValue value = dailyValues.get(date);
            if (value != null) {
                value.count++;
                BigDecimal orderValue = assignment.getOrder().getFinalAmount();
                value.amount = value.amount.add(orderValue == null ? BigDecimal.ZERO : orderValue);
            }
        });

        long deliveredOrders = completed.size();
        BigDecimal deliveredValue = dailyValues.values().stream()
                .map(value -> value.amount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal average = deliveredOrders == 0 ? BigDecimal.ZERO
                : deliveredValue.divide(BigDecimal.valueOf(deliveredOrders), 0, RoundingMode.HALF_UP);
        long maxCount = dailyValues.values().stream().mapToLong(value -> value.count).max().orElse(0);
        var points = new ArrayList<DeliveryStatisticsPoint>();
        dailyValues.forEach((date, value) -> points.add(new DeliveryStatisticsPoint(
                date, date.format(POINT_FORMAT), value.count, value.amount,
                maxCount == 0 ? 0 : (int) Math.round(value.count * 100.0 / maxCount))));

        return DeliveryStatisticsReport.builder()
                .period(selectedPeriod.name())
                .periodLabel(periodLabel(selectedPeriod, start, endExclusive.minusDays(1)))
                .anchor(selectedAnchor)
                .startDate(start)
                .endDate(endExclusive.minusDays(1))
                .previousAnchor(selectedPeriod.previous(selectedAnchor))
                .nextAnchor(selectedPeriod.next(selectedAnchor))
                .deliveredOrders(deliveredOrders)
                .deliveredValue(deliveredValue)
                .averageOrderValue(average)
                .points(points)
                .build();
    }

    private void validateShipper(String email) {
        User shipper = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy tài khoản shipper."));
        boolean hasShipperRole = shipper.getRoles().stream()
                .anyMatch(role -> "ROLE_SHIPPER".equals(role.getName()));
        if (!shipper.isActive() || !hasShipperRole) {
            throw new AccessDeniedException("Tài khoản không có quyền xem thống kê giao hàng.");
        }
    }

    private String periodLabel(DeliveryStatisticsPeriod period, LocalDate start, LocalDate end) {
        return switch (period) {
            case DAY -> "Ngày " + start.format(FULL_FORMAT);
            case WEEK -> "Tuần " + start.format(FULL_FORMAT) + " - " + end.format(FULL_FORMAT);
            case MONTH -> "Tháng " + start.format(MONTH_FORMAT);
        };
    }

    private static class DailyValue {
        private long count;
        private BigDecimal amount = BigDecimal.ZERO;
    }
}
