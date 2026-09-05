package com.opsflow.repository;

import com.opsflow.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserEmailOrderByCreatedAtDesc(String email);
    List<Notification> findByUserEmailAndIsReadFalse(String email);
    List<Notification> findByUser_EmailOrderByCreatedAtDesc(String email);
    List<Notification> findByUser_EmailAndIsReadFalse(String email);
}
