package com.enterprise.devops.filter;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.read.ListAppender;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;
import org.slf4j.event.Level;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.assertj.core.api.Assertions.assertThat;

class RequestLoggingFilterTest {

    private ListAppender<ILoggingEvent> listAppender;
    private Logger filterLogger;

    @BeforeEach
    void setUp() {
        filterLogger = (Logger) LoggerFactory.getLogger(RequestLoggingFilter.class);
        listAppender = new ListAppender<>();
        listAppender.start();
        filterLogger.addAppender(listAppender);
    }

    @AfterEach
    void tearDown() {
        filterLogger.detachAppender(listAppender);
    }

    @Test
    void fastRequest_logsAtInfoLevel() throws Exception {
        RequestLoggingFilter filter = new RequestLoggingFilter(Long.MAX_VALUE);

        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/employees");
        MockHttpServletResponse response = new MockHttpServletResponse();
        response.setStatus(200);

        filter.doFilter(request, response, (req, res) -> { });

        assertThat(listAppender.list).hasSize(1);
        ILoggingEvent event = listAppender.list.get(0);
        assertThat(event.getLevel().toString()).isEqualTo(Level.INFO.name());
        assertThat(event.getFormattedMessage()).contains("method=GET", "uri=/api/employees", "status=200");
    }

    @Test
    void slowRequest_logsAtWarnLevel() throws Exception {
        RequestLoggingFilter filter = new RequestLoggingFilter(0);

        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/employees");
        MockHttpServletResponse response = new MockHttpServletResponse();
        response.setStatus(201);

        filter.doFilter(request, response, (req, res) -> { });

        assertThat(listAppender.list).hasSize(1);
        ILoggingEvent event = listAppender.list.get(0);
        assertThat(event.getLevel().toString()).isEqualTo(Level.WARN.name());
        assertThat(event.getFormattedMessage()).contains("slow_request", "method=POST", "status=201");
    }

    @Test
    void requestId_isAddedAsResponseHeader() throws Exception {
        RequestLoggingFilter filter = new RequestLoggingFilter(Long.MAX_VALUE);

        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/health");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, (req, res) -> { });

        assertThat(response.getHeader("X-Request-Id")).isNotBlank();
    }
}
