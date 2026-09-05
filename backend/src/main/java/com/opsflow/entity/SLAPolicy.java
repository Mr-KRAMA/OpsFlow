package com.opsflow.entity;

import com.opsflow.entity.enums.Priority;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "sla_policies")
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
