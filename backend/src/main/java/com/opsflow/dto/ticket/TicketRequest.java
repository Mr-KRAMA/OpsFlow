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
