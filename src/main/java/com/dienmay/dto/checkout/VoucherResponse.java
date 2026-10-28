package com.dienmay.dto.checkout;

import java.math.BigDecimal;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class VoucherResponse {
    private boolean valid;
    private String code;
    private String message;
    private BigDecimal discountAmount;
    private BigDecimal newFinalAmount;
    
    private BigDecimal subtotal;
    private BigDecimal shippingFee;
}