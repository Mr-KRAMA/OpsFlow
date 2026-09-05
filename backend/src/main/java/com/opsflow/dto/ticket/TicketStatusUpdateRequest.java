package com.opsflow.dto.ticket;

import com.opsflow.entity.enums.TicketStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TicketStatusUpdateRequest {
    @NotNull
    private TicketStatus status;
}
