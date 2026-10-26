package com.dienmay.entity.cart;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.dienmay.entity.product.Product;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "cart_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cart_id", nullable = false)
    private Cart cart;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    @Builder.Default
    private Integer quantity = 1;

    // Đáp ứng yêu cầu STT 9: "Chọn sản phẩm để thanh toán"
    @Column(name = "is_selected", nullable = false)
    @Builder.Default
    private Boolean selected = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public BigDecimal getSubtotal() {
        if (product == null || quantity == null || quantity < 1) {
            throw new IllegalStateException(
                    "Thông tin sản phẩm hoặc số lượng trong giỏ không hợp lệ.");
        }

        BigDecimal unitPrice = product.getSellingPrice();

        if (unitPrice == null || unitPrice.signum() < 0) {
            throw new IllegalStateException(
                    "Sản phẩm chưa có giá bán hợp lệ.");
        }

        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
}