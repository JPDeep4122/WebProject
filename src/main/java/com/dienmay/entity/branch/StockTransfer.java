package com.dienmay.entity.branch;

import java.time.LocalDateTime;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.product.Product;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "stock_transfers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StockTransfer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "transfer_code", nullable = false, unique = true, length = 40)
    private String transferCode;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "from_branch_id", nullable = false)
    private Branch fromBranch; // Chi nhánh xuất

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "to_branch_id", nullable = false)
    private Branch toBranch; // Chi nhánh nhận

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "requested_quantity", nullable = false)
    private Integer requestedQuantity;

    @Column(name = "approved_quantity")
    private Integer approvedQuantity;

    @Column(name = "shipped_quantity")
    private Integer shippedQuantity;

    @Column(name = "received_good_quantity")
    private Integer receivedGoodQuantity;

    @Column(name = "received_quarantine_quantity")
    private Integer receivedQuarantineQuantity;

    @Column(name = "status", nullable = false, length = 35)
    @Builder.Default
    private String status = "REQUESTED";
    // REQUESTED -> APPROVED -> IN_TRANSIT -> RECEIVED / DISPUTED / REJECTED / CANCELLED

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requested_by", nullable = false)
    private User requestedBy;

    @Column(name = "requested_at", nullable = false, updatable = false)
    private LocalDateTime requestedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by")
    private User approvedBy;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipped_by")
    private User shippedBy;

    @Column(name = "shipped_at")
    private LocalDateTime shippedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "received_by")
    private User receivedBy;

    @Column(name = "received_at")
    private LocalDateTime receivedAt;

    @Column(name = "note", length = 500)
    private String note;

    @Column(name = "dispute_note", length = 500)
    private String disputeNote;

    @PrePersist
    void onCreate() {
        if (requestedAt == null) {
            requestedAt = LocalDateTime.now();
        }
        if (status == null) {
            status = "REQUESTED";
        }
    }
}