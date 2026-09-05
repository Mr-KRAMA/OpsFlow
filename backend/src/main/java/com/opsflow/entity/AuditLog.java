package com.opsflow.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "audit_logs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String userEmail;
    private String action;
    private String entityType;
    private String entityId;
    
    @Column(columnDefinition = "TEXT")
    private String previousValue;
    
    @Column(columnDefinition = "TEXT")
    private String newValue;

    private LocalDateTime timestamp;
    private String ipAddress;
}
