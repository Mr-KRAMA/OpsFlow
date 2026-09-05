$dtoPath = "src\main\java\com\opsflow\dto\ticket"
$repoPath = "src\main\java\com\opsflow\repository"
$servicePath = "src\main\java\com\opsflow\service"
$controllerPath = "src\main\java\com\opsflow\controller"

New-Item -ItemType Directory -Force -Path $dtoPath

$ticketRepo = @"
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
"@
Set-Content -Path "$repoPath\TicketRepository.java" -Value $ticketRepo

$categoryRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.TicketCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TicketCategoryRepository extends JpaRepository<TicketCategory, Long> {
}
"@
Set-Content -Path "$repoPath\TicketCategoryRepository.java" -Value $categoryRepo

$ticketRequest = @"
package com.opsflow.dto.ticket;

import com.opsflow.entity.enums.Impact;
import com.opsflow.entity.enums.Priority;
import com.opsflow.entity.enums.Urgency;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TicketRequest {
    @NotBlank
    private String title;
    @NotBlank
    private String description;
    @NotNull
    private Long categoryId;
    
    private String subcategory;
    
    @NotNull
    private Impact impact;
    
    @NotNull
    private Urgency urgency;
    
    private Long assetId;
}
"@
Set-Content -Path "$dtoPath\TicketRequest.java" -Value $ticketRequest

$ticketResponse = @"
package com.opsflow.dto.ticket;

