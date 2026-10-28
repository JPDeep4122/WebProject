package com.dienmay.controller.admin;

import com.dienmay.entity.audit.AuditLog;
import com.dienmay.repository.audit.AuditLogRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/admin/audit-logs")
public class AdminAuditLogController {
    private final AuditLogRepository logs;

    public AdminAuditLogController(AuditLogRepository logs) {
        this.logs = logs;
    }

    @GetMapping
    public String list(@RequestParam(defaultValue = "0") int page, Model model) {
        int safePage = Math.max(0, page);
        Page<AuditLog> logsPage = logs.findAll(PageRequest.of(safePage, 20, Sort.by(Sort.Direction.DESC, "createdAt")));
        model.addAttribute("logs", logsPage.getContent());
        model.addAttribute("logsPage", logsPage);
        return "admin/audit-logs";
    }
}