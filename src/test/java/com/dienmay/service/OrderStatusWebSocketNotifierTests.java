package com.dienmay.service;

import static org.mockito.Mockito.verify;

import java.time.LocalDateTime;

import org.junit.jupiter.api.Test;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import com.dienmay.dto.order.OrderStatusUpdate;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.service.order.OrderStatusChangedEvent;
import com.dienmay.service.order.OrderStatusWebSocketNotifier;

class OrderStatusWebSocketNotifierTests {

    @Test
    void sendsStatusUpdateToPrivateCustomerQueue() {
        var messaging = org.mockito.Mockito.mock(SimpMessagingTemplate.class);
        var notifier = new OrderStatusWebSocketNotifier(messaging);
        var update = new OrderStatusUpdate("ORD-1", OrderStatus.PROCESSING,
                OrderStatus.SHIPPING, LocalDateTime.now());

        notifier.notifyCustomer(new OrderStatusChangedEvent("customer@example.test", 7L, update));

        verify(messaging).convertAndSendToUser(
                "customer@example.test", "/queue/order-status", update);
        verify(messaging).convertAndSend("/topic/branches/7/order-status", update);
        verify(messaging).convertAndSend("/topic/admin/order-status", update);
    }

    @Test
    void guestOrdersNotifyBranchAndAdminWithoutSendingToAnyUser() {
        var messaging = org.mockito.Mockito.mock(SimpMessagingTemplate.class);
        var notifier = new OrderStatusWebSocketNotifier(messaging);
        var update = new OrderStatusUpdate("ORD-GUEST", OrderStatus.PENDING,
                OrderStatus.CONFIRMED, LocalDateTime.now());
        notifier.notifyCustomer(new OrderStatusChangedEvent(null, 7L, update));
        verify(messaging).convertAndSend("/topic/branches/7/order-status", update);
        verify(messaging).convertAndSend("/topic/admin/order-status", update);
        org.mockito.Mockito.verifyNoMoreInteractions(messaging);
    }
}
