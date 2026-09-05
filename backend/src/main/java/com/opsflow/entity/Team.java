package com.opsflow.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "teams")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class Team extends BaseEntity {
    @Column(nullable = false, unique = true)
    private String name;
    
    private String description;
}
