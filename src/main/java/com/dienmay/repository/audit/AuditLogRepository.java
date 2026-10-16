package com.dienmay.repository.audit;
import com.dienmay.entity.audit.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
public interface AuditLogRepository extends JpaRepository<AuditLog,Long> {}
