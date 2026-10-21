package com.dienmay.dto.checkout;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ShippingQuoteRequest {
    @NotBlank
    private String shippingAddress;

    @NotBlank
    private String province;
}
