$servicePath = "src\main\java\com\opsflow\service"
$repoPath = "src\main\java\com\opsflow\repository"
$mainClassPath = "src\main\java\com\opsflow\BackendApplication.java"

$slaRepo = @"
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
"@
Set-Content -Path "$repoPath\SLAPolicyRepository.java" -Value $slaRepo

$slaService = @"
package com.opsflow.service;

import com.opsflow.entity.Ticket;
import com.opsflow.entity.enums.TicketStatus;
import com.opsflow.repository.TicketRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SLAService {
    private static final Logger log = LoggerFactory.getLogger(SLAService.class);
    private final TicketRepository ticketRepository;

    @Scheduled(fixedRate = 60000) // Run every minute
    public void checkSLABreaches() {
        log.info("Running SLA breach check job...");
        LocalDateTime now = LocalDateTime.now();
        
        List<Ticket> activeTickets = ticketRepository.findAll().stream()
            .filter(t -> t.getStatus() != TicketStatus.CLOSED && t.getStatus() != TicketStatus.RESOLVED)
            .toList();

        for (Ticket ticket : activeTickets) {
            // Check Response SLA
            if (ticket.getResponseSlaDeadline() != null && 
                ticket.getStatus() == TicketStatus.NEW && 
                now.isAfter(ticket.getResponseSlaDeadline())) {
                log.warn("Ticket {} has breached response SLA!", ticket.getTicketNumber());
                // In a real app, generate a notification or audit log here
            }

            // Check Resolution SLA
            if (ticket.getResolutionSlaDeadline() != null && 
                now.isAfter(ticket.getResolutionSlaDeadline())) {
                log.warn("Ticket {} has breached resolution SLA!", ticket.getTicketNumber());
                // In a real app, generate a notification or audit log here
            }
        }
    }
}
"@
Set-Content -Path "$servicePath\SLAService.java" -Value $slaService
