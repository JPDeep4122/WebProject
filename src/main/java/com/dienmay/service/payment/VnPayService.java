package com.dienmay.service.payment;

import java.util.Map;
import com.dienmay.entity.order.Order;
import jakarta.servlet.http.HttpServletRequest;

public interface VnPayService {
    // 1. Tạo link thanh toán VNPAY
    String createPaymentUrl(Order order, HttpServletRequest request);

    // 2. Xử lý kết quả trả về từ VNPAY sau khi khách thanh toán
    boolean processPaymentCallback(Map<String, String> params);
}