package com.enterprise.devops.exception;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.read.ListAppender;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;
import org.slf4j.event.Level;
import org.springframework.mock.web.MockHttpServletRequest;

import static org.assertj.core.api.Assertions.assertThat;

class GlobalExceptionHandlerTest {

    private ListAppender<ILoggingEvent> listAppender;
    private Logger handlerLogger;
    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @BeforeEach
    void setUp() {
        handlerLogger = (Logger) LoggerFactory.getLogger(GlobalExceptionHandler.class);
        listAppender = new ListAppender<>();
        listAppender.start();
        handlerLogger.addAppender(listAppender);
    }

    @AfterEach
    void tearDown() {
        handlerLogger.detachAppender(listAppender);
    }

    @Test
    void resourceNotFound_logsAtWarnWithoutStackTrace() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/employees/99");

        handler.handleNotFound(new ResourceNotFoundException("Employee", 99L), request);

        assertThat(listAppender.list).hasSize(1);
        ILoggingEvent event = listAppender.list.get(0);
        assertThat(event.getLevel().toString()).isEqualTo(Level.WARN.name());
        assertThat(event.getThrowableProxy()).isNull();
    }

    @Test
    void genericException_logsAtErrorWithStackTrace() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/employees");

        handler.handleGeneric(new RuntimeException("boom"), request);

        assertThat(listAppender.list).hasSize(1);
        ILoggingEvent event = listAppender.list.get(0);
        assertThat(event.getLevel().toString()).isEqualTo(Level.ERROR.name());
        assertThat(event.getThrowableProxy()).isNotNull();
        assertThat(event.getThrowableProxy().getMessage()).isEqualTo("boom");
    }
}
