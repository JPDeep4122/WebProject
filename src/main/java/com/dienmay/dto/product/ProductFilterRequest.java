package com.dienmay.dto.product;

import java.math.BigDecimal;
import java.util.List;

import lombok.Data;

@Data
public class ProductFilterRequest {
	private String keyword;          // Tìm kiếm theo tên sản phẩm
    private String categorySlug;     // Danh mục: tivi, tu-lanh, may-giat...
    private List<Long> brandIds;     // Danh sách ID thương hiệu muốn lọc
    private BigDecimal minPrice;     // Giá tối thiểu
    private BigDecimal maxPrice;     // Giá tối đa
    private String sortBy;           
}
