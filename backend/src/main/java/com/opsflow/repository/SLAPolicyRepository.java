package com.opsflow.repository;

import com.opsflow.entity.SLAPolicy;
import com.opsflow.entity.enums.Priority;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SLAPolicyRepository extends JpaRepository<SLAPolicy, Long> {
    Optional<SLAPolicy> findByPriority(Priority priority);
}
