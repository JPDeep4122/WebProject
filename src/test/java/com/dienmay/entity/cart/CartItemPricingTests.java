package com.dienmay.entity.cart;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;

import com.dienmay.entity.product.Product;

class CartItemPricingTests {

    @Test
    void originalPriceOnlyProductHasCorrectCartSubtotal() {
        Product product = Product.builder()
                .originalPrice(new BigDecimal("1000000"))
                .build();

        CartItem item = CartItem.builder()
                .product(product)
                .quantity(2)
                .build();

        assertEquals(
                new BigDecimal("2000000"),
                item.getSubtotal());
    }
}