package cyberpulse.event.repository;

import cyberpulse.common.enums.Severity;
import cyberpulse.event.entity.SecurityEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.UUID;

public interface SecurityEventRepository
        extends JpaRepository<SecurityEvent, UUID> {

    Page<SecurityEvent> findBySeverity(
            Severity severity,
            Pageable pageable
    );

    Page<SecurityEvent> findByEventType(
            String eventType,
            Pageable pageable
    );

    long countBySourceIpAndEventTypeAndEventTimeBetween(
            String sourceIp,
            String eventType,
            Instant start,
            Instant end
    );
}
