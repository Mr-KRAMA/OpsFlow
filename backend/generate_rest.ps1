$controllerPath = "src\main\java\com\opsflow\controller"
$repoPath = "src\main\java\com\opsflow\repository"

# Notification
$notifRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserEmailOrderByCreatedAtDesc(String email);
    List<Notification> findByUserEmailAndIsReadFalse(String email);
}
"@
Set-Content -Path "$repoPath\NotificationRepository.java" -Value $notifRepo

$notifController = @"
package com.opsflow.controller;

import com.opsflow.entity.Notification;
import com.opsflow.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationRepository notificationRepository;

    @GetMapping
    public ResponseEntity<List<Notification>> getMyNotifications(Authentication auth) {
        return ResponseEntity.ok(notificationRepository.findByUserEmailOrderByCreatedAtDesc(auth.getName()));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationRepository.findById(id).ifPresent(n -> {
            n.setRead(true);
            notificationRepository.save(n);
        });
        return ResponseEntity.ok().build();
    }
}
"@
Set-Content -Path "$controllerPath\NotificationController.java" -Value $notifController

# Asset
$assetRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.Asset;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AssetRepository extends JpaRepository<Asset, Long> {}
"@
Set-Content -Path "$repoPath\AssetRepository.java" -Value $assetRepo

$assetController = @"
package com.opsflow.controller;

import com.opsflow.entity.Asset;
import com.opsflow.repository.AssetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/assets")
@RequiredArgsConstructor
public class AssetController {

    private final AssetRepository assetRepository;

    @GetMapping
    public ResponseEntity<List<Asset>> getAllAssets() {
        return ResponseEntity.ok(assetRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Asset> createAsset(@RequestBody Asset asset) {
        return ResponseEntity.ok(assetRepository.save(asset));
    }
}
"@
Set-Content -Path "$controllerPath\AssetController.java" -Value $assetController

# Knowledge Base
$kbRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.KnowledgeArticle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KnowledgeArticleRepository extends JpaRepository<KnowledgeArticle, Long> {}
"@
Set-Content -Path "$repoPath\KnowledgeArticleRepository.java" -Value $kbRepo

$kbController = @"
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
"@
Set-Content -Path "$controllerPath\KnowledgeArticleController.java" -Value $kbController

# Dashboard
$dashController = @"
package com.opsflow.controller;

import com.opsflow.entity.enums.TicketStatus;
import com.opsflow.repository.TicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final TicketRepository ticketRepository;

    @GetMapping("/admin")
    public ResponseEntity<Map<String, Object>> getAdminDashboard() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalTickets", ticketRepository.count());
        stats.put("openTickets", ticketRepository.findByStatus(TicketStatus.NEW).size() + ticketRepository.findByStatus(TicketStatus.IN_PROGRESS).size());
        stats.put("resolvedTickets", ticketRepository.findByStatus(TicketStatus.RESOLVED).size());
        return ResponseEntity.ok(stats);
    }
}
"@
Set-Content -Path "$controllerPath\DashboardController.java" -Value $dashController

