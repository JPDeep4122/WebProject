package com.dienmay.service.auth;

import java.util.UUID;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import com.dienmay.dto.auth.GoogleLoginRequest;
import com.dienmay.dto.auth.JwtResponse;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.repository.auth.RoleRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.security.google.GoogleTokenVerifier;
import com.dienmay.security.google.GoogleTokenVerifier.GoogleIdentity;
import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.service.impl.UserDetailsImpl;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GoogleAuthService {

	private final GoogleTokenVerifier googleTokenVerifier;
	private final UserRepository users;
	private final RoleRepository roles;
	private final PasswordEncoder passwordEncoder;
	private final JwtUtils jwtUtils;
	private final TransactionTemplate transactions;

	@Transactional(propagation = Propagation.NOT_SUPPORTED)
	public JwtResponse login(GoogleLoginRequest request) {

		// Xác minh với Google trước khi mở transaction database.
		GoogleIdentity identity = googleTokenVerifier.verify(request.getCredential());

		UserDetailsImpl principal = transactions.execute(status -> {
			User user = users.findByGoogleSub(identity.googleSub()).orElse(null);

			if (user == null) {
				user = users.findByEmailIgnoreCase(identity.email()).orElse(null);

				if (user == null) {
					// Email chưa có: tạo khách hàng mới.
					user = createGoogleUser(identity);
				} else {
					// Email đã có: liên kết với tài khoản hiện tại.
					if (!user.isActive()) {
						throw new IllegalArgumentException(
								"Tài khoản chưa được kích hoạt " + "hoặc đã bị vô hiệu hóa.");
					}

					// identity đã được GoogleTokenVerifier xác minh,
					// bao gồm email_verified = true.
					if (!identity.email().endsWith("@gmail.com")) {
						throw new IllegalArgumentException(
								"Email này cần được liên kết " + "từ tài khoản TECHSEVEN đã đăng nhập.");
					}

					String existingSub = user.getGoogleSub();

					if (existingSub != null && !existingSub.isBlank() && !existingSub.equals(identity.googleSub())) {
						throw new IllegalArgumentException("Tài khoản đã liên kết " + "với một tài khoản Google khác.");
					}

					user.setGoogleSub(identity.googleSub());
					user = users.saveAndFlush(user);
				}
			}

			if (!user.isActive()) {
				throw new IllegalArgumentException("Tài khoản hiện không được phép đăng nhập.");
			}

			return UserDetailsImpl.build(user);
		});
		if (principal == null) {
			throw new IllegalStateException("Không thể tải tài khoản đăng nhập.");
		}

		var authentication = new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());

		SecurityContextHolder.getContext().setAuthentication(authentication);

		String jwt = jwtUtils.generateJwtToken(authentication);

		var roleNames = principal.getAuthorities().stream().map(authority -> authority.getAuthority()).toList();

		return JwtResponse.builder().token(jwt).type("Bearer").id(principal.getId()).email(principal.getEmail())
				.fullName(principal.getFullName()).roles(roleNames).build();
	}

	private User createGoogleUser(GoogleIdentity identity) {

		if (identity.email().length() > 100) {
			throw new IllegalArgumentException("Email vượt quá độ dài hệ thống hỗ trợ.");
		}

		if (users.existsByEmailIgnoreCase(identity.email())) {
			throw new IllegalArgumentException("Email này đã có tài khoản TECHSEVEN. "
					+ "Vui lòng đăng nhập bằng mật khẩu trước " + "để liên kết Google.");
		}

		Role customerRole = roles.findByName("ROLE_CUSTOMER")
				.orElseGet(() -> roles.save(Role.builder().name("ROLE_CUSTOMER").build()));

		String fullName = identity.fullName().trim();
		if (fullName.length() > 100) {
			fullName = fullName.substring(0, 100);
		}

		User user = User.builder().email(identity.email()).googleSub(identity.googleSub()).fullName(fullName)
				.password(passwordEncoder.encode(UUID.randomUUID().toString())).active(true).build();

		user.getRoles().add(customerRole);

		return users.saveAndFlush(user);
	}
}