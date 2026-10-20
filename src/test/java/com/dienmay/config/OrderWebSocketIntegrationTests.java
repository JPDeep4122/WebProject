package com.dienmay.config;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.messaging.converter.JacksonJsonMessageConverter;
import org.springframework.messaging.simp.stomp.StompFrameHandler;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.web.socket.WebSocketHttpHeaders;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import com.dienmay.dto.order.OrderStatusUpdate;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.RoleRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.service.impl.UserDetailsImpl;
import com.dienmay.service.order.OrderStatusChangedEvent;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, properties = {
        "spring.datasource.url=jdbc:h2:mem:order-websocket;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "dienmay.app.jwtSecret=integration-test-secret-key-that-is-long-enough-for-hmac-sha",
        "dienmay.app.jwtExpirationMs=60000"
})
class OrderWebSocketIntegrationTests {
    @LocalServerPort int port;
    @Autowired UserRepository users;
    @Autowired RoleRepository roles;
    @Autowired JwtUtils jwtUtils;
    @Autowired ApplicationEventPublisher events;

    private WebSocketStompClient client;
    private ThreadPoolTaskScheduler scheduler;

    @AfterEach
    void stopClient() {
        if (client != null) client.stop();
        if (scheduler != null) scheduler.destroy();
    }

    @Test
    void authenticatedCustomerReceivesCommittedOrderStatusPayload() throws Exception {
        String email = "ws-" + UUID.randomUUID() + "@example.test";
        Role role = roles.findByName("ROLE_CUSTOMER")
                .orElseGet(() -> roles.save(Role.builder().name("ROLE_CUSTOMER").build()));
        User user = users.save(User.builder().email(email).password("test")
                .fullName("WebSocket Customer").active(true).roles(Set.of(role)).build());
        var details = UserDetailsImpl.build(user);
        String token = jwtUtils.generateJwtToken(new UsernamePasswordAuthenticationToken(
                details, null, details.getAuthorities()));

        client = new WebSocketStompClient(new StandardWebSocketClient());
        client.setMessageConverter(new JacksonJsonMessageConverter());
        scheduler = new ThreadPoolTaskScheduler();
        scheduler.setThreadNamePrefix("order-websocket-test-");
        scheduler.initialize();
        client.setTaskScheduler(scheduler);
        var connectHeaders = new StompHeaders();
        connectHeaders.add("Authorization", "Bearer " + token);
        StompSession session = client.connectAsync(
                "ws://localhost:" + port + "/ws-raw",
                new WebSocketHttpHeaders(), connectHeaders, new StompSessionHandlerAdapter() {})
                .get(10, TimeUnit.SECONDS);

        var received = new LinkedBlockingQueue<Map<?, ?>>();
        session.subscribe("/user/queue/order-status", new StompFrameHandler() {
            @Override public Type getPayloadType(StompHeaders headers) { return Map.class; }
            @Override public void handleFrame(StompHeaders headers, Object payload) {
                received.offer((Map<?, ?>) payload);
            }
        });
        var update = new OrderStatusUpdate("ORD-WS-INTEGRATION", OrderStatus.PROCESSING,
                OrderStatus.SHIPPING, LocalDateTime.now());
        Map<?, ?> payload = null;
        for (int attempt = 0; attempt < 20 && payload == null; attempt++) {
            events.publishEvent(new OrderStatusChangedEvent(email, null, update));
            payload = received.poll(250, TimeUnit.MILLISECONDS);
        }

        assertNotNull(payload);
        assertEquals("ORD-WS-INTEGRATION", payload.get("orderCode"));
        assertEquals("PROCESSING", payload.get("previousStatus"));
        assertEquals("SHIPPING", payload.get("status"));
    }
}
