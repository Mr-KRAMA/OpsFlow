package com.opsflow.entity;

import com.opsflow.entity.enums.ArticleStatus;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "knowledge_articles")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class KnowledgeArticle extends BaseEntity {
    @Column(nullable = false)
    private String title;

    private String category;

    @Column(columnDefinition = "TEXT")
    private String problem;

    @Column(columnDefinition = "TEXT")
    private String solution;

    private String tags;

    @Enumerated(EnumType.STRING)
    private ArticleStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id")
    private User author;
}
