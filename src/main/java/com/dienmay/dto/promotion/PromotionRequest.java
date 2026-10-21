package com.dienmay.dto.promotion;
import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
@Data public class PromotionRequest {
    @NotBlank @Size(max=120) private String name;
    @NotBlank @Size(max=50) private String code;
    @NotNull @DecimalMin("0.01") @DecimalMax("100.00") private BigDecimal discountPercent;
    private LocalDateTime startsAt; private LocalDateTime endsAt;
    @PositiveOrZero private Integer maxUses;
    private Boolean active=true;
}
