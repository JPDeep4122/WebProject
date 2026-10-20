package com.dienmay.config;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.Set;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetailsService;

import com.dienmay.config.websocket.WebSocketAuthInterceptor;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.security.jwt.JwtUtils;

class WebSocketAuthInterceptorTests {
    private JwtUtils jwtUtils;
    private UserDetailsService userDetailsService;
    private UserRepository users;
    private WebSocketAuthInterceptor interceptor;
    private MessageChannel channel;

    @BeforeEach
    void setUp() {
        jwtUtils = mock(JwtUtils.class);
        userDetailsService = mock(UserDetailsService.class);
        users = mock(UserRepository.class);
        channel = mock(MessageChannel.class);
        interceptor = new WebSocketAuthInterceptor(jwtUtils, userDetailsService, users);
    }

    @Test
    void authenticatesValidJwtConnectFrame() {
        var details = org.springframework.security.core.userdetails.User
                .withUsername("customer@example.test").password("x")
                .authorities("ROLE_CUSTOMER").build();
        when(jwtUtils.validateJwtToken("valid-token")).thenReturn(true);
        when(jwtUtils.getUserNameFromJwtToken("valid-token"))
                .thenReturn("customer@example.test");
        when(userDetailsService.loadUserByUsername("customer@example.test"))
                .thenReturn(details);

        Message<?> result = interceptor.preSend(
                message(StompCommand.CONNECT, null, null, "Bearer valid-token"), channel);
        var accessor = StompHeaderAccessor.wrap(result);

        assertDoesNotThrow(() -> {
            if (accessor.getUser() == null) throw new AssertionError("Missing WebSocket principal");
        });
    }

    @Test
    void rejectsAnonymousConnection() {
        assertThrows(AccessDeniedException.class,
                () -> interceptor.preSend(message(StompCommand.CONNECT, null, null, null), channel));
    }

    @Test
    void staffCanSubscribeOnlyToAssignedBranch() {
        var principal = authentication("staff@example.test", "ROLE_STAFF");
        var branch = Branch.builder().id(9L).name("Branch 9").address("Test").build();
        var user = User.builder().email("staff@example.test").password("x")
                .fullName("Staff").active(true).branch(branch).build();
        when(users.findByEmail("staff@example.test")).thenReturn(Optional.of(user));

        assertDoesNotThrow(() -> interceptor.preSend(message(StompCommand.SUBSCRIBE,
                "/topic/branches/9/order-status", principal, null), channel));
        assertThrows(AccessDeniedException.class,
                () -> interceptor.preSend(message(StompCommand.SUBSCRIBE,
                        "/topic/branches/10/order-status", principal, null), channel));
        assertThrows(AccessDeniedException.class,
                () -> interceptor.preSend(message(StompCommand.SUBSCRIBE,
                        "/topic/branches/**", principal, null), channel));
    }

    @Test
    void onlyAdminCanSubscribeToAllOrdersTopic() {
        assertThrows(AccessDeniedException.class,
                () -> interceptor.preSend(message(StompCommand.SUBSCRIBE,
                        "/topic/admin/order-status",
                        authentication("staff@example.test", "ROLE_STAFF"), null), channel));
        assertDoesNotThrow(() -> interceptor.preSend(message(StompCommand.SUBSCRIBE,
                "/topic/admin/order-status",
                authentication("admin@example.test", "ROLE_ADMIN"), null), channel));
    }

    private UsernamePasswordAuthenticationToken authentication(String username, String role) {
        return new UsernamePasswordAuthenticationToken(username, null,
                Set.of(new SimpleGrantedAuthority(role)));
    }

    private Message<byte[]> message(StompCommand command, String destination,
            UsernamePasswordAuthenticationToken principal, String authorization) {
        var accessor = StompHeaderAccessor.create(command);
        if (destination != null) accessor.setDestination(destination);
        if (principal != null) accessor.setUser(principal);
        if (authorization != null) accessor.setNativeHeader("Authorization", authorization);
        accessor.setLeaveMutable(true);
        return MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());
    }
}
