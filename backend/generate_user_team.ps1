$dtoPath = "src\main\java\com\opsflow\dto\user"
$teamDtoPath = "src\main\java\com\opsflow\dto\team"
$controllerPath = "src\main\java\com\opsflow\controller"
$servicePath = "src\main\java\com\opsflow\service"
$repoPath = "src\main\java\com\opsflow\repository"

New-Item -ItemType Directory -Force -Path $dtoPath
New-Item -ItemType Directory -Force -Path $teamDtoPath

$teamRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TeamRepository extends JpaRepository<Team, Long> {
}
"@
Set-Content -Path "$repoPath\TeamRepository.java" -Value $teamRepo

$departmentRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.Department;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DepartmentRepository extends JpaRepository<Department, Long> {
    Optional<Department> findByName(String name);
}
"@
Set-Content -Path "$repoPath\DepartmentRepository.java" -Value $departmentRepo

$userResponse = @"
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
"@
Set-Content -Path "$dtoPath\UserResponse.java" -Value $userResponse

$userUpdateRequest = @"
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
"@
Set-Content -Path "$dtoPath\UserUpdateRequest.java" -Value $userUpdateRequest

$teamResponse = @"
package com.opsflow.dto.team;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class TeamResponse {
    private Long id;
    private String name;
    private String description;
    private LocalDateTime createdAt;
}
"@
Set-Content -Path "$teamDtoPath\TeamResponse.java" -Value $teamResponse

$teamRequest = @"
package com.opsflow.dto.team;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeamRequest {
    @NotBlank
    private String name;
    private String description;
}
"@
Set-Content -Path "$teamDtoPath\TeamRequest.java" -Value $teamRequest

$userService = @"
package com.opsflow.service;

import com.opsflow.dto.user.UserResponse;
import com.opsflow.dto.user.UserUpdateRequest;
import com.opsflow.entity.Team;
import com.opsflow.entity.User;
import com.opsflow.repository.TeamRepository;
import com.opsflow.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final TeamRepository teamRepository;

    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public UserResponse getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return mapToResponse(user);
    }

    public UserResponse updateUser(Long id, UserUpdateRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (request.getFirstName() != null) user.setFirstName(request.getFirstName());
        if (request.getLastName() != null) user.setLastName(request.getLastName());
        if (request.getRole() != null) user.setRole(request.getRole());
        if (request.getActive() != null) user.setActive(request.getActive());

        if (request.getTeamId() != null) {
            Team team = teamRepository.findById(request.getTeamId())
                    .orElseThrow(() -> new RuntimeException("Team not found"));
            user.setTeam(team);
        }

        user = userRepository.save(user);
        return mapToResponse(user);
    }

    private UserResponse mapToResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .role(user.getRole())
                .teamId(user.getTeam() != null ? user.getTeam().getId() : null)
                .teamName(user.getTeam() != null ? user.getTeam().getName() : null)
                .active(user.isActive())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
"@
Set-Content -Path "$servicePath\UserService.java" -Value $userService

$teamService = @"
package com.opsflow.service;

import com.opsflow.dto.team.TeamRequest;
import com.opsflow.dto.team.TeamResponse;
import com.opsflow.entity.Team;
import com.opsflow.repository.TeamRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamService {
    private final TeamRepository teamRepository;

    public List<TeamResponse> getAllTeams() {
        return teamRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public TeamResponse getTeamById(Long id) {
        Team team = teamRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Team not found"));
        return mapToResponse(team);
    }

    public TeamResponse createTeam(TeamRequest request) {
        Team team = new Team();
        team.setName(request.getName());
        team.setDescription(request.getDescription());
        team = teamRepository.save(team);
        return mapToResponse(team);
    }

    public TeamResponse updateTeam(Long id, TeamRequest request) {
        Team team = teamRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Team not found"));
        team.setName(request.getName());
        team.setDescription(request.getDescription());
        team = teamRepository.save(team);
        return mapToResponse(team);
    }

    private TeamResponse mapToResponse(Team team) {
        return TeamResponse.builder()
                .id(team.getId())
                .name(team.getName())
                .description(team.getDescription())
                .createdAt(team.getCreatedAt())
                .build();
    }
}
"@
Set-Content -Path "$servicePath\TeamService.java" -Value $teamService

$userController = @"
package com.opsflow.controller;

import com.opsflow.dto.user.UserResponse;
import com.opsflow.dto.user.UserUpdateRequest;
import com.opsflow.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TEAM_LEAD')")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEAM_LEAD')")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable Long id,
            @RequestBody UserUpdateRequest request
    ) {
        return ResponseEntity.ok(userService.updateUser(id, request));
    }
}
"@
Set-Content -Path "$controllerPath\UserController.java" -Value $userController

$teamController = @"
package com.opsflow.controller;

import com.opsflow.dto.team.TeamRequest;
import com.opsflow.dto.team.TeamResponse;
import com.opsflow.service.TeamService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/teams")
@RequiredArgsConstructor
public class TeamController {

    private final TeamService teamService;

    @GetMapping
    public ResponseEntity<List<TeamResponse>> getAllTeams() {
        return ResponseEntity.ok(teamService.getAllTeams());
    }

    @GetMapping("/{id}")
    public ResponseEntity<TeamResponse> getTeamById(@PathVariable Long id) {
        return ResponseEntity.ok(teamService.getTeamById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TeamResponse> createTeam(@Valid @RequestBody TeamRequest request) {
        return ResponseEntity.ok(teamService.createTeam(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TeamResponse> updateTeam(
            @PathVariable Long id,
            @Valid @RequestBody TeamRequest request
    ) {
        return ResponseEntity.ok(teamService.updateTeam(id, request));
    }
}
"@
Set-Content -Path "$controllerPath\TeamController.java" -Value $teamController
