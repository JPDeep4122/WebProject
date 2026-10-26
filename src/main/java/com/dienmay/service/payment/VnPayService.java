package com.dienmay.service.payment;

import java.util.Map;
import java.time.Instant;

import com.dienmay.entity.order.Order;

import jakarta.servlet.http.HttpServletRequest;

public interface VnPayService {

    void requireConfigured();

    String createPaymentUrl(Order order, HttpServletRequest request, Instant expiresAt);

    boolean isValidSignature(Map<String, String> params);

    Map<String, String> processIpn(Map<String, String> params);
}
