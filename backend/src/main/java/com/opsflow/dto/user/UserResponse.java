package com.opsflow.dto.user;

import com.opsflow.entity.enums.Role;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class UserResponse {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private Role role;
    private Long teamId;
    private String teamName;
    private boolean active;
    private LocalDateTime createdAt;
}
