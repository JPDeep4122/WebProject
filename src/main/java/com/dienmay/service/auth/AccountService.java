package com.dienmay.service.auth;

import java.nio.charset.StandardCharsets;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.auth.AccountProfile;
import com.dienmay.dto.auth.ChangePasswordRequest;
import com.dienmay.dto.auth.ProfileUpdateRequest;
import com.dienmay.entity.auth.Address;
import com.dienmay.entity.auth.User;
import com.dienmay.repository.auth.AddressRepository;
import com.dienmay.repository.auth.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AccountService {
    private final UserRepository users;
    private final AddressRepository addressRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public AccountProfile getProfile(String email) {
        User user = requireActiveUser(email);
        Address defaultAddr = addressRepository.findByUser_IdAndIsDefaultTrue(user.getId())
                .orElse(null);
        String province = defaultAddr != null ? defaultAddr.getProvince() : null;
        String ward = defaultAddr != null ? defaultAddr.getWard() : null;
        String detailAddress = defaultAddr != null ? defaultAddr.getDetailAddress() : null;
        return new AccountProfile(user.getEmail(), user.getFullName(), user.getPhoneNumber(), province, ward, detailAddress);
    }

    @Transactional
    public void updateProfile(String email, ProfileUpdateRequest request) {
        User user = requireActiveUser(email);
        user.setFullName(request.getFullName().strip());
        String phone = request.getPhoneNumber();
        user.setPhoneNumber(phone == null || phone.isBlank() ? null : phone.strip());
        users.save(user);

        // Lưu hoặc cập nhật địa chỉ mặc định của khách hàng
        if (request.getProvince() != null && !request.getProvince().isBlank()) {
            Address addr = addressRepository.findByUser_IdAndIsDefaultTrue(user.getId())
                    .orElseGet(() -> Address.builder().user(user).isDefault(true).build());
            addr.setRecipientName(user.getFullName());
            addr.setPhoneNumber(user.getPhoneNumber() != null ? user.getPhoneNumber() : "");
            addr.setProvince(request.getProvince().strip());
            addr.setWard(request.getWard() != null ? request.getWard().strip() : "");
            addr.setDetailAddress(request.getDetailAddress() != null ? request.getDetailAddress().strip() : "");

            String full = String.join(", ", java.util.stream.Stream.of(addr.getDetailAddress(), addr.getWard(), addr.getProvince())
                    .filter(s -> s != null && !s.isBlank()).toList());
            addr.setFullAddress(full);
            addressRepository.save(addr);
        }
    }

    @Transactional
    public void changePassword(String email, ChangePasswordRequest request) {
        User user = requireActiveUser(email);
        String currentPassword = request.getCurrentPassword();
        if (currentPassword == null || currentPassword.getBytes(StandardCharsets.UTF_8).length > 72
                || !passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new IllegalArgumentException("Mật khẩu hiện tại không chính xác.");
        }
        String newPassword = request.getNewPassword();
        if (newPassword == null || newPassword.isBlank() || newPassword.length() < 8
                || newPassword.getBytes(StandardCharsets.UTF_8).length > 72) {
            throw new IllegalArgumentException("Mật khẩu mới cần ít nhất 8 ký tự và không quá 72 byte UTF-8.");
        }
        if (!newPassword.equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Xác nhận mật khẩu mới chưa khớp.");
        }
        if (passwordEncoder.matches(newPassword, user.getPassword())) {
            throw new IllegalArgumentException("Mật khẩu mới phải khác mật khẩu hiện tại.");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        users.save(user);
    }

    private User requireActiveUser(String email) {
        if (email == null || email.isBlank()) {
            throw new AccessDeniedException("Vui lòng đăng nhập để quản lý hồ sơ.");
        }
        User user = users.findByEmail(email)
                .orElseThrow(() -> new AccessDeniedException("Tài khoản không còn khả dụng."));
        if (!user.isActive()) {
            throw new AccessDeniedException("Tài khoản không còn khả dụng.");
        }
        return user;
    }
}