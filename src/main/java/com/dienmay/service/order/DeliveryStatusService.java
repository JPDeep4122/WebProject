package com.dienmay.service.order;

import java.time.LocalDateTime;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.DeliveryAssignmentRepository;
import com.dienmay.repository.order.OrderRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DeliveryStatusService {
    private final DeliveryAssignmentRepository assignments;
    private final OrderRepository orders;
    private final UserRepository users;
    private final OrderStateMachine orderStateMachine;

    @Transactional
    public void update(Long assignmentId, DeliveryStatus target,
            String failureReason, String shipperEmail) {
        var actor = users.findByEmail(shipperEmail)
                .orElseThrow(() -> new AccessDeniedException("Không có quyền cập nhật đơn giao."));
        boolean shipper = actor.getRoles().stream()
                .anyMatch(role -> "ROLE_SHIPPER".equals(role.getName()));
        if (!actor.isActive() || !shipper) {
            throw new AccessDeniedException("Không có quyền cập nhật đơn giao.");
        }

        var assignment = assignments.findForUpdate(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn giao."));
        if (assignment.getShipper() == null
                || !assignment.getShipper().getEmail().equalsIgnoreCase(actor.getEmail())) {
            throw new AccessDeniedException("Bạn chỉ được cập nhật đơn giao được phân công cho mình.");
        }
        if (!canTransition(assignment.getStatus(), target)) {
            throw new IllegalArgumentException("Không thể chuyển trạng thái giao hàng từ "
                    + assignment.getStatus() + " sang " + target + ".");
        }

        var order = orders.findForUpdate(assignment.getOrder().getId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        LocalDateTime now = LocalDateTime.now();
        switch (target) {
            case DELIVERING -> startDelivering(order.getStatus(), order, assignment, now);
            case DELIVERED_SUCCESS -> completeSuccessfully(order.getStatus(), order, assignment, now);
            case DELIVERED_FAILED -> completeWithFailure(order.getStatus(), assignment, failureReason, now);
            default -> throw new IllegalArgumentException("Trạng thái giao hàng không được hỗ trợ.");
        }
    }

    private boolean canTransition(DeliveryStatus current, DeliveryStatus target) {
        if (current == null || target == null) {
            return false;
        }
        return switch (current) {
            case ASSIGNED, PICKED_UP -> target == DeliveryStatus.DELIVERING;
            case DELIVERING -> target == DeliveryStatus.DELIVERED_SUCCESS
                    || target == DeliveryStatus.DELIVERED_FAILED;
            case DELIVERED_FAILED -> target == DeliveryStatus.DELIVERING;
            default -> false;
        };
    }

    private void startDelivering(OrderStatus orderStatus, Order order,
            DeliveryAssignment assignment, LocalDateTime now) {
        if (orderStatus == OrderStatus.PROCESSING) {
            orderStateMachine.transition(order, OrderStatus.SHIPPING);
        } else if (orderStatus != OrderStatus.SHIPPING) {
            throw new IllegalArgumentException("Đơn hàng chưa sẵn sàng để bắt đầu giao.");
        }
        assignment.setStatus(DeliveryStatus.DELIVERING);
        if (assignment.getPickedUpAt() == null) {
            assignment.setPickedUpAt(now);
        }
        assignment.setCompletedAt(null);
        assignment.setFailureReason(null);
    }

    private void completeSuccessfully(OrderStatus orderStatus, Order order,
            DeliveryAssignment assignment, LocalDateTime now) {
        if (orderStatus == OrderStatus.SHIPPING) {
            orderStateMachine.transition(order, OrderStatus.DELIVERED);
        } else if (orderStatus != OrderStatus.DELIVERED) {
            throw new IllegalArgumentException("Đơn hàng không ở trạng thái đang giao.");
        }
        assignment.setStatus(DeliveryStatus.DELIVERED_SUCCESS);
        assignment.setCompletedAt(now);
        assignment.setFailureReason(null);
    }

    private void completeWithFailure(OrderStatus orderStatus,
            DeliveryAssignment assignment,
            String failureReason, LocalDateTime now) {
        String reason = failureReason == null ? "" : failureReason.trim();
        if (orderStatus != OrderStatus.SHIPPING) {
            throw new IllegalArgumentException("Đơn hàng không ở trạng thái đang giao.");
        }
        if (reason.isEmpty()) {
            throw new IllegalArgumentException("Cần nhập lý do giao hàng thất bại.");
        }
        if (reason.length() > 1000) {
            throw new IllegalArgumentException("Lý do giao thất bại không được vượt quá 1000 ký tự.");
        }
        assignment.setStatus(DeliveryStatus.DELIVERED_FAILED);
        assignment.setCompletedAt(now);
        assignment.setFailureReason(reason);
    }
}
