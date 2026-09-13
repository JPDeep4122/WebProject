package com.dienmay.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // Kích hoạt In-Memory Message Broker với các prefix:
        // /topic: thường dùng cho broadcast/public (ví dụ đơn hàng mới tới tất cả admin/chi nhánh)
        // /queue: thường dùng cho tin nhắn riêng (1-1 / user cụ thể)
        config.enableSimpleBroker("/topic", "/queue");

        // Prefix cho các message client gửi lên server để controller xử lý qua @MessageMapping
        config.setApplicationDestinationPrefixes("/app");

        // Prefix định tuyến cho tin nhắn gửi đích danh user (dùng SimpMessagingTemplate.convertAndSendToUser)
        config.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Đăng ký endpoint STOMP client dùng để bắt tay kết nối (Handshake)
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*") // Cho phép cross-origin nếu cần
                .withSockJS();                 // Fallback bằng SockJS nếu trình duyệt không hỗ trợ WebSocket thuần
    }
}