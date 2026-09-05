package com.opsflow.controller;

import com.opsflow.entity.KnowledgeArticle;
import com.opsflow.repository.KnowledgeArticleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/knowledge/articles")
@RequiredArgsConstructor
public class KnowledgeArticleController {

    private final KnowledgeArticleRepository articleRepository;

    @GetMapping
    public ResponseEntity<List<KnowledgeArticle>> getAllArticles() {
        return ResponseEntity.ok(articleRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<KnowledgeArticle> createArticle(@RequestBody KnowledgeArticle article) {
        return ResponseEntity.ok(articleRepository.save(article));
    }
}
