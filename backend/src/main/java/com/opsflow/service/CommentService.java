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
