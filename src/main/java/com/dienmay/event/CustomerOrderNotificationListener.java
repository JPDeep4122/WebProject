package com.dienmay.event;

import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import com.dienmay.service.notification.CustomerNotificationService;
import com.dienmay.service.order.OrderStatusChangedEvent;
import com.dienmay.service.order.OrderRefundConfirmedEvent;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CustomerOrderNotificationListener {
    private final CustomerNotificationService notifications;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onOrderStatusChanged(OrderStatusChangedEvent event) {
        if (event.update() == null || event.update().status() == null) return;
        notifications.recordOrderStatus(event.recipientEmail(), event.update().orderCode(),
                event.update().status().name());
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onOrderRefundConfirmed(OrderRefundConfirmedEvent event) {
        if (event == null) return;
        notifications.recordRefundConfirmed(event.recipientEmail(), event.orderCode(), event.amount(),
                event.branchName(), event.branchAddress(), event.refundMethod());
    }
}
