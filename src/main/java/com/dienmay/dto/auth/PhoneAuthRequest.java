package com.dienmay.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class PhoneAuthRequest {

    @NotBlank(message = "Thiếu phiên xác thực điện thoại.")
    @Size(max = 8192, message = "Phiên xác thực không hợp lệ.")
    private String idToken;
}