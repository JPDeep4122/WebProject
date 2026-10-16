package com.dienmay.event;
import com.dienmay.entity.audit.AuditLog;
import com.dienmay.repository.audit.AuditLogRepository;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
@Component
public class PromotionEventListener {
    private final AuditLogRepository logs;
    public PromotionEventListener(AuditLogRepository logs){this.logs=logs;}
    @EventListener public void onPromotion(PromotionEvent event){
        logs.save(AuditLog.builder().action(event.getAction()).entityType("PROMOTION").entityId(event.getPromotionId()).actor(event.getActor()).details(event.getDetails()).build());
    }
}
