package com.opsflow.dto.team;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeamRequest {
    @NotBlank
    private String name;
    private String description;
}