import com.opsflow.entity.enums.Impact;
import com.opsflow.entity.enums.Priority;
import com.opsflow.entity.enums.TicketStatus;
import com.opsflow.entity.enums.Urgency;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class TicketResponse {
    private Long id;
    private String ticketNumber;
    private String title;
    private String description;
    private String categoryName;
    private Priority priority;
    private Impact impact;
    private Urgency urgency;
    private TicketStatus status;
    private String creatorName;
    private String assignedAgentName;
    private String assignedTeamName;
    private LocalDateTime responseSlaDeadline;
    private LocalDateTime resolutionSlaDeadline;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
"@
Set-Content -Path "$dtoPath\TicketResponse.java" -Value $ticketResponse


$ticketStatusUpdate = @"
package com.opsflow.dto.ticket;

import com.opsflow.entity.enums.TicketStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TicketStatusUpdateRequest {
    @NotNull
    private TicketStatus status;
}
"@
Set-Content -Path "$dtoPath\TicketStatusUpdateRequest.java" -Value $ticketStatusUpdate


$ticketService = @"
package com.opsflow.service;

import com.opsflow.dto.ticket.TicketRequest;
import com.opsflow.dto.ticket.TicketResponse;
import com.opsflow.entity.Ticket;
import com.opsflow.entity.User;
import com.opsflow.entity.TicketCategory;
import com.opsflow.entity.enums.Priority;
import com.opsflow.entity.enums.TicketStatus;
import com.opsflow.repository.TicketCategoryRepository;
import com.opsflow.repository.TicketRepository;
import com.opsflow.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TicketService {
    private final TicketRepository ticketRepository;
    private final TicketCategoryRepository categoryRepository;
    private final UserRepository userRepository;

    public TicketResponse createTicket(TicketRequest request, String userEmail) {
        User creator = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        TicketCategory category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));

        Priority priority = calculatePriority(request.getImpact().name(), request.getUrgency().name());

        Ticket ticket = Ticket.builder()
                .ticketNumber(generateTicketNumber())
                .title(request.getTitle())
                .description(request.getDescription())
                .category(category)
                .subcategory(request.getSubcategory())
                .impact(request.getImpact())
                .urgency(request.getUrgency())
                .priority(priority)
                .status(TicketStatus.NEW)
                .creator(creator)
                .build();

        // Basic SLA generation logic (placeholder for full SLA engine)
        ticket.setResponseSlaDeadline(LocalDateTime.now().plusHours(getSlaHours(priority, true)));
        ticket.setResolutionSlaDeadline(LocalDateTime.now().plusHours(getSlaHours(priority, false)));

        ticket = ticketRepository.save(ticket);
        return mapToResponse(ticket);
    }

    public TicketResponse updateTicketStatus(Long ticketId, TicketStatus newStatus) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new RuntimeException("Ticket not found"));

        validateStateTransition(ticket.getStatus(), newStatus);
        
        ticket.setStatus(newStatus);
        if (newStatus == TicketStatus.RESOLVED || newStatus == TicketStatus.CLOSED) {
            ticket.setResolvedAt(LocalDateTime.now());
        }

        ticket = ticketRepository.save(ticket);
        return mapToResponse(ticket);
    }

    public List<TicketResponse> getAllTickets() {
        return ticketRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public TicketResponse getTicketById(Long id) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Ticket not found"));
        return mapToResponse(ticket);
    }

    private void validateStateTransition(TicketStatus current, TicketStatus target) {
        // Simple state machine validation
        boolean valid = switch (current) {
            case NEW -> target == TicketStatus.TRIAGED || target == TicketStatus.ASSIGNED || target == TicketStatus.CLOSED;
            case TRIAGED -> target == TicketStatus.ASSIGNED || target == TicketStatus.CLOSED;
            case ASSIGNED -> target == TicketStatus.IN_PROGRESS || target == TicketStatus.CLOSED;
            case IN_PROGRESS -> target == TicketStatus.PENDING || target == TicketStatus.RESOLVED || target == TicketStatus.ASSIGNED;
            case PENDING -> target == TicketStatus.IN_PROGRESS || target == TicketStatus.RESOLVED;
            case RESOLVED -> target == TicketStatus.CLOSED || target == TicketStatus.REOPENED;
            case CLOSED -> false;
            case REOPENED -> target == TicketStatus.ASSIGNED || target == TicketStatus.IN_PROGRESS;
        };
        
        if (!valid) {
            throw new RuntimeException("Invalid state transition from " + current + " to " + target);
        }
    }

    private String generateTicketNumber() {
        String year = String.valueOf(LocalDateTime.now().getYear());
        String randomStr = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        return "INC-" + year + "-" + randomStr;
    }

    private Priority calculatePriority(String impact, String urgency) {
        if (impact.equals("HIGH") && urgency.equals("HIGH")) return Priority.CRITICAL;
        if (impact.equals("HIGH") || urgency.equals("HIGH")) return Priority.HIGH;
        if (impact.equals("MEDIUM") && urgency.equals("MEDIUM")) return Priority.MEDIUM;
        return Priority.LOW;
    }

    private int getSlaHours(Priority priority, boolean isResponse) {
        return switch (priority) {
            case CRITICAL -> isResponse ? 1 : 4;
            case HIGH -> isResponse ? 2 : 8;
            case MEDIUM -> isResponse ? 4 : 24;
            case LOW -> isResponse ? 8 : 48;
        };
    }

    private TicketResponse mapToResponse(Ticket ticket) {
        return TicketResponse.builder()
                .id(ticket.getId())
                .ticketNumber(ticket.getTicketNumber())
                .title(ticket.getTitle())
                .description(ticket.getDescription())
                .categoryName(ticket.getCategory() != null ? ticket.getCategory().getName() : null)
                .priority(ticket.getPriority())
                .impact(ticket.getImpact())
                .urgency(ticket.getUrgency())
                .status(ticket.getStatus())
                .creatorName(ticket.getCreator() != null ? ticket.getCreator().getFirstName() : null)
                .assignedAgentName(ticket.getAssignedAgent() != null ? ticket.getAssignedAgent().getFirstName() : "Unassigned")
                .assignedTeamName(ticket.getAssignedTeam() != null ? ticket.getAssignedTeam().getName() : "Unassigned")
                .responseSlaDeadline(ticket.getResponseSlaDeadline())
                .resolutionSlaDeadline(ticket.getResolutionSlaDeadline())
                .createdAt(ticket.getCreatedAt())
                .updatedAt(ticket.getUpdatedAt())
                .build();
    }
}
"@
Set-Content -Path "$servicePath\TicketService.java" -Value $ticketService


$ticketController = @"
package com.opsflow.controller;

import com.opsflow.dto.ticket.TicketRequest;
import com.opsflow.dto.ticket.TicketResponse;
import com.opsflow.dto.ticket.TicketStatusUpdateRequest;
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
}
"@
Set-Content -Path "$controllerPath\TicketController.java" -Value $ticketController
