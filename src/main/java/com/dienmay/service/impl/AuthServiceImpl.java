package com.dienmay.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.function.Supplier;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.MailException;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.support.TransactionTemplate;

import com.dienmay.dto.auth.ForgotPasswordRequest;
import com.dienmay.dto.auth.JwtResponse;
import com.dienmay.dto.auth.LoginRequest;
import com.dienmay.dto.auth.RegisterRequest;
import com.dienmay.dto.auth.ResetPasswordRequest;
import com.dienmay.dto.auth.VerifyOtpRequest;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.entity.auth.OtpCode;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.repository.auth.OtpCodeRepository;
import com.dienmay.repository.auth.RoleRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.service.auth.AuthService;
import com.dienmay.service.mail.EmailService;
import java.security.SecureRandom;
import java.util.Locale;

@Service
public class AuthServiceImpl implements AuthService {
	private static final Logger log = LoggerFactory.getLogger(AuthServiceImpl.class);

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private RoleRepository roleRepository;

	@Autowired
	private OtpCodeRepository otpCodeRepository;

	@Autowired
	private EmailService emailService;

	@Autowired
	private PasswordEncoder passwordEncoder;

	@Autowired
	private AuthenticationManager authenticationManager;

	@Autowired
	private JwtUtils jwtUtils;

	@Autowired
	private TransactionTemplate transactionTemplate;
	
	private static final SecureRandom OTP_RANDOM = new SecureRandom();

	private static final int MAX_OTP_ATTEMPTS = 5;
	private static final int OTP_RESEND_SECONDS = 60;
	private static final int MAX_OTP_SENDS_PER_HOUR = 5;

	@Override
	@Transactional(propagation = Propagation.NOT_SUPPORTED)
	public ApiResponse<String> register(RegisterRequest request) {
		String email = request.getEmail().trim().toLowerCase();
		return prepareAndSendOtp(email, "REGISTER", () -> registerAccount(request, email));
	}
	
	private ApiResponse<String> authFailure(String message) {
	    return ApiResponse.<String>builder()
	            .success(false)
	            .message(message)
	            .build();
	}

	private ApiResponse<String> registerAccount(RegisterRequest request, String email) {

		if (userRepository.existsByEmail(email)) {
			User existingUser = userRepository.findByEmail(email).get();
			if (existingUser.isBlocked()) {
			    return authFailure(
			            "Tài khoản đã bị khóa. Vui lòng liên hệ cửa hàng.");
			}
			
			if (existingUser.isActive()) {
				return ApiResponse.<String>builder().success(false)
						.message("Email này đã được đăng ký và kích hoạt trước đó!").build();
			}

			existingUser.setFullName(request.getFullname());
			existingUser.setPhoneNumber(request.getPhoneNumber());
			existingUser.setPassword(passwordEncoder.encode(request.getPassword())); 
			userRepository.save(existingUser);
		} else {
			Role customerRole = roleRepository.findByName("ROLE_CUSTOMER")
					.orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_CUSTOMER").build()));

			User newUser = User.builder().email(email).password(passwordEncoder.encode(request.getPassword()))
					.fullName(request.getFullname()).phoneNumber(request.getPhoneNumber()).active(false).build();

			newUser.getRoles().add(customerRole);
			userRepository.save(newUser);
		}

		return ApiResponse.<String>builder().success(true)
				.message("Đăng ký thành công! Mã OTP kích hoạt tài khoản đã được gửi đến email của bạn.").data(email)
				.build();
	}

	@Override
	@Transactional
	public ApiResponse<String> verifyRegisterOtp(VerifyOtpRequest request) {
	    String email = request.getEmail()
	            .trim()
	            .toLowerCase(Locale.ROOT);

	    User user = userRepository.findForOtp(email).orElse(null);

	    if (user == null) {
	        return authFailure("Tài khoản không tồn tại.");
	    }

	    if (user.isBlocked()) {
	        return authFailure(
	                "Tài khoản đã bị khóa. OTP không thể mở khóa tài khoản.");
	    }

	    if (user.isActive()) {
	        return authFailure("Tài khoản đã được kích hoạt.");
	    }

	    ApiResponse<String> checked = consumeOtp(
	            email,
	            "REGISTER",
	            request.getOtpCode().trim());

	    if (!checked.isSuccess()) {
	        return checked;
	    }

	    user.setActive(true);
	    userRepository.save(user);

	    return ApiResponse.<String>builder()
	            .success(true)
	            .message("Xác thực thành công. Bạn có thể đăng nhập.")
	            .build();
	}

	@Override
	@Transactional(propagation = Propagation.NOT_SUPPORTED)
	public ApiResponse<String> resendOtp(String email) {
		String cleanEmail = email.trim().toLowerCase();
		return prepareAndSendOtp(cleanEmail, "REGISTER", () -> checkResendOtp(cleanEmail));
	}

