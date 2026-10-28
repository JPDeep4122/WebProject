package com.dienmay.service.notification;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.notification.NotificationItem;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.notification.UserNotification;
import com.dienmay.entity.promotion.Promotion;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.notification.UserNotificationRepository;
import com.dienmay.repository.promotion.PromotionRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CustomerNotificationService {
    private final UserRepository users;
    private final UserNotificationRepository notifications;
    private final PromotionRepository promotions;

    @Transactional(readOnly = true)
    public NotificationFeed listFor(String email) {
        User user = users.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
        List<NotificationItem> items = notifications.findByUser_IdOrderByCreatedAtDesc(user.getId(), PageRequest.of(0, 50))
                .stream().map(NotificationItem::from).toList();
        return new NotificationFeed(items, notifications.countByUser_IdAndReadAtIsNull(user.getId()));
    }

    @Transactional
    public boolean markRead(String email, Long notificationId) {
        User user = users.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
        return notifications.findByIdAndUser_Id(notificationId, user.getId()).map(notification -> {
            if (notification.getReadAt() == null) notification.setReadAt(LocalDateTime.now());
            return true;
        }).orElse(false);
    }

    @Transactional
    public int markAllRead(String email) {
        User user = users.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
        return notifications.markAllRead(user.getId(), LocalDateTime.now());
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordOrderStatus(String email, String orderCode, String status) {
        if (email == null || email.isBlank() || orderCode == null || orderCode.isBlank()) return;
        users.findByEmailIgnoreCase(email).ifPresent(user -> {
            String label = orderStatusLabel(status);
            UserNotification notification = new UserNotification();
            notification.setUser(user);
            notification.setType("ORDER_STATUS");
            notification.setTitle("Cập nhật đơn hàng " + orderCode);
            notification.setMessage("Đơn hàng " + orderCode + " hiện đã chuyển sang trạng thái: " + label + ".");
            notification.setReferenceType("ORDER");
            notification.setReferenceKey(orderCode);
            notifications.save(notification);
        });
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordRefundConfirmed(String email, String orderCode, java.math.BigDecimal amount,
            String branchName, String branchAddress, String refundMethod) {
        if (email == null || email.isBlank() || orderCode == null || orderCode.isBlank()) return;
        users.findByEmailIgnoreCase(email).ifPresent(user -> {
            boolean cashAtBranch = "CASH_AT_BRANCH".equalsIgnoreCase(refundMethod);
            String cleanBranch = branchName == null || branchName.isBlank()
                    ? "chi nhánh TECHSEVEN" : branchName;
            String amountText = amount == null ? "" : java.text.NumberFormat
                    .getIntegerInstance(java.util.Locale.forLanguageTag("vi-VN")).format(amount) + " ₫";
            String message = cashAtBranch
                    ? "Yêu cầu hoàn tiền cho đơn " + orderCode + " đã được xác nhận. Quý khách vui lòng nhận "
                            + amountText + " tại " + cleanBranch
                            + (branchAddress == null || branchAddress.isBlank() ? "" : ", " + branchAddress)
                            + ". Khi đến quầy, vui lòng cung cấp mã đơn và số điện thoại đặt hàng."
                    : "Chi nhánh " + cleanBranch + " đã xác nhận hoàn " + amountText
                            + " cho đơn " + orderCode + " theo hình thức chuyển khoản. Vui lòng xem chi tiết đơn hàng.";

            UserNotification notification = new UserNotification();
            notification.setUser(user);
            notification.setType("REFUND_CONFIRMED");
            notification.setTitle("Thông tin hoàn tiền đơn " + orderCode);
            notification.setMessage(message);
            notification.setReferenceType("ORDER");
            notification.setReferenceKey(orderCode);
            notifications.save(notification);
        });
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void announcePromotion(Long promotionId) {
        Promotion promotion = promotions.findById(promotionId).orElse(null);
        if (promotion == null) return;
        String message = "Voucher " + promotion.getCode() + " – " + promotion.getName()
                + " vừa được phát hành. Xem điều kiện và thời gian áp dụng trong Kho Voucher.";
        notifications.notifyAllActiveCustomers("Voucher mới từ TECHSEVEN", message,
                promotion.getId(), promotion.getCode());
    }

    private String orderStatusLabel(String status) {
        if (status == null) return "được cập nhật";
        return switch (status) {
            case "PENDING" -> "chờ xác nhận";
            case "CONFIRMED" -> "đã được xác nhận";
            case "PROCESSING" -> "đang được chuẩn bị";
            case "SHIPPING" -> "đang giao hàng";
            case "DELIVERED" -> "đã giao thành công";
            case "CANCELLED" -> "đã bị hủy";
            case "RETURN_REQUESTED" -> "đang chờ xử lý yêu cầu trả hàng";
            case "RETURNED" -> "đã hoàn trả";
            default -> status;
        };
    }

    public record NotificationFeed(List<NotificationItem> items, long unreadCount) {}
}
