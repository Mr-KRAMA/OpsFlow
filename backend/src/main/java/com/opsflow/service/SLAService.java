package com.opsflow.service;

import com.opsflow.entity.Notification;
import com.opsflow.entity.Ticket;
import com.opsflow.entity.enums.TicketStatus;
import com.opsflow.repository.NotificationRepository;
import com.opsflow.repository.TicketRepository;
import com.opsflow.repository.UserRepository;
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
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Scheduled(fixedRate = 60000)
    public void checkSLABreaches() {
        log.info("Running SLA breach check job...");
        LocalDateTime now = LocalDateTime.now();

        List<Ticket> activeTickets = ticketRepository.findAll().stream()
            .filter(t -> t.getStatus() != TicketStatus.CLOSED && t.getStatus() != TicketStatus.RESOLVED)
            .toList();

        for (Ticket ticket : activeTickets) {
            if (ticket.getResponseSlaDeadline() != null &&
                ticket.getStatus() == TicketStatus.NEW &&
                now.isAfter(ticket.getResponseSlaDeadline())) {
                log.warn("Ticket {} breached response SLA!", ticket.getTicketNumber());
                notifyAdmins("⚠️ Response SLA breached for ticket " + ticket.getTicketNumber() + ": " + ticket.getTitle(), ticket.getId());
            }

            if (ticket.getResolutionSlaDeadline() != null &&
                now.isAfter(ticket.getResolutionSlaDeadline())) {
                log.warn("Ticket {} breached resolution SLA!", ticket.getTicketNumber());
                notifyAdmins("🚨 Resolution SLA breached for ticket " + ticket.getTicketNumber() + ": " + ticket.getTitle(), ticket.getId());
            }
        }
    }

    private void notifyAdmins(String message, Long ticketId) {
        userRepository.findAll().stream()
            .filter(u -> u.getRole().name().equals("ADMIN") || u.getRole().name().equals("TEAM_LEAD"))
            .forEach(u -> {
                boolean alreadyNotified = notificationRepository
                    .findByUser_EmailOrderByCreatedAtDesc(u.getEmail())
                    .stream()
                    .anyMatch(n -> n.getMessage().equals(message));
                if (!alreadyNotified) {
                    notificationRepository.save(Notification.builder()
                        .user(u)
                        .message(message)
                        .relatedTicketId(ticketId)
                        .isRead(false)
                        .build());
                }
            });
    }
}
