package com.dienmay.controller.client;

import java.security.Principal;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.dto.checkout.CheckoutPageDto;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.ShippingQuoteRequest;
import com.dienmay.dto.checkout.ShippingQuoteResponse;
import com.dienmay.dto.checkout.VoucherPreviewRequest;
import com.dienmay.dto.checkout.VoucherResponse;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.entity.order.Order;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.checkout.ShippingService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequiredArgsConstructor
public class CheckoutController {

    private final CheckoutService checkoutService;
    private final ShippingService shippingService;

    @GetMapping("/checkout")
    public String viewCheckout(Model model, Principal principal, HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CheckoutPageDto checkoutData = checkoutService.getCheckoutData(email, session);

        if (checkoutData.getItems() == null || checkoutData.getItems().isEmpty()) {
            return "redirect:/cart";
        }

        model.addAttribute("checkoutData", checkoutData);
        model.addAttribute("orderForm", new PlaceOrderRequest());
        return "client/checkout";
    }

    @PostMapping("/api/checkout/apply-voucher")
    @ResponseBody
    public ResponseEntity<ApiResponse<VoucherResponse>> applyVoucher(
            @Valid @RequestBody VoucherPreviewRequest request,
            Principal principal,
            HttpSession session) {

        String email = principal == null
                ? null : principal.getName();

        VoucherResponse result =
                checkoutService.applyVoucher(request, email, session);

        return ResponseEntity.ok(
                ApiResponse.<VoucherResponse>builder()
                        .success(result.isValid())
                        .message(result.getMessage())
                        .data(result)
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
            @Valid @ModelAttribute("orderForm") PlaceOrderRequest request,
            BindingResult bindingResult,
            Principal principal,
            HttpSession session,
            HttpServletRequest servletRequest,
            Model model) {

        String email = principal != null ? principal.getName() : null;

        CheckoutPageDto checkoutData =
                checkoutService.getCheckoutData(email, session);

        if (checkoutData.getItems() == null
                || checkoutData.getItems().isEmpty()) {
            return "redirect:/cart";
        }

        model.addAttribute("checkoutData", checkoutData);

        if (bindingResult.hasErrors()) {
            model.addAttribute(
                    "checkoutError",
                    bindingResult.getAllErrors()
                            .getFirst()
                            .getDefaultMessage());

            return "client/checkout";
        }

        Order order;

        try {
            order = checkoutService.placeOrder(request, email, session, servletRequest);
        } catch (IllegalArgumentException ex) {
            model.addAttribute("checkoutError", ex.getMessage());
            return "client/checkout";
        } catch (IllegalStateException ex) {
            log.warn("Không thể hoàn tất bước tạo đơn hàng", ex);

            model.addAttribute(
                    "checkoutError",
                    "Hiện chưa thể xử lý đơn hàng. "
                            + "Vui lòng kiểm tra thông tin giao hàng "
                            + "hoặc thử lại sau.");

            return "client/checkout";
        } catch (RuntimeException ex) {
            log.error("Không thể hoàn tất checkout", ex);
            model.addAttribute("checkoutError", "Chưa thể hoàn tất đặt hàng. Vui lòng thử lại.");
            return "client/checkout";
        }

        if ("VNPAY".equalsIgnoreCase(request.getPaymentMethod())) {
            return "redirect:" + order.getPayment().getPaymentUrl();
        }

        return "redirect:/order-success/" + order.getOrderCode();
    }

    @PostMapping("/checkout/orders/{orderCode}/pay")
    public String continuePayment(@PathVariable String orderCode, Principal principal,
            HttpSession session, RedirectAttributes flash) {
        String email = principal != null ? principal.getName() : null;
        // Keep authorization failures as 404; do not disclose another customer's order.
        Order order = checkoutService.getOrderByCode(orderCode, email, session);
        try {
            return "redirect:" + checkoutService.continuePayment(order.getOrderCode(), email, session);
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("errorMessage", ex.getMessage());
            return "redirect:/orders/" + order.getOrderCode();
        }
    }

    @GetMapping("/order-success/{orderCode}")
    public String orderSuccess(
            @PathVariable String orderCode,
            Principal principal,
            HttpSession session,
            Model model) {

        String email = principal != null ? principal.getName() : null;

        Order order = checkoutService.getOrderByCode(
                orderCode, email, session);

        model.addAttribute("order", order);
        return "client/order-success";
    }
}
