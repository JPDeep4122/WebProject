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
    void allowsCompleteForwardFlowCancellationAndReturn() {
        assertTrue(stateMachine.canTransition(OrderStatus.PENDING, OrderStatus.CONFIRMED));
        assertTrue(stateMachine.canTransition(OrderStatus.PENDING, OrderStatus.CANCELLED));
        assertTrue(stateMachine.canTransition(OrderStatus.CONFIRMED, OrderStatus.PROCESSING));
        assertTrue(stateMachine.canTransition(OrderStatus.CONFIRMED, OrderStatus.CANCELLED));
        assertTrue(stateMachine.canTransition(OrderStatus.PROCESSING, OrderStatus.SHIPPING));
        assertTrue(stateMachine.canTransition(OrderStatus.PROCESSING, OrderStatus.CANCELLED));
        assertTrue(stateMachine.canTransition(OrderStatus.SHIPPING, OrderStatus.DELIVERED));
        assertTrue(stateMachine.canTransition(OrderStatus.SHIPPING, OrderStatus.CANCELLED));
        assertTrue(stateMachine.canTransition(OrderStatus.DELIVERED, OrderStatus.RETURN_REQUESTED));
        assertTrue(stateMachine.canTransition(OrderStatus.RETURN_REQUESTED, OrderStatus.RETURNED));

        assertFalse(stateMachine.canTransition(OrderStatus.PENDING, OrderStatus.PROCESSING));
        assertFalse(stateMachine.canTransition(OrderStatus.CONFIRMED, OrderStatus.PENDING));
        assertFalse(stateMachine.canTransition(OrderStatus.PROCESSING, OrderStatus.CONFIRMED));
        assertFalse(stateMachine.canTransition(OrderStatus.CONFIRMED, OrderStatus.CONFIRMED));
        assertFalse(stateMachine.canTransition(OrderStatus.DELIVERED, OrderStatus.CANCELLED));
        assertFalse(stateMachine.canTransition(OrderStatus.RETURNED, OrderStatus.RETURN_REQUESTED));
    }

    @Test
    void transitionsOrderAndRejectsInvalidMove() {
        var order = Order.builder().status(OrderStatus.PENDING).build();

        stateMachine.transition(order, OrderStatus.CONFIRMED);
        assertEquals(OrderStatus.CONFIRMED, order.getStatus());
        stateMachine.transition(order, OrderStatus.PROCESSING);
        assertEquals(OrderStatus.PROCESSING, order.getStatus());
        stateMachine.transition(order, OrderStatus.SHIPPING);
        assertEquals(OrderStatus.SHIPPING, order.getStatus());
        stateMachine.transition(order, OrderStatus.DELIVERED);
        assertEquals(OrderStatus.DELIVERED, order.getStatus());

        assertThrows(IllegalArgumentException.class,
                () -> stateMachine.transition(order, OrderStatus.PENDING));
        assertEquals(OrderStatus.DELIVERED, order.getStatus());
    }
}
