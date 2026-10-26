package com.dienmay.controller.auth;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;

import com.dienmay.dto.auth.GoogleLoginRequest;
import com.dienmay.service.auth.GoogleAuthService;

import com.dienmay.dto.auth.ForgotPasswordRequest;
import com.dienmay.dto.auth.JwtResponse;
import com.dienmay.dto.auth.LoginRequest;
import com.dienmay.dto.auth.RegisterRequest;
import com.dienmay.dto.auth.ResetPasswordRequest;
import com.dienmay.dto.auth.VerifyOtpRequest;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.service.auth.AuthService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
	
	@Autowired
    private AuthService authService;
	
	@Autowired
	private GoogleAuthService googleAuthService;
	
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
    
    // 4. API Đăng nhập lấy JWT Token
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<JwtResponse>> login(@Valid @RequestBody LoginRequest request) {
        ApiResponse<JwtResponse> response = authService.login(request);
        return ResponseEntity.ok(response);
    }
    
 // 5. API Yêu cầu gửi OTP Quên mật khẩu
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<String>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        ApiResponse<String> response = authService.forgotPassword(request);
        return ResponseEntity.ok(response);
    }
    
    // 6. API Xác thực OTP và Đặt lại mật khẩu mới
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<String>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        ApiResponse<String> response = authService.resetPassword(request);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/google")
    public ResponseEntity<ApiResponse<JwtResponse>> googleLogin(
            @Valid @RequestBody GoogleLoginRequest request) {

        try {
            JwtResponse jwtResponse = googleAuthService.login(request);

            return ResponseEntity.ok(
                    ApiResponse.<JwtResponse>builder()
                            .success(true)
                            .message("Đăng nhập Google thành công!")
                            .data(jwtResponse)
                            .build());

        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.<JwtResponse>builder()
                            .success(false)
                            .message(ex.getMessage())
                            .build());

        } catch (DataIntegrityViolationException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(ApiResponse.<JwtResponse>builder()
                            .success(false)
                            .message("Thông tin tài khoản bị trùng. "
                                    + "Vui lòng thử lại hoặc đăng nhập "
                                    + "bằng tài khoản hiện có.")
                            .build());

        } catch (IllegalStateException ex) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.<JwtResponse>builder()
                            .success(false)
                            .message("Đăng nhập Google hiện chưa khả dụng. "
                                    + "Vui lòng thử lại sau.")
                            .build());
        }
    }
}
