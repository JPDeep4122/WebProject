package com.dienmay.service;

public interface NotificationService {
    // Gửi broadcast (ví dụ thông báo có đơn mới đến màn hình Admin)
    void sendOrderNotification(String destination, Object payload);

    // Gửi riêng cho 1 user (ví dụ thông báo trạng thái đơn của user đó)
    void sendPrivateNotification(String username, String destination, Object payload);
}