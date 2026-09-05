$basePackage = "com.opsflow.entity"
$enumsPackage = "$basePackage.enums"
$basePath = "src\main\java\com\opsflow\entity"
$enumsPath = "$basePath\enums"

New-Item -ItemType Directory -Force -Path $basePath
New-Item -ItemType Directory -Force -Path $enumsPath

$enums = @{
    "Role" = "public enum Role { EMPLOYEE, SUPPORT_AGENT, TEAM_LEAD, ADMIN }"
    "TicketStatus" = "public enum TicketStatus { NEW, TRIAGED, ASSIGNED, IN_PROGRESS, PENDING, RESOLVED, CLOSED, REOPENED }"
    "Priority" = "public enum Priority { LOW, MEDIUM, HIGH, CRITICAL }"
    "Impact" = "public enum Impact { LOW, MEDIUM, HIGH }"
    "Urgency" = "public enum Urgency { LOW, MEDIUM, HIGH }"
    "AssetStatus" = "public enum AssetStatus { ACTIVE, INACTIVE, REPAIR, RETIRED }"
    "ArticleStatus" = "public enum ArticleStatus { DRAFT, PUBLISHED, ARCHIVED }"
}

foreach ($key in $enums.Keys) {
    $content = "package $enumsPackage;`n`n$($enums[$key])"
    Set-Content -Path "$enumsPath\$key.java" -Value $content
}

$baseEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@MappedSuperclass
@Data
public abstract class BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
"@
Set-Content -Path "$basePath\BaseEntity.java" -Value $baseEntity

$userEntity = @"
package $basePackage;

import $enumsPackage.Role;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"users`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity {
    
    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    private String firstName;
    private String lastName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"team_id`")
    private Team team;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"department_id`")
    private Department department;

    @Column(nullable = false)
    private boolean active = true;
}
"@
Set-Content -Path "$basePath\User.java" -Value $userEntity

$teamEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"teams`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class Team extends BaseEntity {
    @Column(nullable = false, unique = true)
    private String name;
    
    private String description;
}
"@
Set-Content -Path "$basePath\Team.java" -Value $teamEntity

$departmentEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"departments`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class Department extends BaseEntity {
    @Column(nullable = false, unique = true)
    private String name;
}
"@
Set-Content -Path "$basePath\Department.java" -Value $departmentEntity

$ticketEntity = @"
package $basePackage;

import $enumsPackage.*;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = `"tickets`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ticket extends BaseEntity {

    @Column(unique = true, nullable = false, updatable = false)
    private String ticketNumber;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = `"TEXT`")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"category_id`")
    private TicketCategory category;

    private String subcategory;

    @Enumerated(EnumType.STRING)
    private Priority priority;

    @Enumerated(EnumType.STRING)
    private Impact impact;

    @Enumerated(EnumType.STRING)
    private Urgency urgency;

    @Enumerated(EnumType.STRING)
    private TicketStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"creator_id`", nullable = false)
    private User creator;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"assigned_agent_id`")
    private User assignedAgent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"assigned_team_id`")
    private Team assignedTeam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"asset_id`")
    private Asset asset;

    private LocalDateTime responseSlaDeadline;
    private LocalDateTime resolutionSlaDeadline;
    private LocalDateTime resolvedAt;
}
"@
Set-Content -Path "$basePath\Ticket.java" -Value $ticketEntity


$ticketCategoryEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"ticket_categories`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class TicketCategory extends BaseEntity {
    @Column(nullable = false, unique = true)
    private String name;
    
    private String description;
}
"@
Set-Content -Path "$basePath\TicketCategory.java" -Value $ticketCategoryEntity

$ticketCommentEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"ticket_comments`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TicketComment extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"ticket_id`", nullable = false)
    private Ticket ticket;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"author_id`", nullable = false)
    private User author;

    @Column(columnDefinition = `"TEXT`", nullable = false)
    private String content;

    @Column(nullable = false)
    private boolean isInternal;
}
"@
Set-Content -Path "$basePath\TicketComment.java" -Value $ticketCommentEntity

$ticketAttachmentEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"ticket_attachments`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TicketAttachment extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"ticket_id`", nullable = false)
    private Ticket ticket;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"uploader_id`", nullable = false)
    private User uploader;

    @Column(nullable = false)
    private String fileName;

    @Column(nullable = false)
    private String fileType;

    private Long fileSize;

    @Column(nullable = false)
    private String filePath;
}
"@
Set-Content -Path "$basePath\TicketAttachment.java" -Value $ticketAttachmentEntity


$assetEntity = @"
package $basePackage;

import $enumsPackage.AssetStatus;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"assets`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class Asset extends BaseEntity {
    @Column(unique = true, nullable = false)
    private String assetTag;

    private String deviceType;
    private String manufacturer;
    private String model;
    private String serialNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"assigned_user_id`")
    private User assignedUser;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"department_id`")
    private Department department;

    @Enumerated(EnumType.STRING)
    private AssetStatus status;
}
"@
Set-Content -Path "$basePath\Asset.java" -Value $assetEntity


$knowledgeArticleEntity = @"
package $basePackage;

import $enumsPackage.ArticleStatus;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"knowledge_articles`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class KnowledgeArticle extends BaseEntity {
    @Column(nullable = false)
    private String title;

    private String category;

    @Column(columnDefinition = `"TEXT`")
    private String problem;

    @Column(columnDefinition = `"TEXT`")
    private String solution;

    private String tags;

    @Enumerated(EnumType.STRING)
    private ArticleStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"author_id`")
    private User author;
}
"@
Set-Content -Path "$basePath\KnowledgeArticle.java" -Value $knowledgeArticleEntity

$auditLogEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = `"audit_logs`")
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
    
    @Column(columnDefinition = `"TEXT`")
    private String previousValue;
    
    @Column(columnDefinition = `"TEXT`")
    private String newValue;

    private LocalDateTime timestamp;
    private String ipAddress;
}
"@
Set-Content -Path "$basePath\AuditLog.java" -Value $auditLogEntity


$notificationEntity = @"
package $basePackage;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"notifications`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = `"user_id`", nullable = false)
    private User user;

    @Column(nullable = false)
    private String message;

    @Column(nullable = false)
    private boolean isRead = false;

    private Long relatedTicketId;
}
"@
Set-Content -Path "$basePath\Notification.java" -Value $notificationEntity


$slaPolicyEntity = @"
package $basePackage;

import $enumsPackage.Priority;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = `"sla_policies`")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class SLAPolicy extends BaseEntity {
    
    @Enumerated(EnumType.STRING)
    @Column(unique = true, nullable = false)
    private Priority priority;

    @Column(nullable = false)
    private Integer responseTimeHours;

    @Column(nullable = false)
    private Integer resolutionTimeHours;

    @Column(nullable = false)
    private boolean active = true;
}
"@
Set-Content -Path "$basePath\SLAPolicy.java" -Value $slaPolicyEntity
