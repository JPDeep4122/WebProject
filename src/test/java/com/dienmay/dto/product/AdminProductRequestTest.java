package com.dienmay.dto.product;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import java.math.BigDecimal;
import java.util.Arrays;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.Test;

class AdminProductRequestTest {
    private AdminProductRequest validRequest() {
        AdminProductRequest request = new AdminProductRequest();
        request.setName("Sản phẩm thử");
        request.setSlug("san-pham-thu");
        request.setSku("TEST-001");
        request.setCategoryId(1L);
        request.setBrandId(1L);
        request.setOriginalPrice(new BigDecimal("100000"));
        return request;
    }

    @Test
    void rejectsDiscountAboveOriginalPrice() {
        try (ValidatorFactory factory = Validation.buildDefaultValidatorFactory()) {
            AdminProductRequest request = validRequest();
            request.setDiscountPrice(new BigDecimal("100001"));
            assertTrue(factory.getValidator().validate(request).stream()
                    .anyMatch(error -> error.getPropertyPath().toString().equals("discountPriceValid")));
        }
    }

    @Test
    void acceptsAbsentZeroAndEqualDiscount() {
        try (ValidatorFactory factory = Validation.buildDefaultValidatorFactory()) {
            Validator validator = factory.getValidator();
            for (BigDecimal discount : Arrays.asList(null, BigDecimal.ZERO, new BigDecimal("100000"))) {
                AdminProductRequest request = validRequest();
                request.setDiscountPrice(discount);
                assertTrue(validator.validate(request).isEmpty());
            }
        }
    }

    @Test
    void rejectsInvalidCategoryAndBrandIds() {
        try (ValidatorFactory factory = Validation.buildDefaultValidatorFactory()) {
            AdminProductRequest request = validRequest();
            request.setCategoryId(0L);
            request.setBrandId(-1L);
            assertFalse(factory.getValidator().validate(request).isEmpty());
        }
    }
}
