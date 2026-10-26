package com.dienmay.service.order;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;

public enum DeliveryStatisticsPeriod {
    DAY,
    WEEK,
    MONTH;

    public LocalDate start(LocalDate anchor) {
        return switch (this) {
            case DAY -> anchor;
            case WEEK -> anchor.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            case MONTH -> anchor.withDayOfMonth(1);
        };
    }

    public LocalDate endExclusive(LocalDate anchor) {
        LocalDate start = start(anchor);
        return switch (this) {
            case DAY -> start.plusDays(1);
            case WEEK -> start.plusWeeks(1);
            case MONTH -> start.plusMonths(1);
        };
    }

    public LocalDate previous(LocalDate anchor) {
        LocalDate start = start(anchor);
        return switch (this) {
            case DAY -> start.minusDays(1);
            case WEEK -> start.minusWeeks(1);
            case MONTH -> start.minusMonths(1);
        };
    }

    public LocalDate next(LocalDate anchor) {
        LocalDate start = start(anchor);
        return switch (this) {
            case DAY -> start.plusDays(1);
            case WEEK -> start.plusWeeks(1);
            case MONTH -> start.plusMonths(1);
        };
    }

    public static DeliveryStatisticsPeriod parse(String value) {
        if (value == null || value.isBlank()) {
            return WEEK;
        }
        try {
            return valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException ignored) {
            return WEEK;
        }
    }
}
