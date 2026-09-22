package com.dienmay.repository.review;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.review.ReviewMedia;

@Repository
public interface ReviewMediaRepository extends JpaRepository<ReviewMedia, Long> {
}