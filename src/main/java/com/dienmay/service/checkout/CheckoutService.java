package com.dienmay.service.checkout;

import java.math.BigDecimal;
import com.dienmay.dto.checkout.CheckoutPageDto;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.VoucherResponse;
import com.dienmay.entity.order.Order;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public interface CheckoutService {
    CheckoutPageDto getCheckoutData(String userEmail, HttpSession session);
    VoucherResponse applyVoucher(String code, BigDecimal subtotal);
    Order placeOrder(PlaceOrderRequest request, String userEmail, HttpSession session,
            HttpServletRequest servletRequest);
    String continuePayment(String orderCode, String userEmail, HttpSession session);
    Order getOrderByCode(
            String orderCode, String userEmail, HttpSession session);
}
