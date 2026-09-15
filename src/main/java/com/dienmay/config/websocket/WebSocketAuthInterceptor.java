package com.dienmay.config.websocket;

import com.dienmay.security.jwt.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * Interceptor kiểm tra JWT Token khi client thực hiện kết nối (STOMP CONNECT)
 * Phân công: Thành viên 2 (TV2)
 */
@Component
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private UserDetailsService userDetailsService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            List<String> authorization = accessor.getNativeHeader("Authorization");

            if (authorization != null && !authorization.isEmpty()) {
                String bearerToken = authorization.get(0);
                if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
                    String jwt = bearerToken.substring(7);
                    try {
                        if (jwtUtils.validateJwtToken(jwt)) {
                            String username = jwtUtils.getUserNameFromJwtToken(jwt);
                            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                            UsernamePasswordAuthenticationToken authentication =
                                    new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

                            accessor.setUser(authentication);
                        }
                    } catch (Exception e) {
                        System.err.println("[WebSocket Auth] Xác thực JWT thất bại: " + e.getMessage());
                    }
                }
            }
        }
        return message;
    }
}
