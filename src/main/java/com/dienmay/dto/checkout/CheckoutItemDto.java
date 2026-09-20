package com.dienmay.dto.checkout;

import java.math.BigDecimal;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CheckoutItemDto {
    private Long productId;
    private String productName;
    private String productSlug;
    private String imageUrl;
    private BigDecimal price;
    private int quantity;
    private BigDecimal subtotal;
}