package com.dienmay.config;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.google.auth.oauth2.GoogleCredentials;
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
            @Value("${firebase.auth.project-id}") String projectId)
            throws IOException {

        if (projectId.isBlank()) {
            throw new IllegalStateException(
                    "Chưa cấu hình FIREBASE_PROJECT_ID.");
        }

        FirebaseOptions options = FirebaseOptions.builder()
                .setProjectId(projectId.trim())
                .setCredentials(
                        GoogleCredentials.getApplicationDefault())
                .setConnectTimeout(5000)
                .setReadTimeout(10000)
                .build();

        return FirebaseApp.initializeApp(
                options, "techseven-phone");
    }

    @Bean
    public FirebaseAuth phoneFirebaseAuth(
            FirebaseApp techsevenFirebaseApp) {
        return FirebaseAuth.getInstance(techsevenFirebaseApp);
    }
}