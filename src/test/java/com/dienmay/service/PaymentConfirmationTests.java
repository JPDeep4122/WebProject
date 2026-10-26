package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.Test;

import com.dienmay.config.vnpay.VnPayConfig;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.service.impl.VnPayServiceImpl;

class PaymentConfirmationTests {

    private static final String SECRET = "test-only-signing-secret";

    @Test
    void validatesCallbackAndPreservesCompletedPayment() {
        var config = mock(VnPayConfig.class);
        var payments = mock(PaymentRepository.class);

        when(config.getVnpHashSecret()).thenReturn(SECRET);
        when(config.getVnpTmnCode()).thenReturn("TESTMERCHANT");

        var order = Order.builder()
                .id(1L)
                .orderCode("TEST1")
                .status(OrderStatus.PENDING)
                .build();

        var payment = Payment.builder()
                .order(order)
                .paymentMethod(PaymentMethod.VNPAY)
                .paymentStatus(PaymentStatus.PENDING)
                .amount(new BigDecimal("100000"))
                .build();

        when(payments.findByReferenceForUpdate("TEST1"))
                .thenReturn(Optional.of(payment));

        var service = new VnPayServiceImpl(config, payments);
        var params = new HashMap<String, String>();

        params.put("vnp_TmnCode", "TESTMERCHANT");
        params.put("vnp_TxnRef", "TEST1");
        params.put("vnp_Amount", "10000000");
        params.put("vnp_ResponseCode", "00");
        params.put("vnp_TransactionStatus", "00");
        params.put("vnp_TransactionNo", "123456789");
        params.put("vnp_PayDate", "20261020120000");

        params.put("vnp_SecureHash", "0".repeat(128));

        assertEquals("97", service.processIpn(params).get("RspCode"));
        assertEquals(PaymentStatus.PENDING, payment.getPaymentStatus());
        verify(payments, never()).findByReferenceForUpdate(anyString());

        params.put("vnp_Amount", "1");
        sign(params);

        assertEquals("04", service.processIpn(params).get("RspCode"));
        assertEquals(PaymentStatus.PENDING, payment.getPaymentStatus());

        params.put("vnp_Amount", "10000000");
        sign(params);

        assertEquals("00", service.processIpn(params).get("RspCode"));
        assertEquals(PaymentStatus.SUCCESS, payment.getPaymentStatus());
        assertEquals(OrderStatus.PENDING, order.getStatus());

        params.put("vnp_ResponseCode", "24");
        params.put("vnp_TransactionStatus", "02");
        sign(params);

        assertEquals("02", service.processIpn(params).get("RspCode"));
        assertEquals(PaymentStatus.SUCCESS, payment.getPaymentStatus());
        verify(payments, times(1)).save(payment);
    }	

    private void sign(Map<String, String> params) {
        var fields = new HashMap<>(params);
        fields.remove("vnp_SecureHash");

        params.put("vnp_SecureHash",
                VnPayConfig.hashAllFields(fields, SECRET));
    }
}