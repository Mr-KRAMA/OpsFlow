package com.opsflow.service;

import com.opsflow.entity.Ticket;
import com.opsflow.entity.enums.TicketStatus;
import com.opsflow.repository.TicketRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TicketServiceTest {

    @Mock
    private TicketRepository ticketRepository;

    @InjectMocks
    private TicketService ticketService;

    @Test
    void testUpdateTicketStatus_Success() {
        Ticket ticket = new Ticket();
        ticket.setId(1L);
        ticket.setStatus(TicketStatus.NEW);

        when(ticketRepository.findById(1L)).thenReturn(Optional.of(ticket));
        when(ticketRepository.save(any(Ticket.class))).thenReturn(ticket);

        var result = ticketService.updateTicketStatus(1L, TicketStatus.TRIAGED);
        
        assertEquals(TicketStatus.TRIAGED, result.getStatus());
        verify(ticketRepository).save(ticket);
    }
}
