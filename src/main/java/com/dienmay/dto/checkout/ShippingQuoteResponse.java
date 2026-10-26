package com.dienmay.dto.checkout;

import java.math.BigDecimal;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ShippingQuoteResponse {
    private Long branchId;
    private BigDecimal shippingFee;
    private double distanceKm;
    private String branchName;
    private boolean sameProvince;
}
