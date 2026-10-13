package com.dienmay.entity.order;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.payment.Payment;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity đại diện cho bảng orders trong cơ sở dữ liệu
 * Phân công: TV2 - Ngày 03/09
 */
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
    private String orderCode; // Mã đơn hàng (VD: ORD-20260915-101)

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user; // Khách hàng đặt hàng

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id")
    private Branch branch; // Chi nhánh chịu trách nhiệm xử lý đơn

    @Column(name = "total_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount; // Tổng tiền sản phẩm

    @Column(name = "shipping_fee", precision = 15, scale = 2)
    private BigDecimal shippingFee; // Phí vận chuyển

    @Column(name = "discount_amount", precision = 15, scale = 2)
    private BigDecimal discountAmount; // Số tiền giảm giá (voucher)

    @Column(name = "final_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal finalAmount; // Thành tiền cuối cùng phải thanh toán

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private OrderStatus status; // Trạng thái đơn hàng

    @Column(name = "recipient_name", nullable = false, length = 100)
    private String recipientName; // Tên người nhận

    @Column(name = "recipient_phone", nullable = false, length = 20)
    private String recipientPhone; // SĐT người nhận

    @Column(name = "shipping_address", nullable = false, columnDefinition = "TEXT")
    private String shippingAddress; // Địa chỉ giao hàng

    @Column(name = "note", columnDefinition = "TEXT")
    private String note; // Ghi chú đơn hàng

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<OrderItem> orderItems = new ArrayList<>(); // Danh sách sản phẩm trong đơn

    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL)
    private Payment payment; // Thông tin thanh toán

    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL)
    private DeliveryAssignment deliveryAssignment; // Phân công giao hàng

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
}
