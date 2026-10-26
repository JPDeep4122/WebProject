package com.dienmay.dto.chat;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChatAdviceRequest(
        @NotBlank(message = "Vui lòng nhập câu hỏi.")
        @Size(max = 500, message = "Câu hỏi tối đa 500 ký tự.")
        String message) {
}