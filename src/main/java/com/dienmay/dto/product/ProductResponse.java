package com.dienmay.dto.product;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {
    private Long id;
    private String name;
    private String slug;
    private String sku;
    private BigDecimal originalPrice;
    private BigDecimal price;
    private Integer soldQuantity;
    private Double rating;
    private Integer favoriteCount;
    private String thumbnail;
    private Long categoryId;
    private String categoryName;
    private Long brandId;
    private String brandName;
    private LocalDateTime createdAt;
}