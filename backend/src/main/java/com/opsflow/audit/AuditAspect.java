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
