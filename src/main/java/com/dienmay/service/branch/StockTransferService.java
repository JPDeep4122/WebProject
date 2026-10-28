package com.dienmay.service.branch;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.branch.StockTransfer;
import com.dienmay.entity.product.Product;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.branch.StockTransferRepository;
import com.dienmay.repository.product.ProductRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StockTransferService {
    private static final String ADMIN_ROLE = "ROLE_ADMIN";
    private static final String MANAGER_ROLE = "ROLE_BRANCH_MANAGER";
    private static final String STAFF_ROLE = "ROLE_STAFF";

    private final StockTransferRepository transfers;
    private final BranchInventoryRepository inventories;
    private final BranchRepository branches;
    private final ProductRepository products;
    private final UserRepository users;

    @Transactional(readOnly = true)
    public List<StockTransfer> listVisibleTransfers(String actorEmail) {
        User actor = requireActor(actorEmail);
        if (hasRole(actor, ADMIN_ROLE)) {
            return transfers.findTop50ByOrderByRequestedAtDesc();
        }
        if (actor.getBranch() == null) {
            return List.of();
        }
        return transfers.findForBranch(actor.getBranch().getId());
    }

    @Transactional
    public StockTransfer createRequest(Long fromBranchId, Long toBranchId, Long productId,
            Integer quantity, String note, String actorEmail) {
        User actor = requireActor(actorEmail);
        boolean admin = hasRole(actor, ADMIN_ROLE);

        Long effectiveToBranchId = admin ? toBranchId
                : (actor.getBranch() == null ? null : actor.getBranch().getId());
        if (effectiveToBranchId == null || fromBranchId == null) {
            throw new IllegalArgumentException("Vui lòng chọn đầy đủ chi nhánh xuất và chi nhánh nhận.");
        }
        if (Objects.equals(fromBranchId, effectiveToBranchId)) {
            throw new IllegalArgumentException("Chi nhánh xuất và chi nhánh nhận phải khác nhau.");
        }
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Số lượng yêu cầu điều chuyển phải lớn hơn 0.");
        }

        Branch fromBranch = branches.findById(fromBranchId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh xuất."));
        Branch toBranch = branches.findById(effectiveToBranchId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh nhận."));
        Product product = products.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm."));

        String code = "TRF-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMMddHHmm"))
                + "-" + ThreadLocalRandom.current().nextInt(100, 999);

        return transfers.save(StockTransfer.builder()
                .transferCode(code)
                .fromBranch(fromBranch)
                .toBranch(toBranch)
                .product(product)
                .requestedQuantity(quantity)
                .status("REQUESTED")
                .requestedBy(actor)
                .note(note == null || note.isBlank() ? null : note.trim())
                .build());
    }

    @Transactional
    public void approveOrReject(Long transferId, String decision, String actorEmail) {
        User actor = requireManagerOrAdmin(actorEmail);
        boolean admin = hasRole(actor, ADMIN_ROLE);
        StockTransfer transfer = transfers.findByIdForUpdate(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển."));

        if (!"REQUESTED".equals(transfer.getStatus())) {
            throw new IllegalArgumentException("Phiếu điều chuyển không còn ở trạng thái chờ duyệt.");
        }
        if (!admin && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), transfer.getFromBranch().getId()))) {
            throw new AccessDeniedException("Chỉ Quản lý của Chi nhánh xuất hoặc Admin mới được duyệt phiếu điều chuyển.");
        }
        if (Objects.equals(transfer.getRequestedBy().getId(), actor.getId())) {
            throw new AccessDeniedException("Người tạo yêu cầu điều chuyển không được tự duyệt phiếu của mình.");
        }

        if ("REJECTED".equalsIgnoreCase(decision)) {
            transfer.setStatus("REJECTED");
            transfer.setApprovedBy(actor);
            transfer.setApprovedAt(LocalDateTime.now());
            return;
        }

        // APPROVED: Giữ hàng điều chuyển tại chi nhánh xuất (chưa trừ tồn thực tế)
        BranchInventory sourceInv = inventories.findForUpdate(
                transfer.getFromBranch().getId(), transfer.getProduct().getId())
                .orElseThrow(() -> new IllegalArgumentException("Chi nhánh xuất chưa có bản ghi tồn kho cho sản phẩm này."));

        int qty = transfer.getRequestedQuantity();
        if (sourceInv.getAvailableQuantity() < qty) {
            throw new IllegalArgumentException("Tồn khả dụng tại chi nhánh xuất ("
                    + sourceInv.getAvailableQuantity() + ") không đủ để duyệt điều chuyển (" + qty + ").");
        }

        int currentTransferRes = sourceInv.getTransferReservedQuantity() == null ? 0 : sourceInv.getTransferReservedQuantity();
        sourceInv.setTransferReservedQuantity(currentTransferRes + qty);
        sourceInv.recalculateAvailable();
        inventories.save(sourceInv);

        transfer.setApprovedQuantity(qty);
        transfer.setStatus("APPROVED");
        transfer.setApprovedBy(actor);
        transfer.setApprovedAt(LocalDateTime.now());
    }

    @Transactional
    public void confirmShip(Long transferId, String actorEmail) {
        User actor = requireManagerOrAdmin(actorEmail);
        boolean admin = hasRole(actor, ADMIN_ROLE);
        StockTransfer transfer = transfers.findByIdForUpdate(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển."));

        if (!"APPROVED".equals(transfer.getStatus())) {
            throw new IllegalArgumentException("Chỉ phiếu đã phê duyệt mới có thể xác nhận xuất kho.");
        }
        if (!admin && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), transfer.getFromBranch().getId()))) {
            throw new AccessDeniedException("Chỉ Quản lý của Chi nhánh xuất hoặc Admin mới được xác nhận xuất điều chuyển.");
        }

        BranchInventory sourceInv = inventories.findForUpdate(
                transfer.getFromBranch().getId(), transfer.getProduct().getId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tồn kho tại chi nhánh xuất."));

        int qty = transfer.getApprovedQuantity() != null ? transfer.getApprovedQuantity() : transfer.getRequestedQuantity();
        int currentTransferRes = sourceInv.getTransferReservedQuantity() == null ? 0 : sourceInv.getTransferReservedQuantity();
        sourceInv.setTransferReservedQuantity(Math.max(0, currentTransferRes - qty));
        sourceInv.setStockQuantity(sourceInv.getStockQuantity() - qty);
        sourceInv.recalculateAvailable();
        inventories.save(sourceInv);

        transfer.setShippedQuantity(qty);
        transfer.setStatus("IN_TRANSIT");
        transfer.setShippedBy(actor);
        transfer.setShippedAt(LocalDateTime.now());
    }

    @Transactional
    public void confirmReceive(Long transferId, Integer goodQty, Integer quarantineQty,
            String disputeNote, String actorEmail) {
        User actor = requireManagerOrAdmin(actorEmail);
        boolean admin = hasRole(actor, ADMIN_ROLE);
        StockTransfer transfer = transfers.findByIdForUpdate(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển."));

        if (!"IN_TRANSIT".equals(transfer.getStatus())) {
            throw new IllegalArgumentException("Chỉ phiếu đang vận chuyển (IN_TRANSIT) mới có thể xác nhận nhận hàng.");
        }
        if (!admin && (actor.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), transfer.getToBranch().getId()))) {
            throw new AccessDeniedException("Chỉ Quản lý của Chi nhánh nhận hoặc Admin mới được xác nhận nhận hàng điều chuyển.");
        }
        if (transfer.getShippedBy() != null && Objects.equals(transfer.getShippedBy().getId(), actor.getId()) && !admin) {
            throw new AccessDeniedException("Một người không được đóng vai cả bên xuất và bên nhận trên cùng phiếu.");
        }

        int safeGood = goodQty == null ? 0 : goodQty;
        int safeQuarantine = quarantineQty == null ? 0 : quarantineQty;
        int shipped = transfer.getShippedQuantity() != null ? transfer.getShippedQuantity() : transfer.getRequestedQuantity();
        if (safeGood < 0 || safeQuarantine < 0 || (safeGood + safeQuarantine) > shipped) {
            throw new IllegalArgumentException("Tổng số lượng nhận không hợp lệ hoặc vượt quá số lượng đã xuất (" + shipped + ").");
        }

        BranchInventory destInv = inventories.findForUpdate(
                transfer.getToBranch().getId(), transfer.getProduct().getId())
                .orElseGet(() -> BranchInventory.builder()
                        .branch(transfer.getToBranch())
                        .product(transfer.getProduct())
                        .stockQuantity(0)
                        .reservedQuantity(0)
                        .transferReservedQuantity(0)
                        .quarantineQuantity(0)
                        .availableQuantity(0)
                        .build());

        int totalReceivedPhysical = safeGood + safeQuarantine;
        destInv.setStockQuantity(destInv.getStockQuantity() + totalReceivedPhysical);
        int currentQuarantine = destInv.getQuarantineQuantity() == null ? 0 : destInv.getQuarantineQuantity();
        destInv.setQuarantineQuantity(currentQuarantine + safeQuarantine);
        destInv.recalculateAvailable();
        inventories.save(destInv);

        boolean hasDiscrepancy = (totalReceivedPhysical != shipped) || (safeQuarantine > 0);
        if (hasDiscrepancy && (disputeNote == null || disputeNote.isBlank())) {
            throw new IllegalArgumentException("Có chênh lệch số lượng hoặc hàng lỗi cách ly — vui lòng nhập ghi chú biên bản đối soát.");
        }

        transfer.setReceivedGoodQuantity(safeGood);
        transfer.setReceivedQuarantineQuantity(safeQuarantine);
        transfer.setStatus(hasDiscrepancy ? "DISPUTED" : "RECEIVED");
        transfer.setReceivedBy(actor);
        transfer.setReceivedAt(LocalDateTime.now());
        transfer.setDisputeNote(disputeNote == null || disputeNote.isBlank() ? null : disputeNote.trim());
    }

    private User requireActor(String email) {
        User actor = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Vui lòng đăng nhập."));
        if (!actor.isActive() || actor.isBlocked()
                || (!hasRole(actor, ADMIN_ROLE) && !hasRole(actor, MANAGER_ROLE) && !hasRole(actor, STAFF_ROLE))) {
            throw new AccessDeniedException("Bạn không có quyền truy cập phân hệ điều chuyển.");
        }
        return actor;
    }

    private User requireManagerOrAdmin(String email) {
        User actor = requireActor(email);
        if (!hasRole(actor, ADMIN_ROLE) && !hasRole(actor, MANAGER_ROLE)) {
            throw new AccessDeniedException("Chỉ Quản lý chi nhánh hoặc Admin tổng mới được phê duyệt/xuất/nhận điều chuyển.");
        }
        return actor;
    }

    private boolean hasRole(User user, String roleName) {
        return user.getRoles().stream().anyMatch(r -> roleName.equals(r.getName()));
    }
}