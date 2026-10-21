package com.dienmay.entity.audit;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
@Entity @Table(name="audit_logs") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AuditLog {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
    @Column(nullable=false) private String action;
    @Column(nullable=false) private String entityType;
    private Long entityId;
    private String actor;
    @Column(columnDefinition="TEXT") private String details;
    @Column(nullable=false, updatable=false) private LocalDateTime createdAt;
    @PrePersist void created(){ if(createdAt==null) createdAt=LocalDateTime.now(); }
}
