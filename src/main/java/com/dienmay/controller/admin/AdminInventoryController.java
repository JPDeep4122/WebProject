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

import com.dienmay.service.branch.BranchInventoryManagementService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/inventory")
@RequiredArgsConstructor
public class AdminInventoryController {
    private final BranchInventoryManagementService inventoryService;

    @GetMapping
    public String list(@RequestParam(required = false) Long branchId,
            @RequestParam(required = false, defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Principal principal, Model model) {
        int safePage = Math.max(0, page);
        int safeSize = Arrays.asList(10, 20, 50).contains(size) ? size : 20;
        var pageable = PageRequest.of(safePage, safeSize,
                Sort.by(Sort.Direction.ASC, "product.name"));
        var overview = inventoryService.load(
                principal.getName(), branchId, keyword, pageable);

        model.addAttribute("inventoryPage", overview.getInventories());
        model.addAttribute("branches", overview.getBranches());
        model.addAttribute("adjustments", overview.getRecentAdjustments());
        model.addAttribute("selectedBranchId", overview.getSelectedBranchId());
        model.addAttribute("canChooseBranch", overview.isCanChooseBranch());
        model.addAttribute("warning", overview.getWarning());
        model.addAttribute("keyword", keyword == null ? "" : keyword.trim());
        model.addAttribute("pageSize", safeSize);
        return "admin/inventory";
    }

    @PostMapping("/{id}/adjust")
    public String adjust(@PathVariable Long id,
            @RequestParam Integer newStock,
            @RequestParam String reason,
            @RequestParam(required = false) Long branchId,
            Principal principal, RedirectAttributes flash) {
        try {
            inventoryService.adjust(id, newStock, reason, principal.getName());
            flash.addFlashAttribute("success", "Đã điều chỉnh tồn kho và lưu lịch sử thay đổi.");
        } catch (IllegalArgumentException | AccessDeniedException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        if (branchId != null) {
            flash.addAttribute("branchId", branchId);
        }
        return "redirect:/admin/inventory";
    }
}
