package com.dienmay.service.order;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.shipper.DeliveryFailureRequest;
import com.dienmay.dto.shipper.DeliverySuccessRequest;
import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.DeliveryAttempt;
import com.dienmay.entity.order.DeliveryCollectionMethod;
import com.dienmay.entity.order.DeliveryFailureCode;
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.DeliveryAssignmentRepository;
import com.dienmay.repository.order.DeliveryAttemptRepository;
import com.dienmay.repository.order.OrderRepository;

@Service
public class DeliveryStatusService {

    private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private final DeliveryAssignmentRepository assignments;
    private final OrderRepository orders;
    private final UserRepository users;
    private final OrderStateMachine orderStateMachine;
    private final DeliveryAttemptRepository attempts;

    @Autowired
    public DeliveryStatusService(
            DeliveryAssignmentRepository assignments,
            OrderRepository orders,
            UserRepository users,
            OrderStateMachine orderStateMachine,
            @Autowired(required = false) DeliveryAttemptRepository attempts) {
        this.assignments = assignments;
        this.orders = orders;
        this.users = users;
        this.orderStateMachine = orderStateMachine;
        this.attempts = attempts;
    }

    @Transactional(readOnly = true)
    public DeliveryAssignment getAssignmentForShipper(Long assignmentId, String shipperEmail) {
        var actor = getVerifiedShipper(shipperEmail);
        var assignment = assignments.findDetailedById(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn phân công."));
        boolean adminOrStaff = actor.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equals(r.getName()) || "ROLE_STAFF".equals(r.getName()));
        if (!adminOrStaff && (assignment.getShipper() == null
                || !assignment.getShipper().getEmail().equalsIgnoreCase(actor.getEmail()))) {
            throw new AccessDeniedException("Bạn không có quyền truy cập bản phân công này.");
        }
        return assignment;
    }
    
