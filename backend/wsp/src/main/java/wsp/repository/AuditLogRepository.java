package wsp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import wsp.entity.AuditLog;

/**
 * Repozytorium wpisów audytu zapisywanych przez aspekt AOP.
 */
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
}
