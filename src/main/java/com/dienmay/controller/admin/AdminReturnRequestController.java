package com.dienmay.controller.admin;

import java.security.Principal;
import java.util.Arrays;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.entity.order.ReturnRequestStatus;
import com.dienmay.service.order.ReturnRequestService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/returns")
@RequiredArgsConstructor
public class AdminReturnRequestController {
    private final ReturnRequestService returnRequestService;

    @GetMapping
    public String list(@RequestParam(required = false) Long branchId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Principal principal, Model model) {
        int safePage = Math.max(page, 0);
        int safeSize = Arrays.asList(10, 20, 50).contains(size) ? size : 20;
        ReturnRequestStatus selectedStatus = parseStatus(status);
        var overview = returnRequestService.loadForManagement(principal.getName(), branchId,
                selectedStatus, PageRequest.of(safePage, safeSize,
                        Sort.by(Sort.Direction.DESC, "requestedAt")));
        model.addAttribute("requestsPage", overview.getRequests());
        model.addAttribute("branches", overview.getBranches());
        model.addAttribute("selectedBranchId", overview.getSelectedBranchId());
        model.addAttribute("canChooseBranch", overview.isCanChooseBranch());
        model.addAttribute("warning", overview.getWarning());
        model.addAttribute("statuses", ReturnRequestStatus.values());
        model.addAttribute("selectedStatus", selectedStatus == null ? "" : selectedStatus.name());
        model.addAttribute("pageSize", safeSize);
        return "admin/returns";
    }

    @PostMapping("/{id}/review")
    public String review(@PathVariable Long id,
            @RequestParam ReturnRequestStatus decision,
            @RequestParam(required = false) String reviewNote,
            @RequestParam(required = false) Long branchId,
            Principal principal, RedirectAttributes flash) {
        try {
            returnRequestService.review(id, decision, reviewNote, principal.getName());
            flash.addFlashAttribute("success", decision == ReturnRequestStatus.APPROVED
                    ? "Đã duyệt yêu cầu trả hàng." : "Đã từ chối yêu cầu trả hàng.");
        } catch (IllegalArgumentException | AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        if (branchId != null) {
            flash.addAttribute("branchId", branchId);
        }
        return "redirect:/admin/returns";
    }

    @PostMapping("/{id}/complete")
    public String complete(@PathVariable Long id,
            @RequestParam(required = false) String completionNote,
            @RequestParam(defaultValue = "RESTOCK") String disposition,
            @RequestParam(required = false) Long branchId,
            Principal principal, RedirectAttributes flash) {
        try {
            returnRequestService.complete(id, completionNote, disposition, principal.getName());
            flash.addFlashAttribute("success",
                    "QUARANTINE".equalsIgnoreCase(disposition)
                            ? "Đã nhận hàng trả vào Kho cách ly (chờ kiểm định) và ghi nhận hoàn tiền."
                            : "Đã nhận hàng trả vào Kho khả dụng và ghi nhận hoàn tiền.");
        } catch (IllegalArgumentException | AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        if (branchId != null) {
            flash.addAttribute("branchId", branchId);
        }
        return "redirect:/admin/returns";
    }

    private ReturnRequestStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        try {
            return ReturnRequestStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException ignored) {
            return null;
        }
    }
}
