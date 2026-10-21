package com.dienmay.dto.order;

import java.math.BigDecimal;
import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class DeliveryStatisticsPoint {
    private final LocalDate date;
    private final String label;
    private final long orderCount;
    private final BigDecimal orderValue;
    private final int percentage;
}
