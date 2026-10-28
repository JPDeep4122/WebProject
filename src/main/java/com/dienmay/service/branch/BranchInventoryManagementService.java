package com.dienmay.service.branch;

import java.time.LocalDateTime;
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
    private static final String MANAGER_ROLE = "ROLE_BRANCH_MANAGER";
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
        Long ownBranchId = actor.getBranch() == null ? null : actor.getBranch().getId();
        Long effectiveBranchId = effectiveBranchId(actor, admin, requestedBranchId);
        String normalizedKeyword = keyword == null ? "" : keyword.trim();

        boolean viewingOwnBranchOrAdmin = admin
                || (ownBranchId != null && Objects.equals(ownBranchId, effectiveBranchId));

        Page<BranchInventory> result = (!admin && ownBranchId == null)
                ? Page.empty(pageable)
                : inventories.search(effectiveBranchId, normalizedKeyword, pageable);
        List<com.dienmay.entity.branch.Branch> visibleBranches = branches.findByActiveTrue();

        List<InventoryAdjustment> recent;
        if (!viewingOwnBranchOrAdmin) {
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
                .canChooseBranch(true)
                .warning(!admin && ownBranchId == null
                        ? "Tài khoản nhân sự chưa được gán chi nhánh."
                        : (!viewingOwnBranchOrAdmin
                                ? "Chế độ tra cứu tồn kho liên chi nhánh: Chỉ hiển thị số lượng khả dụng và thông tin liên hệ của chi nhánh khác."
                                : null))
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
        int delta = newStock - previousStock;
        String normalizedReason = reason.trim();

        adjustments.save(InventoryAdjustment.builder()
                .inventory(inventory)
                .branch(inventory.getBranch())
                .product(inventory.getProduct())
                .adjustedBy(actor)
                .previousStock(previousStock)
                .newStock(newStock)
                .deltaQuantity(delta)
                .reservedQuantity(inventory.getReservedQuantity())
                .reason(normalizedReason)
                .status("PENDING")
                .build());
    }

    @Transactional
    public void reviewAdjustment(Long adjustmentId, String decision, String reviewNote, String actorEmail) {
        User actor = requireActor(actorEmail);
        boolean admin = hasRole(actor, ADMIN_ROLE);
        boolean manager = hasRole(actor, MANAGER_ROLE);
        if (!admin && !manager) {
            throw new AccessDeniedException("Nhân viên không có quyền phê duyệt phiếu điều chỉnh kho.");
        }

        InventoryAdjustment adjustment = adjustments.findByIdForUpdate(adjustmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chỉnh kho."));
        if (!"PENDING".equals(adjustment.getStatus())) {
            throw new IllegalArgumentException("Phiếu điều chỉnh kho này đã được xử lý trước đó.");
        }

        if (!admin && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), adjustment.getBranch().getId()))) {
            throw new AccessDeniedException("Bạn chỉ được phê duyệt phiếu điều chỉnh thuộc chi nhánh của mình.");
        }

        User creator = adjustment.getAdjustedBy();
        if (creator != null && Objects.equals(creator.getId(), actor.getId())) {
            throw new AccessDeniedException("Nguyên tắc kiểm soát nội bộ: Người tạo phiếu không được tự phê duyệt phiếu của chính mình.");
        }
        if (creator != null && hasRole(creator, MANAGER_ROLE) && !admin) {
            throw new AccessDeniedException("Phiếu điều chỉnh do Quản lý chi nhánh tạo phải do Admin tổng phê duyệt.");
        }

        String normalizedDecision = decision == null ? "" : decision.trim().toUpperCase();
        if (!"APPROVED".equals(normalizedDecision) && !"REJECTED".equals(normalizedDecision)) {
            throw new IllegalArgumentException("Quyết định phê duyệt không hợp lệ.");
        }

        if ("APPROVED".equals(normalizedDecision)) {
            BranchInventory inventory = inventories.findByIdForUpdate(adjustment.getInventory().getId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bản ghi tồn kho."));
            int currentStock = inventory.getStockQuantity();
            int delta = adjustment.getDeltaQuantity() != null
                    ? adjustment.getDeltaQuantity()
                    : (adjustment.getNewStock() - adjustment.getPreviousStock());
            int updatedStock = currentStock + delta;
            int minRequired = inventory.getTotalHeldAndQuarantine();
            if (updatedStock < minRequired) {
                throw new IllegalArgumentException("Không thể duyệt: Tồn thực tế sau điều chỉnh (" + updatedStock
                        + ") thấp hơn tổng hàng giữ và cách ly hiện tại (" + minRequired + ").");
            }
            adjustment.setPreviousStock(currentStock);
            adjustment.setNewStock(updatedStock);
            inventory.setStockQuantity(updatedStock);
            inventory.recalculateAvailable();
            inventories.save(inventory);
        }

        adjustment.setStatus(normalizedDecision);
        adjustment.setReviewedBy(actor);
        adjustment.setReviewedAt(LocalDateTime.now());
        adjustment.setReviewNote(reviewNote == null || reviewNote.isBlank() ? null : reviewNote.trim());
        adjustments.save(adjustment);
    }

    private Long effectiveBranchId(User actor, boolean admin, Long requestedBranchId) {
        if (requestedBranchId != null) {
            if (!branches.existsById(requestedBranchId)) {
                throw new IllegalArgumentException("Chi nhánh không tồn tại.");
            }
            return requestedBranchId;
        }
        if (admin) {
            return null;
        }
        return actor.getBranch() == null ? null : actor.getBranch().getId();
    }

    private User requireActor(String email) {
        User actor = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy tài khoản đang đăng nhập."));
        if (!actor.isActive() || actor.isBlocked()
                || (!hasRole(actor, ADMIN_ROLE) && !hasRole(actor, MANAGER_ROLE) && !hasRole(actor, STAFF_ROLE))) {
            throw new AccessDeniedException("Tài khoản không có quyền quản lý tồn kho.");
        }
        return actor;
    }

    private void authorizeBranch(User actor, BranchInventory inventory) {
        if (hasRole(actor, ADMIN_ROLE)) {
            return;
        }
        if (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), inventory.getBranch().getId())) {
            throw new AccessDeniedException("Bạn chỉ được lập yêu cầu điều chỉnh tồn kho tại chi nhánh của mình.");
        }
    }

    private void validateAdjustment(BranchInventory inventory, Integer newStock, String reason) {
        if (newStock == null || newStock < 0) {
            throw new IllegalArgumentException("Tồn kho mới phải là số không âm.");
        }
        int minRequired = inventory.getTotalHeldAndQuarantine();
        if (newStock < minRequired) {
            throw new IllegalArgumentException("Tồn kho mới không được thấp hơn tổng lượng đang giữ và cách ly ("
                    + minRequired + ").");
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