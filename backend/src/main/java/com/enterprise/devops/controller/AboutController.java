package com.enterprise.devops.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/about")
public class AboutController {

    @Value("${app.version}")
    private String appVersion;

    @GetMapping
    public Map<String, Object> about() {
        return Map.of(
                "name", "Enterprise DevOps Learning Platform",
                "description", "A single evolving application used to teach CI/CD, GitOps, "
                        + "observability, and Kubernetes across progressive projects.",
                "version", appVersion,
                "modules", new String[] {"Employee", "Department", "Project", "Health", "About"}
        );
    }
}
