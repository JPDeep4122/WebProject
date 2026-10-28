package com.dienmay.entity.promotion;

import java.math.BigDecimal;
import java.time.Instant;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "voucher_usages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VoucherUsage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "promotion_id", nullable = false)
    private Promotion promotion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "discount_amount", nullable = false,
            precision = 15, scale = 2)
    private BigDecimal discountAmount;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "released_at")
    private Instant releasedAt;

    @Column(name = "release_reason", length = 100)
    private String releaseReason;

    @PrePersist
    void beforeInsert() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}