package com.dienmay.entity.order;

import com.dienmay.entity.auth.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Entity đại diện cho bảng delivery_assignments (phân công đơn hàng cho Shipper)
 * Phân công: TV2 - Ngày 03/09
 */
@Entity
@Table(name = "delivery_assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipper_id", nullable = false)
    private User shipper; // Nhân viên giao hàng (Shipper)

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private DeliveryStatus status; // ASSIGNED, PICKED_UP, DELIVERING,...

    @Column(name = "assigned_at", nullable = false)
    private LocalDateTime assignedAt; // Thời điểm phân công

    @Column(name = "picked_up_at")
    private LocalDateTime pickedUpAt; // Thời điểm shipper nhận/lấy hàng

    @Column(name = "completed_at")
    private LocalDateTime completedAt; // Thời điểm giao thành công/thất bại

    @Column(name = "failure_reason", columnDefinition = "TEXT")
    private String failureReason; // Lý do nếu giao thất bại

    @Column(name = "proof_image", length = 255)
    private String proofImage; // URL ảnh bằng chứng giao hàng

    @PrePersist
    protected void onCreate() {
        if (this.assignedAt == null) {
            this.assignedAt = LocalDateTime.now();
        }
        if (this.status == null) {
            this.status = DeliveryStatus.ASSIGNED;
        }
    }
}
