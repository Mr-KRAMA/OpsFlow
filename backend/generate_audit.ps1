$aopPath = "src\main\java\com\opsflow\audit"
$repoPath = "src\main\java\com\opsflow\repository"
$controllerPath = "src\main\java\com\opsflow\controller"
$servicePath = "src\main\java\com\opsflow\service"

New-Item -ItemType Directory -Force -Path $aopPath

$auditRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
    List<AuditLog> findByEntityIdAndEntityType(String entityId, String entityType);
}
"@
Set-Content -Path "$repoPath\AuditLogRepository.java" -Value $auditRepo

$auditableAnnotation = @"
package com.opsflow.audit;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Auditable {
    String action();
    String entityType() default "Ticket";
}
"@
Set-Content -Path "$aopPath\Auditable.java" -Value $auditableAnnotation

$auditAspect = @"
package com.opsflow.audit;

import com.opsflow.entity.AuditLog;
import com.opsflow.repository.AuditLogRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;

@Aspect
@Component
@RequiredArgsConstructor
public class AuditAspect {

    private final AuditLogRepository auditLogRepository;

    @AfterReturning(pointcut = "@annotation(auditable)", returning = "result")
    public void logAction(JoinPoint joinPoint, Auditable auditable, Object result) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = (auth != null) ? auth.getName() : "SYSTEM";
        
        String ipAddress = "UNKNOWN";
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            HttpServletRequest request = attributes.getRequest();
            ipAddress = request.getRemoteAddr();
        }

        // Try to extract entity ID if result is a known DTO
        String entityId = "N/A";
        try {
            if (result != null) {
                java.lang.reflect.Method getIdMethod = result.getClass().getMethod("getId");
                Object id = getIdMethod.invoke(result);
                if (id != null) entityId = String.valueOf(id);
            }
        } catch (Exception e) {
            // Ignore if no getId method
        }

        AuditLog log = AuditLog.builder()
                .userEmail(userEmail)
                .action(auditable.action())
                .entityType(auditable.entityType())
                .entityId(entityId)
                .timestamp(LocalDateTime.now())
                .ipAddress(ipAddress)
                .build();

        auditLogRepository.save(log);
    }
}
"@
Set-Content -Path "$aopPath\AuditAspect.java" -Value $auditAspect


$auditController = @"
package com.opsflow.controller;

import com.opsflow.entity.AuditLog;
import com.opsflow.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/audit-logs")
@RequiredArgsConstructor
public class AuditController {

    private final AuditLogRepository auditLogRepository;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AuditLog>> getAuditLogs() {
        // In a real app, use pagination
        return ResponseEntity.ok(auditLogRepository.findAll());
    }
}
"@
Set-Content -Path "$controllerPath\AuditController.java" -Value $auditController
