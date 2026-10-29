package com.dienmay.controller.admin;

import java.security.Principal;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.validation.Valid;
import com.dienmay.dto.branch.InventoryStockRequest;
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

        model.addAttribute("selectedBranchId", overview.getSelectedBranchId());
        model.addAttribute("canChooseBranch", overview.isCanChooseBranch());
        model.addAttribute("canEditInventory", overview.isCanEditInventory());
        model.addAttribute("warning", overview.getWarning());
        model.addAttribute("keyword", keyword == null ? "" : keyword.trim());
        model.addAttribute("pageSize", safeSize);
        model.addAttribute("paginationPages", paginationPages(overview.getInventories().getNumber(),
                overview.getInventories().getTotalPages()));
        return "admin/inventory";
    }

    @PostMapping("/{id}/stock")
    public String updateStock(@PathVariable Long id,
            @Valid @ModelAttribute InventoryStockRequest request, BindingResult result,
            @RequestParam(required = false) Long branchId,
            Principal principal, RedirectAttributes redirect) {
        if (branchId != null) redirect.addAttribute("branchId", branchId);
        if (result.hasErrors()) {
            redirect.addFlashAttribute("error", result.getAllErrors().getFirst().getDefaultMessage());
            return "redirect:/admin/inventory";
        }
        try {
            inventoryService.updateStock(id, request, principal.getName());
            redirect.addFlashAttribute("success", "Đã cập nhật tồn kho thành công.");
        } catch (AccessDeniedException exception) {
            throw exception;
        } catch (IllegalArgumentException exception) {
            redirect.addFlashAttribute("error", exception.getMessage());
        }
        return "redirect:/admin/inventory";
    }

    private List<PageNumber> paginationPages(int currentPage, int totalPages) {
        if (totalPages <= 0) return List.of();
        TreeSet<Integer> visible = new TreeSet<>();
        int start = currentPage == 0 ? 0 : currentPage;
        for (int page = start; page < Math.min(start + 3, totalPages); page++) {
            visible.add(page);
        }
        if (totalPages > 3) {
            for (int page = Math.max(0, totalPages - 3); page < totalPages; page++) {
                visible.add(page);
            }
        }
        List<PageNumber> result = new ArrayList<>();
        int previous = -1;
        for (int page : visible) {
            result.add(new PageNumber(page, previous >= 0 && page - previous > 1));
            previous = page;
        }
        return result;
    }

    public record PageNumber(int index, boolean gapBefore) { }

}
