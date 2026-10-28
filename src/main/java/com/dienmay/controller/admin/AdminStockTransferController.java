package com.dienmay.controller.admin;

import java.security.Principal;

import org.springframework.data.domain.Sort;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.entity.auth.User;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.service.branch.StockTransferService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/transfers")
@RequiredArgsConstructor
public class AdminStockTransferController {

    private final StockTransferService transferService;
    private final BranchRepository branches;
    private final ProductRepository products;
    private final UserRepository users;

    @GetMapping
    public String list(Principal principal, Model model) {
        User actor = users.findByEmail(principal.getName())
                .orElseThrow(() -> new AccessDeniedException("Vui lòng đăng nhập."));
        boolean admin = actor.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
        boolean manager = actor.getRoles().stream().anyMatch(r -> "ROLE_BRANCH_MANAGER".equals(r.getName()));

        model.addAttribute("transfers", transferService.listVisibleTransfers(principal.getName()));
        model.addAttribute("branches", branches.findByActiveTrue());
        model.addAttribute("products", products.findAll(Sort.by("name")));
        model.addAttribute("isAdmin", admin);
        model.addAttribute("canApproveOrConfirm", admin || manager);
        model.addAttribute("actorBranch", actor.getBranch());
        return "admin/transfers";
    }

    @PostMapping
    public String create(@RequestParam Long fromBranchId,
            @RequestParam(required = false) Long toBranchId,
            @RequestParam Long productId,
            @RequestParam Integer quantity,
            @RequestParam(required = false) String note,
            Principal principal, RedirectAttributes flash) {
        try {
            var created = transferService.createRequest(
                    fromBranchId, toBranchId, productId, quantity, note, principal.getName());
            flash.addFlashAttribute("success", "Đã tạo phiếu yêu cầu điều chuyển " + created.getTransferCode());
        } catch (RuntimeException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/transfers";
    }

    @PostMapping("/{id}/approve")
    public String approve(@PathVariable Long id, @RequestParam String decision,
            Principal principal, RedirectAttributes flash) {
        try {
            transferService.approveOrReject(id, decision, principal.getName());
            flash.addFlashAttribute("success", "APPROVED".equalsIgnoreCase(decision)
                    ? "Đã duyệt phiếu và giữ tồn kho điều chuyển tại chi nhánh xuất."
                    : "Đã từ chối phiếu điều chuyển.");
        } catch (RuntimeException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/transfers";
    }

    @PostMapping("/{id}/ship")
    public String ship(@PathVariable Long id, Principal principal, RedirectAttributes flash) {
        try {
            transferService.confirmShip(id, principal.getName());
            flash.addFlashAttribute("success", "Đã xác nhận xuất kho điều chuyển (Hàng đang vận chuyển IN_TRANSIT).");
        } catch (RuntimeException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/transfers";
    }

    @PostMapping("/{id}/receive")
    public String receive(@PathVariable Long id,
            @RequestParam Integer goodQty,
            @RequestParam(defaultValue = "0") Integer quarantineQty,
            @RequestParam(required = false) String disputeNote,
            Principal principal, RedirectAttributes flash) {
        try {
            transferService.confirmReceive(id, goodQty, quarantineQty, disputeNote, principal.getName());
            flash.addFlashAttribute("success", "Đã xác nhận nhận hàng điều chuyển và cập nhật tồn kho chi nhánh nhận.");
        } catch (RuntimeException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/transfers";
    }
}