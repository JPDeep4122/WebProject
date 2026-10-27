package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.orm.jpa.EntityManagerHolder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.server.ResponseStatusException;

import com.dienmay.dto.cart.AddToCartRequest;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.ShippingQuoteResponse;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.cart.Cart;
import com.dienmay.entity.cart.CartItem;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.entity.product.Product;
import com.dienmay.entity.promotion.Promotion;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.service.cart.CartService;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.checkout.PurchaseValidator;
import com.dienmay.service.checkout.ShippingService;
import com.dienmay.service.impl.CartServiceImpl;
import com.dienmay.service.impl.CheckoutServiceImpl;
import com.dienmay.service.payment.VnPayService;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
@Import({CheckoutServiceImpl.class, CartServiceImpl.class, PurchaseValidator.class,
        CheckoutCartIntegrationTests.Transactions.class})
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class CheckoutCartIntegrationTests {
    @TestConfiguration(proxyBeanMethods = false)
    static class Transactions {
        @Bean TransactionTemplate transactionTemplate(PlatformTransactionManager manager) {
            return new TransactionTemplate(manager);
        }
    }

    @Autowired CheckoutService checkout;
    @Autowired CartService carts;
    @Autowired EntityManager em;
    @Autowired EntityManagerFactory entityManagerFactory;
    @Autowired TransactionTemplate tx;
    @Autowired OrderRepository orders;
    @Autowired PaymentRepository payments;
    @Autowired UserRepository users;
    @MockitoBean ShippingService shipping;
    @MockitoBean VnPayService vnPay;

    MockHttpSession session;
    PlaceOrderRequest request;
    ShippingQuoteResponse quote;
    Long branchId, productId, cartId, itemId, inventoryId, userId;
    String contactEmail;

    @BeforeEach
    void seed() {
        String suffix = UUID.randomUUID().toString();
        contactEmail = suffix + "@example.test";
        session = new MockHttpSession();
        session.setAttribute("GUEST_CART_SESSION", suffix);
        tx.executeWithoutResult(s -> {
            var branch = Branch.builder().name("Checkout " + suffix).address("Pickup")
                    .province("Ho Chi Minh").active(true).build();
            em.persist(branch); branchId = branch.getId();
            var product = Product.builder().name("Product " + suffix).sku(suffix).slug(suffix)
                    .originalPrice(new BigDecimal("100000"))
                    .price(new BigDecimal("100000")).discountPrice(new BigDecimal("70000")).build();
            em.persist(product); productId = product.getId();
            var inventory = BranchInventory.builder().branch(branch).product(product)
                    .stockQuantity(5).reservedQuantity(1).build();
            em.persist(inventory); inventoryId = inventory.getId();
            var user = User.builder().email(contactEmail).password("test").fullName("Account owner")
                    .active(true).build();
            em.persist(user); userId = user.getId();
            var cart = Cart.builder().sessionId(suffix).build();
            em.persist(cart); cartId = cart.getId();
            var item = CartItem.builder().cart(cart).product(product).quantity(2).selected(true).build();
            cart.getItems().add(item);
            em.persist(item); itemId = item.getId();
        });
        quote = ShippingQuoteResponse.builder().branchId(branchId).shippingFee(BigDecimal.ZERO)
                .sameProvince(true).branchName("Test branch").build();
        when(shipping.quote(anyString(), anyString())).thenReturn(quote);
        when(vnPay.createPaymentUrl(any(), any(), any())).thenAnswer(invocation ->
                "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?ref="
                        + ((Order) invocation.getArgument(0)).getOrderCode());
        request = new PlaceOrderRequest();
        request.setRecipientName("Guest recipient");
        request.setRecipientPhone("0901234567");
        request.setRecipientEmail(contactEmail);
        request.setShippingAddress("123 Test street");
        request.setProvince("Ho Chi Minh");
        request.setPaymentMethod("VNPAY");
    }

    private Order place() {
        return checkout.placeOrder(request, contactEmail, session, new MockHttpServletRequest());
    }

    private AddToCartRequest addRequest(int quantity) {
        var add = new AddToCartRequest();
        add.setProductId(productId);
        add.setQuantity(quantity);
        return add;
    }

    private void assertCartQuantity(int expected) {
        tx.executeWithoutResult(s -> {
            var cart = em.find(Cart.class, cartId);
            assertEquals(expected == 0 ? 0 : 1, cart.getItems().size());
            if (expected > 0) assertEquals(expected, cart.getItems().getFirst().getQuantity());
        });
    }

    @Test
    void authenticatedOrderUsesSellingPriceAndRetainsOwnership() {
        long userCount = users.count();
        Order result = place();
        assertEquals(userId, result.getUser().getId());
        assertEquals(contactEmail, result.getRecipientEmail());
        assertEquals(userCount, users.count());
        assertEquals(0, new BigDecimal("140000").compareTo(result.getFinalAmount()));
        assertEquals(0, new BigDecimal("70000").compareTo(result.getOrderItems().getFirst().getPrice()));
        assertNotNull(result.getPayment().getPaymentUrl());
        assertTrue(result.getPayment().isPaymentLinkAvailable());
        assertNull(session.getAttribute("GUEST_CHECKOUT_ORDER_" + result.getId()));
        assertCartQuantity(0);
        assertEquals(1, tx.<Integer>execute(s -> orders.findByUserIdOrderByCreatedAtDesc(userId).size()).intValue());
        assertEquals(result.getId(), checkout.getOrderByCode(result.getOrderCode(), contactEmail, session).getId());
        assertEquals(result.getId(), checkout.getOrderByCode(
                result.getOrderCode().replace("-", "").toUpperCase(java.util.Locale.ROOT), contactEmail, session).getId());
    }

    @Test
    void authenticatedOrderUsesPrincipalEvenWhenRecipientEmailIsDifferent() {
        tx.executeWithoutResult(s -> em.find(Cart.class, cartId).setUser(em.find(User.class, userId)));
        request.setRecipientEmail("someone-else@example.test");
        Order result = checkout.placeOrder(request, contactEmail, session, new MockHttpServletRequest());
        assertEquals(userId, result.getUser().getId());
        assertEquals("someone-else@example.test", result.getRecipientEmail());
        assertNull(session.getAttribute("GUEST_CHECKOUT_ORDER_" + result.getId()));
    }

    @Test
    void missingVnPayConfigurationLeavesCartAndOrdersUntouched() {
        long before = orders.count();
        doThrow(new IllegalStateException("Missing VNPay config")).when(vnPay).requireConfigured();
        assertThrows(IllegalStateException.class, this::place);
        assertEquals(before, orders.count());
        assertCartQuantity(2);
        verifyNoInteractions(shipping);
    }

    @Test
    void urlCreationFailureRollsBackOrderPaymentVoucherAndCart() {
        String code = ("TEST-" + UUID.randomUUID()).toUpperCase(java.util.Locale.ROOT);
        Long promotionId = tx.execute(s -> {
            var promotion = Promotion.builder().name("Checkout rollback").code(code)
                    .discountPercent(BigDecimal.TEN).startsAt(LocalDateTime.now().minusDays(1))
                    .endsAt(LocalDateTime.now().plusDays(1)).maxUses(10).build();
            em.persist(promotion);
            return promotion.getId();
        });
        request.setVoucherCode(code);
        long orderCount = orders.count();
        long paymentCount = payments.count();
        doThrow(new IllegalStateException("Cannot sign URL"))
                .when(vnPay).createPaymentUrl(any(), any(), any());
        assertThrows(IllegalStateException.class, this::place);
        assertEquals(orderCount, orders.count());
        assertEquals(paymentCount, payments.count());
        assertCartQuantity(2);
        assertEquals(0, tx.<Integer>execute(s -> em.find(Promotion.class, promotionId).getUsedCount()).intValue());
        assertTrue(java.util.Collections.list(session.getAttributeNames()).stream()
                .noneMatch(name -> name.startsWith("GUEST_CHECKOUT_ORDER_")));
    }

    @Test
    void codWorksWithoutCallingVnPay() {
        request.setPaymentMethod("COD");
        Order result = place();
        assertEquals(PaymentMethod.COD, result.getPayment().getPaymentMethod());
        assertNull(result.getPayment().getPaymentUrl());
        assertFalse(result.getPayment().isPaymentLinkAvailable());
        verifyNoInteractions(vnPay);
    }

    @Test
    void continuePaymentReusesSameAttemptAndRequiresOwnership() {
        Order result = place();
        long before = orders.count();
        clearInvocations(vnPay);
        assertEquals(result.getPayment().getPaymentUrl(),
                checkout.continuePayment(result.getOrderCode(), contactEmail, session));
        assertEquals(before, orders.count());
        verifyNoInteractions(vnPay);
        assertEquals(result.getPayment().getPaymentUrl(),
                checkout.continuePayment(result.getOrderCode(), contactEmail, new MockHttpSession()));
        assertThrows(ResponseStatusException.class,
                () -> checkout.getOrderByCode(result.getOrderCode(), null, new MockHttpSession()));
    }

    @Test
    void expiredFinishedOrCancelledPaymentsCannotBeReopened() {
        Order result = place();
        tx.executeWithoutResult(s -> em.find(Order.class, result.getId()).getPayment()
                .setPaymentExpiresAt(Instant.now().minusSeconds(1)));
        assertThrows(IllegalArgumentException.class,
                () -> checkout.continuePayment(result.getOrderCode(), contactEmail, session));
        for (var status : new PaymentStatus[] {PaymentStatus.SUCCESS, PaymentStatus.FAILED}) {
            tx.executeWithoutResult(s -> {
                var payment = em.find(Order.class, result.getId()).getPayment();
                payment.setPaymentExpiresAt(Instant.now().plusSeconds(900));
                payment.setPaymentStatus(status);
            });
            assertThrows(IllegalArgumentException.class,
                    () -> checkout.continuePayment(result.getOrderCode(), contactEmail, session));
        }
        tx.executeWithoutResult(s -> {
            var order = em.find(Order.class, result.getId());
            order.getPayment().setPaymentStatus(PaymentStatus.PENDING);
            order.setStatus(OrderStatus.CANCELLED);
        });
        assertThrows(IllegalArgumentException.class,
                () -> checkout.continuePayment(result.getOrderCode(), contactEmail, session));
    }

    @Test
    void inactiveProductsAreRejectedByEveryPurchaseEntryPoint() {
        tx.executeWithoutResult(s -> em.find(Product.class, productId).setActive(false));
        long before = orders.count();
        assertThrows(IllegalArgumentException.class, () -> carts.addToCart(addRequest(1), null, session));
        assertThrows(IllegalArgumentException.class, () -> carts.buyNow(addRequest(1), null, session));
        assertThrows(IllegalArgumentException.class, () -> carts.updateQuantity(itemId, 3, null, session));
        assertThrows(IllegalArgumentException.class, this::place);
        assertEquals(before, orders.count());
        assertCartQuantity(2);
    }

    @Test
    void checksCombinedCartQuantityAndUpdatesAgainstAvailableStock() {
        assertThrows(IllegalArgumentException.class, () -> carts.addToCart(addRequest(3), null, session));
        assertThrows(IllegalArgumentException.class, () -> carts.updateQuantity(itemId, 5, null, session));
        assertThrows(IllegalArgumentException.class, () -> carts.buyNow(addRequest(5), null, session));
        assertCartQuantity(2);
        var result = carts.addToCart(addRequest(2), null, session);
        assertEquals(4, result.getItems().getFirst().getQuantity());
    }

    @Test
    void checkoutChecksSelectedBranchEvenWhenOtherBranchesHaveStock() {
        tx.executeWithoutResult(s -> {
            em.find(BranchInventory.class, inventoryId).setStockQuantity(1);
            em.find(BranchInventory.class, inventoryId).setReservedQuantity(0);
            var other = Branch.builder().name("Other").address("Other").build();
            em.persist(other);
            em.persist(BranchInventory.builder().branch(other).product(em.find(Product.class, productId))
                    .stockQuantity(10).reservedQuantity(0).build());
        });
        long before = orders.count();
        assertThrows(IllegalArgumentException.class, this::place);
        assertEquals(before, orders.count());
        assertCartQuantity(2);
    }

    @Test
    void duplicateCartLinesCannotBypassBranchStockValidation() {
        tx.executeWithoutResult(s -> {
            var cart = em.find(Cart.class, cartId);
            var duplicate = CartItem.builder().cart(cart).product(em.find(Product.class, productId))
                    .quantity(3).selected(true).build();
            cart.getItems().add(duplicate);
            em.persist(duplicate);
        });
        long before = orders.count();
        assertThrows(IllegalArgumentException.class, this::place);
        assertEquals(before, orders.count());
    }

    @Test
    void simultaneousCheckoutsCreateOnlyOneOrderFromTheSameCart() throws Exception {
        var barrier = new CyclicBarrier(2);
        when(shipping.quote(anyString(), anyString())).thenAnswer(invocation -> {
            barrier.await(10, TimeUnit.SECONDS);
            return quote;
        });
        long before = orders.count();
        try (var pool = Executors.newFixedThreadPool(2)) {
            var first = pool.submit(this::attemptCheckout);
            var second = pool.submit(this::attemptCheckout);
            assertNotEquals(first.get(20, TimeUnit.SECONDS), second.get(20, TimeUnit.SECONDS));
        }
        assertEquals(before + 1, orders.count());
        assertCartQuantity(0);
    }

    @Test
    void checkoutDiscardsItemsCachedByAPreviousPagePreview() throws Exception {
        EntityManager preview = entityManagerFactory.createEntityManager();
        TransactionSynchronizationManager.bindResource(entityManagerFactory, new EntityManagerHolder(preview));
        try {
            assertEquals(1, checkout.getCheckoutData(contactEmail, session).getItems().size());
            try (var pool = Executors.newSingleThreadExecutor()) {
                assertNotNull(pool.submit(this::place).get(15, TimeUnit.SECONDS));
            }
            long before = orders.count();
            assertThrows(IllegalArgumentException.class, this::place);
            assertEquals(before, orders.count());
        } finally {
            TransactionSynchronizationManager.unbindResource(entityManagerFactory);
            preview.close();
        }
    }

    @Test
    void checkoutRefreshesProductThatWasDisabledAfterThePreview() throws Exception {
        EntityManager preview = entityManagerFactory.createEntityManager();
        TransactionSynchronizationManager.bindResource(entityManagerFactory, new EntityManagerHolder(preview));
        try {
            assertEquals(1, checkout.getCheckoutData(contactEmail, session).getItems().size());
            try (var pool = Executors.newSingleThreadExecutor()) {
                pool.submit(() -> tx.executeWithoutResult(s -> em.find(Product.class, productId).setActive(false)))
                        .get(15, TimeUnit.SECONDS);
            }
            assertThrows(IllegalArgumentException.class, this::place);
        } finally {
            TransactionSynchronizationManager.unbindResource(entityManagerFactory);
            preview.close();
        }
        assertCartQuantity(2);
    }

    private boolean attemptCheckout() {
        try { place(); return true; }
        catch (IllegalArgumentException ex) { return false; }
    }

    @Test
    void guestCannotPreviewOrCreateOrdersEvenWhenRecipientEmailExists() {
        long before = orders.count();
        assertEquals(HttpStatus.UNAUTHORIZED, assertThrows(ResponseStatusException.class,
                () -> checkout.getCheckoutData(null, session)).getStatusCode());
        assertEquals(HttpStatus.UNAUTHORIZED, assertThrows(ResponseStatusException.class,
                () -> checkout.placeOrder(request, null, session, new MockHttpServletRequest())).getStatusCode());
        assertEquals(HttpStatus.UNAUTHORIZED, assertThrows(ResponseStatusException.class,
                () -> checkout.placeOrder(request, "anonymousUser", session, new MockHttpServletRequest())).getStatusCode());
        assertEquals(before, orders.count());
        assertCartQuantity(2);
        verifyNoInteractions(shipping, vnPay);
    }

    @Test
    void signInClaimsGuestCartOnceAndGuestAfterLogoutCannotSeeIt() {
        var signedIn = carts.getCart(contactEmail, session);
        assertEquals(cartId, signedIn.getCartId());
        assertEquals(2, signedIn.getTotalQuantity());
        assertNull(session.getAttribute("GUEST_CART_SESSION"));
        assertEquals(2, carts.getCart(contactEmail, session).getTotalQuantity());
        var guestAfterLogout = carts.getCart(null, session);
        assertNotEquals(cartId, guestAfterLogout.getCartId());
        assertEquals(0, guestAfterLogout.getTotalQuantity());
        assertEquals(2, carts.getCart(contactEmail, new MockHttpSession()).getTotalQuantity());
    }

    @Test
    void signInMergesGuestItemsWithExistingAccountCartExactlyOnce() {
        Long accountCartId = tx.execute(s -> {
            var accountCart = Cart.builder().user(em.find(User.class, userId)).build();
            em.persist(accountCart);
            var item = CartItem.builder().cart(accountCart).product(em.find(Product.class, productId))
                    .quantity(1).selected(false).build();
            accountCart.getItems().add(item);
            em.persist(item);
            return accountCart.getId();
        });
        var merged = carts.getCart(contactEmail, session);
        assertEquals(accountCartId, merged.getCartId());
        assertEquals(1, merged.getItems().size());
        assertEquals(3, merged.getItems().getFirst().getQuantity());
        assertTrue(merged.getItems().getFirst().getSelected());
        assertEquals(3, carts.getCart(contactEmail, session).getTotalQuantity());
        assertNull(session.getAttribute("GUEST_CART_SESSION"));
        assertEquals(0, carts.getCart(null, session).getTotalQuantity());
    }

    @Test
    void legacyGuestOrderCapabilityDoesNotGrantAnonymousOrOtherAccountAccess() {
        Order result = place();
        session.setAttribute("GUEST_CHECKOUT_ORDER_" + result.getId(), Boolean.TRUE);
        assertEquals(HttpStatus.UNAUTHORIZED, assertThrows(ResponseStatusException.class,
                () -> checkout.getOrderByCode(result.getOrderCode(), null, session)).getStatusCode());
        String otherEmail = "other-" + UUID.randomUUID() + "@example.test";
        tx.executeWithoutResult(s -> em.persist(User.builder().email(otherEmail).password("x")
                .fullName("Other customer").active(true).build()));
        assertEquals(HttpStatus.NOT_FOUND, assertThrows(ResponseStatusException.class,
                () -> checkout.continuePayment(result.getOrderCode(), otherEmail, session)).getStatusCode());
        assertEquals(result.getId(), checkout.getOrderByCode(result.getOrderCode(), contactEmail, session).getId());
    }

    @Test
    void blockedAccountCannotCheckoutOrConsumeGuestCart() {
        tx.executeWithoutResult(s -> em.find(User.class, userId).setBlocked(true));
        long before = orders.count();
        assertEquals(HttpStatus.FORBIDDEN, assertThrows(ResponseStatusException.class, this::place).getStatusCode());
        assertEquals(before, orders.count());
        assertCartQuantity(2);
        verifyNoInteractions(shipping, vnPay);
    }

    @Test
    void twoAccountsCannotBothClaimTheSameGuestCart() throws Exception {
        String secondEmail = "second-" + UUID.randomUUID() + "@example.test";
        tx.executeWithoutResult(s -> em.persist(User.builder().email(secondEmail).password("x")
                .fullName("Second customer").active(true).build()));
        var barrier = new CyclicBarrier(2);
        try (var pool = Executors.newFixedThreadPool(2)) {
            var first = pool.submit(() -> { barrier.await(10, TimeUnit.SECONDS); return carts.getCart(contactEmail, session).getTotalQuantity(); });
            var second = pool.submit(() -> { barrier.await(10, TimeUnit.SECONDS); return carts.getCart(secondEmail, session).getTotalQuantity(); });
            assertEquals(2, first.get(20, TimeUnit.SECONDS) + second.get(20, TimeUnit.SECONDS));
        }
        assertEquals(2, carts.getCart(contactEmail, new MockHttpSession()).getTotalQuantity()
                + carts.getCart(secondEmail, new MockHttpSession()).getTotalQuantity());
    }
}
