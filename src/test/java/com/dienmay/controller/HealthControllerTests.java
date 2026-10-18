package com.dienmay.controller;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.sql.Connection;
import java.sql.SQLException;
import javax.sql.DataSource;

import org.junit.jupiter.api.Test;
import org.springframework.boot.availability.ApplicationAvailability;
import org.springframework.boot.availability.ReadinessState;
import org.springframework.http.HttpStatus;

class HealthControllerTests {
    private final DataSource dataSource = mock(DataSource.class);
    private final ApplicationAvailability availability = mock(ApplicationAvailability.class);
    private final HealthController controller = new HealthController(dataSource, availability);

    @Test
    void startupIsNotReadyAndDoesNotBorrowDatabaseConnection() {
        when(availability.getReadinessState()).thenReturn(ReadinessState.REFUSING_TRAFFIC);
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, controller.health().getStatusCode());
        verifyNoInteractions(dataSource);
    }

    @Test
    void readyDatabaseIsHealthyAndConnectionIsReturned() throws Exception {
        when(availability.getReadinessState()).thenReturn(ReadinessState.ACCEPTING_TRAFFIC);
        Connection connection = mock(Connection.class);
        when(dataSource.getConnection()).thenReturn(connection);
        when(connection.isValid(2)).thenReturn(true);
        assertEquals(HttpStatus.OK, controller.health().getStatusCode());
        verify(connection).close();
    }

    @Test
    void invalidConnectionReturnsUnavailableAndClosesConnection() throws Exception {
        when(availability.getReadinessState()).thenReturn(ReadinessState.ACCEPTING_TRAFFIC);
        Connection connection = mock(Connection.class);
        when(dataSource.getConnection()).thenReturn(connection);
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, controller.health().getStatusCode());
        verify(connection).close();
    }

    @Test
    void exhaustedPoolReturnsUnavailableWithoutExposingDatabaseDetails() throws Exception {
        when(availability.getReadinessState()).thenReturn(ReadinessState.ACCEPTING_TRAFFIC);
        when(dataSource.getConnection()).thenThrow(new SQLException("private database details"));
        var response = controller.health();
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, response.getStatusCode());
        assertEquals("DOWN", response.getBody().get("status"));
        assertEquals(1, response.getBody().size());
    }
}
