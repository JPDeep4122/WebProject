package com.dienmay.service.order;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.TreeMap;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.order.OrderRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderFulfillmentService {
    private final OrderRepository orders;
    private final BranchInventoryRepository inventories;
    private final UserRepository users;
    private final OrderStateMachine stateMachine;

    @Transactional
    public void startShipping(Long orderId, String email) {
        transition(orderId, email, OrderStatus.SHIPPING, false, true);
    }

    @Transactional
    public void markDelivered(Long orderId, String email) {
        transition(orderId, email, OrderStatus.DELIVERED, false, false);
    }

    @Transactional
    public void cancel(Long orderId, String email) {
        transition(orderId, email, OrderStatus.CANCELLED, true, false);
    }

    @Transactional
    public void requestReturn(Long orderId, String email) {
        transition(orderId, email, OrderStatus.RETURN_REQUESTED, false, false);
    }

    @Transactional
    public void completeReturn(Long orderId, String email) {
        transition(orderId, email, OrderStatus.RETURNED, true, false);
    }

    private void transition(Long orderId, String email, OrderStatus target,
            boolean restoreStock, boolean requireAssignment) {
        var actor = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không có quyền xử lý đơn."));
        boolean admin = actor.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
        boolean staff = actor.getRoles().stream().anyMatch(r -> "ROLE_STAFF".equals(r.getName()));
        if (!actor.isActive() || (!admin && !staff)) {
            throw new AccessDeniedException("Không có quyền xử lý đơn.");
        }

        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (order.getBranch() == null) {
            throw new IllegalArgumentException("Đơn hàng chưa được gán chi nhánh.");
        }
        Long branchId = order.getBranch().getId();
        if (!admin && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), branchId))) {
            throw new AccessDeniedException("Bạn chỉ được xử lý đơn của chi nhánh được gán.");
        }
        if (!stateMachine.canTransition(order.getStatus(), target)) {
            throw new IllegalArgumentException(
                    "Không thể chuyển trạng thái đơn từ " + order.getStatus() + " sang " + target + ".");
        }
        if (requireAssignment && order.getDeliveryAssignment() == null) {
            throw new IllegalArgumentException("Cần phân công shipper trước khi bắt đầu giao hàng.");
        }

        if (restoreStock) {
            restoreInventory(order, branchId);
        }
        stateMachine.transition(order, target);
        syncDeliveryStatus(order, target);
    }

    private void syncDeliveryStatus(Order order, OrderStatus target) {
        var assignment = order.getDeliveryAssignment();
        if (assignment == null) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        if (target == OrderStatus.SHIPPING
                && (assignment.getStatus() == DeliveryStatus.ASSIGNED
                        || assignment.getStatus() == DeliveryStatus.PICKED_UP
                        || assignment.getStatus() == DeliveryStatus.DELIVERED_FAILED)) {
            assignment.setStatus(DeliveryStatus.DELIVERING);
            if (assignment.getPickedUpAt() == null) {
                assignment.setPickedUpAt(now);
            }
            assignment.setCompletedAt(null);
            assignment.setFailureReason(null);
        } else if (target == OrderStatus.DELIVERED) {
            assignment.setStatus(DeliveryStatus.DELIVERED_SUCCESS);
            assignment.setCompletedAt(now);
            assignment.setFailureReason(null);
        }
    }

    private void restoreInventory(Order order, Long branchId) {
        if (order.getOrderItems().isEmpty()) {
            throw new IllegalArgumentException("Đơn hàng không có sản phẩm để hoàn kho.");
        }
        var quantities = new TreeMap<Long, Integer>();
        for (var item : order.getOrderItems()) {
            if (item.getProduct() == null || item.getQuantity() == null || item.getQuantity() <= 0) {
                throw new IllegalArgumentException("Sản phẩm hoặc số lượng trong đơn không hợp lệ.");
            }
            quantities.merge(item.getProduct().getId(), item.getQuantity(), Math::addExact);
        }

        for (var entry : quantities.entrySet()) {
            var inventory = inventories.findForUpdate(branchId, entry.getKey())
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Chi nhánh chưa có tồn kho cho sản phẩm #" + entry.getKey()));
            int restoredStock = Math.addExact(inventory.getStockQuantity(), entry.getValue());
            inventory.setStockQuantity(restoredStock);
            inventory.setAvailableQuantity(restoredStock - inventory.getReservedQuantity());
        }
    }
}
