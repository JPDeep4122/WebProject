package com.dienmay.controller.admin;

import java.security.Principal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.dto.order.OrderStatusSnapshot;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.service.order.OrderService;
import com.dienmay.service.order.OrderStatusWebSocketNotifier;
import com.dienmay.service.order.DeliveryProofStorageService;

import jakarta.servlet.http.HttpServletRequest;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
public class AdminOrderController {

    private final OrderService orderService;
    private final UserRepository userRepository;
    private final BranchRepository branchRepository;
    private final OrderRepository orderRepository;
    private final com.dienmay.service.order.OrderConfirmationService confirmationService;
    private final com.dienmay.service.order.OrderPickingService pickingService;
    private final com.dienmay.service.order.OrderFulfillmentService fulfillmentService;
    private final com.dienmay.service.order.DeliveryAssignmentService deliveryAssignmentService;
    private final DeliveryProofStorageService deliveryProofStorageService;

    @PostMapping("/{id}/confirm")
    public String confirm(
            @PathVariable Long id,
            @RequestParam(defaultValue = "list") String returnTo,
            Principal principal,
            RedirectAttributes flash) {

        try {
            confirmationService.confirm(id, principal.getName());
            flash.addFlashAttribute(
                    "success",
                    "Đã xác nhận đơn hàng và trừ tồn kho chi nhánh.");
        } catch (IllegalArgumentException | AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }

        return orderActionRedirect(id, returnTo);
    }

    @PostMapping("/{id}/start-picking")
    public String startPicking(@PathVariable Long id,
            Principal principal, RedirectAttributes flash) {
        try {
            pickingService.startPicking(id, principal.getName());
            flash.addFlashAttribute("success", "Đã chuyển đơn sang bước lấy và chuẩn bị hàng.");
        } catch (IllegalArgumentException | AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @PostMapping("/{id}/assign")
    public String assign(
            @PathVariable Long id,
            @RequestParam Long shipperId,
            @RequestParam(defaultValue = "list") String returnTo,
            Principal principal,
            RedirectAttributes flash) {

        try {
            deliveryAssignmentService.assign(
                    id,
                    shipperId,
                    principal.getName());

            flash.addFlashAttribute(
                    "success",
                    "Đã phân công đơn hàng cho shipper.");
        } catch (IllegalArgumentException | AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }

        return orderActionRedirect(id, returnTo);
    }

    @PostMapping("/{id}/cancel")
    public String cancel(@PathVariable Long id,
            Principal principal, RedirectAttributes flash) {
        return execute(id, principal, flash, fulfillmentService::cancel,
                "Đã hủy đơn hàng.");
    }

    @PostMapping("/{id}/confirm-cod-handover")
    @Transactional
    public String confirmCodHandover(@PathVariable Long id, Principal principal, RedirectAttributes flash) {
        try {
            Order order = findAccessibleOrder(id, principal);
            User actor = userRepository.findByEmail(principal.getName())
                    .orElseThrow(() -> new AccessDeniedException("Vui lòng đăng nhập."));
            boolean admin = actor.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
            boolean manager = actor.getRoles().stream().anyMatch(r -> "ROLE_BRANCH_MANAGER".equals(r.getName()));
            if (!admin && !manager) {
                throw new AccessDeniedException(
                        "Chỉ Quản lý chi nhánh hoặc Admin tổng mới được xác nhận nhận bàn giao tiền COD từ Shipper.");
            }
            var assignment = order.getDeliveryAssignment();
            if (assignment == null || !"PENDING_HANDOVER".equals(assignment.getCodHandoverStatus())) {
                throw new IllegalArgumentException("Đơn hàng này không ở trạng thái chờ bàn giao tiền COD.");
            }
            assignment.setCodHandoverStatus("HANDED_OVER");
            assignment.setCodHandedOverAt(LocalDateTime.now());
            assignment.setCodReceivedBy(actor);
            flash.addFlashAttribute("success", "Đã xác nhận nhận đủ tiền thu hộ COD từ Shipper về quỹ chi nhánh.");
        } catch (RuntimeException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/orders/" + id;
    }

    @GetMapping
    public String listOrders(
            @RequestParam(required = false) Long branchId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Principal principal,
            Model model) {
        User currentUser = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy tài khoản đang đăng nhập."));
        boolean admin = currentUser.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));

        Long effectiveBranchId = admin ? branchId
                : currentUser.getBranch() == null ? null : currentUser.getBranch().getId();
        OrderStatus selectedStatus = parseStatus(status);
        int safePage = Math.max(page, 0);
        int safeSize = Arrays.asList(10, 20, 50).contains(size) ? size : 20;
        var pageable = PageRequest.of(safePage, safeSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<Order> orders;
        if (!admin && effectiveBranchId == null) {
            orders = Page.empty(pageable);
            model.addAttribute("error", "Tài khoản nhân sự chưa được gán chi nhánh.");
        } else {
            orders = orderService.getOrdersForBranch(effectiveBranchId, selectedStatus, pageable);
        }

        model.addAttribute("ordersPage", orders);
        model.addAttribute("statuses", OrderStatus.values());
        model.addAttribute("selectedStatus", selectedStatus == null ? "" : selectedStatus.name());
        model.addAttribute("selectedBranchId", effectiveBranchId);
        model.addAttribute("branches", admin ? branchRepository.findByActiveTrue()
                : currentUser.getBranch() == null ? List.of() : List.of(currentUser.getBranch()));
        var shippers = userRepository
                .findDistinctByRoles_NameAndActiveTrueOrderByFullNameAsc("ROLE_SHIPPER");
        if (effectiveBranchId != null) {
            shippers = shippers.stream()
                    .filter(shipper -> shipper.getBranch() != null
                            && Objects.equals(shipper.getBranch().getId(), effectiveBranchId))
                    .toList();
        }
        model.addAttribute("shippers", shippers);
        model.addAttribute("canChooseBranch", admin);
        model.addAttribute("pageSize", safeSize);
        model.addAttribute("orderRealtimeDestination",
                admin && effectiveBranchId == null
                        ? OrderStatusWebSocketNotifier.ADMIN_DESTINATION
                        : effectiveBranchId == null ? ""
                        : OrderStatusWebSocketNotifier.branchDestination(effectiveBranchId));
        return "admin/orders";
    }

    @GetMapping("/{id}")
    public String orderDetail(
            @PathVariable Long id,
            Principal principal,
            Model model,
            HttpServletRequest request) {

        Order order = findAccessibleOrder(id, principal);

        var shippers = userRepository
                .findDistinctByRoles_NameAndActiveTrueOrderByFullNameAsc(
                        "ROLE_SHIPPER")
                .stream()
                .filter(shipper -> !shipper.isBlocked())
                .filter(shipper ->
                        order.getBranch() != null
                        && shipper.getBranch() != null
                        && Objects.equals(
                                shipper.getBranch().getId(),
                                order.getBranch().getId()))
                .toList();

        var assignment = order.getDeliveryAssignment();

        if (assignment != null && assignment.getProofPublicId() != null) {
            String proofUrl = deliveryProofStorageService.resolveViewUrl(
                    assignment.getProofPublicId(), request.getContextPath());
            if (proofUrl != null && proofUrl.contains("/shipper/orders/proof/")) {
                proofUrl = request.getContextPath() + "/admin/orders/" + order.getId() + "/proof";
            }
            model.addAttribute("proofViewUrl", proofUrl);
        }

        boolean assignableOrder =
                order.getBranch() != null
                && (order.getStatus() == OrderStatus.CONFIRMED
                    || order.getStatus() == OrderStatus.PROCESSING);

        boolean notPickedUp =
                assignment == null
                || (assignment.getStatus()
                        == com.dienmay.entity.order.DeliveryStatus.ASSIGNED
                    && assignment.getPickedUpAt() == null);

        model.addAttribute("order", order);
        model.addAttribute("shippers", shippers);
        model.addAttribute("canConfirm",
                order.getStatus() == OrderStatus.PENDING);
        model.addAttribute("canAssign", assignableOrder && notPickedUp);

        return "admin/order-detail";
    }

    @GetMapping("/{id}/proof")
    public ResponseEntity<byte[]> viewDeliveryProof(@PathVariable Long id, Principal principal) {
        Order order = findAccessibleOrder(id, principal);
        var assignment = order.getDeliveryAssignment();
        if (assignment == null || assignment.getProofPublicId() == null
                || assignment.getProofPublicId().isBlank()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy ảnh minh chứng.");
        }

        try {
            byte[] bytes = deliveryProofStorageService.loadLocalProofBytes(assignment.getProofPublicId());
            MediaType mediaType = assignment.getProofPublicId().toLowerCase().endsWith(".png")
                    ? MediaType.IMAGE_PNG : MediaType.IMAGE_JPEG;
            return ResponseEntity.ok()
                    .header(HttpHeaders.CACHE_CONTROL, "private, no-store")
                    .contentType(mediaType)
                    .body(bytes);
        } catch (java.io.IOException | IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy ảnh minh chứng.");
        }
    }

    private Order findAccessibleOrder(Long id, Principal principal) {
        if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        User actor = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new AccessDeniedException("Không có quyền xem đơn hàng."));
        boolean admin = actor.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));
        boolean manager = actor.getRoles().stream()
                .anyMatch(role -> "ROLE_BRANCH_MANAGER".equals(role.getName()));
        boolean staff = actor.getRoles().stream()
                .anyMatch(role -> "ROLE_STAFF".equals(role.getName()));
        if (!actor.isActive() || actor.isBlocked() || (!admin && !manager && !staff)) {
            throw new AccessDeniedException("Không có quyền xem đơn hàng.");
        }

