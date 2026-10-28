package com.dienmay.dto.checkout;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class VoucherPreviewRequest {

    @Size(max = 50)
    private String code;

    @NotBlank
    private String shippingAddress;

    @NotBlank
    private String province;

    @NotBlank
    @Pattern(regexp = "COD|VNPAY")
    private String paymentMethod;
}