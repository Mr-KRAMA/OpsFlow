package com.opsflow.dto.ticket;

import lombok.Data;

@Data
public class TicketAssignmentRequest {
    private Long agentId;
    private Long teamId;
}
