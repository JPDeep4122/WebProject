package com.dienmay.entity.branch;

import com.dienmay.entity.product.Product;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

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
    private Integer stockQuantity; // Tồn thực tế tại chi nhánh

    @Column(name = "reserved_quantity", nullable = false)
    private Integer reservedQuantity; // Giữ cho đơn hàng

    @Column(name = "transfer_reserved_quantity", nullable = false)
    @Builder.Default
    private Integer transferReservedQuantity = 0; // Giữ cho phiếu điều chuyển

    @Column(name = "quarantine_quantity", nullable = false)
    @Builder.Default
    private Integer quarantineQuantity = 0; // Hàng cách ly (lỗi/hỏng/chờ kiểm định)

    @Column(name = "available_quantity", nullable = false)
    private Integer availableQuantity; // Khả dụng = Thực tế - Giữ đơn - Giữ điều chuyển - Cách ly

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Transient
    public int getTotalHeldAndQuarantine() {
        int orderRes = reservedQuantity == null ? 0 : reservedQuantity;
        int transferRes = transferReservedQuantity == null ? 0 : transferReservedQuantity;
        int quarantine = quarantineQuantity == null ? 0 : quarantineQuantity;
        return orderRes + transferRes + quarantine;
    }

    public void recalculateAvailable() {
        if (this.stockQuantity == null) this.stockQuantity = 0;
        if (this.reservedQuantity == null) this.reservedQuantity = 0;
        if (this.transferReservedQuantity == null) this.transferReservedQuantity = 0;
        if (this.quarantineQuantity == null) this.quarantineQuantity = 0;
        this.availableQuantity = this.stockQuantity - getTotalHeldAndQuarantine();
    }

    @PrePersist
    @PreUpdate
    protected void onSave() {
        if (this.stockQuantity == null) this.stockQuantity = 0;
        if (this.reservedQuantity == null) this.reservedQuantity = 0;
        if (this.transferReservedQuantity == null) this.transferReservedQuantity = 0;
        if (this.quarantineQuantity == null) this.quarantineQuantity = 0;
        if (this.stockQuantity < 0 || this.reservedQuantity < 0
                || this.transferReservedQuantity < 0 || this.quarantineQuantity < 0) {
            throw new IllegalStateException("Các loại số lượng tồn kho không được âm");
        }
        if (getTotalHeldAndQuarantine() > this.stockQuantity) {
            throw new IllegalStateException("Tổng hàng giữ và hàng cách ly không được vượt quá tồn thực tế");
        }
        recalculateAvailable();
        this.updatedAt = LocalDateTime.now();
    }
}