package com.dienmay.event;

import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import com.dienmay.service.notification.CustomerNotificationService;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CustomerPromotionNotificationListener {
    private final CustomerNotificationService notifications;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onPromotionCreated(PromotionEvent event) {
        if ("PROMOTION_CREATED".equals(event.getAction())) {
            notifications.announcePromotion(event.getPromotionId());
        }
    }
}
