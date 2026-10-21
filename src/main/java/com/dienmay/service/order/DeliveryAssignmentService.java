package com.dienmay.service.order;

import java.time.LocalDateTime;
import java.util.Objects;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.DeliveryAssignmentRepository;
import com.dienmay.repository.order.OrderRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DeliveryAssignmentService {
    private static final String SHIPPER_ROLE = "ROLE_SHIPPER";

    private final OrderRepository orders;
    private final UserRepository users;
    private final DeliveryAssignmentRepository assignments;

    @Transactional
    public void assign(Long orderId, Long shipperId, String actorEmail) {
        var actor = users.findByEmail(actorEmail)
                .orElseThrow(() -> new AccessDeniedException("Không có quyền phân công đơn hàng."));
        boolean admin = hasRole(actor, "ROLE_ADMIN");
        boolean staff = hasRole(actor, "ROLE_STAFF");
        if (!actor.isActive() || (!admin && !staff)) {
            throw new AccessDeniedException("Không có quyền phân công đơn hàng.");
        }

        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (order.getBranch() == null) {
            throw new IllegalArgumentException("Đơn hàng chưa được gán chi nhánh.");
        }
        if (order.getStatus() != OrderStatus.PROCESSING) {
            throw new IllegalArgumentException("Chỉ được phân công khi đơn đang được chuẩn bị.");
        }

        Long orderBranchId = order.getBranch().getId();
        if (!admin && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), orderBranchId))) {
            throw new AccessDeniedException("Bạn chỉ được phân công đơn của chi nhánh được gán.");
        }

        var shipper = users.findById(shipperId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên vận chuyển."));
        if (!shipper.isActive() || !hasRole(shipper, SHIPPER_ROLE)) {
            throw new IllegalArgumentException("Tài khoản được chọn không phải shipper đang hoạt động.");
        }
        if (shipper.getBranch() == null
                || !Objects.equals(shipper.getBranch().getId(), orderBranchId)) {
            throw new IllegalArgumentException("Shipper phải thuộc cùng chi nhánh với đơn hàng.");
        }

        var assignment = assignments.findByOrderId(orderId).orElseGet(() ->
                DeliveryAssignment.builder().order(order).build());
        assignment.setShipper(shipper);
        assignment.setStatus(DeliveryStatus.ASSIGNED);
        assignment.setAssignedAt(LocalDateTime.now());
        assignment.setPickedUpAt(null);
        assignment.setCompletedAt(null);
        assignment.setFailureReason(null);
        assignment.setProofImage(null);
        assignments.save(assignment);
        order.setDeliveryAssignment(assignment);
    }

    private boolean hasRole(com.dienmay.entity.auth.User user, String role) {
        return user.getRoles().stream().anyMatch(item -> role.equals(item.getName()));
    }
}
