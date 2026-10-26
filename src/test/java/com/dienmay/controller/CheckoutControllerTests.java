package com.dienmay.controller;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.ui.ExtendedModelMap;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap;

import com.dienmay.controller.client.CheckoutController;
import com.dienmay.dto.checkout.CheckoutItemDto;
import com.dienmay.dto.checkout.CheckoutPageDto;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.payment.Payment;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.checkout.ShippingService;

class CheckoutControllerTests {
    @Test
    void vnpayRedirectUsesTheLinkAlreadyCommittedByCheckout() {
        var checkout = mock(CheckoutService.class);
        var controller = new CheckoutController(checkout, mock(ShippingService.class));
        var request = new PlaceOrderRequest();
        request.setPaymentMethod("VNPAY");
        var order = Order.builder().orderCode("ORD-TEST").build();
        order.setPayment(Payment.builder().order(order)
                .paymentUrl("https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?ref=ORDTEST").build());
        when(checkout.getCheckoutData(any(), any())).thenReturn(CheckoutPageDto.builder()
                .items(List.of(CheckoutItemDto.builder().build())).build());
        when(checkout.placeOrder(any(), any(), any(), any())).thenReturn(order);
        String view = controller.placeOrder(request, new BeanPropertyBindingResult(request, "orderForm"),
                null, new MockHttpSession(), new MockHttpServletRequest(), new ExtendedModelMap());
        assertEquals("redirect:" + order.getPayment().getPaymentUrl(), view);
    }

    @Test
    void urlOrDatabaseFailureKeepsUserOnCheckoutWithAnError() {
        var checkout = mock(CheckoutService.class);
        var controller = new CheckoutController(checkout, mock(ShippingService.class));
        var request = new PlaceOrderRequest();
        var model = new ExtendedModelMap();
        when(checkout.getCheckoutData(any(), any())).thenReturn(CheckoutPageDto.builder()
                .items(List.of(CheckoutItemDto.builder().build())).build());
        when(checkout.placeOrder(any(), any(), any(), any()))
                .thenThrow(new IllegalStateException("Cannot create payment URL"));
        assertEquals("client/checkout", controller.placeOrder(request,
                new BeanPropertyBindingResult(request, "orderForm"), null,
                new MockHttpSession(), new MockHttpServletRequest(), model));
        assertNotNull(model.get("checkoutError"));
        assertNotNull(model.get("checkoutData"));
    }

    @Test
    void retryPreservesNotFoundForUnauthorizedUsersAndShowsExpiryForOwners() {
        var checkout = mock(CheckoutService.class);
        var controller = new CheckoutController(checkout, mock(ShippingService.class));
        var session = new MockHttpSession();
        var flash = new RedirectAttributesModelMap();
        when(checkout.getOrderByCode(eq("ORD-TEST"), isNull(), eq(session)))
                .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
        assertThrows(ResponseStatusException.class,
                () -> controller.continuePayment("ORD-TEST", null, session, flash));
        verify(checkout, never()).continuePayment(any(), any(), any());
        when(checkout.getOrderByCode(eq("ORD-TEST"), isNull(), eq(session)))
                .thenReturn(Order.builder().orderCode("ORD-TEST").build());
        when(checkout.continuePayment(eq("ORD-TEST"), isNull(), eq(session)))
                .thenThrow(new IllegalArgumentException("Payment link expired"));
        assertEquals("redirect:/order-success/ORD-TEST",
                controller.continuePayment("ORD-TEST", null, session, flash));
        assertEquals("Payment link expired", flash.getFlashAttributes().get("paymentError"));
    }
}
