package com.opsflow.dto.user;

import com.opsflow.entity.enums.Role;
import lombok.Data;

@Data
public class UserUpdateRequest {
    private String firstName;
    private String lastName;
    private Role role;
    private Long teamId;
    private Boolean active;
}
