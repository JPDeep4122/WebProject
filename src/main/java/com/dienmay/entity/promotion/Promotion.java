package com.dienmay.entity.promotion;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity @Table(name="promotions") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Promotion {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
    @Column(nullable=false, length=120) private String name;
    @Column(nullable=false, unique=true, length=50) private String code;
    @Column(name="discount_percent", nullable=false, precision=5, scale=2) private BigDecimal discountPercent;
    private LocalDateTime startsAt;
    private LocalDateTime endsAt;
    private Integer maxUses;
    @Builder.Default private Integer usedCount=0;
    @Builder.Default private boolean active=true;
    @Column(nullable=false, updatable=false) private LocalDateTime createdAt;
    @PrePersist void created() { if(createdAt==null) createdAt=LocalDateTime.now(); if(usedCount==null) usedCount=0; }
}