        Order order = orderRepository.findDetailedById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng."));
        if (!admin && (actor.getBranch() == null || order.getBranch() == null
                || !Objects.equals(actor.getBranch().getId(), order.getBranch().getId()))) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng.");
        }
        return order;
    }

    @GetMapping("/status-snapshot")
    @ResponseBody
    public List<OrderStatusSnapshot> statusSnapshot(
            @RequestParam(required = false) Long branchId,
            Principal principal) {
        if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập.");
        }
        User currentUser = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Không tìm thấy tài khoản đang đăng nhập."));
        boolean admin = currentUser.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));
        Long effectiveBranchId = admin ? branchId
                : currentUser.getBranch() == null ? null : currentUser.getBranch().getId();
        if (!admin && effectiveBranchId == null) return List.of();
        var pageable = PageRequest.of(0, 500, Sort.by(Sort.Direction.DESC, "updatedAt"));
        return orderService.getOrdersForBranch(effectiveBranchId, null, pageable).stream()
                .map(OrderStatusSnapshot::from).toList();
    }

    private OrderStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        try {
            return OrderStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException ignored) {
            return null;
        }
    }

    private String execute(Long id, Principal principal,
            RedirectAttributes flash,
            OrderAction action, String successMessage) {
        try {
            action.run(id, principal.getName());
            flash.addFlashAttribute("success", successMessage);
        } catch (IllegalArgumentException | AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @FunctionalInterface
    private interface OrderAction {
        void run(Long orderId, String email);
    }

    private String orderActionRedirect(Long id, String returnTo) {
        return "detail".equals(returnTo)
                ? "redirect:/admin/orders/" + id
                : "redirect:/admin/orders";
    }
}