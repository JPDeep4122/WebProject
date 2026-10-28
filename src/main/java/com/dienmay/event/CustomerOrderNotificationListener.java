package com.dienmay.event;

import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import com.dienmay.service.notification.CustomerNotificationService;
import com.dienmay.service.order.OrderStatusChangedEvent;

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
}
