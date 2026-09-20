package com.dienmay.controller.client;

import java.math.BigDecimal;
import java.security.Principal;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.dienmay.dto.checkout.CheckoutPageDto;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.VoucherResponse;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.entity.order.Order;
import com.dienmay.service.checkout.CheckoutService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class CheckoutController {

    private final CheckoutService checkoutService;

    // 1. Xem trang thanh toán: /checkout
    @GetMapping("/checkout")
    public String viewCheckout(Model model, Principal principal, HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CheckoutPageDto checkoutData = checkoutService.getCheckoutData(email, session);

        // Nếu không có sản phẩm nào được chọn, điều hướng lại về giỏ hàng
        if (checkoutData.getItems() == null || checkoutData.getItems().isEmpty()) {
            return "redirect:/cart";
        }

        model.addAttribute("checkoutData", checkoutData);
        return "client/checkout";
    }

    // 2. API AJAX kiểm tra mã giảm giá
    @PostMapping("/api/checkout/apply-voucher")
    @ResponseBody
    public ResponseEntity<ApiResponse<VoucherResponse>> applyVoucher(
            @RequestParam String code, 
            @RequestParam BigDecimal subtotal) {
        VoucherResponse res = checkoutService.applyVoucher(code, subtotal);
        return ResponseEntity.ok(ApiResponse.<VoucherResponse>builder()
                .success(res.isValid())
                .message(res.getMessage())
                .data(res)
                .build());
    }

    // 3. Đặt hàng (Submit Form)
    @PostMapping("/checkout/place-order")
    public String placeOrder(
            @ModelAttribute PlaceOrderRequest request, 
            Principal principal, 
            HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        Order order = checkoutService.placeOrder(request, email, session);

        // Điều hướng sang trang đặt hàng thành công
        return "redirect:/order-success/" + order.getOrderCode();
    }

    // 4. Trang đặt hàng thành công
    @GetMapping("/order-success/{orderCode}")
    public String orderSuccess(@PathVariable String orderCode, Model model) {
        Order order = checkoutService.getOrderByCode(orderCode);
        model.addAttribute("order", order);
        return "client/order-success";
    }
}