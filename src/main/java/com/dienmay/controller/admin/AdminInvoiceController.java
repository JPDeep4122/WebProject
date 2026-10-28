package com.dienmay.controller.admin;

import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.order.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.util.StringUtils;

@Controller
@RequestMapping("/admin/invoices")
@RequiredArgsConstructor
public class AdminInvoiceController {

    private final OrderRepository orderRepository;
    private final BranchRepository branchRepository;

    @GetMapping
    public String listInvoices(@RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long branchId,
            Model model) {
        int safePage = Math.max(page, 0);
        String keyword = q == null ? "" : q.trim();
        Long customerId = null;
        if (StringUtils.hasText(keyword)) {
            try {
                customerId = Long.valueOf(keyword);
            } catch (NumberFormatException ignored) {
                // Non-numeric searches match invoice/order codes only.
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
                // Ignore invalid status values and show all non-cancelled invoices.
            }
        }
        var pageable = PageRequest.of(safePage, 20, Sort.by(Sort.Direction.DESC, "createdAt"));
        var invoicesPage = orderRepository.filterInvoices(OrderStatus.CANCELLED, selectedStatus,
                branchId, keyword, customerId, pageable);
        model.addAttribute("invoicesPage", invoicesPage);
        model.addAttribute("searchQuery", keyword);
        model.addAttribute("statuses", java.util.Arrays.stream(OrderStatus.values())
                .filter(invoiceStatus -> invoiceStatus != OrderStatus.CANCELLED).toList());
        model.addAttribute("selectedStatus", selectedStatus == null ? "" : selectedStatus.name());
        model.addAttribute("selectedBranchId", branchId);
        model.addAttribute("branches", branchRepository.findByActiveTrue());
        return "admin/invoices";
    }
}
