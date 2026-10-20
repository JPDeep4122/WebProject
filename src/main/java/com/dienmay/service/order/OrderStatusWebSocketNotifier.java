package com.dienmay.service.order;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class OrderStatusWebSocketNotifier {
    public static final String USER_DESTINATION = "/queue/order-status";
    public static final String ADMIN_DESTINATION = "/topic/admin/order-status";

    private final SimpMessagingTemplate messagingTemplate;

    @TransactionalEventListener(
            phase = TransactionPhase.AFTER_COMMIT,
            fallbackExecution = true)
    public void notifyCustomer(OrderStatusChangedEvent event) {
        if (event.recipientEmail() == null || event.recipientEmail().isBlank()) {
            return;
        }
        messagingTemplate.convertAndSendToUser(
                event.recipientEmail(), USER_DESTINATION, event.update());
        if (event.branchId() != null) {
            messagingTemplate.convertAndSend(
                    branchDestination(event.branchId()), event.update());
            messagingTemplate.convertAndSend(ADMIN_DESTINATION, event.update());
        }
    }

    public static String branchDestination(Long branchId) {
        return "/topic/branches/" + branchId + "/order-status";
    }
}
