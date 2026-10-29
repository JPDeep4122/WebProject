package com.dienmay.service.branch;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.branch.BranchInventoryOverview;
import com.dienmay.dto.branch.InventoryStockRequest;
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
    private final BranchRepository branches;
    private final UserRepository users;
    private final InventoryAdjustmentRepository adjustments;

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

        return BranchInventoryOverview.builder()
                .inventories(result)
                .branches(visibleBranches)
                .selectedBranchId(effectiveBranchId)
                .canChooseBranch(true)
                .canEditInventory(viewingOwnBranchOrAdmin)
                .warning(!admin && ownBranchId == null
                        ? "Tài khoản nhân sự chưa được gán chi nhánh."
                        : (!viewingOwnBranchOrAdmin
                                ? "Chế độ tra cứu tồn kho liên chi nhánh: Chỉ hiển thị số lượng khả dụng và thông tin liên hệ của chi nhánh khác."
                                : null))
                .build();
    }

    @Transactional
    @CacheEvict(cacheNames = {"customerHomeProducts", "customerProductDetails",
            "customerCatalogPages", "customerFilteredBrands"}, allEntries = true)
    public void updateStock(Long inventoryId, InventoryStockRequest request, String actorEmail) {
        User actor = requireActor(actorEmail);
        BranchInventory inventory = inventories.findByIdForUpdate(inventoryId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tồn kho sản phẩm."));
        if (!hasRole(actor, ADMIN_ROLE) && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), inventory.getBranch().getId()))) {
            throw new AccessDeniedException("Bạn chỉ được sửa tồn kho của chi nhánh mình.");
        }
        if (!inventory.getBranch().isActive()) {
            throw new IllegalArgumentException("Không thể sửa tồn kho của chi nhánh đã ngừng hoạt động.");
        }
        Integer newStock = request.getNewStock();
        String reason = request.getReason() == null ? "" : request.getReason().trim();
        if (newStock == null || newStock < 0 || reason.isBlank() || reason.length() > 500) {
            throw new IllegalArgumentException("Nhập tồn thực tế không âm và lý do từ 1 đến 500 ký tự.");
        }
        if (!Objects.equals(request.getExpectedStock(), inventory.getStockQuantity())) {
            throw new IllegalArgumentException("Tồn kho đã thay đổi. Vui lòng tải lại trang và kiểm tra trước khi lưu.");
        }
        long held = (long) (inventory.getReservedQuantity() == null ? 0 : inventory.getReservedQuantity())
                + (inventory.getTransferReservedQuantity() == null ? 0 : inventory.getTransferReservedQuantity())
                + (inventory.getQuarantineQuantity() == null ? 0 : inventory.getQuarantineQuantity());
        if (newStock < held) {
            throw new IllegalArgumentException("Tồn thực tế phải từ " + held
                    + " trở lên để đủ hàng đang giữ và hàng cách ly.");
        }
        int previousStock = inventory.getStockQuantity();
        if (newStock == previousStock) {
            throw new IllegalArgumentException("Tồn thực tế mới phải khác số tồn hiện tại.");
        }
        inventory.setStockQuantity(newStock);
        inventory.recalculateAvailable();
        inventories.save(inventory);
        adjustments.save(InventoryAdjustment.builder()
                .inventory(inventory).branch(inventory.getBranch()).product(inventory.getProduct())
                .adjustedBy(actor).previousStock(previousStock).newStock(newStock)
                .deltaQuantity(newStock - previousStock).reservedQuantity(inventory.getReservedQuantity())
                .reason(reason).status("APPROVED").reviewedBy(actor).reviewedAt(LocalDateTime.now())
                .reviewNote("Cập nhật tồn kho trực tiếp").build());
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

    private boolean hasRole(User user, String roleName) {
        return user.getRoles().stream().anyMatch(role -> roleName.equals(role.getName()));
    }
}
