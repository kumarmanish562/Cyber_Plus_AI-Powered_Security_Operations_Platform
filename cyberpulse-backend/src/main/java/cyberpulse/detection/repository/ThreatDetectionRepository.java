package cyberpulse.detection.repository;

import cyberpulse.detection.entity.ThreatDetection;
import org.springframework.data.jpa.repository.JpaRepository;


import java.util.UUID;

public interface ThreatDetectionRepository
        extends JpaRepository<ThreatDetection, UUID> {

    boolean existsByRuleIdAndEventId(
            UUID ruleId,
            UUID eventId
    );
}
