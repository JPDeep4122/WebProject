package com.dienmay.config.websocket;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * Cấu hình WebSocket với STOMP Message Broker dành cho dự án dienmay-shop
 * Phân công: Thành viên 2 (TV2 - Đơn hàng & Vận chuyển) - Ngày 02/09
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final WebSocketAuthInterceptor webSocketAuthInterceptor;

    public WebSocketConfig(WebSocketAuthInterceptor webSocketAuthInterceptor) {
        this.webSocketAuthInterceptor = webSocketAuthInterceptor;
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Endpoint chính để Client kết nối WebSocket via STOMP (hỗ trợ SockJS fallback)
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS();

        // Endpoint WebSocket thuần (Raw WebSocket cho Mobile App / Postman test)
        registry.addEndpoint("/ws-raw")
                .setAllowedOriginPatterns("*");
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Prefix cho client đăng ký subscribe nhận thông báo từ server
        // /topic dùng cho broadcast (tất cả các client)
        // /queue dùng cho tin nhắn riêng (1-1 hoặc user cụ thể)
        registry.enableSimpleBroker("/topic", "/queue");

        // Prefix cho client gửi tin nhắn tới các phương thức @MessageMapping trong Controller
        registry.setApplicationDestinationPrefixes("/app");

        // Prefix hỗ trợ gửi tin nhắn đích danh cho từng User cụ thể (/user/{username}/queue/...)
        registry.setUserDestinationPrefix("/user");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        // Đăng ký Interceptor xác thực JWT Token từ header Authorization trong STOMP CONNECT frame
        registration.interceptors(webSocketAuthInterceptor);
    }
}
