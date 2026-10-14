package com.dienmay.dto.product;

import java.math.BigDecimal;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminProductRequest {
    @NotBlank @Size(max = 255) private String name;
    @NotBlank @Size(max = 255) private String slug;
    @NotBlank @Size(max = 50) private String sku;
    private String shortDescription;
    private String description;
    @NotNull @PositiveOrZero private BigDecimal originalPrice;
    @PositiveOrZero private BigDecimal discountPrice;
    @Size(max = 500) private String mainImageUrl;
    @NotNull private Long categoryId;
    @NotNull private Long brandId;
    private Boolean active = true;
    private Boolean featured = false;
}
