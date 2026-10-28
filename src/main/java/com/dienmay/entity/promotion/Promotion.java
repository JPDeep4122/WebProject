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
	private VoucherType discountType = VoucherType.FIXED;

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

	@Transient
	public String getBenefitLabel() {
		var number = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi-VN"));
		number.setMaximumFractionDigits(2);
		if (discountType == VoucherType.SHIPPING) {
			if (maxDiscountAmount != null && maxDiscountAmount.compareTo(BigDecimal.valueOf(1000)) >= 0
					&& maxDiscountAmount.remainder(BigDecimal.valueOf(1000)).signum() == 0) {
				return "FREESHIP " + number.format(maxDiscountAmount.divide(BigDecimal.valueOf(1000))) + "K";
			}
			return "FREESHIP";
		}
		if (discountType == VoucherType.PERCENT) {
			return "GIẢM " + number.format(discountPercent == null ? BigDecimal.ZERO : discountPercent) + "%";
		}
		BigDecimal amount = discountAmount == null ? BigDecimal.ZERO : discountAmount;
		BigDecimal thousand = BigDecimal.valueOf(1000);
		BigDecimal million = BigDecimal.valueOf(1000000);
		if (amount.compareTo(million) >= 0 && amount.remainder(million).signum() == 0) {
			return "GIẢM " + number.format(amount.divide(million)) + "TR";
		}
		if (amount.compareTo(thousand) >= 0 && amount.remainder(thousand).signum() == 0) {
			return "GIẢM " + number.format(amount.divide(thousand)) + "K";
		}
		return "GIẢM " + number.format(amount) + "₫";
	}

	@Transient
	public String getDisplayName() {
		String raw = name == null ? "" : name.replaceFirst("^\\[TV08\\]\\s*", "").trim();
		if (code != null && code.startsWith("TV08-")) {
			String benefit = getBenefitLabel();
			if (discountType == VoucherType.SHIPPING) {
				if (minOrderAmount != null && minOrderAmount.signum() > 0) {
					return "Miễn phí vận chuyển cho đơn từ " + getMinOrderAmountDisplay();
				}
				return maxDiscountAmount != null
						? "Hỗ trợ phí giao hàng tối đa " + getMaxDiscountAmountDisplay()
						: "Miễn phí vận chuyển toàn quốc 100%";
			}
			if (newCustomerOnly) {
				return "Ưu đãi Bạn Mới — " + benefit + " đơn hàng đầu tiên";
			}
			if (requiredPaymentMethod != null) {
				return "Độc quyền " + requiredPaymentMethod.name() + " — " + benefit + " toàn sàn";
			}
			if (maxDiscountAmount != null) {
				return "Siêu Deal Điện Máy — " + benefit + " (Tối đa " + getMaxDiscountAmountDisplay() + ")";
			}
			if (minOrderAmount != null && minOrderAmount.signum() > 0) {
				return "Voucher TECHSEVEN — " + benefit + " cho đơn từ " + getMinOrderAmountDisplay();
			}
			return "Ưu đãi TECHSEVEN — " + benefit + " toàn bộ sản phẩm";
		}
		return raw.isEmpty() ? "Ưu đãi mua sắm TECHSEVEN" : raw;
	}

	@Transient
	public String getEndsAtDisplay() {
		return endsAt == null ? "Không giới hạn thời gian"
				: endsAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
	}

	@Transient
	public String getMinOrderAmountDisplay() {
		return formatVnd(minOrderAmount);
	}

	@Transient
	public String getMaxDiscountAmountDisplay() {
		return maxDiscountAmount == null ? "" : formatVnd(maxDiscountAmount);
	}

	private String formatVnd(BigDecimal amount) {
		var number = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi-VN"));
		number.setMaximumFractionDigits(2);
		return number.format(amount == null ? BigDecimal.ZERO : amount) + " ₫";
	}
}