package com.dienmay.service.impl;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.service.order.OrderService;
import com.dienmay.service.order.OrderStateMachine;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final OrderStateMachine stateMachine;

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
        if (userEmail == null || userEmail.isBlank()
                || userEmail.equalsIgnoreCase("anonymousUser")) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập.");
        }

        if (orderCode == null || orderCode.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng.");
        }

        String cleanCode = orderCode.trim();

        Order order = orderRepository.findByOrderCode(cleanCode)
                .orElseGet(() -> orderRepository.findAll().stream()
                        .filter(o -> o.getOrderCode() != null
                                && o.getOrderCode().replace("-", "")
                                        .equalsIgnoreCase(cleanCode.replace("-", "")))
                        .findFirst()
                        .orElseThrow(() -> new ResponseStatusException(
                                HttpStatus.NOT_FOUND,
                                "Không tìm thấy đơn hàng.")));

        if (order.getUser() == null
                || !userEmail.equalsIgnoreCase(order.getUser().getEmail())) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng.");
        }

        return order;
    }

    @Override
    @Transactional
    public boolean cancelOrder(String orderCode, String userEmail, String cancelReason) {
        Order order = orderRepository.findByCodeForUpdate(orderCode.trim())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (userEmail == null || order.getUser() == null
                || !userEmail.equalsIgnoreCase(order.getUser().getEmail())) {
            throw new org.springframework.security.access.AccessDeniedException("Bạn không có quyền hủy đơn hàng này.");
        }

        if (order.getStatus() != OrderStatus.PENDING) {
            return false;
        }

        stateMachine.transition(order, OrderStatus.CANCELLED);
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
    public Order trackOrder(String orderCode, String phone, String userEmail) {
        Order order;
        try {
            order = getOrderDetail(orderCode, userEmail);
        } catch (ResponseStatusException ex) {
            if (ex.getStatusCode() == HttpStatus.NOT_FOUND) return null;
            throw ex;
        }
        return phone != null && order.getRecipientPhone() != null
                && order.getRecipientPhone().replace(" ", "").equals(phone.trim().replace(" ", "")) ? order : null;
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Order> getOrdersForBranch(Long branchId, OrderStatus status, Pageable pageable) {
        if (branchId != null && status != null) {
            return orderRepository.findByBranchIdAndStatus(branchId, status, pageable);
        }
        if (branchId != null) {
            return orderRepository.findByBranchId(branchId, pageable);
        }
        if (status != null) {
            return orderRepository.findByStatus(status, pageable);
        }
        return orderRepository.findAll(pageable);
    }
}
