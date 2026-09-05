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
