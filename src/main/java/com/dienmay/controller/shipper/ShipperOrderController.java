package com.dienmay.controller.shipper;

import java.security.Principal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Arrays;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.dto.shipper.DeliveryFailureRequest;
import com.dienmay.dto.shipper.DeliverySuccessRequest;
import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.DeliveryFailureCode;
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.DeliveryAssignmentRepository;
import com.dienmay.service.order.DeliveryProofStorageService;
import com.dienmay.service.order.DeliveryStatisticsPeriod;
import com.dienmay.service.order.DeliveryStatisticsService;
import com.dienmay.service.order.DeliveryStatusService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/shipper")
@RequiredArgsConstructor
public class ShipperOrderController {

    private final DeliveryAssignmentRepository assignments;
    private final UserRepository users;
    private final DeliveryStatusService deliveryStatusService;
    private final DeliveryStatisticsService deliveryStatisticsService;
    private final DeliveryProofStorageService proofStorageService;

    @GetMapping
    public String home() {
        return "redirect:/shipper/orders";
    }

    @GetMapping("/orders")
    public String list(@RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Principal principal, Model model) {
        var shipper = users.findByEmail(principal.getName())
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy tài khoản shipper."));
        DeliveryStatus selectedStatus = parseStatus(status);
        int safePage = Math.max(page, 0);
        int safeSize = Arrays.asList(10, 20, 50).contains(size) ? size : 20;
        var pageable = PageRequest.of(safePage, safeSize,
                Sort.by(Sort.Direction.DESC, "assignedAt"));

        var result = selectedStatus == null
                ? assignments.findAssignedTo(shipper.getEmail(), pageable)
                : assignments.findAssignedToByStatus(shipper.getEmail(), selectedStatus, pageable);

        model.addAttribute("assignmentsPage", result);
        model.addAttribute("shipper", shipper);
        model.addAttribute("statuses", DeliveryStatus.values());
        model.addAttribute("failureCodes", DeliveryFailureCode.values());
        model.addAttribute("selectedStatus", selectedStatus == null ? "" : selectedStatus.name());
        model.addAttribute("pageSize", safeSize);
        return "shipper/orders";
    }

