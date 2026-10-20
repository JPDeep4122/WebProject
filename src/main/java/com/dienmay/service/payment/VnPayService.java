package com.dienmay.service.payment;

import java.util.Map;

import com.dienmay.entity.order.Order;

import jakarta.servlet.http.HttpServletRequest;

public interface VnPayService {

    String createPaymentUrl(Order order, HttpServletRequest request);

    boolean isValidSignature(Map<String, String> params);

    Map<String, String> processIpn(Map<String, String> params);
}	