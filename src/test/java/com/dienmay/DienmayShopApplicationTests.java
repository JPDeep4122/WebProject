package com.dienmay;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.verify;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.dienmay.repository.auth.UserRepository;
import com.dienmay.service.mail.EmailService;
import com.zaxxer.hikari.HikariDataSource;

@ActiveProfiles("render")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, properties = {
    "spring.datasource.url=jdbc:h2:mem:application;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.datasource.username=sa",
    "spring.datasource.password=",
    "spring.datasource.hikari.leak-detection-threshold=0",
    "dienmay.app.jwtSecret=test-only-secret-key-at-least-32-bytes-long"
})
class DienmayShopApplicationTests {
	@Value("${local.server.port}")
	private int port;

	@MockitoBean
	private EmailService emailService;

	@Autowired
	private HikariDataSource dataSource;

	@Autowired
	private UserRepository users;

	@Test
	void applicationStartsAndHealthChecksDatabase() throws Exception {
		var response = get("/health");
		assertEquals(200, response.statusCode());
		assertTrue(response.body().contains("UP"));
	}

	@Test
	void homePageRendersAgainstIsolatedDatabase() throws Exception {
		var response = get("/");
		assertEquals(200, response.statusCode());
		assertTrue(response.body().contains("Điện Máy UTE"));
	}

	@Test
	void registrationReleasesJpaConnectionBeforeMailWithOpenInViewEnabled() throws Exception {
		doAnswer(invocation -> {
			assertFalse(TransactionSynchronizationManager.isActualTransactionActive());
			assertEquals(0, dataSource.getHikariPoolMXBean().getActiveConnections());
			assertTrue(users.existsByEmail("register@example.test"));
			return null;
		}).when(emailService).sendOtpEmail(anyString(), anyString());
		String body = """
				{"email":"register@example.test","password":"password123","fullname":"Customer","phoneNumber":"0900000000"}
				""";
		try (HttpClient client = HttpClient.newHttpClient()) {
			var request = HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/api/auth/register"))
					.header("Content-Type", "application/json")
					.POST(HttpRequest.BodyPublishers.ofString(body)).build();
			var response = client.send(request, HttpResponse.BodyHandlers.ofString());
			assertEquals(200, response.statusCode());
			assertTrue(response.body().contains("\"success\":true"));
			verify(emailService).sendOtpEmail(anyString(), anyString());
		}
	}

	private HttpResponse<String> get(String path) throws Exception {
		try (HttpClient client = HttpClient.newHttpClient()) {
			return client.send(HttpRequest.newBuilder(URI.create("http://localhost:" + port + path)).build(),
					HttpResponse.BodyHandlers.ofString());
		}
	}

}
