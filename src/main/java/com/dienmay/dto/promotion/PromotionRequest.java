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

    @NotBlank(message = "Vui lòng nhập tên chương trình voucher.")
    @Size(max = 120, message = "Tên chương trình không được vượt quá 120 ký tự.")
    private String name;

    @NotBlank(message = "Vui lòng nhập mã voucher.")
    @Pattern(regexp = "[A-Za-z0-9][A-Za-z0-9_-]{1,49}",
            message = "Mã voucher gồm 2–50 ký tự: chữ, số, dấu gạch ngang hoặc gạch dưới.")
    private String code;

    @NotNull
    private VoucherType discountType = VoucherType.FIXED;

    @DecimalMin(value = "0.01", message = "Phần trăm giảm phải lớn hơn 0.")
    @DecimalMax(value = "100.00", message = "Phần trăm giảm không được vượt quá 100%.")
    private BigDecimal discountPercent;

    @DecimalMin(value = "0.01", message = "Số tiền giảm phải lớn hơn 0.")
    private BigDecimal discountAmount;

    @DecimalMin(value = "0.01", message = "Mức giảm tối đa phải lớn hơn 0.")
    private BigDecimal maxDiscountAmount;

    @NotNull(message = "Vui lòng nhập giá trị đơn hàng tối thiểu.")
    @DecimalMin(value = "0.00", message = "Giá trị đơn hàng tối thiểu không được âm.")
    private BigDecimal minOrderAmount = BigDecimal.ZERO;

    private PaymentMethod requiredPaymentMethod;

    private Boolean newCustomerOnly = false;

    @Min(value = 1, message = "Lượt dùng mỗi khách phải từ 1 trở lên; để trống nếu không giới hạn.")
    private Integer perUserLimit;

    @Min(value = 1, message = "Tổng số lượt phải từ 1 trở lên; để trống nếu không giới hạn.")
    private Integer maxUses;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime startsAt;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime endsAt;

    private Boolean active = true;

    private Set<Long> categoryIds = new HashSet<>();
}
