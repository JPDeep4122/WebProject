package com.dienmay.dto.auth;

import lombok.Value;

@Value
public class AccountProfile {
    String email;
    String fullName;
    String phoneNumber;
}
