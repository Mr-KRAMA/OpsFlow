$dtoPath = "src\main\java\com\opsflow\dto\ticket"
$commentDtoPath = "src\main\java\com\opsflow\dto\comment"
$controllerPath = "src\main\java\com\opsflow\controller"
$servicePath = "src\main\java\com\opsflow\service"
$repoPath = "src\main\java\com\opsflow\repository"

New-Item -ItemType Directory -Force -Path $commentDtoPath

$assignmentRequest = @"
package com.opsflow.dto.ticket;

import lombok.Data;

@Data
public class TicketAssignmentRequest {
    private Long agentId;
    private Long teamId;
}
"@
Set-Content -Path "$dtoPath\TicketAssignmentRequest.java" -Value $assignmentRequest

$commentRequest = @"
package com.opsflow.dto.comment;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CommentRequest {
    @NotBlank
    private String content;
    private boolean isInternal;
}
"@
Set-Content -Path "$commentDtoPath\CommentRequest.java" -Value $commentRequest

$commentResponse = @"
package com.opsflow.dto.comment;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class CommentResponse {
    private Long id;
    private Long ticketId;
    private String authorName;
    private String content;
    private boolean isInternal;
    private LocalDateTime createdAt;
}
"@
Set-Content -Path "$commentDtoPath\CommentResponse.java" -Value $commentResponse

$commentRepo = @"
package com.opsflow.repository;

import com.opsflow.entity.TicketComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TicketCommentRepository extends JpaRepository<TicketComment, Long> {
    List<TicketComment> findByTicketId(Long ticketId);
    List<TicketComment> findByTicketIdAndIsInternalFalse(Long ticketId);
}
"@
Set-Content -Path "$repoPath\TicketCommentRepository.java" -Value $commentRepo

$commentService = @"
package com.opsflow.service;

import com.opsflow.dto.comment.CommentRequest;
import com.opsflow.dto.comment.CommentResponse;
import com.opsflow.entity.Ticket;
import com.opsflow.entity.TicketComment;
import com.opsflow.entity.User;
import com.opsflow.entity.enums.Role;
import com.opsflow.repository.TicketCommentRepository;
import com.opsflow.repository.TicketRepository;
import com.opsflow.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final TicketCommentRepository commentRepository;
    private final TicketRepository ticketRepository;
    private final UserRepository userRepository;

    public CommentResponse addComment(Long ticketId, CommentRequest request, String userEmail) {
        User author = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new RuntimeException("Ticket not found"));

        if (request.isInternal() && author.getRole() == Role.EMPLOYEE) {
            throw new RuntimeException("Employees cannot add internal notes");
        }

        TicketComment comment = TicketComment.builder()
                .ticket(ticket)
                .author(author)
                .content(request.getContent())
                .isInternal(request.isInternal())
                .build();

        comment = commentRepository.save(comment);
        return mapToResponse(comment);
    }

    public List<CommentResponse> getCommentsByTicketId(Long ticketId, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<TicketComment> comments;
        if (user.getRole() == Role.EMPLOYEE) {
            comments = commentRepository.findByTicketIdAndIsInternalFalse(ticketId);
        } else {
            comments = commentRepository.findByTicketId(ticketId);
        }

        return comments.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private CommentResponse mapToResponse(TicketComment comment) {
        return CommentResponse.builder()
                .id(comment.getId())
                .ticketId(comment.getTicket().getId())
                .authorName(comment.getAuthor().getFirstName() + " " + comment.getAuthor().getLastName())
                .content(comment.getContent())
                .isInternal(comment.isInternal())
                .createdAt(comment.getCreatedAt())
                .build();
    }
}
"@
Set-Content -Path "$servicePath\CommentService.java" -Value $commentService

$commentController = @"
package com.opsflow.controller;

import com.opsflow.dto.comment.CommentRequest;
import com.opsflow.dto.comment.CommentResponse;
import com.opsflow.service.CommentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tickets/{ticketId}/comments")
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;

    @PostMapping
    public ResponseEntity<CommentResponse> addComment(
            @PathVariable Long ticketId,
            @Valid @RequestBody CommentRequest request,
            Authentication authentication
    ) {
        return ResponseEntity.ok(commentService.addComment(ticketId, request, authentication.getName()));
    }

    @GetMapping
    public ResponseEntity<List<CommentResponse>> getComments(
            @PathVariable Long ticketId,
            Authentication authentication
    ) {
        return ResponseEntity.ok(commentService.getCommentsByTicketId(ticketId, authentication.getName()));
    }
}
"@
Set-Content -Path "$controllerPath\CommentController.java" -Value $commentController
