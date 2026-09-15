package cyberpulse.detection.repository;

import cyberpulse.detection.entity.DetectionRule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface DetectionRuleRepository
        extends JpaRepository<DetectionRule, UUID> {

    List<DetectionRule> findByEnabledTrue();

    boolean existsByNameIgnoreCase(String name);
}
