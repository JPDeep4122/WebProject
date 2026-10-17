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
import org.springframework.web.bind.annotation.RequestBody;

import com.dienmay.dto.checkout.CheckoutPageDto;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.VoucherResponse;
import com.dienmay.dto.checkout.ShippingQuoteRequest;
import com.dienmay.dto.checkout.ShippingQuoteResponse;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.entity.order.Order;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.checkout.ShippingService;
import com.dienmay.service.payment.VnPayService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class CheckoutController {

    private final CheckoutService checkoutService;
    private final VnPayService vnPayService; // TIÊM VNPAY SERVICE
    private final ShippingService shippingService;

    @GetMapping("/checkout")
    public String viewCheckout(Model model, Principal principal, HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CheckoutPageDto checkoutData = checkoutService.getCheckoutData(email, session);

        if (checkoutData.getItems() == null || checkoutData.getItems().isEmpty()) {
            return "redirect:/cart";
        }

        model.addAttribute("checkoutData", checkoutData);
        return "client/checkout";
    }

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

    @PostMapping("/api/checkout/shipping-quote")
    @ResponseBody
    public ResponseEntity<ApiResponse<ShippingQuoteResponse>> shippingQuote(@RequestBody ShippingQuoteRequest request) {
        try {
            ShippingQuoteResponse quote = shippingService.quote(request.getShippingAddress(), request.getProvince());
            return ResponseEntity.ok(ApiResponse.<ShippingQuoteResponse>builder().success(true)
                    .message(quote.isSameProvince() ? "Giao hàng cùng tỉnh/thành, miễn phí vận chuyển." : "Đã tính phí theo tuyến đường Google Maps.")
                    .data(quote).build());
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return ResponseEntity.badRequest().body(ApiResponse.<ShippingQuoteResponse>builder()
                    .success(false).message(ex.getMessage()).build());
        }
    }

    // ĐẶT HÀNG & RẼ NHÁNH VNPAY HOẶC COD
    @PostMapping("/checkout/place-order")
    public String placeOrder(
            @ModelAttribute PlaceOrderRequest request, 
            Principal principal, 
            HttpSession session,
            HttpServletRequest servletRequest) {
        String email = (principal != null) ? principal.getName() : null;
        Order order = checkoutService.placeOrder(request, email, session);

        // NẾU CHỌN THANH TOÁN VNPAY -> TẠO LINK VÀ CHUYỂN HƯỚNG SANG CỔNG VNPAY
        if ("VNPAY".equalsIgnoreCase(request.getPaymentMethod())) {
            String vnpayUrl = vnPayService.createPaymentUrl(order, servletRequest);
            return "redirect:" + vnpayUrl;
        }

        // Mặc định COD: sang trang chúc mừng
        return "redirect:/order-success/" + order.getOrderCode();
    }

    @GetMapping("/order-success/{orderCode}")
    public String orderSuccess(@PathVariable String orderCode, Model model) {
        Order order = checkoutService.getOrderByCode(orderCode);
        model.addAttribute("order", order);
        return "client/order-success";
    }
}
