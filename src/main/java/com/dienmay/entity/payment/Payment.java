package com.dienmay.entity.payment;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "order_id", nullable = false, unique = true)
	private Order order;

	@Enumerated(EnumType.STRING)
	@Column(name = "payment_method", nullable = false, length = 30)
	private PaymentMethod paymentMethod;

	@Enumerated(EnumType.STRING)
	@Column(name = "payment_status", nullable = false, length = 30)
	private PaymentStatus paymentStatus;

	@Column(name = "amount", nullable = false, precision = 15, scale = 2)
	private BigDecimal amount;

	@Column(name = "transaction_no", length = 100)
	private String transactionNo;

	@Column(name = "payment_time")
	private LocalDateTime paymentTime;

	@Column(name = "created_at", nullable = false, updatable = false)
	private LocalDateTime createdAt;

	@Column(name = "payment_url", columnDefinition = "TEXT")
	private String paymentUrl;

	@Column(name = "payment_expires_at")
	private Instant paymentExpiresAt;

	// --- Lưu vết hoàn tiền khi đơn trả trước (VNPay) bị hủy ---
	@Column(name = "refunded_at")
	private LocalDateTime refundedAt;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "refunded_by_user_id")
	private User refundedBy;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "refund_branch_id")
	private Branch refundBranch;

	@Column(name = "refund_method", length = 40)
	private String refundMethod; // CASH_AT_BRANCH hoặc BANK_TRANSFER

	@Column(name = "refund_note", length = 500)
	private String refundNote;

	@PrePersist
	protected void onCreate() {
		this.createdAt = LocalDateTime.now();
		if (this.paymentStatus == null) {
			this.paymentStatus = PaymentStatus.PENDING;
		}
	}

	@Transient
	public boolean isPaymentLinkAvailable() {
		if (order == null || paymentMethod != PaymentMethod.VNPAY || paymentStatus != PaymentStatus.PENDING
				|| paymentUrl == null || paymentUrl.isBlank() || paymentExpiresAt == null
				|| !paymentExpiresAt.isAfter(Instant.now())) {
			return false;
		}

		var status = order.getStatus();

		return status == OrderStatus.PENDING || status == OrderStatus.CONFIRMED || status == OrderStatus.PROCESSING;
	}
}