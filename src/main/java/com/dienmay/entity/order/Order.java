package com.dienmay.entity.order;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_code", unique = true, nullable = false, length = 50)
    private String orderCode; 

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = true)
    private User user;

    @Column(name = "recipient_email", length = 100)
    private String recipientEmail;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id")
    private Branch branch;

    @Column(name = "total_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount; 

    @Column(name = "shipping_fee", precision = 15, scale = 2)
    private BigDecimal shippingFee; 

    @Column(name = "discount_amount", precision = 15, scale = 2)
    private BigDecimal discountAmount; 

    @Column(name = "final_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal finalAmount; 

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private OrderStatus status; 

    @Column(name = "recipient_name", nullable = false, length = 100)
    private String recipientName;

    @Column(name = "recipient_phone", nullable = false, length = 20)
    private String recipientPhone;

    @Column(name = "shipping_address", nullable = false, columnDefinition = "TEXT")
    private String shippingAddress; 

    @Column(name = "note", columnDefinition = "TEXT")
    private String note; 

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<OrderItem> orderItems = new ArrayList<>(); 

    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL)
    private Payment payment; 

    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL)
    private DeliveryAssignment deliveryAssignment; 

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = OrderStatus.PENDING;
        }
        if (this.shippingFee == null) {
            this.shippingFee = BigDecimal.ZERO;
        }
        if (this.discountAmount == null) {
            this.discountAmount = BigDecimal.ZERO;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    @Column(name = "voucher_code", length = 50)
    private String voucherCode;
    
    @Transient
    public boolean isAwaitingPayment() {
        if (status != OrderStatus.PENDING || payment == null) {
            return false;
        }

        return payment.getPaymentMethod() == PaymentMethod.VNPAY
                && (payment.getPaymentStatus() == PaymentStatus.PENDING
                    || payment.getPaymentStatus() == PaymentStatus.FAILED);
    }

    @Transient
    public boolean isReadyForConfirmation() {
        if (status != OrderStatus.PENDING
                || payment == null
                || payment.getPaymentMethod() == null
                || payment.getPaymentStatus() == null) {
            return false;
        }

        return switch (payment.getPaymentMethod()) {
            case VNPAY ->
                    payment.getPaymentStatus() == PaymentStatus.SUCCESS;

            case COD ->
                    payment.getPaymentStatus() == PaymentStatus.PENDING
                    || payment.getPaymentStatus() == PaymentStatus.SUCCESS;

            default -> false;
        };
    }

    @Transient
    public boolean isPrepaidVnPay() {
        return payment != null
                && payment.getPaymentMethod() == PaymentMethod.VNPAY
                && (payment.getPaymentStatus() == PaymentStatus.SUCCESS
                    || payment.getPaymentStatus() == PaymentStatus.REFUNDED);
    }

    @Transient
    public boolean isRefundRequired() {
        return status == OrderStatus.CANCELLED
                && payment != null
                && payment.getPaymentMethod() == PaymentMethod.VNPAY
                && payment.getPaymentStatus() == PaymentStatus.SUCCESS;
    }

    @Transient
    public boolean isRefundCompleted() {
        return status == OrderStatus.CANCELLED
                && payment != null
                && payment.getPaymentMethod() == PaymentMethod.VNPAY
                && payment.getPaymentStatus() == PaymentStatus.REFUNDED;
    }
}