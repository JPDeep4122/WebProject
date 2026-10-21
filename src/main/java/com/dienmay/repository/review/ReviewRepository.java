package com.dienmay.repository.review;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.review.Review;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findByProductIdAndActiveTrueOrderByCreatedAtDesc(Long productId);

    long countByProductIdAndActiveTrue(Long productId);

    long countByProductIdAndRatingAndActiveTrue(Long productId, Integer rating);

    boolean existsByUserIdAndProductId(Long userId, Long productId);

    @Query("SELECT AVG(CAST(r.rating as double)) FROM Review r WHERE r.product.id = :productId AND r.active = true")
    Double calculateAverageRating(@Param("productId") Long productId);
}