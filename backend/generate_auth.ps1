$dtoPath = "src\main\java\com\opsflow\dto\auth"
$controllerPath = "src\main\java\com\opsflow\controller"
$servicePath = "src\main\java\com\opsflow\service"

New-Item -ItemType Directory -Force -Path $dtoPath
New-Item -ItemType Directory -Force -Path $controllerPath
New-Item -ItemType Directory -Force -Path $servicePath

$authRequest = @"
package com.opsflow.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AuthRequest {
    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;
}
"@
Set-Content -Path "$dtoPath\AuthRequest.java" -Value $authRequest

$registerRequest = @"
package com.opsflow.dto.auth;

import com.opsflow.entity.enums.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @NotNull
    private Role role;
}
"@
Set-Content -Path "$dtoPath\RegisterRequest.java" -Value $registerRequest

$authResponse = @"
package com.opsflow.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    private String token;
    private String email;
    private String role;
}
"@
Set-Content -Path "$dtoPath\AuthResponse.java" -Value $authResponse

$authService = @"
package com.opsflow.service;

import com.opsflow.dto.auth.AuthRequest;
import com.opsflow.dto.auth.AuthResponse;
import com.opsflow.dto.auth.RegisterRequest;
import com.opsflow.entity.User;
import com.opsflow.repository.UserRepository;
import com.opsflow.security.JwtUtil;
import com.opsflow.security.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already in use");
        }

        var user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .active(true)
                .build();

        userRepository.save(user);

        var userDetails = new UserDetailsImpl(user);
        var jwtToken = jwtUtil.generateToken(userDetails);

        return AuthResponse.builder()
                .token(jwtToken)
                .email(user.getEmail())
                .role(user.getRole().name())
                .build();
    }

    public AuthResponse authenticate(AuthRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        var user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        var userDetails = new UserDetailsImpl(user);
        var jwtToken = jwtUtil.generateToken(userDetails);

        return AuthResponse.builder()
                .token(jwtToken)
                .email(user.getEmail())
                .role(user.getRole().name())
                .build();
    }
}
"@
Set-Content -Path "$servicePath\AuthService.java" -Value $authService


$authController = @"
package com.opsflow.controller;

import com.opsflow.dto.auth.AuthRequest;
import com.opsflow.dto.auth.AuthResponse;
import com.opsflow.dto.auth.RegisterRequest;
import com.opsflow.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> authenticate(
            @Valid @RequestBody AuthRequest request
    ) {
        return ResponseEntity.ok(authService.authenticate(request));
    }
}
"@
Set-Content -Path "$controllerPath\AuthController.java" -Value $authController
