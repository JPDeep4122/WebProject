package com.dienmay.entity.order;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import com.dienmay.entity.auth.User;

import jakarta.persistence.CascadeType;
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
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.OrderBy;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "delivery_assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryAssignment {

    private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VN_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipper_id", nullable = false)
    private User shipper; 

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private DeliveryStatus status; 

    @Column(name = "assigned_at", nullable = false)
    private LocalDateTime assignedAt; 

    @Column(name = "picked_up_at")
    private LocalDateTime pickedUpAt; 

    @Column(name = "delivery_started_at")
    private Instant deliveryStartedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "failure_code", length = 50)
    private DeliveryFailureCode failureCode; 

    @Column(name = "failure_reason", columnDefinition = "TEXT")
    private String failureReason; 

    @Column(name = "received_by", length = 100)
    private String receivedBy; 

    @Enumerated(EnumType.STRING)
    @Column(name = "collection_method", length = 30)
    private DeliveryCollectionMethod collectionMethod;

    @Column(name = "collected_amount", precision = 15, scale = 2)
    private BigDecimal collectedAmount; 

    @Column(name = "proof_image", length = 255)
    private String proofImage; 

    @Column(name = "proof_public_id", length = 255)
    private String proofPublicId; 
    
    @Column(name = "completion_note", length = 500)
    private String completionNote;
    
    @Column(name = "cod_handover_status", length = 30)
    @Builder.Default
    private String codHandoverStatus = "NONE"; 

    @Column(name = "cod_handed_over_at")
    private LocalDateTime codHandedOverAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cod_received_by_id")
    private User codReceivedBy;
    
    @OneToMany(mappedBy = "assignment", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("attemptNo ASC")
    @Builder.Default
    private List<DeliveryAttempt> attempts = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (this.assignedAt == null) {
            this.assignedAt = LocalDateTime.now();
        }
        if (this.status == null) {
            this.status = DeliveryStatus.ASSIGNED;
        }
    }

    @Transient
    public String getAssignedAtVn() {
        return assignedAt == null ? "" : assignedAt.format(VN_FMT);
    }

    @Transient
    public String getPickedUpAtVn() {
        return pickedUpAt == null ? "" : pickedUpAt.format(VN_FMT);
    }

    @Transient
    public String getDeliveryStartedAtVn() {
        return deliveryStartedAt == null ? "" : deliveryStartedAt.atZone(VN_ZONE).format(VN_FMT);
    }

    @Transient
    public String getCompletedAtVn() {
        return completedAt == null ? "" : completedAt.format(VN_FMT);
    }
}