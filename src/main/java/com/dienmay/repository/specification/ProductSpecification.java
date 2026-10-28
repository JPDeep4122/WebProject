package com.dienmay.repository.specification;

import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import org.springframework.data.jpa.domain.Specification;
import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.product.Product;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public class ProductSpecification {

    public static Specification<Product> filter(ProductFilterRequest req) {
        return filter(req, true);
    }

    public static Specification<Product> filter(ProductFilterRequest req, boolean includeBrands) {
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
            if (includeBrands && req.getBrandIds() != null && !req.getBrandIds().isEmpty()) {
                predicates.add(root.get("brand").get("id").in(req.getBrandIds()));
            }

            // Use the same selling price for filtering, sorting and display.
            if (req.getMinPrice() != null) {
                predicates.add(cb.greaterThanOrEqualTo(
                    sellingPrice(root, cb), req.getMinPrice()
                ));
            }
            if (req.getMaxPrice() != null) {
                predicates.add(cb.lessThanOrEqualTo(
                    sellingPrice(root, cb), req.getMaxPrice()
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

            // EXISTS avoids duplicate products when several branches have stock.
            if (Boolean.TRUE.equals(req.getInStockOnly()) || req.getBranchId() != null) {
                var stock = query.subquery(Integer.class);
                var inventory = stock.from(BranchInventory.class);
                List<Predicate> stockConditions = new ArrayList<>();
                stockConditions.add(cb.equal(inventory.get("product").get("id"), root.get("id")));
                stockConditions.add(cb.isTrue(inventory.get("branch").get("active")));
                stockConditions.add(cb.greaterThan(inventory.get("availableQuantity"), 0));
                if (req.getBranchId() != null) {
                    stockConditions.add(cb.equal(inventory.get("branch").get("id"), req.getBranchId()));
                }
                stock.select(cb.literal(1)).where(stockConditions.toArray(new Predicate[0]));
                predicates.add(cb.exists(stock));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    public static Expression<BigDecimal> sellingPrice(Root<Product> root, CriteriaBuilder cb) {
        return cb.<BigDecimal>coalesce().value(root.get("discountPrice"))
                .value(root.get("price")).value(root.get("originalPrice"));
    }
}
