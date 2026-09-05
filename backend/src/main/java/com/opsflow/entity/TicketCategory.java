package com.opsflow.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "ticket_categories")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class TicketCategory extends BaseEntity {
    @Column(nullable = false, unique = true)
    private String name;
    
    private String description;
}
