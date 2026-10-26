package com.dienmay.controller.auth;

import java.security.Principal;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.dienmay.dto.auth.JwtResponse;
import com.dienmay.dto.auth.PhoneAuthRequest;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.service.auth.PhoneAuthService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class PhoneAuthController {

    private final PhoneAuthService phoneAuthService;

    @PostMapping("/account/phone/link")
    public ApiResponse<String> link(
            @Valid @RequestBody PhoneAuthRequest request,
            Principal principal) {

        if (principal == null) {
            throw new AccessDeniedException(
                    "Vui lòng đăng nhập trước khi liên kết.");
        }

        String phone = phoneAuthService.link(
                principal.getName(), request.getIdToken());

        return ApiResponse.<String>builder()
                .success(true)
                .message("Liên kết số điện thoại thành công.")
                .data(phone)
                .build();
    }

    @PostMapping("/auth/phone/login")
    public ApiResponse<JwtResponse> login(
            @Valid @RequestBody PhoneAuthRequest request) {

        JwtResponse result =
                phoneAuthService.login(request.getIdToken());

        return ApiResponse.<JwtResponse>builder()
                .success(true)
                .message("Đăng nhập bằng số điện thoại thành công.")
                .data(result)
                .build();
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<Void> invalid(IllegalArgumentException ex) {
        return failure(ex.getMessage());
    }

    @ExceptionHandler(AccessDeniedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public ApiResponse<Void> denied(AccessDeniedException ex) {
        return failure(ex.getMessage());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ApiResponse<Void> conflict() {
        return failure(
                "Số điện thoại đã được sử dụng. "
                + "Vui lòng kiểm tra lại thông tin liên kết.");
    }

    @ExceptionHandler(IllegalStateException.class)
    @ResponseStatus(HttpStatus.SERVICE_UNAVAILABLE)
    public ApiResponse<Void> unavailable() {
        return failure(
                "Xác thực điện thoại hiện chưa khả dụng. "
                + "Vui lòng thử lại sau.");
    }

    private ApiResponse<Void> failure(String message) {
        return ApiResponse.<Void>builder()
                .success(false)
                .message(message)
                .build();
    }
}