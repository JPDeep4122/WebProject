package com.dienmay.dto.review;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductReviewStatsDto {

    private Double averageRating; 
    private Long totalReviews;    

    private Long count5Star;
    private Long count4Star;
    private Long count3Star;
    private Long count2Star;
    private Long count1Star;

    private Integer percent5Star;
    private Integer percent4Star;
    private Integer percent3Star;
    private Integer percent2Star;
    private Integer percent1Star;
}