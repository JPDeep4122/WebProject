package com.dienmay.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminUserRequest {
    @NotBlank @Email private String email;
    @NotBlank @Size(max = 100) private String fullName;
    @Size(min = 6, max = 100) private String password;
    @Size(max = 20) private String phoneNumber;
    @NotBlank private String role = "ROLE_CUSTOMER";
    private Long branchId;
    private Boolean active = true;
}
