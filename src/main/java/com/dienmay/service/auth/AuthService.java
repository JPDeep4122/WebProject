package com.dienmay.service.auth;

import com.dienmay.dto.auth.ForgotPasswordRequest;
import com.dienmay.dto.auth.JwtResponse;
import com.dienmay.dto.auth.LoginRequest;
import com.dienmay.dto.auth.RegisterRequest;
import com.dienmay.dto.auth.ResetPasswordRequest;
import com.dienmay.dto.auth.VerifyOtpRequest;
import com.dienmay.dto.common.ApiResponse;

public interface AuthService {
	ApiResponse<String> register(RegisterRequest request);
	ApiResponse<String> verifyRegisterOtp(VerifyOtpRequest request);
	ApiResponse<String> resendOtp(String email);
	ApiResponse<JwtResponse> login(LoginRequest request);
	ApiResponse<String> forgotPassword(ForgotPasswordRequest request);
	ApiResponse<String> resetPassword(ResetPasswordRequest request);
}
