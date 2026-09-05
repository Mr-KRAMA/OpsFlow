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
