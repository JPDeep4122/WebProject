package com.dienmay.controller.client;

import java.security.Principal;
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

    // 1. API GỬI ĐÁNH GIÁ 
    @PostMapping
    public ResponseEntity<ApiResponse<ReviewResponse>> submitReview(
            @ModelAttribute ReviewRequest request,
            @RequestParam(value = "files", required = false) List<MultipartFile> files,
            @RequestParam(required = false) String email,
            @CookieValue(value = "accessToken", required = false) String cookieToken,
            Principal principal) {

        String userEmail = resolveEmail(principal, email, cookieToken);
        if (userEmail == null || userEmail.equalsIgnoreCase("anonymousUser")) {
            return ResponseEntity.badRequest().body(ApiResponse.<ReviewResponse>builder()
                    .success(false)
                    .message("Vui lòng đăng nhập để gửi đánh giá sản phẩm!")
                    .build());
        }

        try {
            ReviewResponse response = reviewService.createReview(request, files, userEmail);
            return ResponseEntity.ok(ApiResponse.<ReviewResponse>builder()
                    .success(true)
                    .message("Cảm ơn bạn đã gửi đánh giá sản phẩm thành công!")
                    .data(response)
                    .build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.<ReviewResponse>builder()
                    .success(false)
                    .message(e.getMessage())
                    .build());
        }
    }

    // 2. API KIỂM TRA ĐIỀU KIỆN ĐƯỢC PHÉP ĐÁNH GIÁ
    @GetMapping("/check-eligibility")
    public ResponseEntity<ApiResponse<Boolean>> checkEligibility(
            @RequestParam Long productId,
            @RequestParam(required = false) String email,
            @CookieValue(value = "accessToken", required = false) String cookieToken,
            Principal principal) {

        String userEmail = resolveEmail(principal, email, cookieToken);
        boolean canReview = reviewService.canUserReviewProduct(userEmail, productId);
        return ResponseEntity.ok(ApiResponse.<Boolean>builder()
                .success(true)
                .data(canReview)
                .build());
    }

    private String resolveEmail(Principal principal, String email, String cookieToken) {
        if (principal != null && !principal.getName().equalsIgnoreCase("anonymousUser")) {
            return principal.getName();
        }
        if (email != null && !email.trim().isEmpty()) {
            return email.trim();
        }
        if (cookieToken != null && jwtUtils.validateJwtToken(cookieToken)) {
            return jwtUtils.getUserNameFromJwtToken(cookieToken);
        }
        return null;
    }
}