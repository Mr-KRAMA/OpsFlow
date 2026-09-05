package com.opsflow.controller;

import com.opsflow.entity.enums.TicketStatus;
import com.opsflow.repository.TicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final TicketRepository ticketRepository;

    @GetMapping("/admin")
    public ResponseEntity<Map<String, Object>> getAdminDashboard() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalTickets", ticketRepository.count());
        stats.put("openTickets", ticketRepository.findByStatus(TicketStatus.NEW).size() + ticketRepository.findByStatus(TicketStatus.IN_PROGRESS).size() + ticketRepository.findByStatus(TicketStatus.ASSIGNED).size());
        stats.put("resolvedTickets", ticketRepository.findByStatus(TicketStatus.RESOLVED).size());
        stats.put("slaBreachedTickets", ticketRepository.findAll().stream()
                .filter(t -> t.getResolutionSlaDeadline() != null && t.getResolutionSlaDeadline().isBefore(java.time.LocalDateTime.now())
                        && t.getStatus() != TicketStatus.RESOLVED && t.getStatus() != TicketStatus.CLOSED)
                .count());
        return ResponseEntity.ok(stats);
    }
}