    @PostMapping("/orders/{assignmentId}/pickup")
    public String confirmPickup(@PathVariable Long assignmentId, Principal principal, RedirectAttributes flash) {
        try {
            var asg = deliveryStatusService.getAssignmentForShipper(assignmentId, principal.getName());
            deliveryStatusService.confirmPickup(assignmentId, principal.getName());
            flash.addFlashAttribute("success", "Đã xác nhận lấy kiện hàng từ chi nhánh cho đơn " + asg.getOrder().getOrderCode() + ".");
        } catch (IllegalArgumentException | IllegalStateException | org.springframework.security.access.AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/shipper/orders";
    }

    @PostMapping("/orders/{assignmentId}/start-delivery")
    public String startDelivery(@PathVariable Long assignmentId, Principal principal, RedirectAttributes flash) {
        try {
            var asg = deliveryStatusService.getAssignmentForShipper(assignmentId, principal.getName());
            deliveryStatusService.startDelivery(assignmentId, principal.getName());
            flash.addFlashAttribute("success", "Đã bắt đầu đi giao đơn " + asg.getOrder().getOrderCode() + " (Lượt giao mới).");
        } catch (IllegalArgumentException | IllegalStateException | org.springframework.security.access.AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/shipper/orders";
    }
    
    @PostMapping("/orders/{assignmentId}/success")
    public String completeSuccess(
            @PathVariable Long assignmentId,
            @ModelAttribute DeliverySuccessRequest request,
            @RequestParam("proof") MultipartFile proofFile,
            Principal principal,
            RedirectAttributes flash) {
        String proofPublicId = null;
        try {
            var asg = deliveryStatusService.getAssignmentForShipper(assignmentId, principal.getName());
            proofStorageService.validateProofFile(proofFile, true);
            proofPublicId = proofStorageService.storePrivateProof(proofFile, assignmentId, 1);
            deliveryStatusService.completeSuccess(assignmentId, request, proofPublicId, principal.getName());
            String amountText = java.text.NumberFormat.getNumberInstance(java.util.Locale.forLanguageTag("vi-VN"))
                    .format(request.getCollectedAmount() != null ? request.getCollectedAmount() : java.math.BigDecimal.ZERO);
            String msg = "Đã hoàn tất giao đơn " + asg.getOrder().getOrderCode() + ". "
                    + (request.getCollectionMethod() == com.dienmay.entity.order.DeliveryCollectionMethod.CASH
                            ? "Đã ghi nhận thu hộ " + amountText + " ₫."
                            : "Không thu tiền (Đã thanh toán online).");
            flash.addFlashAttribute("success", msg);
        } catch (Exception ex) {
            if (proofPublicId != null) {
                proofStorageService.deleteProofQuietly(proofPublicId);
            }
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/shipper/orders";
    }
    
    @PostMapping("/orders/{assignmentId}/failure")
    public String completeFailure(
            @PathVariable Long assignmentId,
            @ModelAttribute DeliveryFailureRequest request,
            @RequestParam(name = "proof", required = false) MultipartFile proofFile,
            Principal principal,
            RedirectAttributes flash) {
        String optionalProofId = null;
        try {
            if (proofFile != null && !proofFile.isEmpty()) {
                proofStorageService.validateProofFile(proofFile, false);
                optionalProofId = proofStorageService.storePrivateProof(proofFile, assignmentId, 1);
            }
            deliveryStatusService.completeFailure(assignmentId, request, optionalProofId, principal.getName());
            String reasonText = request.getFailureCode() != null ? request.getFailureCode().getLabel() : "Không xác định";
            flash.addFlashAttribute("success", "Đã ghi nhận giao thất bại. Lý do: " + reasonText + ".");
        } catch (Exception ex) {
            if (optionalProofId != null) {
                proofStorageService.deleteProofQuietly(optionalProofId);
            }
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/shipper/orders";
    }

    // 5. ENDPOINT XEM CHI TIẾT ĐƠN GIAO & TẠO SIGNED URL
    @GetMapping("/orders/{assignmentId}")
    public String detail(@PathVariable Long assignmentId, Principal principal, Model model, HttpServletRequest request) {
        DeliveryAssignment assignment = deliveryStatusService.getAssignmentForShipper(assignmentId, principal.getName());
        model.addAttribute("assignment", assignment);
        model.addAttribute("order", assignment.getOrder());
        model.addAttribute("attempts", assignment.getAttempts());
        if (assignment.getProofPublicId() != null) {
            model.addAttribute("proofSignedUrl", proofStorageService.resolveViewUrl(assignment.getProofPublicId(), request.getContextPath()));
        }
        return "shipper/order-detail";
    }

    // 6. ENDPOINT STREAM ẢNH MINH CHỨNG BẢO MẬT (KIỂM TRA QUYỀN)
    @GetMapping("/orders/proof/{proofPublicId}")
    public ResponseEntity<byte[]> viewProof(@PathVariable String proofPublicId, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            // Never use a client-supplied file identifier as authorization. Verify
            // that the proof belongs to a delivery currently assigned to this shipper.
            if (proofPublicId == null || proofPublicId.isBlank()
                    || assignments.countProofsOwnedByShipper(proofPublicId, principal.getName()) == 0) {
                return ResponseEntity.notFound().build();
            }
            byte[] bytes = proofStorageService.loadLocalProofBytes(proofPublicId);
            MediaType type = proofPublicId.toLowerCase().endsWith(".png") ? MediaType.IMAGE_PNG : MediaType.IMAGE_JPEG;
            return ResponseEntity.ok()
                    .header(HttpHeaders.CACHE_CONTROL, "private, max-age=3600")
                    .contentType(type)
                    .body(bytes);
        } catch (Exception ex) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/statistics")
    public String statistics(@RequestParam(required = false) String period,
            @RequestParam(required = false) String date,
            Principal principal, Model model) {
        DeliveryStatisticsPeriod selectedPeriod = DeliveryStatisticsPeriod.parse(period);
        LocalDate anchor = parseDate(date);
        var report = deliveryStatisticsService.summarize(
                principal.getName(), selectedPeriod, anchor);
        var shipper = users.findByEmail(principal.getName())
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy tài khoản shipper."));
        model.addAttribute("report", report);
        model.addAttribute("shipper", shipper);
        return "shipper/statistics";
    }

    private DeliveryStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        try {
            return DeliveryStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException ignored) {
            return null;
        }
    }

    private LocalDate parseDate(String date) {
        if (date == null || date.isBlank()) {
            return LocalDate.now();
        }
        try {
            return LocalDate.parse(date.trim());
        } catch (DateTimeParseException ignored) {
            return LocalDate.now();
        }
    }
}
