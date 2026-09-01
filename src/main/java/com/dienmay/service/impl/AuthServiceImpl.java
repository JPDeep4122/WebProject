package com.dienmay.service.impl;

import java.time.LocalDateTime;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.ApiResponse;
import com.dienmay.dto.RegisterRequest;
import com.dienmay.dto.VerifyOtpRequest;
import com.dienmay.entity.OtpCode;
import com.dienmay.entity.Role;
import com.dienmay.entity.User;
import com.dienmay.repository.OtpCodeRepository;
import com.dienmay.repository.RoleRepository;
import com.dienmay.repository.UserRepository;
import com.dienmay.service.AuthService;
import com.dienmay.service.EmailService;

@Service
public class AuthServiceImpl implements AuthService{
	
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
	
	@Override
	@Transactional
	public ApiResponse<String> register(RegisterRequest request) {
		
		String email = request.getEmail().trim().toLowerCase();
		
		//1. Kiểm tra xem email đã tồn tại và đã kích hoạt chưa
		if (userRepository.existsByEmail(email)) {
			User existingUser = userRepository.findByEmail(email).get();
			if (existingUser.isActive()) {
				return ApiResponse.<String>builder()
						.success(false)
						.message("Email này đã được đăng ký và kích hoạt trước đó!")
						.build();
			}
			
			// Nếu tài khoản đã tạo rồi nhưng chưa kích hoạt, update information
			existingUser.setFullName(request.getFullname());
			existingUser.setPhoneNumber(request.getPhoneNumber());
			existingUser.setPassword(request.getPassword());
			userRepository.save(existingUser);
		} else {
			// 2. Lấy role mặc định ROLE_CUSTOMER (nếu chưa có trong DB thì tự tạo)
			Role customerRole = roleRepository.findByName("ROLE_CUSTOMER")
					.orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_CUSTOMER").build()));
			
            // 3. Tạo User mới với trạng thái chưa kích hoạt (active = false)
			User newUser = User.builder()
					.email(email)
					.password(passwordEncoder.encode(request.getPassword()))
					.fullName(request.getFullname())
					.phoneNumber(request.getPhoneNumber())
					.active(false)
					.build();
			
			newUser.getRoles().add(customerRole);
			userRepository.save(newUser);
		}
		
		// 4. Sinh mã OTP & gửi email
        sendNewOtp(email, "REGISTER");
        
        return ApiResponse.<String>builder()
                .success(true)
                .message("Đăng ký thành công! Mã OTP kích hoạt tài khoản đã được gửi đến email của bạn.")
                .data(email)
                .build();
	}
	
	@Override
	@Transactional
	public ApiResponse<String> verifyRegisterOtp(VerifyOtpRequest request) {
		
		String email = request.getEmail().trim().toLowerCase();
		String otp = request.getOtpCode().trim();
		
		
        // 1. Tìm mã OTP hợp lệ mới nhất
		OtpCode otpCode = otpCodeRepository
                .findTopByEmailAndTypeAndUsedFalseOrderByCreatedAtDesc(email, "REGISTER")
                .orElse(null);
		
		
		if (otpCode == null) {
			return ApiResponse.<String>builder()
					.success(false)
					.message("Không tìm thấy mã OTP hoặc mã đã được sử dụng!")
					.build();
		}
		
        // 2. Kiểm tra hạn sử dụng (5 phút)
		if (LocalDateTime.now().isAfter(otpCode.getExpiryTime())) {
			return ApiResponse.<String>builder()
					.success(false)
					.message("Mã OTP đã hết hạn! Vui lòng yêu cầu gửi lại mã mới.")
					.build();
		}
		
		 // 3. Kiểm tra mã nhập vào có khớp không
		if (!otpCode.getOtpCode().equals(otp)) {
			return ApiResponse.<String>builder()
					.success(false)
					.message("Mã OTP không chính xác! Vui lòng kiểm tra lại.")
					.build();	
		}
		
        // 4. Hợp lệ: Đánh dấu OTP đã dùng & Kích hoạt tài khoản User
		otpCode.setUsed(true);
		otpCodeRepository.save(otpCode);

		User user = userRepository.findByEmail(email).orElse(null);
		if (user == null) {
			user.setActive(true); 		// Tạo tài khoản thành công
			userRepository.save(user);
		}
		
		return ApiResponse.<String>builder()
				.success(true)
				.message("Xác thực OTP thành công! Tài khoản của bạn đã được kích hoạt và có thể đăng nhập ngay.")
				.build();
	}
	
	@Override
	@Transactional
	public ApiResponse<String> resendOtp(String email) {
		
		String cleanEmail = email.trim().toLowerCase();
		User user = userRepository.findByEmail(cleanEmail).orElse(null);
		
		if (user == null) {
			return ApiResponse.<String>builder()
				.success(false)
				.message("Email không tồn tại trong hệ thống!")
				.build();
		}
		
		if (user.isActive()) {
			return ApiResponse.<String>builder()
				.success(false)
				.message("Tài khoản này đã được kích hoạt rồi, không cần gửi lại OTP!")
				.build();
		}
		
		sendNewOtp(cleanEmail, "REGISTER");
		
		return ApiResponse.<String>builder()
				.success(true)
				.message("Đã gửi lại mã OTP mới đến email của bạn!")
				.build();
	}
	
	private void sendNewOtp(String email, String type) {
		String randomOtp = String.valueOf(new Random().nextInt(900000) + 100000);
		
		OtpCode otpCode = OtpCode.builder()
				.email(email)
				.otpCode(randomOtp)
				.type(type)
				.expiryTime(LocalDateTime.now().plusMinutes(5))
				.used(false)
				.build();
		
		otpCodeRepository.save(otpCode);
		
		emailService.sendOtpEmail(email, randomOtp);
	}
}
