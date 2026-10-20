package com.dienmay.dto.order;

import java.time.LocalDateTime;

import com.dienmay.entity.order.OrderStatus;

public record OrderStatusUpdate(
        String orderCode,
        OrderStatus previousStatus,
        OrderStatus status,
        LocalDateTime changedAt) {
}
