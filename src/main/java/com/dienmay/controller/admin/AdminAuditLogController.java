package com.dienmay.controller.admin;
import com.dienmay.repository.audit.AuditLogRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
@Controller @RequestMapping("/admin/audit-logs")
public class AdminAuditLogController {
    private final AuditLogRepository logs;
    public AdminAuditLogController(AuditLogRepository logs){this.logs=logs;}
    @GetMapping public String list(Model model){model.addAttribute("logs",logs.findAll());return "admin/audit-logs";}
}
