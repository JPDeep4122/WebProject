package com.dienmay.service.order;

import java.util.ArrayList;
import java.util.TreeMap;
import java.util.Objects;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.order.OrderRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderConfirmationService {
    private final OrderRepository orders;
    private final BranchInventoryRepository inventories;
    private final UserRepository users;
    private final OrderStateMachine stateMachine;

    @Transactional
    public void confirm(Long orderId, String email) {
        var actor = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không có quyền xác nhận đơn."));
        boolean admin = actor.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
        boolean manager = actor.getRoles().stream().anyMatch(r -> "ROLE_BRANCH_MANAGER".equals(r.getName()));
        boolean staff = actor.getRoles().stream().anyMatch(r -> "ROLE_STAFF".equals(r.getName()));
        if (!actor.isActive() || actor.isBlocked() || (!admin && !manager && !staff)) {
            throw new AccessDeniedException("Không có quyền xác nhận đơn.");
        }
        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (order.getBranch() == null) {
            throw new IllegalArgumentException("Đơn hàng chưa được gán chi nhánh.");
        }
        Long branchId = order.getBranch().getId();
        if (!admin && (actor.getBranch() == null || !Objects.equals(actor.getBranch().getId(), branchId))) {
            throw new AccessDeniedException("Bạn chỉ được xác nhận đơn của chi nhánh được gán.");
        }
        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalArgumentException("Chỉ có thể xác nhận đơn đang chờ xác nhận.");
        }
        if (order.getOrderItems().isEmpty()) {
            throw new IllegalArgumentException("Đơn hàng không có sản phẩm.");
        }
        var quantities = new TreeMap<Long, Integer>();
        for (var item : order.getOrderItems()) {
            if (item.getProduct() == null || item.getQuantity() == null || item.getQuantity() <= 0) {
                throw new IllegalArgumentException("Sản phẩm hoặc số lượng trong đơn không hợp lệ.");
            }
            quantities.merge(item.getProduct().getId(), item.getQuantity(), Math::addExact);
        }
        var locked = new ArrayList<BranchInventory>();
        for (var entry : quantities.entrySet()) {
            var inventory = inventories.findForUpdate(branchId, entry.getKey())
                    .orElseThrow(() -> new IllegalArgumentException("Chi nhánh chưa có tồn kho cho sản phẩm #" + entry.getKey()));
            int qty = entry.getValue();
            int stock = inventory.getStockQuantity();
            int reserved = inventory.getReservedQuantity();
            int consumedFromReserved = Math.min(reserved, qty);
            int remainingReserved = reserved - consumedFromReserved;
            if (stock - remainingReserved < qty) {
                throw new IllegalArgumentException("Không đủ hàng cho sản phẩm #" + entry.getKey()
                        + ". Khả dụng: " + Math.max(0, stock - remainingReserved) + ", cần: " + qty);
            }
            locked.add(inventory);
        }
        for (var inventory : locked) {
            int qty = quantities.get(inventory.getProduct().getId());
            int newReserved = Math.max(0, inventory.getReservedQuantity() - qty);
            int newStock = inventory.getStockQuantity() - qty;
            inventory.setReservedQuantity(newReserved);
            inventory.setStockQuantity(newStock);
            inventory.setAvailableQuantity(newStock - newReserved);
        }
        stateMachine.transition(order, OrderStatus.CONFIRMED);
    }
}