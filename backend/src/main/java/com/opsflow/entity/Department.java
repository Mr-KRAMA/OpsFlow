package com.opsflow.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "departments")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class Department extends BaseEntity {
    @Column(nullable = false, unique = true)
    private String name;
}
