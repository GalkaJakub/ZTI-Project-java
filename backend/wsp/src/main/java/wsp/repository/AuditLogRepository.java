package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.AuditLog;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
}
