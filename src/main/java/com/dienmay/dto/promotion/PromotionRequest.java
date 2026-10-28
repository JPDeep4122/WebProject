package com.dienmay.dto.promotion;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import org.springframework.format.annotation.DateTimeFormat;

import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.promotion.VoucherType;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class PromotionRequest {

    @NotBlank
    @Size(max = 120)
    private String name;

    @NotBlank
    @Pattern(regexp = "[A-Za-z0-9][A-Za-z0-9_-]{1,49}")
    private String code;

    @NotNull
    private VoucherType discountType = VoucherType.FIXED;

    @DecimalMin("0.01")
    @DecimalMax("100.00")
    private BigDecimal discountPercent;

    @DecimalMin("0.01")
    private BigDecimal discountAmount;

    @DecimalMin("0.01")
    private BigDecimal maxDiscountAmount;

    @NotNull
    @DecimalMin("0.00")
    private BigDecimal minOrderAmount = BigDecimal.ZERO;

    private PaymentMethod requiredPaymentMethod;

    private Boolean newCustomerOnly = false;

    @Min(1)
    private Integer perUserLimit;

    @PositiveOrZero
    private Integer maxUses;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime startsAt;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime endsAt;

    private Boolean active = true;

    private Set<Long> categoryIds = new HashSet<>();
}
