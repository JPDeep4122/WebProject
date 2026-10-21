package com.dienmay.service.impl;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.dienmay.dto.review.ProductReviewStatsDto;
import com.dienmay.dto.review.ReviewRequest;
import com.dienmay.dto.review.ReviewResponse;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderItem;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.product.Product;
import com.dienmay.entity.review.Review;
import com.dienmay.entity.review.ReviewMedia;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.repository.review.ReviewMediaRepository;
import com.dienmay.repository.review.ReviewRepository;
import com.dienmay.service.CloudinaryService;
import com.dienmay.service.review.ReviewService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final ReviewMediaRepository reviewMediaRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final CloudinaryService cloudinaryService;

    @Override
    @Transactional
    public ReviewResponse createReview(ReviewRequest request, List<MultipartFile> files, String userEmail) {
        if (userEmail == null || userEmail.equalsIgnoreCase("anonymousUser")) {
            throw new RuntimeException("Vui lòng đăng nhập để gửi đánh giá sản phẩm!");
        }

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("Tài khoản người dùng không tồn tại!"));
        
        if (!user.isActive()) {
            throw new IllegalArgumentException(
                    "Tài khoản hiện không được phép gửi đánh giá.");
        }
        
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Sản phẩm không tồn tại!"));

        // 1. Kiểm tra độ dài bình luận >= 50 ký tự (theo đặc tả DoD)
        if (request.getComment() == null || request.getComment().trim().length() < 50) {
            throw new RuntimeException("Nội dung đánh giá phải có ít nhất 50 ký tự!");
        }

        // 2. Kiểm tra số sao
        if (request.getRating() == null || request.getRating() < 1 || request.getRating() > 5) {
            throw new RuntimeException("Số sao đánh giá phải từ 1 đến 5 sao!");
        }

        // 3. Kiểm tra điều kiện: Người dùng phải đã mua sản phẩm này trong đơn hàng DELIVERED
        String requestedCode = request.getOrderCode() == null
                || request.getOrderCode().isBlank()
                ? null
                : request.getOrderCode().trim().replace("-", "");

        Order matchedOrder = orderRepository
                .findByUserIdAndStatusOrderByCreatedAtDesc(
                        user.getId(), OrderStatus.DELIVERED)
                .stream()
                .filter(order -> requestedCode == null
                        || (order.getOrderCode() != null
                            && order.getOrderCode().replace("-", "")
                                    .equalsIgnoreCase(requestedCode)))
                .filter(order -> order.getOrderItems() != null
                        && order.getOrderItems().stream()
                                .anyMatch(item -> item.getProduct() != null
                                        && product.getId().equals(
                                                item.getProduct().getId())))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException(
                        "Bạn chỉ được đánh giá sản phẩm trong đơn hàng "
                        + "của mình đã giao thành công."));

        // Kiểm tra xem đã từng đánh giá sản phẩm này chưa
        if (reviewRepository.existsByUserIdAndProductId(user.getId(), product.getId())) {
            throw new RuntimeException("Bạn đã đánh giá sản phẩm này rồi! Cảm ơn bạn.");
        }

        // 4. Lưu Review vào CSDL
        Review review = Review.builder()
                .user(user)
                .product(product)
                .order(matchedOrder)
                .rating(request.getRating())
                .comment(request.getComment().trim())
                .active(true)
                .build();

        Review savedReview = reviewRepository.save(review);

        // 5. Upload ảnh / video lên Cloudinary nếu có đính kèm
        if (files != null && !files.isEmpty()) {
            for (MultipartFile file : files) {
                if (file != null && !file.isEmpty()) {
                    try {
                        String mediaUrl = cloudinaryService.uploadFile(file, "reviews");
                        String contentType = file.getContentType();
                        String mediaType = (contentType != null && contentType.startsWith("video")) ? "VIDEO" : "IMAGE";

                        ReviewMedia media = ReviewMedia.builder()
                                .review(savedReview)
                                .mediaUrl(mediaUrl)
                                .mediaType(mediaType)
                                .build();
                        reviewMediaRepository.save(media);
                        savedReview.getMediaList().add(media);
                    } catch (Exception ignored) {
                    }
                }
            }
        }

        // 6. Cập nhật lại điểm đánh giá trung bình cho Product
        Double avg = reviewRepository.calculateAverageRating(product.getId());
        if (avg != null) {
            double rounded = Math.round(avg * 10.0) / 10.0;
            product.setRating(rounded);
            productRepository.save(product);
        }

        return mapToResponse(savedReview);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReviewResponse> getReviewsByProductId(Long productId) {
        List<Review> reviews = reviewRepository.findByProductIdAndActiveTrueOrderByCreatedAtDesc(productId);
        return reviews.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ProductReviewStatsDto getReviewStats(Long productId) {
        long total = reviewRepository.countByProductIdAndActiveTrue(productId);
        Double avg = reviewRepository.calculateAverageRating(productId);
        double roundedAvg = (avg != null) ? Math.round(avg * 10.0) / 10.0 : 0.0;

        long c5 = reviewRepository.countByProductIdAndRatingAndActiveTrue(productId, 5);
        long c4 = reviewRepository.countByProductIdAndRatingAndActiveTrue(productId, 4);
        long c3 = reviewRepository.countByProductIdAndRatingAndActiveTrue(productId, 3);
        long c2 = reviewRepository.countByProductIdAndRatingAndActiveTrue(productId, 2);
        long c1 = reviewRepository.countByProductIdAndRatingAndActiveTrue(productId, 1);

        int p5 = total > 0 ? (int) Math.round((c5 * 100.0) / total) : 0;
        int p4 = total > 0 ? (int) Math.round((c4 * 100.0) / total) : 0;
        int p3 = total > 0 ? (int) Math.round((c3 * 100.0) / total) : 0;
        int p2 = total > 0 ? (int) Math.round((c2 * 100.0) / total) : 0;
        int p1 = total > 0 ? (int) Math.round((c1 * 100.0) / total) : 0;

        return ProductReviewStatsDto.builder()
                .averageRating(roundedAvg)
                .totalReviews(total)
                .count5Star(c5)
                .count4Star(c4)
                .count3Star(c3)
                .count2Star(c2)
                .count1Star(c1)
                .percent5Star(p5)
                .percent4Star(p4)
                .percent3Star(p3)
                .percent2Star(p2)
                .percent1Star(p1)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public boolean canUserReviewProduct(String userEmail, Long productId) {
        if (userEmail == null || userEmail.equalsIgnoreCase("anonymousUser")) {
            return false;
        }
        User user = userRepository.findByEmail(userEmail).orElse(null);
        if (user == null || !user.isActive()) return false;

        // Nếu đã đánh giá rồi thì không cho đánh giá lại
        if (reviewRepository.existsByUserIdAndProductId(user.getId(), productId)) {
            return false;
        }

        // Kiểm tra xem đã có đơn hàng nào DELIVERED chứa sản phẩm này chưa
        List<Order> deliveredOrders = orderRepository.findByUserIdAndStatusOrderByCreatedAtDesc(user.getId(), OrderStatus.DELIVERED);
        for (Order o : deliveredOrders) {
            if (o.getOrderItems() != null) {
                for (OrderItem item : o.getOrderItems()) {
                    if (item.getProduct().getId().equals(productId)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private ReviewResponse mapToResponse(Review r) {
        List<ReviewResponse.MediaItemDto> mediaList = Collections.emptyList();
        if (r.getMediaList() != null) {
            mediaList = r.getMediaList().stream()
                    .map(m -> ReviewResponse.MediaItemDto.builder()
                            .mediaUrl(m.getMediaUrl())
                            .mediaType(m.getMediaType())
                            .build())
                    .collect(Collectors.toList());
        }

        String fullName = (r.getUser() != null && r.getUser().getFullName() != null) 
                ? r.getUser().getFullName() : "Khách hàng";
        String email = (r.getUser() != null) ? r.getUser().getEmail() : "";

        return ReviewResponse.builder()
                .id(r.getId())
                .userFullName(fullName)
                .userEmail(maskEmail(email))
                .rating(r.getRating())
                .comment(r.getComment())
                .createdAt(r.getCreatedAt())
                .mediaList(mediaList)
                .build();
    }

    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        int atIndex = email.indexOf("@");
        if (atIndex <= 3) return email.charAt(0) + "***" + email.substring(atIndex);
        return email.substring(0, 3) + "***" + email.substring(atIndex);
    }
}