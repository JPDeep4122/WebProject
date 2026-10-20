package com.dienmay.controller.client;

import java.security.Principal;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.payment.VnPayService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final VnPayService vnPayService;
    private final CheckoutService checkoutService;

    @GetMapping("/vnpay-return")
    public String vnpayReturn(
            @RequestParam Map<String, String> allParams,
            Principal principal,
            HttpSession session,
            Model model) {

        if (!vnPayService.isValidSignature(allParams)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Thông tin thanh toán không hợp lệ.");
        }

        String email = principal != null ? principal.getName() : null;

        Order order = checkoutService.getOrderByCode(
                allParams.get("vnp_TxnRef"), email, session);

        if (order.getPayment() == null) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Không tìm thấy thông tin thanh toán.");
        }

        PaymentStatus status = order.getPayment().getPaymentStatus();

        model.addAttribute("order", order);
        model.addAttribute("isSuccess", status == PaymentStatus.SUCCESS);
        model.addAttribute("isPending", status == PaymentStatus.PENDING);
        model.addAttribute(
                "transactionNo", order.getPayment().getTransactionNo());
        model.addAttribute("bankCode", allParams.get("vnp_BankCode"));
        model.addAttribute("cardType", allParams.get("vnp_CardType"));
        model.addAttribute("responseCode", allParams.get("vnp_ResponseCode"));

        return "client/payment-result";
    }
    
    @GetMapping("/vnpay-ipn")
    @ResponseBody
    public Map<String, String> vnpayIpn(
            @RequestParam Map<String, String> params) {

        try {
            return vnPayService.processIpn(params);
        } catch (Exception ex) {
            log.error("Không xử lý được IPN VNPay", ex);
            return Map.of(
                    "RspCode", "99",
                    "Message", "Processing error");
        }
    }
}