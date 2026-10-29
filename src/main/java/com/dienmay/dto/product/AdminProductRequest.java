package com.dienmay.dto.product;

import java.math.BigDecimal;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

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
    @NotNull(message = "Vui lòng chọn danh mục.") @Positive private Long categoryId;
    @NotNull(message = "Vui lòng chọn thương hiệu.") @Positive private Long brandId;
    private Boolean active = true;
    private Boolean featured = false;
    private String specifications;
    private MultipartFile mainImage;
    private List<MultipartFile> galleryImages;

    @AssertTrue(message = "Giá khuyến mãi không được lớn hơn giá gốc.")
    public boolean isDiscountPriceValid() {
        return discountPrice == null || originalPrice == null
                || discountPrice.compareTo(originalPrice) <= 0;
    }
}
