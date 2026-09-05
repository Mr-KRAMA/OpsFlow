package com.opsflow.entity;

import com.opsflow.entity.enums.AssetStatus;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "assets")
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
    @JoinColumn(name = "assigned_user_id")
    private User assignedUser;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;

    @Enumerated(EnumType.STRING)
    private AssetStatus status;
}