	private ApiResponse<String> checkResendOtp(String cleanEmail) {
		User user = userRepository.findByEmail(cleanEmail).orElse(null);

		if (user == null) {
			return ApiResponse.<String>builder().success(false).message("Email không tồn tại trong hệ thống!").build();
		}
		
		if (user.isBlocked()) {
		    return authFailure(
		            "Tài khoản đã bị khóa. Vui lòng liên hệ cửa hàng.");
		}

		if (user.isActive()) {
			return ApiResponse.<String>builder().success(false)
					.message("Tài khoản này đã được kích hoạt rồi, không cần gửi lại OTP!").build();
		}

		return ApiResponse.<String>builder().success(true).message("Đã gửi lại mã OTP mới đến email của bạn!").build();
	}

	private String createOtp(String email, String type) {
	    otpCodeRepository.invalidateUnused(email, type);

	    String otp = String.format(
	            Locale.ROOT,
	            "%06d",
	            OTP_RANDOM.nextInt(1_000_000));

	    OtpCode entity = OtpCode.builder()
	            .email(email)
	            .otpCode(otp)
	            .type(type)
	            .expiryTime(LocalDateTime.now().plusMinutes(5))
	            .used(false)
	            .failedAttempts(0)
	            .build();

	    otpCodeRepository.save(entity);

	    return otp;
	}

	private ApiResponse<String> prepareAndSendOtp(
	        String email,
	        String type,
	        Supplier<ApiResponse<String>> prepare) {

	    OtpDelivery delivery = transactionTemplate.execute(status -> {
	        // Khóa tài khoản hiện có để các instance dùng chung giới hạn.
	        User account = userRepository.findForOtp(email).orElse(null);

	        if (account != null && account.isBlocked()) {
	            return new OtpDelivery(
	                    authFailure("Tài khoản đã bị khóa."),
	                    null);
	        }

	        LocalDateTime now = LocalDateTime.now();

	        OtpCode latest = otpCodeRepository
	                .findTopByEmailAndTypeOrderByIdDesc(email, type)
	                .orElse(null);

	        if (latest != null
	                && latest.getCreatedAt() != null
	                && now.isBefore(
	                        latest.getCreatedAt()
	                                .plusSeconds(OTP_RESEND_SECONDS))) {

	            return new OtpDelivery(
	                    authFailure(
	                            "Vui lòng chờ 60 giây giữa hai lần gửi OTP."),
	                    null);
	        }

	        long sentCount = otpCodeRepository
	                .countByEmailAndCreatedAtAfter(
	                        email,
	                        now.minusHours(1));

	        if (sentCount >= MAX_OTP_SENDS_PER_HOUR) {
	            return new OtpDelivery(
	                    authFailure(
	                            "Bạn đã đạt giới hạn 5 lần gửi OTP trong một giờ."),
	                    null);
	        }

	        ApiResponse<String> response = prepare.get();

	        String otp = response.isSuccess()
	                ? createOtp(email, type)
	                : null;

	        return new OtpDelivery(response, otp);
	    });

	    if (delivery == null) {
	        throw new IllegalStateException("Không thể chuẩn bị OTP.");
	    }

	    // SMTP thực hiện sau khi transaction database đã kết thúc.
	    if (delivery.otp() != null) {
	        try {
	            emailService.sendOtpEmail(email, delivery.otp());
	        } catch (MailException ex) {
	            log.warn(
	                    "OTP email delivery failed: {}",
	                    ex.getClass().getSimpleName());

	            return ApiResponse.<String>builder()
	                    .success(false)
	                    .data(email)
	                    .message(
	                            "Không gửi được email OTP. "
	                            + "Vui lòng thử gửi lại mã sau.")
	                    .build();
	        }
	    }

	    return delivery.response();
	}

	private record OtpDelivery(ApiResponse<String> response, String otp) {}

	@Override
	public ApiResponse<JwtResponse> login(LoginRequest request) {
		String email = request.getEmail().trim().toLowerCase();

		// 1. Kiểm tra tài khoản có tồn tại không
		User user = userRepository.findByEmail(email).orElse(null);
		
		
		if (user == null) {
			return ApiResponse.<JwtResponse>builder().success(false).message("Tài khoản email này chưa được đăng ký!")
					.build();
		}
		
		if (user.isBlocked()) {
	        return ApiResponse.<JwtResponse>builder()
	                .success(false)
	                .message("Tài khoản đã bị khóa.")
	                .build();
	    }


		// 2. Kiểm tra tài khoản đã kích hoạt (active == true) chưa
		if (!user.isActive()) {
			return ApiResponse.<JwtResponse>builder().success(false)
					.message("Tài khoản chưa được kích hoạt! Vui lòng nhập mã OTP để kích hoạt trước khi đăng nhập.")
					.build();
		}

		// 3. Thực hiện xác thực mật khẩu qua AuthenticationManager
		try {
			Authentication authentication = authenticationManager
					.authenticate(new UsernamePasswordAuthenticationToken(email, request.getPassword()));

			SecurityContextHolder.getContext().setAuthentication(authentication);

			// 4. Sinh mã JWT Token
			String jwt = jwtUtils.generateJwtToken(authentication);

			UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
			List<String> roles = userDetails.getAuthorities().stream().map(item -> item.getAuthority())
					.collect(Collectors.toList());

			JwtResponse jwtResponse = JwtResponse.builder().token(jwt).type("Bearer").id(userDetails.getId())
					.email(userDetails.getEmail()).fullName(userDetails.getFullName()).roles(roles).build();

			return ApiResponse.<JwtResponse>builder().success(true).message("Đăng nhập thành công!").data(jwtResponse)
					.build();

		} catch (BadCredentialsException e) {
			return ApiResponse.<JwtResponse>builder().success(false).message("Mật khẩu không chính xác!").build();
		}
	}

