package com.dienmay.service.order;

import com.dienmay.dto.order.OrderStatusUpdate;

public record OrderStatusChangedEvent(
        String recipientEmail,
        Long branchId,
        OrderStatusUpdate update) {
}
