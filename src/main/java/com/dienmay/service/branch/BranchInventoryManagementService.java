package com.dienmay.service.branch;

import java.util.List;
import java.util.Objects;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.branch.BranchInventoryOverview;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.branch.InventoryAdjustment;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.branch.InventoryAdjustmentRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BranchInventoryManagementService {
    private static final String ADMIN_ROLE = "ROLE_ADMIN";
    private static final String STAFF_ROLE = "ROLE_STAFF";

    private final BranchInventoryRepository inventories;
    private final InventoryAdjustmentRepository adjustments;
    private final BranchRepository branches;
    private final UserRepository users;

    @Transactional(readOnly = true)
    public BranchInventoryOverview load(String actorEmail, Long requestedBranchId,
            String keyword, Pageable pageable) {
        User actor = requireActor(actorEmail);
        boolean admin = hasRole(actor, ADMIN_ROLE);
        Long effectiveBranchId = effectiveBranchId(actor, admin, requestedBranchId);
        String normalizedKeyword = keyword == null ? "" : keyword.trim();

        Page<BranchInventory> result = !admin && effectiveBranchId == null
                ? Page.empty(pageable)
                : inventories.search(effectiveBranchId, normalizedKeyword, pageable);
        List<com.dienmay.entity.branch.Branch> visibleBranches = admin
                ? branches.findByActiveTrue()
                : actor.getBranch() == null ? List.of() : List.of(actor.getBranch());
        List<InventoryAdjustment> recent;
        if (!admin && effectiveBranchId == null) {
            recent = List.of();
        } else if (effectiveBranchId == null) {
            recent = adjustments.findTop20ByOrderByCreatedAtDesc();
        } else {
            recent = adjustments.findTop20ByBranchIdOrderByCreatedAtDesc(effectiveBranchId);
        }

        return BranchInventoryOverview.builder()
                .inventories(result)
                .branches(visibleBranches)
                .recentAdjustments(recent)
                .selectedBranchId(effectiveBranchId)
                .canChooseBranch(admin)
                .warning(!admin && effectiveBranchId == null
                        ? "Tài khoản nhân viên chưa được gán chi nhánh." : null)
                .build();
    }

    @Transactional
    public void adjust(Long inventoryId, Integer newStock, String reason, String actorEmail) {
        User actor = requireActor(actorEmail);
        BranchInventory inventory = inventories.findByIdForUpdate(inventoryId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tồn kho cần điều chỉnh."));
        authorizeBranch(actor, inventory);
        validateAdjustment(inventory, newStock, reason);

        int previousStock = inventory.getStockQuantity();
        String normalizedReason = reason.trim();
        inventory.setStockQuantity(newStock);
        inventory.setAvailableQuantity(newStock - inventory.getReservedQuantity());
        inventories.save(inventory);
        adjustments.save(InventoryAdjustment.builder()
                .inventory(inventory)
                .branch(inventory.getBranch())
                .product(inventory.getProduct())
                .adjustedBy(actor)
                .previousStock(previousStock)
                .newStock(newStock)
                .reservedQuantity(inventory.getReservedQuantity())
                .reason(normalizedReason)
                .build());
    }

    private User requireActor(String email) {
        User actor = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy tài khoản đang đăng nhập."));
        if (!actor.isActive() || (!hasRole(actor, ADMIN_ROLE) && !hasRole(actor, STAFF_ROLE))) {
            throw new AccessDeniedException("Tài khoản không có quyền quản lý tồn kho.");
        }
        return actor;
    }

    private Long effectiveBranchId(User actor, boolean admin, Long requestedBranchId) {
        if (admin) {
            if (requestedBranchId != null && !branches.existsById(requestedBranchId)) {
                throw new IllegalArgumentException("Chi nhánh không tồn tại.");
            }
            return requestedBranchId;
        }
        return actor.getBranch() == null ? null : actor.getBranch().getId();
    }

    private void authorizeBranch(User actor, BranchInventory inventory) {
        if (hasRole(actor, ADMIN_ROLE)) {
            return;
        }
        if (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), inventory.getBranch().getId())) {
            throw new AccessDeniedException("Bạn chỉ được điều chỉnh tồn kho tại chi nhánh của mình.");
        }
    }

    private void validateAdjustment(BranchInventory inventory, Integer newStock, String reason) {
        if (newStock == null || newStock < 0) {
            throw new IllegalArgumentException("Tồn kho mới phải là số không âm.");
        }
        if (newStock < inventory.getReservedQuantity()) {
            throw new IllegalArgumentException("Tồn kho mới không được thấp hơn số lượng đang giữ chỗ ("
                    + inventory.getReservedQuantity() + ").");
        }
        if (newStock.equals(inventory.getStockQuantity())) {
            throw new IllegalArgumentException("Tồn kho mới không thay đổi so với hiện tại.");
        }
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập lý do điều chỉnh tồn kho.");
        }
        if (reason.trim().length() > 500) {
            throw new IllegalArgumentException("Lý do điều chỉnh tối đa 500 ký tự.");
        }
    }

    private boolean hasRole(User user, String roleName) {
        return user.getRoles().stream().anyMatch(role -> roleName.equals(role.getName()));
    }
}
