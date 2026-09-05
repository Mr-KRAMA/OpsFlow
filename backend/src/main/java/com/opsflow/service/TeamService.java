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
