package com.dienmay.service.impl;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.service.order.OrderService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public List<Order> getOrdersByUser(String userEmail, OrderStatus status) {
        if (userEmail == null || userEmail.equalsIgnoreCase("anonymousUser")) {
            return Collections.emptyList();
        }

        User user = userRepository.findByEmail(userEmail).orElse(null);
        if (user == null) {
            return Collections.emptyList();
        }

        if (status != null) {
            return orderRepository.findByUserIdAndStatusOrderByCreatedAtDesc(user.getId(), status);
        } else {
            return orderRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Order getOrderDetail(String orderCode, String userEmail) {
        if (orderCode == null || orderCode.trim().isEmpty()) {
            throw new RuntimeException("Mã đơn hàng không hợp lệ!");
        }

        String cleanCode = orderCode.trim();
        Order order = orderRepository.findByOrderCode(cleanCode)
                .orElseGet(() -> orderRepository.findAll().stream()
                        .filter(o -> o.getOrderCode() != null && o.getOrderCode().replace("-", "").equalsIgnoreCase(cleanCode.replace("-", "")))
                        .findFirst()
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + cleanCode)));

        if (userEmail != null && !userEmail.equalsIgnoreCase("anonymousUser")) {
            if (order.getUser() != null && !userEmail.equalsIgnoreCase(order.getUser().getEmail())) {
                throw new RuntimeException("Bạn không có quyền truy cập đơn hàng này!");
            }
        }

        return order;
    }

    @Override
    @Transactional
    public boolean cancelOrder(String orderCode, String userEmail, String cancelReason) {
        Order order = getOrderDetail(orderCode, userEmail);

        if (order.getStatus() != OrderStatus.PENDING) {
            return false;
        }

        order.setStatus(OrderStatus.CANCELLED);
        String reasonText = (cancelReason != null && !cancelReason.trim().isEmpty())
                ? " [Lý do hủy: " + cancelReason.trim() + "]"
                : " [Khách hàng tự hủy đơn]";

        String currentNote = (order.getNote() != null) ? order.getNote() : "";
        order.setNote(currentNote + reasonText);
        order.setUpdatedAt(LocalDateTime.now());

        orderRepository.save(order);
        return true;
    }

    @Override
    @Transactional(readOnly = true)
    public Order trackOrder(String orderCode, String phone) {
        if (orderCode == null || phone == null) {
            return null;
        }

        String cleanCode = orderCode.trim();
        String cleanPhone = phone.trim();

        return orderRepository.findByOrderCodeAndRecipientPhone(cleanCode, cleanPhone)
                .orElseGet(() -> orderRepository.findAll().stream()
                        .filter(o -> o.getOrderCode() != null
                                && o.getOrderCode().replace("-", "").equalsIgnoreCase(cleanCode.replace("-", ""))
                                && o.getRecipientPhone() != null
                                && o.getRecipientPhone().replace(" ", "").equals(cleanPhone.replace(" ", "")))
                        .findFirst().orElse(null));
    }
}