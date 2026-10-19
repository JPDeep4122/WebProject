package com.dienmay.entity.branch;

import com.dienmay.entity.product.Product;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Entity đại diện cho bảng branch_inventory (Quản lý tồn kho theo từng chi nhánh)
 * Phân công: TV2 - Ngày 03/09
 */
@Entity
@Table(
    name = "branch_inventory",
    uniqueConstraints = @UniqueConstraint(columnNames = {"branch_id", "product_id"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BranchInventory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id", nullable = false)
    private Branch branch;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "stock_quantity", nullable = false)
    private Integer stockQuantity; // Tổng tồn kho thực tế tại chi nhánh

    @Column(name = "reserved_quantity", nullable = false)
    private Integer reservedQuantity; // Số lượng hàng đã giữ chỗ (chờ giao)

    @Column(name = "available_quantity", nullable = false)
    private Integer availableQuantity; // Số lượng có thể bán = stockQuantity - reservedQuantity

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onSave() {
        if (this.stockQuantity == null) this.stockQuantity = 0;
        if (this.reservedQuantity == null) this.reservedQuantity = 0;
        if (this.stockQuantity < 0) {
            throw new IllegalStateException("Tồn kho không được âm");
        }
        if (this.reservedQuantity < 0) {
            throw new IllegalStateException("Số lượng giữ chỗ không được âm");
        }
        if (this.reservedQuantity > this.stockQuantity) {
            throw new IllegalStateException("Số lượng giữ chỗ không được vượt quá tồn kho");
        }
        this.availableQuantity = this.stockQuantity - this.reservedQuantity;
        this.updatedAt = LocalDateTime.now();
    }
}
