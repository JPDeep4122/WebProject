package com.dienmay.dto.notification;

import java.time.LocalDateTime;

import com.dienmay.entity.notification.UserNotification;

public record NotificationItem(
        Long id,
        String type,
        String title,
        String message,
        String referenceType,
        Long referenceId,
        String referenceKey,
        LocalDateTime createdAt,
        boolean read) {

    public static NotificationItem from(UserNotification notification) {
        return new NotificationItem(notification.getId(), notification.getType(), notification.getTitle(),
                notification.getMessage(), notification.getReferenceType(), notification.getReferenceId(),
                notification.getReferenceKey(), notification.getCreatedAt(), notification.getReadAt() != null);
    }
}