    @Transactional
    public void confirmPickup(Long assignmentId, String shipperEmail) {
        var actor = getVerifiedShipper(shipperEmail);
        Long orderId = getOrderIdFromAssignment(assignmentId);

        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        var assignment = assignments.findForUpdate(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn giao."));

        verifyOwnership(assignment, actor.getEmail());
        if (assignment.getStatus() != DeliveryStatus.ASSIGNED) {
            throw new IllegalArgumentException("Đơn giao không ở trạng thái chờ nhận hàng.");
        }

        assignment.setStatus(DeliveryStatus.PICKED_UP);
        assignment.setPickedUpAt(LocalDateTime.now(VN_ZONE));
    }

    @Transactional
    public void startDelivery(Long assignmentId, String shipperEmail) {
        var actor = getVerifiedShipper(shipperEmail);
        Long orderId = getOrderIdFromAssignment(assignmentId);

        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        var assignment = assignments.findForUpdate(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn giao."));

        verifyOwnership(assignment, actor.getEmail());

        if (assignment.getStatus() == DeliveryStatus.DELIVERED_FAILED
                && assignment.getFailureCode() != null
                && assignment.getFailureCode().isRequiresStaffReview()) {
            throw new IllegalArgumentException(
                    "Đơn hàng gặp sự cố '" + assignment.getFailureCode().getLabel()
                    + "' cần nhân viên chi nhánh kiểm tra trước khi giao lại.");
        }

        if (assignment.getStatus() != DeliveryStatus.ASSIGNED
                && assignment.getStatus() != DeliveryStatus.PICKED_UP
                && assignment.getStatus() != DeliveryStatus.DELIVERED_FAILED) {
            throw new IllegalArgumentException("Không thể bắt đầu giao từ trạng thái " + assignment.getStatus() + ".");
        }

        orderStateMachine.requirePaymentBeforeDelivery(order, OrderStatus.SHIPPING);
        if (order.getStatus() == OrderStatus.PROCESSING || order.getStatus() == OrderStatus.CONFIRMED) {
            orderStateMachine.transition(order, OrderStatus.SHIPPING);
        } else if (order.getStatus() != OrderStatus.SHIPPING) {
            throw new IllegalArgumentException("Đơn hàng chưa sẵn sàng để bắt đầu giao.");
        }

        Instant nowInstant = Instant.now();
        LocalDateTime nowLocal = LocalDateTime.ofInstant(nowInstant, VN_ZONE);

        assignment.setStatus(DeliveryStatus.DELIVERING);
        if (assignment.getPickedUpAt() == null) {
            assignment.setPickedUpAt(nowLocal);
        }
        assignment.setDeliveryStartedAt(nowInstant);
        assignment.setCompletedAt(null);
        assignment.setFailureCode(null);
        assignment.setFailureReason(null);

        if (attempts != null) {
            int nextAttemptNo = attempts.findMaxAttemptNoByAssignmentId(assignment.getId()) + 1;
            DeliveryAttempt attempt = DeliveryAttempt.builder()
                    .assignment(assignment)
                    .attemptNo(nextAttemptNo)
                    .shipper(assignment.getShipper())
                    .startedAt(nowInstant)
                    .status(DeliveryStatus.DELIVERING)
                    .build();
            attempts.save(attempt);
            assignment.getAttempts().add(attempt);
        }
    }

    @Transactional
    public void completeSuccess(
            Long assignmentId,
            DeliverySuccessRequest request,
            String proofPublicId,
            String shipperEmail) {

        if (proofPublicId == null || proofPublicId.isBlank()) {
            throw new IllegalArgumentException("Thiếu ảnh minh chứng bàn giao hàng hợp lệ.");
        }

        var actor = getVerifiedShipper(shipperEmail);
        Long orderId = getOrderIdFromAssignment(assignmentId);

        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        var assignment = assignments.findForUpdate(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn giao."));

        verifyOwnership(assignment, actor.getEmail());

        if (assignment.getStatus() != DeliveryStatus.DELIVERING) {
            throw new IllegalArgumentException("Chỉ được hoàn tất khi đơn đang ở trạng thái giao.");
        }
        if (order.getStatus() != OrderStatus.SHIPPING) {
            throw new IllegalArgumentException("Đơn hàng không ở trạng thái đang giao.");
        }

        Payment payment = order.getPayment();
        if (payment == null || payment.getPaymentMethod() == null) {
            throw new IllegalArgumentException("Đơn hàng chưa có thông tin thanh toán hợp lệ.");
        }

        // Tách biệt rõ ràng xử lý COD vs VNPay
        DeliveryCollectionMethod resolvedMethod;
        BigDecimal resolvedAmount;

        if (payment.getPaymentMethod() == PaymentMethod.COD) {
            if (request.getCollectionMethod() != DeliveryCollectionMethod.CASH) {
                throw new IllegalArgumentException("Đơn COD chỉ hỗ trợ thu tiền mặt (CASH).");
            }
            if (request.getCollectedAmount() == null
                    || order.getFinalAmount() == null
                    || request.getCollectedAmount().compareTo(order.getFinalAmount()) != 0) {
                throw new IllegalArgumentException("Số tiền thực thu phải khớp đúng số tiền cần thu của đơn.");
            }
            if (!request.isCodConfirmed()) {
                throw new IllegalArgumentException("Vui lòng tích xác nhận đã thu đủ tiền COD.");
            }
            resolvedMethod = DeliveryCollectionMethod.CASH;
            resolvedAmount = request.getCollectedAmount();
        } else if (payment.getPaymentMethod() == PaymentMethod.VNPAY) {
            if (payment.getPaymentStatus() != PaymentStatus.SUCCESS) {
                throw new IllegalArgumentException("Đơn VNPay chưa thanh toán thành công, không thể bàn giao.");
            }
            resolvedMethod = DeliveryCollectionMethod.PREPAID;
            resolvedAmount = BigDecimal.ZERO;
        } else {
            throw new IllegalArgumentException("Phương thức thanh toán không được hỗ trợ.");
        }

        Instant nowInstant = Instant.now();
        LocalDateTime nowLocal = LocalDateTime.ofInstant(nowInstant, VN_ZONE);

        // Chuyển trạng thái Order sang DELIVERED
        orderStateMachine.transition(order, OrderStatus.DELIVERED);

        // Nếu là COD: sau khi đủ 5 điều kiện mới chuyển payment sang SUCCESS
        if (payment.getPaymentMethod() == PaymentMethod.COD) {
            orderStateMachine.confirmCodPaymentCollected(order, nowLocal);
        }

        assignment.setStatus(DeliveryStatus.DELIVERED_SUCCESS);
        assignment.setCompletedAt(nowLocal);
        assignment.setFailureCode(null);
        assignment.setFailureReason(null);
        assignment.setReceivedBy(request.getReceivedBy().trim());
        assignment.setCollectionMethod(resolvedMethod);
        assignment.setCollectedAmount(resolvedAmount);
        assignment.setProofPublicId(proofPublicId);
        assignment.setCompletionNote(request.getCompletionNote() != null ? request.getCompletionNote().trim() : null);

        if (attempts != null) {
            DeliveryAttempt currentAttempt = attempts
                    .findTopByAssignmentIdOrderByAttemptNoDesc(assignment.getId())
                    .filter(a -> a.getStatus() == DeliveryStatus.DELIVERING && a.getCompletedAt() == null)
                    .orElseGet(() -> {
                        int nextAttemptNo = attempts.findMaxAttemptNoByAssignmentId(assignment.getId()) + 1;
                        return DeliveryAttempt.builder()
                                .assignment(assignment)
                                .attemptNo(nextAttemptNo)
                                .shipper(assignment.getShipper())
                                .startedAt(nowInstant)
                                .build();
                    });

            currentAttempt.setCompletedAt(nowInstant);
            currentAttempt.setStatus(DeliveryStatus.DELIVERED_SUCCESS);
            currentAttempt.setReceivedBy(request.getReceivedBy().trim());
            currentAttempt.setCollectionMethod(resolvedMethod);
            currentAttempt.setCollectedAmount(resolvedAmount);
            currentAttempt.setProofPublicId(proofPublicId);
            currentAttempt.setCompletionNote(assignment.getCompletionNote());
            attempts.save(currentAttempt);
        }
    }

    @Transactional
    public void completeFailure(
            Long assignmentId,
            DeliveryFailureRequest request,
            String optionalProofPublicId,
            String shipperEmail) {

        if (request.getFailureCode() == null) {
            throw new IllegalArgumentException("Vui lòng chọn mã lý do giao thất bại.");
        }
        String reason = request.getFailureReason() == null ? "" : request.getFailureReason().trim();
        if (reason.length() < 10 || reason.length() > 1000) {
            throw new IllegalArgumentException("Chi tiết lý do giao thất bại phải từ 10 đến 1.000 ký tự.");
        }

        var actor = getVerifiedShipper(shipperEmail);
        Long orderId = getOrderIdFromAssignment(assignmentId);

        var order = orders.findForUpdate(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        var assignment = assignments.findForUpdate(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn giao."));

        verifyOwnership(assignment, actor.getEmail());

        if (assignment.getStatus() != DeliveryStatus.DELIVERING) {
            throw new IllegalArgumentException("Chỉ được báo thất bại khi đơn đang ở trạng thái giao.");
        }
        if (order.getStatus() != OrderStatus.SHIPPING) {
            throw new IllegalArgumentException("Đơn hàng không ở trạng thái đang giao.");
        }

        if (request.getFailureCode() == DeliveryFailureCode.INSUFFICIENT_COD_PAYMENT
                && order.getPayment() != null
                && order.getPayment().getPaymentMethod() == PaymentMethod.VNPAY) {
            throw new IllegalArgumentException("Lý do 'Khách không thanh toán đủ COD' không áp dụng cho đơn VNPay.");
        }

        Instant nowInstant = Instant.now();
        LocalDateTime nowLocal = LocalDateTime.ofInstant(nowInstant, VN_ZONE);

        assignment.setStatus(DeliveryStatus.DELIVERED_FAILED);
        assignment.setCompletedAt(nowLocal);
        assignment.setFailureCode(request.getFailureCode());
        assignment.setFailureReason(reason);
        if (optionalProofPublicId != null) {
            assignment.setProofPublicId(optionalProofPublicId);
        }

        if (attempts != null) {
            DeliveryAttempt currentAttempt = attempts
                    .findTopByAssignmentIdOrderByAttemptNoDesc(assignment.getId())
                    .filter(a -> a.getCompletedAt() == null)
                    .orElseGet(() -> {
                        int nextAttemptNo = attempts.findMaxAttemptNoByAssignmentId(assignment.getId()) + 1;
                        return DeliveryAttempt.builder()
                                .assignment(assignment)
                                .attemptNo(nextAttemptNo)
                                .shipper(assignment.getShipper())
                                .startedAt(nowInstant)
                                .build();
                    });

            currentAttempt.setCompletedAt(nowInstant);
            currentAttempt.setStatus(DeliveryStatus.DELIVERED_FAILED);
            currentAttempt.setFailureCode(request.getFailureCode());
            currentAttempt.setFailureDetails(reason);
            if (optionalProofPublicId != null) {
                currentAttempt.setProofPublicId(optionalProofPublicId);
            }
            attempts.save(currentAttempt);
        }
    }

    @Transactional
    public void update(Long assignmentId, DeliveryStatus target, String failureReason, String shipperEmail) {
        if (target == DeliveryStatus.DELIVERING) {
            startDelivery(assignmentId, shipperEmail);
        } else if (target == DeliveryStatus.DELIVERED_FAILED) {
            completeFailure(assignmentId,
                    new DeliveryFailureRequest(DeliveryFailureCode.OTHER,
                            failureReason != null && failureReason.length() >= 10 ? failureReason : "Khách không nghe máy khi giao hàng"),
                    null, shipperEmail);
        } else if (target == DeliveryStatus.DELIVERED_SUCCESS) {
            var asg = assignments.findById(assignmentId).orElseThrow();
            boolean cod = asg.getOrder().getPayment() != null && asg.getOrder().getPayment().getPaymentMethod() == PaymentMethod.COD;
            completeSuccess(assignmentId,
                    new DeliverySuccessRequest(asg.getOrder().getRecipientName(),
                            cod ? DeliveryCollectionMethod.CASH : DeliveryCollectionMethod.PREPAID,
                            cod ? asg.getOrder().getFinalAmount() : BigDecimal.ZERO,
                            true, null),
                    "legacy_test_proof", shipperEmail);
        }
    }

    private Long getOrderIdFromAssignment(Long assignmentId) {
        return assignments.findById(assignmentId)
                .map(a -> a.getOrder().getId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn phân công #" + assignmentId));
    }

    private com.dienmay.entity.auth.User getVerifiedShipper(String email) {
        var actor = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Không tìm thấy tài khoản."));
        boolean shipper = actor.getRoles().stream().anyMatch(r -> "ROLE_SHIPPER".equals(r.getName()));
        boolean admin = actor.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
        if (!actor.isActive() || (!shipper && !admin)) {
            throw new AccessDeniedException("Không có quyền thực hiện thao tác vận chuyển.");
        }
        return actor;
    }

    private void verifyOwnership(DeliveryAssignment assignment, String actorEmail) {
        if (assignment.getShipper() == null || !assignment.getShipper().getEmail().equalsIgnoreCase(actorEmail)) {
            throw new AccessDeniedException("Bạn chỉ được cập nhật đơn giao được phân công cho mình.");
        }
    }
}