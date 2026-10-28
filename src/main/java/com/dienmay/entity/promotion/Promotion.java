package com.dienmay.entity.promotion;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.product.Category;

@Entity
@Table(name = "promotions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Promotion {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	@Column(nullable = false, length = 120)
	private String name;
	@Column(nullable = false, unique = true, length = 50)
	private String code;
	@Column(name = "discount_percent", precision = 5, scale = 2)
	private BigDecimal discountPercent;
	private LocalDateTime startsAt;
	private LocalDateTime endsAt;
	private Integer maxUses;
	@Builder.Default
	private Integer usedCount = 0;
	@Builder.Default
	private boolean active = true;
	@Column(nullable = false, updatable = false)
	private LocalDateTime createdAt;

	@PrePersist
	void created() {
		if (createdAt == null)
			createdAt = LocalDateTime.now();
		if (usedCount == null)
			usedCount = 0;
	}

	@Enumerated(EnumType.STRING)
	@Column(name = "discount_type", nullable = false, length = 20)
	@Builder.Default
	private VoucherType discountType = VoucherType.PERCENT;

	@Column(name = "discount_amount", precision = 15, scale = 2)
	private BigDecimal discountAmount;

	@Column(name = "max_discount_amount", precision = 15, scale = 2)
	private BigDecimal maxDiscountAmount;

	@Column(name = "min_order_amount", nullable = false, precision = 15, scale = 2)
	@Builder.Default
	private BigDecimal minOrderAmount = BigDecimal.ZERO;

	@Enumerated(EnumType.STRING)
	@Column(name = "required_payment_method", length = 30)
	private PaymentMethod requiredPaymentMethod;

	@Column(name = "new_customer_only", nullable = false)
	@Builder.Default
	private boolean newCustomerOnly = false;

	@Column(name = "per_user_limit")
	private Integer perUserLimit;

	@ManyToMany
	@JoinTable(name = "promotion_categories", joinColumns = @JoinColumn(name = "promotion_id"), inverseJoinColumns = @JoinColumn(name = "category_id"))
	@Builder.Default
	private Set<Category> categories = new HashSet<>();

	@Transient
	public Set<Long> getCategoryIds() {
		return categories.stream().map(Category::getId).collect(Collectors.toSet());
	}
}
