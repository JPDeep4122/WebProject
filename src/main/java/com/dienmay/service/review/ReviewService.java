package com.dienmay.service.review;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.dienmay.dto.review.ProductReviewStatsDto;
import com.dienmay.dto.review.ReviewRequest;
import com.dienmay.dto.review.ReviewResponse;

public interface ReviewService {

    ReviewResponse createReview(ReviewRequest request, List<MultipartFile> files, String userEmail);

    List<ReviewResponse> getReviewsByProductId(Long productId);

    ProductReviewStatsDto getReviewStats(Long productId);

    boolean canUserReviewProduct(String userEmail, Long productId);
}