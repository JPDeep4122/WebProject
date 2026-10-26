package com.dienmay.entity.payment;

import com.dienmay.entity.order.Order;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.Instant;
import com.dienmay.entity.order.OrderStatus;

/**
 * Entity đại diện cho bảng payments (thông tin thanh toán đơn hàng)
 * Phân công: TV2 - Ngày 03/09
 */
@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method", nullable = false, length = 30)
    private PaymentMethod paymentMethod; // COD, VNPAY, MOMO,...

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false, length = 30)
    private PaymentStatus paymentStatus; // PENDING, SUCCESS, FAILED,...

    @Column(name = "amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(name = "transaction_no", length = 100)
    private String transactionNo; // Mã giao dịch từ VNPay / MoMo / Ngân hàng

    @Column(name = "payment_time")
    private LocalDateTime paymentTime;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.paymentStatus == null) {
            this.paymentStatus = PaymentStatus.PENDING;
        }
    }

    @Column(name = "payment_url", columnDefinition = "TEXT")
    private String paymentUrl;

    @Column(name = "payment_expires_at")
    private Instant paymentExpiresAt;

    @Transient
    public boolean isPaymentLinkAvailable() {
        if (order == null
                || paymentMethod != PaymentMethod.VNPAY
                || paymentStatus != PaymentStatus.PENDING
                || paymentUrl == null
                || paymentUrl.isBlank()
                || paymentExpiresAt == null
                || !paymentExpiresAt.isAfter(Instant.now())) {
            return false;
        }

        var status = order.getStatus();

        return status == OrderStatus.PENDING
                || status == OrderStatus.CONFIRMED
                || status == OrderStatus.PROCESSING;
    }
}
