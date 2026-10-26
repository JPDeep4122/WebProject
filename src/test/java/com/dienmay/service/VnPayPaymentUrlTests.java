package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;

import java.math.BigDecimal;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.util.ReflectionTestUtils;

import com.dienmay.config.vnpay.VnPayConfig;
import com.dienmay.entity.order.Order;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.service.impl.VnPayServiceImpl;

class VnPayPaymentUrlTests {
    private VnPayConfig config() {
        var config = new VnPayConfig();
        ReflectionTestUtils.setField(config, "vnpTmnCode", "TESTCODE");
        ReflectionTestUtils.setField(config, "vnpHashSecret", "unit-test-signing-secret");
        ReflectionTestUtils.setField(config, "vnpPayUrl", "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html");
        ReflectionTestUtils.setField(config, "vnpReturnUrl", "https://shop.example.test/payment/vnpay-return");
        return config;
    }

    @Test
    void generatedLinkHasValidSignatureAndExactlyThePersistedExpiry() {
        var service = new VnPayServiceImpl(config(), mock(PaymentRepository.class));
        var order = Order.builder().orderCode("ORD-20261027-ABC123")
                .finalAmount(new BigDecimal("140000")).build();
        Instant expiry = Instant.now().plusSeconds(900).truncatedTo(ChronoUnit.SECONDS);
        String url = service.createPaymentUrl(order, new MockHttpServletRequest(), expiry);
        var params = new HashMap<String, String>();
        for (String entry : URI.create(url).getRawQuery().split("&")) {
            String[] pair = entry.split("=", 2);
            params.put(URLDecoder.decode(pair[0], StandardCharsets.UTF_8),
                    URLDecoder.decode(pair[1], StandardCharsets.UTF_8));
        }
        assertEquals("ORD20261027ABC123", params.get("vnp_TxnRef"));
        assertEquals("14000000", params.get("vnp_Amount"));
        assertEquals(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")
                .withZone(ZoneId.of("Asia/Ho_Chi_Minh")).format(expiry), params.get("vnp_ExpireDate"));
        assertTrue(service.isValidSignature(params));
        params.put("vnp_Amount", "100");
        assertFalse(service.isValidSignature(params));
    }

    @Test
    void missingOrInvalidReturnUrlIsRejectedBeforeCheckout() {
        var config = config();
        var service = new VnPayServiceImpl(config, mock(PaymentRepository.class));
        ReflectionTestUtils.setField(config, "vnpReturnUrl", "");
        assertThrows(IllegalStateException.class, service::requireConfigured);
        ReflectionTestUtils.setField(config, "vnpReturnUrl", "javascript:alert(1)");
        assertThrows(IllegalStateException.class, service::requireConfigured);
    }

    @Test
    void expiredLinkAndZeroAmountCannotGeneratePaymentUrl() {
        var service = new VnPayServiceImpl(config(), mock(PaymentRepository.class));
        var order = Order.builder().orderCode("ORD-TEST").finalAmount(BigDecimal.TEN).build();
        assertThrows(IllegalArgumentException.class, () -> service.createPaymentUrl(
                order, new MockHttpServletRequest(), Instant.now().minusSeconds(1)));
        order.setFinalAmount(BigDecimal.ZERO);
        assertThrows(IllegalArgumentException.class, () -> service.createPaymentUrl(
                order, new MockHttpServletRequest(), Instant.now().plusSeconds(900)));
    }
}
