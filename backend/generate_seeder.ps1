$seederPath = "src\main\java\com\opsflow\component"
New-Item -ItemType Directory -Force -Path $seederPath

$dbSeeder = @"
package com.opsflow.component;

import com.opsflow.entity.Team;
import com.opsflow.entity.User;
import com.opsflow.entity.enums.Role;
import com.opsflow.repository.TeamRepository;
import com.opsflow.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.context.annotation.Profile;

@Component
@RequiredArgsConstructor
@Profile("!test")
public class DatabaseSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (userRepository.count() == 0) {
            seedTeams();
            seedUsers();
        }
    }

    private void seedTeams() {
        Team itSupport = new Team();
        itSupport.setName("IT Support Level 1");
        itSupport.setDescription("First line of IT support");
        
        Team networkTeam = new Team();
        networkTeam.setName("Network Infrastructure");
        networkTeam.setDescription("Handles all networking issues");

        teamRepository.save(itSupport);
        teamRepository.save(networkTeam);
    }

    private void seedUsers() {
        Team itSupport = teamRepository.findAll().get(0);

        User admin = User.builder()
                .firstName("System")
                .lastName("Admin")
                .email("admin@opsflow.com")
                .password(passwordEncoder.encode("admin123"))
                .role(Role.ADMIN)
                .active(true)
                .build();

        User teamLead = User.builder()
                .firstName("John")
                .lastName("Doe")
                .email("lead@opsflow.com")
                .password(passwordEncoder.encode("lead123"))
                .role(Role.TEAM_LEAD)
                .team(itSupport)
                .active(true)
                .build();

        User agent = User.builder()
                .firstName("Jane")
                .lastName("Smith")
                .email("agent@opsflow.com")
                .password(passwordEncoder.encode("agent123"))
                .role(Role.SUPPORT_AGENT)
                .team(itSupport)
                .active(true)
                .build();

        User employee = User.builder()
                .firstName("Bob")
                .lastName("Employee")
                .email("employee@opsflow.com")
                .password(passwordEncoder.encode("emp123"))
                .role(Role.EMPLOYEE)
                .active(true)
                .build();

        userRepository.save(admin);
        userRepository.save(teamLead);
        userRepository.save(agent);
        userRepository.save(employee);
    }
}
"@
Set-Content -Path "$seederPath\DatabaseSeeder.java" -Value $dbSeeder
