package com.dienmay.controller.admin;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.order.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.util.StringUtils;

import java.security.Principal;
import java.util.List;

@Controller
@RequestMapping("/admin/invoices")
@RequiredArgsConstructor
public class AdminInvoiceController {

    private final OrderRepository orderRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;

    @GetMapping
    public String listInvoices(@RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long branchId,
            Principal principal,
            Model model) {
        User actor = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new AccessDeniedException("Vui lòng đăng nhập."));
        boolean admin = actor.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
        Long effectiveBranchId = admin ? branchId
                : (actor.getBranch() == null ? null : actor.getBranch().getId());

        int safePage = Math.max(page, 0);
        String keyword = q == null ? "" : q.trim();
        Long customerId = null;
        if (StringUtils.hasText(keyword)) {
            try {
                customerId = Long.valueOf(keyword);
            } catch (NumberFormatException ignored) {
            }
        }
        OrderStatus selectedStatus = null;
        if (StringUtils.hasText(status)) {
            try {
                selectedStatus = OrderStatus.valueOf(status.trim().toUpperCase());
                if (selectedStatus == OrderStatus.CANCELLED) {
                    selectedStatus = null;
                }
            } catch (IllegalArgumentException ignored) {
            }
        }
        var pageable = PageRequest.of(safePage, 20, Sort.by(Sort.Direction.DESC, "createdAt"));
        var invoicesPage = (!admin && effectiveBranchId == null)
                ? Page.empty(pageable)
                : orderRepository.filterInvoices(OrderStatus.CANCELLED, selectedStatus,
                        effectiveBranchId, keyword, customerId, pageable);
        model.addAttribute("invoicesPage", invoicesPage);
        model.addAttribute("searchQuery", keyword);
        model.addAttribute("statuses", java.util.Arrays.stream(OrderStatus.values())
                .filter(invoiceStatus -> invoiceStatus != OrderStatus.CANCELLED).toList());
        model.addAttribute("selectedStatus", selectedStatus == null ? "" : selectedStatus.name());
        model.addAttribute("selectedBranchId", effectiveBranchId);
        model.addAttribute("branches", admin ? branchRepository.findByActiveTrue()
                : (actor.getBranch() == null ? List.of() : List.of(actor.getBranch())));
        return "admin/invoices";
    }
}