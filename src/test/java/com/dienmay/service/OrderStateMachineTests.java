package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.service.order.OrderStateMachine;

class OrderStateMachineTests {
    private final OrderStateMachine stateMachine = new OrderStateMachine();

    @Test
    void allowsOnlyPartOneForwardFlowAndPendingCancellation() {
        assertTrue(stateMachine.canTransition(OrderStatus.PENDING, OrderStatus.CONFIRMED));
        assertTrue(stateMachine.canTransition(OrderStatus.PENDING, OrderStatus.CANCELLED));
        assertTrue(stateMachine.canTransition(OrderStatus.CONFIRMED, OrderStatus.PROCESSING));

        assertFalse(stateMachine.canTransition(OrderStatus.PENDING, OrderStatus.PROCESSING));
        assertFalse(stateMachine.canTransition(OrderStatus.CONFIRMED, OrderStatus.PENDING));
        assertFalse(stateMachine.canTransition(OrderStatus.PROCESSING, OrderStatus.CONFIRMED));
        assertFalse(stateMachine.canTransition(OrderStatus.CONFIRMED, OrderStatus.CONFIRMED));
    }

    @Test
    void transitionsOrderAndRejectsInvalidMove() {
        var order = Order.builder().status(OrderStatus.PENDING).build();

        stateMachine.transition(order, OrderStatus.CONFIRMED);
        assertEquals(OrderStatus.CONFIRMED, order.getStatus());
        stateMachine.transition(order, OrderStatus.PROCESSING);
        assertEquals(OrderStatus.PROCESSING, order.getStatus());

        assertThrows(IllegalArgumentException.class,
                () -> stateMachine.transition(order, OrderStatus.PENDING));
        assertEquals(OrderStatus.PROCESSING, order.getStatus());
    }
}
