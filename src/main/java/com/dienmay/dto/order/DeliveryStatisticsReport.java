package com.dienmay.dto.order;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class DeliveryStatisticsReport {
    private final String period;
    private final String periodLabel;
    private final LocalDate anchor;
    private final LocalDate startDate;
    private final LocalDate endDate;
    private final LocalDate previousAnchor;
    private final LocalDate nextAnchor;
    private final long deliveredOrders;
    private final BigDecimal deliveredValue;
    private final BigDecimal averageOrderValue;
    private final List<DeliveryStatisticsPoint> points;
}
