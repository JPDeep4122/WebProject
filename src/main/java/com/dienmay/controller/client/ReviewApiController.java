package com.dienmay.controller.client;

import java.security.Principal;
import jakarta.validation.Valid;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.dienmay.dto.common.ApiResponse;
import com.dienmay.dto.review.ReviewRequest;
import com.dienmay.dto.review.ReviewResponse;
import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.service.review.ReviewService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewApiController {

    private final ReviewService reviewService;
    private final JwtUtils jwtUtils;

    @PostMapping
    public ResponseEntity<ApiResponse<ReviewResponse>> submitReview(
            @Valid @ModelAttribute ReviewRequest request,
            @RequestParam(value = "files", required = false)
            List<MultipartFile> files,
            Principal principal) {

        if (principal == null
                || "anonymousUser".equalsIgnoreCase(principal.getName())) {
            return ResponseEntity.status(401)
                    .body(ApiResponse.<ReviewResponse>builder()
                            .success(false)
                            .message("Vui lòng đăng nhập để đánh giá.")
                            .build());
        }

        try {
            ReviewResponse response = reviewService.createReview(
                    request, files, principal.getName());

            return ResponseEntity.ok(
                    ApiResponse.<ReviewResponse>builder()
                            .success(true)
                            .message("Đã gửi đánh giá thành công.")
                            .data(response)
                            .build());
        } catch (RuntimeException ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.<ReviewResponse>builder()
                            .success(false)
                            .message(ex.getMessage())
                            .build());
        }
    }

    @GetMapping("/check-eligibility")
    public ResponseEntity<ApiResponse<Boolean>> checkEligibility(
            @RequestParam Long productId,
            Principal principal) {

        String email = principal != null ? principal.getName() : null;

        boolean eligible = reviewService.canUserReviewProduct(
                email, productId);

        return ResponseEntity.ok(
                ApiResponse.<Boolean>builder()
                        .success(true)
                        .data(eligible)
                        .build());
    }
}