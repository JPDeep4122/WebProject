package com.dienmay.controller.admin;

import com.dienmay.entity.order.OrderStatus;
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

    @GetMapping
    public String listInvoices(@RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String q, Model model) {
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
        var pageable = PageRequest.of(safePage, 20, Sort.by(Sort.Direction.DESC, "createdAt"));
        var invoicesPage = StringUtils.hasText(keyword)
                ? orderRepository.searchInvoices(OrderStatus.CANCELLED, keyword, customerId, pageable)
                : orderRepository.findByStatusNot(OrderStatus.CANCELLED, pageable);
        model.addAttribute("invoicesPage", invoicesPage);
        model.addAttribute("searchQuery", keyword);
        return "admin/invoices";
    }
}
