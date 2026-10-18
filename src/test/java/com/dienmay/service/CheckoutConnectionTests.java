package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.interceptor.TransactionInterceptor;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;

import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.ShippingQuoteResponse;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.cart.Cart;
import com.dienmay.entity.cart.CartItem;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.product.Product;
import com.dienmay.repository.auth.*;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.cart.*;
import com.dienmay.repository.order.*;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.repository.promotion.PromotionRepository;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.checkout.ShippingService;
import com.dienmay.service.impl.CheckoutServiceImpl;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

class CheckoutConnectionTests {
    private HikariDataSource pool;
    private JdbcTemplate jdbc;
    private OrderItemRepository orderItems;
    private PaymentRepository payments;
    private CartItemRepository cartItems;
    private CheckoutService service;
    private PlaceOrderRequest request;

    @BeforeEach
    void setUp() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:h2:mem:" + UUID.randomUUID() + ";DB_CLOSE_DELAY=-1");
        config.setMaximumPoolSize(1);
        config.setMinimumIdle(0);
        config.setConnectionTimeout(250);
        pool = new HikariDataSource(config);
        jdbc = new JdbcTemplate(pool);
        jdbc.execute("create table placed_orders (code varchar(100))");
        DataSourceTransactionManager manager = new DataSourceTransactionManager(pool);

        CartRepository carts = mock(CartRepository.class);
        cartItems = mock(CartItemRepository.class);
        UserRepository users = mock(UserRepository.class);
        OrderRepository orders = mock(OrderRepository.class);
        orderItems = mock(OrderItemRepository.class);
        payments = mock(PaymentRepository.class);
        BranchRepository branches = mock(BranchRepository.class);
        ShippingService shipping = mock(ShippingService.class);
        when(shipping.quote(anyString(), anyString())).thenAnswer(invocation -> {
            assertFalse(TransactionSynchronizationManager.isActualTransactionActive());
            assertEquals(0, pool.getHikariPoolMXBean().getActiveConnections());
            assertEquals(1, jdbc.queryForObject("select 1", Integer.class));
            return ShippingQuoteResponse.builder().branchId(1L).shippingFee(BigDecimal.ZERO).build();
        });
        User user = User.builder().id(1L).email("customer@example.test").build();
        Cart cart = Cart.builder().user(user).build();
        Product product = Product.builder().id(1L).price(BigDecimal.valueOf(100000)).build();
        cart.getItems().add(CartItem.builder().cart(cart).product(product).quantity(1).selected(true).build());
        when(carts.findByUser_Email(user.getEmail())).thenReturn(Optional.of(cart));
        when(users.findByEmail(user.getEmail())).thenReturn(Optional.of(user));
        when(branches.findById(1L)).thenReturn(Optional.of(new Branch()));
        when(orders.save(any(Order.class))).thenAnswer(invocation -> {
            assertTrue(TransactionSynchronizationManager.isActualTransactionActive());
            Order order = invocation.getArgument(0);
            order.setId(1L);
            jdbc.update("insert into placed_orders (code) values (?)", order.getOrderCode());
            return order;
        });

        CheckoutServiceImpl target = new CheckoutServiceImpl(carts, cartItems, mock(AddressRepository.class),
                users, mock(RoleRepository.class), orders, orderItems, payments,
                mock(PromotionRepository.class), mock(ApplicationEventPublisher.class), shipping, branches,
                new TransactionTemplate(manager));
        ProxyFactory factory = new ProxyFactory(target);
        factory.addAdvice(new TransactionInterceptor(manager, new AnnotationTransactionAttributeSource()));
        service = (CheckoutService) factory.getProxy();
        request = new PlaceOrderRequest();
        request.setShippingAddress("123 Test Street");
        request.setProvince("Test Province");
    }

    @AfterEach
    void tearDown() {
        pool.close();
    }

    @Test
    void shippingDoesNotHoldConnectionAndOrderStillCommits() {
        Order order = service.placeOrder(request, "customer@example.test", new MockHttpSession());
        assertEquals(BigDecimal.valueOf(100000), order.getFinalAmount());
        assertEquals(1, jdbc.queryForObject("select count(*) from placed_orders", Integer.class));
        verify(payments).save(any());
        verify(cartItems).deleteAll(any());
        assertEquals(0, pool.getHikariPoolMXBean().getActiveConnections());
    }

    @Test
    void failureSavingOrderItemsRollsBackOrderAndPreservesCart() {
        when(orderItems.saveAll(any())).thenThrow(new IllegalStateException("Database failure"));
        assertThrows(IllegalStateException.class,
                () -> service.placeOrder(request, "customer@example.test", new MockHttpSession()));
        assertEquals(0, jdbc.queryForObject("select count(*) from placed_orders", Integer.class));
        verifyNoInteractions(payments);
        verify(cartItems, never()).deleteAll(any());
    }
}
