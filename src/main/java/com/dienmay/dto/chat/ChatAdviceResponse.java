package com.dienmay.dto.chat;

import java.math.BigDecimal;
import java.util.List;

public record ChatAdviceResponse(
        String answer,
        List<ProductCard> products) {

    public record ProductCard(
            Long id,
            String name,
            BigDecimal price,
            String slug,
            String imageUrl) {
    }
}