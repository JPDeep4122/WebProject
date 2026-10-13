package com.dienmay.repository.specification;

import java.util.ArrayList;
import java.util.List;
import org.springframework.data.jpa.domain.Specification;
import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.product.Product;
import jakarta.persistence.criteria.Predicate;

public class ProductSpecification {

    public static Specification<Product> filter(ProductFilterRequest req) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // 0. Luôn chỉ lấy các sản phẩm đang kinh doanh (active = true)
            predicates.add(cb.isTrue(root.get("active")));

            // 1. Lọc theo Danh mục (ID hoặc Slug)
            if (req.getCategoryId() != null) {
                predicates.add(cb.equal(root.get("category").get("id"), req.getCategoryId()));
            }
            if (req.getCategorySlug() != null && !req.getCategorySlug().trim().isEmpty()) {
                predicates.add(cb.equal(root.get("category").get("slug"), req.getCategorySlug().trim()));
            }

            // 2. Lọc theo Thương hiệu (danh sách ID)
            if (req.getBrandIds() != null && !req.getBrandIds().isEmpty()) {
                predicates.add(root.get("brand").get("id").in(req.getBrandIds()));
            }

            // 3. Lọc theo Khoảng giá (lấy discountPrice, nếu null thì fallback về price)
            if (req.getMinPrice() != null) {
                predicates.add(cb.greaterThanOrEqualTo(
                    cb.coalesce(root.get("discountPrice"), root.get("price")), req.getMinPrice()
                ));
            }
            if (req.getMaxPrice() != null) {
                predicates.add(cb.lessThanOrEqualTo(
                    cb.coalesce(root.get("discountPrice"), root.get("price")), req.getMaxPrice()
                ));
            }

            // 4. Lọc theo Đánh giá sao (từ X sao trở lên)
            if (req.getMinRating() != null && req.getMinRating() > 0) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("rating"), req.getMinRating()));
            }

            // 5. Tìm kiếm theo từ khóa tên sản phẩm (nếu có)
            if (req.getKeyword() != null && !req.getKeyword().trim().isEmpty()) {
                String searchPattern = "%" + req.getKeyword().trim().toLowerCase() + "%";
                predicates.add(cb.like(cb.lower(root.get("name")), searchPattern));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}