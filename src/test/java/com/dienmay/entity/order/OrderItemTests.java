package com.dienmay.entity.order;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;

class OrderItemTests {

    @Test
    void calculatesSubtotalBeforeSaving() {
        OrderItem item = OrderItem.builder()
                .quantity(3)
                .price(new BigDecimal("125000.50"))
                .build();

        item.validateAndCalculateSubtotal();

        assertEquals(new BigDecimal("375001.50"), item.getSubtotal());
    }

    @Test
    void rejectsInvalidQuantityAndNegativePrice() {
        OrderItem zeroQuantity = OrderItem.builder()
                .quantity(0)
                .price(BigDecimal.TEN)
                .build();
        OrderItem negativePrice = OrderItem.builder()
                .quantity(1)
                .price(BigDecimal.valueOf(-1))
                .build();

        assertThrows(IllegalStateException.class, zeroQuantity::validateAndCalculateSubtotal);
        assertThrows(IllegalStateException.class, negativePrice::validateAndCalculateSubtotal);
    }
}
