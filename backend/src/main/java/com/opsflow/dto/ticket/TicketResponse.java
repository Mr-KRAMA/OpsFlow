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
