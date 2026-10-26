package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.ArrayList;

import org.junit.jupiter.api.Test;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.service.order.OrderStatusChangedEvent;
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
        order.setPayment(Payment.builder().order(order).paymentMethod(PaymentMethod.COD)
                .paymentStatus(PaymentStatus.PENDING).build());

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

    @Test
    void publishesCustomerUpdateForSuccessfulTransition() {
        var events = new ArrayList<Object>();
        stateMachine.setApplicationEventPublisher(events::add);
        var user = User.builder().email("customer@example.test").build();
        var branch = Branch.builder().id(12L).name("Branch 12").address("Test").build();
        var order = Order.builder().orderCode("ORD-REALTIME-1").user(user).branch(branch)
                .status(OrderStatus.PENDING).build();

        stateMachine.transition(order, OrderStatus.CONFIRMED);

        assertEquals(1, events.size());
        var event = (OrderStatusChangedEvent) events.get(0);
        assertEquals("customer@example.test", event.recipientEmail());
        assertEquals(12L, event.branchId());
        assertEquals("ORD-REALTIME-1", event.update().orderCode());
        assertEquals(OrderStatus.PENDING, event.update().previousStatus());
        assertEquals(OrderStatus.CONFIRMED, event.update().status());
    }

    @Test
    void blocksUnpaidAndFailedVnPayBeforeShippingOrDelivery() {
        for (var paymentStatus : new PaymentStatus[] {PaymentStatus.PENDING, PaymentStatus.FAILED}) {
            for (var current : new OrderStatus[] {OrderStatus.PROCESSING, OrderStatus.SHIPPING}) {
                var order = Order.builder().status(current).build();
                order.setPayment(Payment.builder().order(order).paymentMethod(PaymentMethod.VNPAY)
                        .paymentStatus(paymentStatus).build());
                var target = current == OrderStatus.PROCESSING ? OrderStatus.SHIPPING : OrderStatus.DELIVERED;
                assertThrows(IllegalArgumentException.class, () -> stateMachine.transition(order, target));
                assertEquals(current, order.getStatus());
            }
        }
    }

    @Test
    void allowsPaidVnPayAndRejectsMissingPayment() {
        var order = Order.builder().status(OrderStatus.PROCESSING).build();
        assertThrows(IllegalArgumentException.class, () -> stateMachine.transition(order, OrderStatus.SHIPPING));
        order.setPayment(Payment.builder().order(order).paymentMethod(PaymentMethod.VNPAY)
                .paymentStatus(PaymentStatus.SUCCESS).build());
        stateMachine.transition(order, OrderStatus.SHIPPING);
        stateMachine.transition(order, OrderStatus.DELIVERED);
        assertEquals(OrderStatus.DELIVERED, order.getStatus());
    }

    @Test
    void guestOrderStillPublishesBranchEventWithoutUsingContactEmailAsIdentity() {
        var events = new ArrayList<Object>();
        stateMachine.setApplicationEventPublisher(events::add);
        var order = Order.builder().orderCode("ORD-GUEST").recipientEmail("other@example.test")
                .branch(Branch.builder().id(12L).build()).status(OrderStatus.PENDING).build();
        stateMachine.transition(order, OrderStatus.CONFIRMED);
        var event = (OrderStatusChangedEvent) events.getFirst();
        org.junit.jupiter.api.Assertions.assertNull(event.recipientEmail());
        assertEquals(12L, event.branchId());
    }
}
