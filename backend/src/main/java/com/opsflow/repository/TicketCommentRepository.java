package com.opsflow.repository;

import com.opsflow.entity.TicketComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TicketCommentRepository extends JpaRepository<TicketComment, Long> {
    List<TicketComment> findByTicketId(Long ticketId);
    List<TicketComment> findByTicketIdAndIsInternalFalse(Long ticketId);
}
