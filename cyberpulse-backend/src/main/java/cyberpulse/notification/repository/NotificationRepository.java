package cyberpulse.notification.repository;

import cyberpulse.notification.entity.Notification;
import org.aspectj.weaver.ast.Not;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface NotificationRepository
        extends JpaRepository<Notification, UUID> {

    Page<Notification> findByUserId(
            UUID userId,
            Pageable pageable
    );

    Page<Notification> findByUserIdAndReadFalse(
            UUID userId,
            Pageable pageable
    );
}