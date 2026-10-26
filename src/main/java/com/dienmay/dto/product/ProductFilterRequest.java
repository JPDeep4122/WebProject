package com.dienmay.dto.product;

import java.math.BigDecimal;
import java.util.List;
import lombok.Data;

@Data
public class ProductFilterRequest {
    private Long categoryId;           // Lọc theo ID danh mục
    private String categorySlug;       // Lọc theo Slug danh mục (VD: tivi, tu-lanh)
    private List<Long> brandIds;       // Lọc theo danh sách Thương hiệu
    private BigDecimal minPrice;       // Giá tối thiểu
    private BigDecimal maxPrice;       // Giá tối đa
    private Double minRating;          // Đánh giá từ X sao trở lên (>= 4.0, >= 3.0)
    private String keyword;            // Từ khóa tìm kiếm tên SP
    private Boolean inStockOnly = false;
    private Long branchId;
    
    // Tham số sắp xếp: "price_asc", "price_desc", "newest", "bestseller", "rating"
    private String sortBy = "newest";  
    
    // Phân trang (dùng Integer wrapper để hỗ trợ null check)
    private Integer page = 0;          // Trang hiện tại (0-indexed)
    private Integer size = 12;         // Số lượng SP mỗi trang
}
