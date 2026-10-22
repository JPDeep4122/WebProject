package com.dienmay.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

// Do not generate toString(): this object contains passwords.
@Getter
@Setter
public class ChangePasswordRequest {
    @NotBlank(message = "Vui lòng nhập mật khẩu hiện tại.")
    @Size(max = 72, message = "Mật khẩu hiện tại tối đa 72 ký tự.")
    private String currentPassword;

    @NotBlank(message = "Vui lòng nhập mật khẩu mới.")
    @Size(min = 8, max = 72, message = "Mật khẩu mới cần từ 8 đến 72 ký tự.")
    private String newPassword;

    @NotBlank(message = "Vui lòng xác nhận mật khẩu mới.")
    @Size(max = 72, message = "Xác nhận mật khẩu tối đa 72 ký tự.")
    private String confirmPassword;
}
