package com.opsflow.repository;

import com.opsflow.entity.Ticket;
import com.opsflow.entity.enums.TicketStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, Long> {
    List<Ticket> findByCreatorId(Long creatorId);
    List<Ticket> findByAssignedAgentId(Long agentId);
    List<Ticket> findByAssignedTeamId(Long teamId);
    List<Ticket> findByStatus(TicketStatus status);
}
