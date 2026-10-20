package com.dienmay.service.order;

import java.time.LocalDateTime;
import java.util.EnumSet;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.order.ReturnRequestOverview;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderReturnRequest;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.order.ReturnRequestStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.order.OrderReturnRequestRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReturnRequestService {
    private static final String ADMIN_ROLE = "ROLE_ADMIN";
    private static final String STAFF_ROLE = "ROLE_STAFF";
    private static final EnumSet<ReturnRequestStatus> ACTIVE_STATUSES =
            EnumSet.of(ReturnRequestStatus.PENDING, ReturnRequestStatus.APPROVED);

    private final OrderReturnRequestRepository returnRequests;
    private final OrderRepository orders;
    private final UserRepository users;
    private final BranchRepository branches;
    private final OrderStateMachine stateMachine;

    @Transactional
    public OrderReturnRequest submit(String orderCode, String reason, String customerEmail) {
        User customer = requireActiveUser(customerEmail);
        Order order = orders.findByCodeForUpdate(cleanOrderCode(orderCode))
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (order.getUser() == null
                || !customer.getEmail().equalsIgnoreCase(order.getUser().getEmail())) {
            throw new AccessDeniedException("Bạn không có quyền yêu cầu trả đơn hàng này.");
        }
        if (order.getStatus() != OrderStatus.DELIVERED) {
            throw new IllegalArgumentException("Chỉ đơn đã giao mới có thể yêu cầu trả hàng.");
        }
        if (returnRequests.existsByOrderIdAndStatusIn(order.getId(), ACTIVE_STATUSES)) {
            throw new IllegalArgumentException("Đơn hàng đã có yêu cầu trả hàng đang được xử lý.");
        }
        String normalizedReason = normalizeReason(reason);
        return returnRequests.save(OrderReturnRequest.builder()
                .order(order)
                .requestedBy(customer)
                .reason(normalizedReason)
                .requestedRefundAmount(order.getFinalAmount())
                .status(ReturnRequestStatus.PENDING)
                .build());
    }

    @Transactional(readOnly = true)
    public Optional<OrderReturnRequest> findLatestForCustomer(Long orderId, String customerEmail) {
        Order order = orders.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (order.getUser() == null || customerEmail == null
                || !customerEmail.equalsIgnoreCase(order.getUser().getEmail())) {
            throw new AccessDeniedException("Bạn không có quyền xem yêu cầu trả hàng này.");
        }
        return returnRequests.findFirstByOrderIdOrderByRequestedAtDesc(orderId);
    }

    @Transactional(readOnly = true)
    public ReturnRequestOverview loadForManagement(String actorEmail, Long requestedBranchId,
            ReturnRequestStatus status, Pageable pageable) {
        User actor = requireManager(actorEmail);
        boolean admin = hasRole(actor, ADMIN_ROLE);
        Long effectiveBranchId = admin ? validateBranch(requestedBranchId)
                : actor.getBranch() == null ? null : actor.getBranch().getId();
        Page<OrderReturnRequest> result = !admin && effectiveBranchId == null
                ? Page.empty(pageable)
                : returnRequests.search(effectiveBranchId, status, pageable);
        List<com.dienmay.entity.branch.Branch> visibleBranches = admin
                ? branches.findByActiveTrue()
                : actor.getBranch() == null ? List.of() : List.of(actor.getBranch());
        return ReturnRequestOverview.builder()
                .requests(result)
                .branches(visibleBranches)
                .selectedBranchId(effectiveBranchId)
                .canChooseBranch(admin)
                .warning(!admin && effectiveBranchId == null
                        ? "Tài khoản nhân viên chưa được gán chi nhánh." : null)
                .build();
    }

    @Transactional
    public void review(Long requestId, ReturnRequestStatus decision,
            String reviewNote, String actorEmail) {
        if (decision != ReturnRequestStatus.APPROVED && decision != ReturnRequestStatus.REJECTED) {
            throw new IllegalArgumentException("Quyết định xét duyệt không hợp lệ.");
        }
        User actor = requireManager(actorEmail);
        OrderReturnRequest request = returnRequests.findByIdForUpdate(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu trả hàng."));
        if (request.getStatus() != ReturnRequestStatus.PENDING) {
            throw new IllegalArgumentException("Yêu cầu này đã được xét duyệt.");
        }
        authorizeBranch(actor, request.getOrder());
        String normalizedNote = normalizeReviewNote(reviewNote, decision);

        if (decision == ReturnRequestStatus.APPROVED) {
            Order order = orders.findForUpdate(request.getOrder().getId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
            if (order.getStatus() != OrderStatus.DELIVERED) {
                throw new IllegalArgumentException("Đơn hàng không còn ở trạng thái đã giao.");
            }
            stateMachine.transition(order, OrderStatus.RETURN_REQUESTED);
        }
        request.setStatus(decision);
        request.setReviewedBy(actor);
        request.setReviewedAt(LocalDateTime.now());
        request.setReviewNote(normalizedNote);
    }

    private User requireActiveUser(String email) {
        User user = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy tài khoản đang đăng nhập."));
        if (!user.isActive()) {
            throw new AccessDeniedException("Tài khoản đã bị khóa.");
        }
        return user;
    }

    private User requireManager(String email) {
        User actor = requireActiveUser(email);
        if (!hasRole(actor, ADMIN_ROLE) && !hasRole(actor, STAFF_ROLE)) {
            throw new AccessDeniedException("Tài khoản không có quyền xét duyệt trả hàng.");
        }
        return actor;
    }

    private void authorizeBranch(User actor, Order order) {
        if (hasRole(actor, ADMIN_ROLE)) {
            return;
        }
        if (actor.getBranch() == null || order.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), order.getBranch().getId())) {
            throw new AccessDeniedException("Bạn chỉ được xét duyệt yêu cầu của chi nhánh mình.");
        }
    }

    private Long validateBranch(Long branchId) {
        if (branchId != null && !branches.existsById(branchId)) {
            throw new IllegalArgumentException("Chi nhánh không tồn tại.");
        }
        return branchId;
    }

    private String normalizeReason(String reason) {
        if (reason == null || reason.trim().length() < 10) {
            throw new IllegalArgumentException("Lý do trả hàng phải có ít nhất 10 ký tự.");
        }
        if (reason.trim().length() > 1000) {
            throw new IllegalArgumentException("Lý do trả hàng tối đa 1000 ký tự.");
        }
        return reason.trim();
    }

    private String normalizeReviewNote(String note, ReturnRequestStatus decision) {
        String normalized = note == null ? "" : note.trim();
        if (decision == ReturnRequestStatus.REJECTED && normalized.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập lý do từ chối.");
        }
        if (normalized.length() > 500) {
            throw new IllegalArgumentException("Ghi chú xét duyệt tối đa 500 ký tự.");
        }
        return normalized.isBlank() ? null : normalized;
    }

    private String cleanOrderCode(String orderCode) {
        if (orderCode == null || orderCode.isBlank()) {
            throw new IllegalArgumentException("Mã đơn hàng không hợp lệ.");
        }
        return orderCode.trim();
    }

    private boolean hasRole(User user, String roleName) {
        return user.getRoles().stream().anyMatch(role -> roleName.equals(role.getName()));
    }
}
