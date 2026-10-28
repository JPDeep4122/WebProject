package com.dienmay.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ProfileUpdateRequest {
    @NotBlank(message = "Vui lòng nhập họ tên.")
    @Size(max = 100, message = "Họ tên tối đa 100 ký tự.")
    private String fullName;

    @Size(max = 20, message = "Số điện thoại tối đa 20 ký tự.")
    @Pattern(regexp = "^$|\\+?[0-9]{9,15}",
            message = "Số điện thoại gồm 9–15 chữ số, có thể bắt đầu bằng dấu +.")
    private String phoneNumber;

    private String province;
    private String ward;
    private String detailAddress;
}