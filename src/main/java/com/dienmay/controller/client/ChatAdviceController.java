package com.dienmay.controller.client;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.dienmay.dto.chat.ChatAdviceRequest;
import com.dienmay.dto.chat.ChatAdviceResponse;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.service.chat.GeminiChatService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatAdviceController {

    private final GeminiChatService chat;

    private long windowStart = System.nanoTime();
    private int requests;

    @PostMapping("/advice")
    public ResponseEntity<ApiResponse<ChatAdviceResponse>> advise(
            @Valid @RequestBody ChatAdviceRequest request) {

        if (!takeSlot()) {
            return failure(
                    HttpStatus.TOO_MANY_REQUESTS,
                    "Tư vấn AI đang nhận nhiều câu hỏi."
                    + " Bạn thử lại sau một phút nhé.");
        }

        try {
            ChatAdviceResponse result =
                    chat.advise(request.message().trim());

            return ResponseEntity.ok(
                    ApiResponse.<ChatAdviceResponse>builder()
                            .success(true)
                            .message("Đã xử lý câu hỏi.")
                            .data(result)
                            .build());

        } catch (IllegalStateException ex) {
            return failure(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    ex.getMessage());
        }
    }

    private synchronized boolean takeSlot() {

        long now = System.nanoTime();

        if (now - windowStart
                >= java.time.Duration.ofMinutes(1).toNanos()) {
            windowStart = now;
            requests = 0;
        }

        if (requests >= 6) {
            return false;
        }

        requests++;
        return true;
    }

    private ResponseEntity<ApiResponse<ChatAdviceResponse>> failure(
            HttpStatus status,
            String message) {

        return ResponseEntity.status(status)
                .body(
                        ApiResponse.<ChatAdviceResponse>builder()
                                .success(false)
                                .message(message)
                                .build());
    }
}