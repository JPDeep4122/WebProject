package com.dienmay.entity.order;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

import com.dienmay.entity.auth.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Entity lưu lịch sử từng lần giao hàng (delivery_attempts)
 */
@Entity
@Table(
    name = "delivery_attempts",
    uniqueConstraints = @UniqueConstraint(
        name = "uk_delivery_attempts_assignment_attempt_no",
        columnNames = {"assignment_id", "attempt_no"}
    )
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryAttempt {

    private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VN_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignment_id", nullable = false)
    private DeliveryAssignment assignment;

    @Column(name = "attempt_no", nullable = false)
    private Integer attemptNo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipper_id", nullable = false)
    private User shipper;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private DeliveryStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "failure_code", length = 50)
    private DeliveryFailureCode failureCode;

    @Column(name = "failure_details", columnDefinition = "TEXT")
    private String failureDetails;

    @Column(name = "received_by", length = 100)
    private String receivedBy;

    @Enumerated(EnumType.STRING)
    @Column(name = "collection_method", length = 30)
    private DeliveryCollectionMethod collectionMethod;

    @Column(name = "collected_amount", precision = 15, scale = 2)
    private BigDecimal collectedAmount;

    @Column(name = "proof_public_id", length = 255)
    private String proofPublicId;
    
    @Column(name = "completion_note", length = 500)
    private String completionNote;

    @Transient
    public String getStartedAtVn() {
        return startedAt == null ? "" : startedAt.atZone(VN_ZONE).format(VN_FMT);
    }

    @Transient
    public String getCompletedAtVn() {
        return completedAt == null ? "" : completedAt.atZone(VN_ZONE).format(VN_FMT);
    }
}