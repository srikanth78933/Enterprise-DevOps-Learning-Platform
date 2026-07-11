package com.enterprise.devops.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;

/**
 * Logs one line per request (method, path, status, duration) at INFO, or
 * WARN if the request exceeded the slow-request threshold. Every log line
 * from within a request's lifecycle also carries the same requestId via
 * MDC, so Kibana can group a request's application logs with its
 * exception logs by that field.
 */
@Component
public class RequestLoggingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);
    private static final String REQUEST_ID_MDC_KEY = "requestId";

    private final long slowRequestThresholdMs;

    public RequestLoggingFilter(@Value("${app.logging.slow-request-threshold-ms:1000}") long slowRequestThresholdMs) {
        this.slowRequestThresholdMs = slowRequestThresholdMs;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        String requestId = UUID.randomUUID().toString();
        MDC.put(REQUEST_ID_MDC_KEY, requestId);
        response.setHeader("X-Request-Id", requestId);

        long start = System.currentTimeMillis();
        try {
            chain.doFilter(request, response);
        } finally {
            long durationMs = System.currentTimeMillis() - start;
            logRequest(request, response, durationMs);
            MDC.remove(REQUEST_ID_MDC_KEY);
        }
    }

    private void logRequest(HttpServletRequest request, HttpServletResponse response, long durationMs) {
        String method = request.getMethod();
        String uri = request.getRequestURI();
        int status = response.getStatus();

        if (durationMs >= slowRequestThresholdMs) {
            log.warn("slow_request method={} uri={} status={} durationMs={}", method, uri, status, durationMs);
        } else {
            log.info("request method={} uri={} status={} durationMs={}", method, uri, status, durationMs);
        }
    }
}