	@Override
	@Transactional(propagation = Propagation.NOT_SUPPORTED)
	public ApiResponse<String> forgotPassword(ForgotPasswordRequest request) {
		String email = request.getEmail().trim().toLowerCase();
		return prepareAndSendOtp(email, "FORGOT_PASSWORD", () -> checkForgotPassword(email));
	}

	private ApiResponse<String> checkForgotPassword(String email) {

		// 1. Kiểm tra tài khoản có tồn tại không
		User user = userRepository.findByEmail(email).orElse(null);
		if (user == null) {
			return ApiResponse.<String>builder().success(false).message("Email này chưa được đăng ký trong hệ thống!")
					.build();
		}
		
		if (user.isBlocked()) {
		    return authFailure(
		            "Tài khoản đã bị khóa. Vui lòng liên hệ cửa hàng.");
		}

		// 2. Kiểm tra tài khoản đã kích hoạt chưa
		if (!user.isActive()) {
			return ApiResponse.<String>builder().success(false)
					.message("Tài khoản chưa được kích hoạt, không thể sử dụng chức năng quên mật khẩu!").build();
		}

		return ApiResponse.<String>builder().success(true)
				.message("Mã OTP đặt lại mật khẩu đã được gửi đến email của bạn!").data(email).build();
	}

	@Override
	@Transactional
	public ApiResponse<String> resetPassword(ResetPasswordRequest request) {
	    String email = request.getEmail()
	            .trim()
	            .toLowerCase(Locale.ROOT);

	    User user = userRepository.findForOtp(email).orElse(null);

	    if (user == null || user.isBlocked() || !user.isActive()) {
	        return authFailure(
	                "Tài khoản hiện không được phép đặt lại mật khẩu.");
	    }

	    ApiResponse<String> checked = consumeOtp(
	            email,
	            "FORGOT_PASSWORD",
	            request.getOtpCode().trim());

	    if (!checked.isSuccess()) {
	        return checked;
	    }

	    user.setPassword(
	            passwordEncoder.encode(request.getNewPassword()));

	    userRepository.save(user);

	    return ApiResponse.<String>builder()
	            .success(true)
	            .message("Đặt lại mật khẩu thành công.")
	            .build();
	}
	
	private ApiResponse<String> consumeOtp(
	        String email,
	        String type,
	        String enteredCode) {

	    OtpCode otp = otpCodeRepository
	            .findTopByEmailAndTypeOrderByIdDesc(email, type)
	            .orElse(null);

	    if (otp == null) {
	        return authFailure("Không tìm thấy OTP. Vui lòng yêu cầu mã mới.");
	    }

	    if (otp.isUsed() || otp.getFailedAttempts() >= MAX_OTP_ATTEMPTS) {
	        return authFailure(
	                "OTP đã được sử dụng hoặc vô hiệu hóa. "
	                + "Vui lòng yêu cầu mã mới.");
	    }

	    if (!LocalDateTime.now().isBefore(otp.getExpiryTime())) {
	        otp.setUsed(true);
	        otpCodeRepository.save(otp);

	        return authFailure("OTP đã hết hạn. Vui lòng yêu cầu mã mới.");
	    }

	    if (!otp.getOtpCode().equals(enteredCode)) {
	        int failures = otp.getFailedAttempts() + 1;

	        otp.setFailedAttempts(failures);

	        if (failures >= MAX_OTP_ATTEMPTS) {
	            otp.setUsed(true);
	        }

	        otpCodeRepository.save(otp);

	        return authFailure(
	                failures >= MAX_OTP_ATTEMPTS
	                        ? "Bạn đã nhập sai 5 lần. OTP đã bị vô hiệu hóa."
	                        : "OTP không chính xác. Bạn còn "
	                                + (MAX_OTP_ATTEMPTS - failures)
	                                + " lần thử.");
	    }

	    otp.setUsed(true);
	    otpCodeRepository.save(otp);

	    return ApiResponse.<String>builder()
	            .success(true)
	            .message("OTP hợp lệ.")
	            .build();
	}
}
