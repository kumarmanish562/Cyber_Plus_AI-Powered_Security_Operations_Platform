package cyberpulse.risk.repository;

import cyberpulse.risk.entity.RiskAssessment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface RiskAssessmentRepository
        extends JpaRepository<RiskAssessment, UUID> {

    boolean existsByDetectionId(UUID detectionId);
}
