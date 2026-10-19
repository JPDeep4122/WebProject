package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import java.util.HashMap;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import com.dienmay.config.vnpay.VnPayConfig;
import com.dienmay.entity.order.*;
import com.dienmay.entity.payment.*;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.service.impl.VnPayServiceImpl;

class PaymentConfirmationTests {
    @Test void successfulPaymentWaitsForBranchStockConfirmation() {
        var config = mock(VnPayConfig.class);
        var orders = mock(OrderRepository.class);
        var payments = mock(PaymentRepository.class);
        when(config.getVnpHashSecret()).thenReturn("test-only-signing-secret");
        var order = Order.builder().id(1L).orderCode("TEST1").status(OrderStatus.PENDING).build();
        var payment = Payment.builder().order(order).paymentStatus(PaymentStatus.PENDING).build();
        when(orders.findByOrderCode("TEST1")).thenReturn(Optional.of(order));
        when(payments.findByOrderId(1L)).thenReturn(Optional.of(payment));
        var params = new HashMap<String, String>();
        params.put("vnp_TxnRef", "TEST1"); params.put("vnp_ResponseCode", "00");
        params.put("vnp_TransactionNo", "TEST-TXN");
        params.put("vnp_SecureHash", VnPayConfig.hashAllFields(params, "test-only-signing-secret"));
        assertTrue(new VnPayServiceImpl(config, orders, payments).processPaymentCallback(params));
        assertEquals(PaymentStatus.SUCCESS, payment.getPaymentStatus());
        assertEquals(OrderStatus.PENDING, order.getStatus());
        verify(orders, never()).save(any());
    }
}
