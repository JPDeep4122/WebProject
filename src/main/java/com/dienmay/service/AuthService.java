package com.dienmay.service;

import com.dienmay.dto.ApiResponse;
import com.dienmay.dto.JwtResponse;
import com.dienmay.dto.LoginRequest;
import com.dienmay.dto.RegisterRequest;
import com.dienmay.dto.VerifyOtpRequest;

public interface AuthService {
	ApiResponse<String> register(RegisterRequest request);
	ApiResponse<String> verifyRegisterOtp(VerifyOtpRequest request);
	ApiResponse<String> resendOtp(String email);
	ApiResponse<JwtResponse> login(LoginRequest request);
}
