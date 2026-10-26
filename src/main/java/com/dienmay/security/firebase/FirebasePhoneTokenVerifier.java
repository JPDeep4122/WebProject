package com.dienmay.security.firebase;

import java.time.Instant;
import java.util.Map;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Component;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class FirebasePhoneTokenVerifier {

    private final ObjectProvider<FirebaseAuth> authProvider;

    public PhoneIdentity verify(String idToken) {
        if (idToken == null || idToken.isBlank()
                || idToken.length() > 8192) {
            throw new IllegalArgumentException(
                    "Thiếu hoặc sai định dạng phiên xác thực.");
        }

        FirebaseAuth auth = authProvider.getIfAvailable();

        if (auth == null) {
            throw new IllegalStateException(
                    "Xác thực số điện thoại hiện chưa được bật.");
        }

        FirebaseToken token;

        try {
            // Kiểm tra token và trạng thái thu hồi/vô hiệu hóa.
            token = auth.verifyIdToken(idToken, true);
        } catch (FirebaseAuthException ex) {
            throw new IllegalArgumentException(
                    "Không xác minh được phiên đăng nhập "
                    + "bằng số điện thoại. Vui lòng thử lại.",
                    ex);
        }

        Object firebaseClaim = token.getClaims().get("firebase");

        if (!(firebaseClaim instanceof Map<?, ?> firebase)
                || !"phone".equals(
                        firebase.get("sign_in_provider"))) {
            throw new IllegalArgumentException(
                    "Vui lòng xác thực bằng mã OTP điện thoại.");
        }

        Object phoneClaim = token.getClaims().get("phone_number");

        if (!(phoneClaim instanceof String phone)
                || !phone.matches("\\+[1-9]\\d{1,14}")) {
            throw new IllegalArgumentException(
                    "Phiên xác thực thiếu số điện thoại hợp lệ.");
        }

        Object timeClaim = token.getClaims().get("auth_time");

        if (!(timeClaim instanceof Number time)) {
            throw new IllegalArgumentException(
                    "Phiên xác thực thiếu thời gian đăng nhập.");
        }

        long authenticatedAt = time.longValue();
        long now = Instant.now().getEpochSecond();

        if (authenticatedAt <= 0
                || authenticatedAt > now + 60
                || now - authenticatedAt > 300) {
            throw new IllegalArgumentException(
                    "Vui lòng xác thực lại bằng OTP điện thoại.");
        }

        return new PhoneIdentity(
                token.getUid(),
                phone,
                authenticatedAt);
    }

    public record PhoneIdentity(
            String firebaseUid,
            String phoneNumber,
            long authenticatedAt) {
    }
}