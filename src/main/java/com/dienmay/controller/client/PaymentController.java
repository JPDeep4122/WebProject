package com.dienmay.controller.client;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.dienmay.entity.order.Order;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.payment.VnPayService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final VnPayService vnPayService;
    private final CheckoutService checkoutService;

    // VNPAY CHUYỂN HƯỚNG VỀ ĐÂY SAU KHI KHÁCH THANH TOÁN XONG
    @GetMapping("/vnpay-return")
    public String vnpayReturn(@RequestParam Map<String, String> allParams, Model model) {
        boolean isSuccess = vnPayService.processPaymentCallback(allParams);
        String orderCode = allParams.get("vnp_TxnRef");
        
        Order order = checkoutService.getOrderByCode(orderCode);

        model.addAttribute("isSuccess", isSuccess);
        model.addAttribute("order", order);
        model.addAttribute("transactionNo", allParams.get("vnp_TransactionNo"));
        model.addAttribute("bankCode", allParams.get("vnp_BankCode"));
        model.addAttribute("cardType", allParams.get("vnp_CardType"));
        model.addAttribute("responseCode", allParams.get("vnp_ResponseCode"));

        return "client/payment-result";
    }
}