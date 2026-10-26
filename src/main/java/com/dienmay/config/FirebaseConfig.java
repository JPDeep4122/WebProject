package com.dienmay.config;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Base64;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ServiceAccountCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;

@Configuration(proxyBeanMethods = false)
@ConditionalOnProperty(
        name = "firebase.auth.enabled",
        havingValue = "true")
public class FirebaseConfig {

    @Bean(destroyMethod = "delete")
    public FirebaseApp techsevenFirebaseApp(
            @Value("${firebase.auth.project-id}") String projectId,
            @Value("${firebase.auth.credentials-base64:}") String encoded)
            throws IOException {

        if (projectId.isBlank()) {
            throw new IllegalStateException(
                    "Chưa cấu hình FIREBASE_PROJECT_ID.");
        }

        GoogleCredentials credentials;

        if (encoded.isBlank()) {
            // Local: tiếp tục đọc GOOGLE_APPLICATION_CREDENTIALS.
            credentials = GoogleCredentials.getApplicationDefault();
        } else {
            byte[] decoded;

            try {
                decoded = Base64.getDecoder().decode(encoded.trim());
            } catch (IllegalArgumentException ex) {
                throw new IllegalStateException(
                        "FIREBASE_SERVICE_ACCOUNT_BASE64 không hợp lệ.",
                        ex);
            }

            try (var stream = new ByteArrayInputStream(decoded)) {
                credentials = ServiceAccountCredentials.fromStream(stream);
            }
        }

        FirebaseOptions options = FirebaseOptions.builder()
                .setProjectId(projectId.trim())
                .setCredentials(credentials)
                .setConnectTimeout(5000)
                .setReadTimeout(10000)
                .build();

        return FirebaseApp.initializeApp(options, "techseven-phone");
    }

    @Bean
    public FirebaseAuth phoneFirebaseAuth(
            FirebaseApp techsevenFirebaseApp) {
        return FirebaseAuth.getInstance(techsevenFirebaseApp);
    }
}