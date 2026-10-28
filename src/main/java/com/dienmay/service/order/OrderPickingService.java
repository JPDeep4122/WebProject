package com.dienmay.service.order;

import java.util.Objects;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderPickingService {
    private final OrderRepository orders;
    private final UserRepository users;
    private final OrderStateMachine stateMachine;

    @Transactional
    public void startPicking(Long orderId, String email) {
        var actor = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không có quyền xử lý đơn."));
        boolean admin = actor.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
        boolean manager = actor.getRoles().stream().anyMatch(r -> "ROLE_BRANCH_MANAGER".equals(r.getName()));
        boolean staff = actor.getRoles().stream().anyMatch(r -> "ROLE_STAFF".equals(r.getName()));
        if (!actor.isActive() || actor.isBlocked() || (!admin && !manager && !staff)) {
            throw new AccessDeniedException("Không có quyền xử lý đơn.");
        }

        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (order.getBranch() == null) {
            throw new IllegalArgumentException("Đơn hàng chưa được gán chi nhánh.");
        }
        if (!admin && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), order.getBranch().getId()))) {
            throw new AccessDeniedException("Bạn chỉ được xử lý đơn của chi nhánh được gán.");
        }

        stateMachine.transition(order, OrderStatus.PROCESSING);
    }
}
