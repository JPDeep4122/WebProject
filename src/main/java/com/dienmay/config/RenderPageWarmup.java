package com.dienmay.config;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
@Order(Ordered.LOWEST_PRECEDENCE)
@ConditionalOnProperty(name = "app.warmup.enabled", havingValue = "true")
public class RenderPageWarmup implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(RenderPageWarmup.class);
    private final Environment environment;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        int port = environment.getRequiredProperty("local.server.port", Integer.class);
        String contextPath = environment.getProperty("server.servlet.context-path", "");
        // Readiness remains REFUSING_TRAFFIC until all runners finish. Compile the
        // shared JSP layout here instead of on the first public visitor's request.
        try (HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build()) {
            for (String path : List.of("/", "/products", "/login")) {
                long started = System.nanoTime();
                log.info("Warming Render page {} before accepting traffic", path);
                HttpRequest request = HttpRequest.newBuilder(
                        URI.create("http://127.0.0.1:" + port + contextPath + path))
                        .timeout(Duration.ofSeconds(180)).GET().build();
                var response = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                if (response.statusCode() != 200) {
                    throw new IllegalStateException("Page warmup failed for " + path
                            + ": HTTP " + response.statusCode());
                }
                if (!response.headers().firstValue("Content-Type").orElse("").startsWith("text/html")
                        || !response.body().contains("Điện Máy UTE")
                        || !response.body().contains("</html>")) {
                    throw new IllegalStateException("Page warmup did not render expected HTML for " + path);
                }
                log.info("Warmed Render page {} in {} ms", path,
                        Duration.ofNanos(System.nanoTime() - started).toMillis());
            }
        }
        log.info("Render pages are ready");
    }
}
