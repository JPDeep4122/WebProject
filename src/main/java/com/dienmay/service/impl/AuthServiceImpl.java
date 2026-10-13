package com.dienmay.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

@Service
public class AuthServiceImpl implements AuthService {

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

	@Override
	@Transactional
	public ApiResponse<String> register(RegisterRequest request) {
		String email = request.getEmail().trim().toLowerCase();

		// 1. Kiểm tra xem email đã tồn tại và đã kích hoạt chưa
		if (userRepository.existsByEmail(email)) {
			User existingUser = userRepository.findByEmail(email).get();
			if (existingUser.isActive()) {
				return ApiResponse.<String>builder().success(false)
						.message("Email này đã được đăng ký và kích hoạt trước đó!").build();
			}

			// Nếu tài khoản đã tạo nhưng chưa kích hoạt -> cập nhật lại thông tin và MÃ HÓA
			// MẬT KHẨU
			existingUser.setFullName(request.getFullname());
			existingUser.setPhoneNumber(request.getPhoneNumber());
			existingUser.setPassword(passwordEncoder.encode(request.getPassword())); // [FIXED: Mã hóa BCrypt]
			userRepository.save(existingUser);
		} else {
			// 2. Lấy role mặc định ROLE_CUSTOMER (nếu chưa có trong DB thì tự tạo)
			Role customerRole = roleRepository.findByName("ROLE_CUSTOMER")
					.orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_CUSTOMER").build()));

			// 3. Tạo User mới với trạng thái chưa kích hoạt (active = false)
			User newUser = User.builder().email(email).password(passwordEncoder.encode(request.getPassword()))
					.fullName(request.getFullname()).phoneNumber(request.getPhoneNumber()).active(false).build();

			newUser.getRoles().add(customerRole);
			userRepository.save(newUser);
		}

		// 4. Sinh mã OTP & gửi email
		sendNewOtp(email, "REGISTER");

		return ApiResponse.<String>builder().success(true)
				.message("Đăng ký thành công! Mã OTP kích hoạt tài khoản đã được gửi đến email của bạn.").data(email)
				.build();
	}

	@Override
	@Transactional
	public ApiResponse<String> verifyRegisterOtp(VerifyOtpRequest request) {
		String email = request.getEmail().trim().toLowerCase();
		String otp = request.getOtpCode().trim();

		// 1. Tìm mã OTP hợp lệ mới nhất
		OtpCode otpCode = otpCodeRepository.findTopByEmailAndTypeAndUsedFalseOrderByCreatedAtDesc(email, "REGISTER")
				.orElse(null);

		if (otpCode == null) {
			return ApiResponse.<String>builder().success(false)
					.message("Không tìm thấy mã OTP hoặc mã đã được sử dụng!").build();
		}

		// 2. Kiểm tra hạn sử dụng (5 phút)
		if (LocalDateTime.now().isAfter(otpCode.getExpiryTime())) {
			return ApiResponse.<String>builder().success(false)
					.message("Mã OTP đã hết hạn! Vui lòng yêu cầu gửi lại mã mới.").build();
		}

		// 3. Kiểm tra mã nhập vào có khớp không
		if (!otpCode.getOtpCode().equals(otp)) {
			return ApiResponse.<String>builder().success(false)
					.message("Mã OTP không chính xác! Vui lòng kiểm tra lại.").build();
		}

		// 4. Hợp lệ: Đánh dấu OTP đã dùng & Kích hoạt tài khoản User
		otpCode.setUsed(true);
		otpCodeRepository.save(otpCode);

		User user = userRepository.findByEmail(email).orElse(null);
		if (user != null) { // [FIXED: Đổi từ user == null thành user != null]
			user.setActive(true);
			userRepository.save(user);
		}

		return ApiResponse.<String>builder().success(true)
				.message("Xác thực OTP thành công! Tài khoản của bạn đã được kích hoạt và có thể đăng nhập ngay.")
				.build();
	}

