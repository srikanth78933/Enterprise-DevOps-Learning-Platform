package com.enterprise.devops.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

/**
 * Lightweight liveness endpoint used by the frontend "Health" page and by
 * Kubernetes readiness/liveness probes in later projects.
 * Deeper health info (DB connectivity, disk space) is exposed separately
 * by Spring Boot Actuator at /actuator/health.
 */
@RestController
@RequestMapping("/api/health")
public class HealthController {

    @GetMapping
    public Map<String, Object> health() {
        return Map.of(
                "status", "UP",
                "service", "enterprise-devops-backend",
                "timestamp", Instant.now().toString()
        );
    }
}
