package com.opsflow.controller;

import com.opsflow.dto.ticket.TicketRequest;
import com.opsflow.dto.ticket.TicketResponse;
import com.opsflow.dto.ticket.TicketStatusUpdateRequest;
import com.opsflow.entity.TicketCategory;
import com.opsflow.repository.TicketCategoryRepository;
import com.opsflow.service.TicketService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tickets")
@RequiredArgsConstructor
public class TicketController {

    private final TicketService ticketService;
    private final TicketCategoryRepository categoryRepository;

    @GetMapping("/categories")
    public ResponseEntity<List<TicketCategory>> getCategories() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<TicketResponse> createTicket(
            @Valid @RequestBody TicketRequest request,
            Authentication authentication
    ) {
        return ResponseEntity.ok(ticketService.createTicket(request, authentication.getName()));
    }

    @GetMapping
    public ResponseEntity<List<TicketResponse>> getAllTickets() {
        return ResponseEntity.ok(ticketService.getAllTickets());
    }

    @GetMapping("/{id}")
    public ResponseEntity<TicketResponse> getTicketById(@PathVariable Long id) {
        return ResponseEntity.ok(ticketService.getTicketById(id));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<TicketResponse> updateTicketStatus(
            @PathVariable Long id,
            @Valid @RequestBody TicketStatusUpdateRequest request
    ) {
        return ResponseEntity.ok(ticketService.updateTicketStatus(id, request.getStatus()));
    }

    @PatchMapping("/{id}/assign")
    public ResponseEntity<TicketResponse> assignTicket(
            @PathVariable Long id,
            @RequestBody com.opsflow.dto.ticket.TicketAssignmentRequest request
    ) {
        return ResponseEntity.ok(ticketService.assignTicket(id, request.getAgentId(), request.getTeamId()));
    }
}
