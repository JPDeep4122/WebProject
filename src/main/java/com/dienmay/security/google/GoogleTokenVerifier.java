package com.dienmay.security.google;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

@Component
public class GoogleTokenVerifier {

    private final String clientId;
    private final GoogleIdTokenVerifier verifier;

    public GoogleTokenVerifier(
            @Value("${google.auth.client-id:}") String clientId) {

        this.clientId = clientId.trim();

        this.verifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(),
                GsonFactory.getDefaultInstance())
                .setAudience(List.of(this.clientId))
                .build();
    }

    public GoogleIdentity verify(String credential) {
        if (clientId.isBlank()) {
            throw new IllegalStateException(
                    "Chưa cấu hình GOOGLE_CLIENT_ID.");
        }

        if (credential == null || credential.isBlank()) {
            throw new IllegalArgumentException(
                    "Google ID token không được để trống.");
        }

        GoogleIdToken token;

        try {
            token = verifier.verify(credential);
        } catch (GeneralSecurityException ex) {
            throw new IllegalArgumentException(
                    "Không xác minh được Google ID token.", ex);
        } catch (IOException ex) {
            throw new IllegalStateException(
                    "Không thể xác minh với Google. Vui lòng thử lại.", ex);
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException(
                    "Google ID token không đúng định dạng.", ex);
        }

        if (token == null) {
            throw new IllegalArgumentException(
                    "Google ID token không hợp lệ hoặc đã hết hạn.");
        }

        var payload = token.getPayload();
        String googleSub = payload.getSubject();
        String email = payload.getEmail();

        if (googleSub == null || googleSub.isBlank()) {
            throw new IllegalArgumentException(
                    "Token thiếu mã định danh tài khoản Google.");
        }

        if (email == null || email.isBlank()
                || !Boolean.TRUE.equals(payload.getEmailVerified())) {
            throw new IllegalArgumentException(
                    "Email Google chưa được xác minh.");
        }

        String fullName = payload.get("name") instanceof String name
                && !name.isBlank() ? name : email;

        return new GoogleIdentity(
                googleSub,
                email.trim().toLowerCase(Locale.ROOT),
                fullName);
    }

    public record GoogleIdentity(
            String googleSub,
            String email,
            String fullName) {
    }
}