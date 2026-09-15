package cyberpulse.incident.repository;

import cyberpulse.common.enums.IncidentStatus;
import cyberpulse.common.enums.Severity;
import cyberpulse.incident.entity.Incident;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface IncidentRepository
        extends JpaRepository<Incident, UUID> {

    Page<Incident> findByStatus(
            IncidentStatus status,
            Pageable pageable
    );

    Page<Incident> findBySeverity(
            Severity severity,
            Pageable pageable
    );

    Page<Incident> findByAssignedToId(
            UUID userId,
            Pageable pageable
    );
}