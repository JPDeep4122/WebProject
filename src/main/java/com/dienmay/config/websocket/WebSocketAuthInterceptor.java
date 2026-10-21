package com.dienmay.config.websocket;

import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.repository.auth.UserRepository;

import lombok.RequiredArgsConstructor;

import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Objects;
import java.util.regex.Pattern;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {
    private static final Pattern BRANCH_DESTINATION = Pattern.compile(
            "^/topic/branches/(\\d+)/order-status$");

    private final JwtUtils jwtUtils;
    private final UserDetailsService userDetailsService;
    private final UserRepository userRepository;

	@Override
	public Message<?> preSend(Message<?> message, MessageChannel channel) {
		StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor == null) {
            return message;
        }
        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            List<String> authorization = accessor.getNativeHeader("Authorization");

			if (authorization != null && !authorization.isEmpty()) {
				String bearerToken = authorization.get(0);
				if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
					String jwt = bearerToken.substring(7);
					try {
						if (jwtUtils.validateJwtToken(jwt)) {
							String username = jwtUtils.getUserNameFromJwtToken(jwt);
							UserDetails userDetails = userDetailsService.loadUserByUsername(username);

							UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
									userDetails, null, userDetails.getAuthorities());

                            accessor.setUser(authentication);
                        }
                    } catch (Exception e) {
                        System.err.println("[WebSocket Auth] Xác thực JWT thất bại: " + e.getMessage());
                    }
                }
            }
            if (accessor.getUser() == null) {
                throw new AccessDeniedException("Bạn cần đăng nhập để nhận cập nhật đơn hàng.");
            }
        }
        if (accessor.getUser() != null
                && accessor.getCommand() != StompCommand.DISCONNECT) {
            userDetailsService.loadUserByUsername(accessor.getUser().getName());
        }
        if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            authorizeOrderSubscription(accessor);
        }
        return message;
    }

    private void authorizeOrderSubscription(StompHeaderAccessor accessor) {
        String destination = accessor.getDestination();
        if (destination == null) {
            return;
        }
        Authentication authentication = accessor.getUser() instanceof Authentication auth ? auth : null;
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new AccessDeniedException("Bạn cần đăng nhập để nhận cập nhật đơn hàng.");
        }
        if (destination.startsWith("/topic/admin/")) {
            requireRole(authentication, "ROLE_ADMIN");
            return;
        }
        var matcher = BRANCH_DESTINATION.matcher(destination);
        if (!destination.startsWith("/topic/branches/")) {
            return;
        }
        if (!matcher.matches()) {
            throw new AccessDeniedException("Kênh cập nhật chi nhánh không hợp lệ.");
        }
        if (hasRole(authentication, "ROLE_ADMIN")) {
            return;
        }
        requireRole(authentication, "ROLE_STAFF");
        Long requestedBranchId = Long.valueOf(matcher.group(1));
        var user = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy tài khoản WebSocket."));
        if (user.getBranch() == null
                || !Objects.equals(user.getBranch().getId(), requestedBranchId)) {
            throw new AccessDeniedException("Bạn chỉ được nhận đơn của chi nhánh được gán.");
        }
    }

    private void requireRole(Authentication authentication, String role) {
        if (!hasRole(authentication, role)) {
            throw new AccessDeniedException("Không có quyền đăng ký kênh cập nhật đơn hàng.");
        }
    }

    private boolean hasRole(Authentication authentication, String role) {
        return authentication.getAuthorities().stream()
                .anyMatch(authority -> role.equals(authority.getAuthority()));
    }
}
