package com.dienmay.controller;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.boot.availability.ApplicationAvailability;
import org.springframework.boot.availability.ReadinessState;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class HealthController {
    private final DataSource dataSource;
    private final ApplicationAvailability availability;

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        // Do not report ready before startup tasks (including data seeding) finish.
        if (availability.getReadinessState() != ReadinessState.ACCEPTING_TRAFFIC) {
            return unavailable();
        }
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(2)) {
                return ResponseEntity.ok(Map.of("status", "UP"));
            }
        } catch (SQLException ex) {
            // Keep database details out of this public endpoint.
        }
        return unavailable();
    }

    private ResponseEntity<Map<String, String>> unavailable() {
        return ResponseEntity.status(503).body(Map.of("status", "DOWN"));
    }
}
