package com.dienmay.event;
import lombok.Getter;
@Getter
public class PromotionEvent {
    private final Long promotionId; private final String action; private final String actor; private final String details;
    public PromotionEvent(Long promotionId, String action, String actor, String details){this.promotionId=promotionId;this.action=action;this.actor=actor;this.details=details;}
}
