package com.dienmay.entity.order;

import com.dienmay.entity.product.Product;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

/**
 * Entity đại diện cho bảng order_items (chi tiết từng sản phẩm trong đơn hàng)
 * Phân công: TV2 - Ngày 03/09
 */
@Entity
@Table(name = "order_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "price", nullable = false, precision = 15, scale = 2)
    private BigDecimal price; // Giá sản phẩm tại thời điểm đặt hàng

    @Column(name = "subtotal", nullable = false, precision = 15, scale = 2)
    private BigDecimal subtotal; // Thành tiền (price * quantity)

    @PrePersist
    @PreUpdate
    protected void validateAndCalculateSubtotal() {
        if (quantity == null || quantity <= 0) {
            throw new IllegalStateException("Số lượng sản phẩm trong đơn phải lớn hơn 0");
        }
        if (price == null || price.signum() < 0) {
            throw new IllegalStateException("Giá sản phẩm trong đơn không được âm");
        }
        subtotal = price.multiply(BigDecimal.valueOf(quantity));
    }
}
