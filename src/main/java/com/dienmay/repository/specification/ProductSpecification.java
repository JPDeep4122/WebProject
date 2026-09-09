package com.dienmay.repository.specification;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.product.Product;

import jakarta.persistence.criteria.Predicate;

public class ProductSpecification {

    public static Specification<Product> filter(ProductFilterRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // 1. Chỉ lấy sản phẩm đang hoạt động (active = true)
            predicates.add(cb.isTrue(root.get("active")));

            // 2. Lọc theo từ khóa tìm kiếm (Tên sản phẩm)
            if (request.getKeyword() != null && !request.getKeyword().trim().isEmpty()) {
                String likeKeyword = "%" + request.getKeyword().trim().toLowerCase() + "%";
                predicates.add(cb.like(cb.lower(root.get("name")), likeKeyword));
            }

            // 3. Lọc theo danh mục (categorySlug)
            if (request.getCategorySlug() != null && !request.getCategorySlug().trim().isEmpty()) {
                predicates.add(cb.equal(root.get("category").get("slug"), request.getCategorySlug().trim()));
            }

            // 4. Lọc theo danh sách thương hiệu (brandIds)
            if (request.getBrandIds() != null && !request.getBrandIds().isEmpty()) {
                predicates.add(root.get("brand").get("id").in(request.getBrandIds()));
            }

            // 5. Lọc theo giá tối thiểu (minPrice)
            if (request.getMinPrice() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("discountPrice"), request.getMinPrice()));
            }

            // 6. Lọc theo giá tối đa (maxPrice)
            if (request.getMaxPrice() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("discountPrice"), request.getMaxPrice()));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}