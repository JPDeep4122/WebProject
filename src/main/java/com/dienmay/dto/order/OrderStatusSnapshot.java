package com.dienmay.dto.order;

import java.time.LocalDateTime;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;

public record OrderStatusSnapshot(
        String orderCode,
        OrderStatus status,
        LocalDateTime updatedAt) {

    public static OrderStatusSnapshot from(Order order) {
        return new OrderStatusSnapshot(
                order.getOrderCode(), order.getStatus(), order.getUpdatedAt());
    }
}