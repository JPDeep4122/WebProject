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

@Controller
@RequestMapping("/admin/invoices")
@RequiredArgsConstructor
public class AdminInvoiceController {

    private final OrderRepository orderRepository;

    @GetMapping
    public String listInvoices(@RequestParam(defaultValue = "0") int page, Model model) {
        int safePage = Math.max(page, 0);
        var invoicesPage = orderRepository.findByStatusNot(OrderStatus.CANCELLED,
                PageRequest.of(safePage, 20, Sort.by(Sort.Direction.DESC, "createdAt")));
        model.addAttribute("invoicesPage", invoicesPage);
        return "admin/invoices";
    }
}
