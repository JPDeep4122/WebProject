package com.dienmay.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.dienmay.dto.ApiResponse;
import com.dienmay.dto.RegisterRequest;
import com.dienmay.dto.VerifyOtpRequest;
import com.dienmay.service.AuthService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
	
	@Autowired
    private AuthService authService;
	
    // 1. API Đăng ký tài khoản
	@PostMapping("/register")
	public ResponseEntity<ApiResponse<String>> register(@Valid @RequestBody RegisterRequest request) {
		ApiResponse<String> response = authService.register(request);
		return ResponseEntity.ok(response);
	}
	
	// 2. API Xác thực mã OTP
	@PostMapping("/verify-otp") 
	public ResponseEntity<ApiResponse<String>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
		ApiResponse<String> response = authService.verifyRegisterOtp(request);
        return ResponseEntity.ok(response);
	}
	
	 // 3. API Gửi lại mã OTP
    @PostMapping("/resend-otp")
    public ResponseEntity<ApiResponse<String>> resendOtp(@RequestParam String email) {
        ApiResponse<String> response = authService.resendOtp(email);
        return ResponseEntity.ok(response);
    }
}
