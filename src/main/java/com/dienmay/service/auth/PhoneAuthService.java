package com.dienmay.service.auth;

import java.time.LocalDateTime;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import com.dienmay.dto.auth.JwtResponse;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.security.firebase.FirebasePhoneTokenVerifier;
import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.service.impl.UserDetailsImpl;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(propagation = Propagation.NOT_SUPPORTED)
public class PhoneAuthService {

    private final FirebasePhoneTokenVerifier phoneVerifier;
    private final UserRepository users;
    private final TransactionTemplate transactions;
    private final JwtUtils jwtUtils;

    public String link(String email, String idToken) {
        if (email == null || email.isBlank()) {
            throw new AccessDeniedException(
                    "Vui lòng đăng nhập trước khi liên kết.");
        }

        // Gọi Firebase trước khi mở transaction database.
        var identity = phoneVerifier.verify(idToken);

        return transactions.execute(status -> {
            var user = users.findForPhoneLink(email)
                    .orElseThrow(() -> new AccessDeniedException(
                            "Tài khoản không còn khả dụng."));

            if (!user.isActive()) {
                throw new AccessDeniedException(
                        "Tài khoản hiện không được phép sử dụng.");
            }

            String phone = identity.phoneNumber();
            String firebaseUid = identity.firebaseUid();

            boolean alreadyLinked =
                    user.getVerifiedPhoneNumber() != null
                    || user.getFirebasePhoneUid() != null;

            if (alreadyLinked) {
                boolean sameBinding =
                        phone.equals(user.getVerifiedPhoneNumber())
                        && firebaseUid.equals(
                                user.getFirebasePhoneUid());

                if (!sameBinding) {
                    throw new IllegalArgumentException(
                            "Tài khoản đã liên kết số điện thoại khác.");
                }
            } else if (
                    users.existsByVerifiedPhoneNumberOrFirebasePhoneUid(
                            phone, firebaseUid)) {
                throw new IllegalArgumentException(
                        "Số điện thoại đã liên kết tài khoản khác.");
            }

            user.setVerifiedPhoneNumber(phone);
            user.setFirebasePhoneUid(firebaseUid);
            user.setPhoneVerifiedAt(LocalDateTime.now());

            users.saveAndFlush(user);
            return phone;
        });
    }

    public JwtResponse login(String idToken) {
        var identity = phoneVerifier.verify(idToken);

        UserDetailsImpl principal = transactions.execute(status -> {
            var user = users.findByFirebasePhoneUid(
                            identity.firebaseUid())
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Số điện thoại chưa được liên kết. "
                            + "Vui lòng đăng nhập bằng email hoặc Google "
                            + "và xác minh số trong Hồ sơ."));

            if (!identity.phoneNumber().equals(
                        user.getVerifiedPhoneNumber())
                    || user.getPhoneVerifiedAt() == null) {
                throw new IllegalArgumentException(
                        "Thông tin liên kết điện thoại không hợp lệ.");
            }

            if (!user.isActive()) {
                throw new AccessDeniedException(
                        "Tài khoản hiện không được phép đăng nhập.");
            }

            return UserDetailsImpl.build(user);
        });

        if (principal == null) {
            throw new IllegalStateException(
                    "Không thể tải tài khoản đăng nhập.");
        }

        var authentication =
                new UsernamePasswordAuthenticationToken(
                        principal, null, principal.getAuthorities());

        SecurityContextHolder.getContext()
                .setAuthentication(authentication);

        String jwt = jwtUtils.generateJwtToken(authentication);

        var roleNames = principal.getAuthorities().stream()
                .map(authority -> authority.getAuthority())
                .toList();

        return JwtResponse.builder()
                .token(jwt)
                .type("Bearer")
                .id(principal.getId())
                .email(principal.getEmail())
                .fullName(principal.getFullName())
                .roles(roleNames)
                .build();
    }
}