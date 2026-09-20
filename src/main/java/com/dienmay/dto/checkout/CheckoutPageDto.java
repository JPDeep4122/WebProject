package com.dienmay.dto.checkout;

import java.math.BigDecimal;
import java.util.List;
import com.dienmay.entity.auth.Address;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CheckoutPageDto {
    private List<CheckoutItemDto> items;
    private List<Address> savedAddresses;
    private BigDecimal subtotal;
    private BigDecimal shippingFee;
    private BigDecimal discountAmount;
    private BigDecimal finalAmount;
}