package com.dienmay.repository.notification;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.dienmay.entity.notification.UserNotification;

public interface UserNotificationRepository extends JpaRepository<UserNotification, Long> {
    List<UserNotification> findByUser_IdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    long countByUser_IdAndReadAtIsNull(Long userId);

    Optional<UserNotification> findByIdAndUser_Id(Long id, Long userId);

    @Modifying
    @Query("update UserNotification n set n.readAt = :readAt where n.user.id = :userId and n.readAt is null")
    int markAllRead(@Param("userId") Long userId, @Param("readAt") LocalDateTime readAt);

    @Modifying
    @Query(value = """
            INSERT INTO user_notifications (user_id, type, title, message, reference_type, reference_id,
                                            reference_key, created_at)
            SELECT DISTINCT u.id, 'VOUCHER', :title, :message, 'PROMOTION', :promotionId, :code, CURRENT_TIMESTAMP
            FROM users u
            JOIN user_roles ur ON ur.user_id = u.id
            JOIN roles r ON r.id = ur.role_id
            WHERE r.name = 'ROLE_CUSTOMER' AND u.is_active = TRUE AND u.is_blocked = FALSE
            """, nativeQuery = true)
    int notifyAllActiveCustomers(@Param("title") String title, @Param("message") String message,
                                 @Param("promotionId") Long promotionId, @Param("code") String code);
}
