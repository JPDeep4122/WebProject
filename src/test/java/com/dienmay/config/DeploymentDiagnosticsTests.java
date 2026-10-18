package com.dienmay.config;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.Properties;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.info.BuildProperties;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;

class DeploymentDiagnosticsTests {
    @Test
    void healthResponseIdentifiesRevisionCompiledIntoArtifact() throws Exception {
        var filter = filter(new MockEnvironment());
        var response = new MockHttpServletResponse();
        try {
            filter.doFilter(new MockHttpServletRequest("GET", "/health"), response,
                    (request, result) -> result.getWriter().write("UP"));
            assertEquals("0123456789abcdef", response.getHeader("X-App-Revision"));
            assertEquals("UP", response.getContentAsString());
        } finally {
            filter.shutdown();
        }
    }

    @Test
    void blockedPageLogsStackBeforeItCompletesWithoutLoggingRequestSecrets() throws Exception {
        var filter = filter(new MockEnvironment()
                .withProperty("app.diagnostics.slow-request-ms", "25"));
        var events = new LinkedBlockingQueue<ILoggingEvent>();
        var appender = new AppenderBase<ILoggingEvent>() {
            @Override
            protected void append(ILoggingEvent event) {
                events.add(event);
            }
        };
        Logger logger = (Logger) LoggerFactory.getLogger(DeploymentDiagnostics.class);
        appender.start();
        logger.addAppender(appender);
        var entered = new CountDownLatch(1);
        var release = new CountDownLatch(1);
        var request = new MockHttpServletRequest("GET", "/login");
        request.setQueryString("token=private-query-token");
        request.addHeader("Authorization", "Bearer private-header-token");
        try (var worker = Executors.newSingleThreadExecutor()) {
            var pending = worker.submit(() -> {
                filter.doFilter(request, new MockHttpServletResponse(), (req, res) -> {
                    entered.countDown();
                    try {
                        if (!release.await(3, TimeUnit.SECONDS)) {
                            throw new AssertionError("Test did not release request");
                        }
                    } catch (InterruptedException ex) {
                        Thread.currentThread().interrupt();
                        throw new AssertionError(ex);
                    }
                });
                return null;
            });
            try {
                assertTrue(entered.await(1, TimeUnit.SECONDS));
                ILoggingEvent warning = events.poll(2, TimeUnit.SECONDS);
                assertNotNull(warning);
                String message = warning.getFormattedMessage();
                assertTrue(message.contains("Slow page request"));
                assertTrue(message.contains("path=/login"));
                assertTrue(message.contains("CountDownLatch.await"));
                assertFalse(message.contains("private-query-token"));
                assertFalse(message.contains("private-header-token"));
                assertFalse(pending.isDone());
            } finally {
                release.countDown();
            }
            pending.get(1, TimeUnit.SECONDS);
        } finally {
            filter.shutdown();
            logger.detachAppender(appender);
            appender.stop();
        }
    }

    @SuppressWarnings("unchecked")
    private DeploymentDiagnostics filter(MockEnvironment environment) {
        ObjectProvider<BuildProperties> builds = mock(ObjectProvider.class);
        var properties = new Properties();
        properties.setProperty("revision", "0123456789abcdef");
        when(builds.getIfAvailable()).thenReturn(new BuildProperties(properties));
        return new DeploymentDiagnostics(builds, environment);
    }
}