	@Override
	@Transactional
	public ApiResponse<String> resendOtp(String email) {
		String cleanEmail = email.trim().toLowerCase();
		User user = userRepository.findByEmail(cleanEmail).orElse(null);

		if (user == null) {
			return ApiResponse.<String>builder().success(false).message("Email không tồn tại trong hệ thống!").build();
		}

		if (user.isActive()) {
			return ApiResponse.<String>builder().success(false)
					.message("Tài khoản này đã được kích hoạt rồi, không cần gửi lại OTP!").build();
		}

		sendNewOtp(cleanEmail, "REGISTER");

		return ApiResponse.<String>builder().success(true).message("Đã gửi lại mã OTP mới đến email của bạn!").build();
	}

	private void sendNewOtp(String email, String type) {
		String randomOtp = String.valueOf(new Random().nextInt(900000) + 100000);

		OtpCode otpCode = OtpCode.builder().email(email).otpCode(randomOtp).type(type)
				.expiryTime(LocalDateTime.now().plusMinutes(5)).used(false).build();

		otpCodeRepository.save(otpCode);

		emailService.sendOtpEmail(email, randomOtp);
	}

	@Override
	public ApiResponse<JwtResponse> login(LoginRequest request) {
		String email = request.getEmail().trim().toLowerCase();

		// 1. Kiểm tra tài khoản có tồn tại không
		User user = userRepository.findByEmail(email).orElse(null);
		if (user == null) {
			return ApiResponse.<JwtResponse>builder().success(false).message("Tài khoản email này chưa được đăng ký!")
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
	@Transactional
	public ApiResponse<String> forgotPassword(ForgotPasswordRequest request) {
		String email = request.getEmail().trim().toLowerCase();

		// 1. Kiểm tra tài khoản có tồn tại không
		User user = userRepository.findByEmail(email).orElse(null);
		if (user == null) {
			return ApiResponse.<String>builder().success(false).message("Email này chưa được đăng ký trong hệ thống!")
					.build();
		}

		// 2. Kiểm tra tài khoản đã kích hoạt chưa
		if (!user.isActive()) {
			return ApiResponse.<String>builder().success(false)
					.message("Tài khoản chưa được kích hoạt, không thể sử dụng chức năng quên mật khẩu!").build();
		}

		// 3. Sinh OTP FORGOT_PASSWORD và gửi về Gmail
		sendNewOtp(email, "FORGOT_PASSWORD");

		return ApiResponse.<String>builder().success(true)
				.message("Mã OTP đặt lại mật khẩu đã được gửi đến email của bạn!").data(email).build();
	}

	@Override
	@Transactional
	public ApiResponse<String> resetPassword(ResetPasswordRequest request) {
		String email = request.getEmail().trim().toLowerCase();
		String otp = request.getOtpCode().trim();

		// 1. Tìm mã OTP loại FORGOT_PASSWORD mới nhất và chưa sử dụng
		OtpCode otpCode = otpCodeRepository
				.findTopByEmailAndTypeAndUsedFalseOrderByCreatedAtDesc(email, "FORGOT_PASSWORD").orElse(null);

		if (otpCode == null) {
			return ApiResponse.<String>builder().success(false)
					.message("Không tìm thấy mã OTP hoặc mã đã được sử dụng!").build();
		}

		// 2. Kiểm tra hạn OTP (5 phút)
		if (LocalDateTime.now().isAfter(otpCode.getExpiryTime())) {
			return ApiResponse.<String>builder().success(false)
					.message("Mã OTP đã hết hạn! Vui lòng yêu cầu cấp lại mã mới.").build();
		}

		// 3. Kiểm tra mã OTP khớp không
		if (!otpCode.getOtpCode().equals(otp)) {
			return ApiResponse.<String>builder().success(false)
					.message("Mã OTP không chính xác! Vui lòng kiểm tra lại.").build();
		}

		// 4. Đánh dấu OTP đã dùng
		otpCode.setUsed(true);
		otpCodeRepository.save(otpCode);

		// 5. Cập nhật mật khẩu mới (Mã hóa bằng BCrypt)
		User user = userRepository.findByEmail(email).orElse(null);
		if (user != null) {
			user.setPassword(passwordEncoder.encode(request.getNewPassword()));
			userRepository.save(user);
		}

		return ApiResponse.<String>builder().success(true)
				.message("Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới ngay.").build();

	}
}