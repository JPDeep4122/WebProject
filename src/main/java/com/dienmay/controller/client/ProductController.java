package com.dienmay.controller.client;

import java.security.Principal;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.util.UriComponentsBuilder;
import jakarta.servlet.http.HttpServletRequest;

import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.dto.review.ProductReviewStatsDto;
import com.dienmay.dto.review.ReviewResponse;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.product.Product;
import com.dienmay.service.product.ProductService;
import com.dienmay.service.review.ReviewService;

@Controller
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @Autowired
    private ReviewService reviewService;

    // Xem danh sách sản phẩm có bộ lọc (hoặc theo danh mục)
    @GetMapping
    public String listProducts(@ModelAttribute ProductFilterRequest filter, Model model,
            HttpServletRequest request) {
        if (filter.getBranchId() != null) filter.setInStockOnly(true);
        var page = productService.filterProductsPage(filter);
        if (page.getTotalPages() > 0 && page.getNumber() >= page.getTotalPages()) {
            filter.setPage(page.getTotalPages() - 1);
            page = productService.filterProductsPage(filter);
        }
        model.addAttribute("products", page.getContent());
        model.addAttribute("productPage", page);
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("brands", productService.getBrandsForFilter(filter));
        model.addAttribute("branches", productService.getActiveBranches());
        model.addAttribute("filter", filter);
        model.addAttribute("catalogPage", true);
        model.addAttribute("filterCount", filterCount(filter));
        model.addAttribute("clearFiltersUrl", catalogUrl(request.getContextPath(), filter, 0, true));
        model.addAttribute("productsUrl", request.getContextPath() + "/products");
        List<Map<String, Object>> links = new ArrayList<>();
        for (int index = Math.max(0, page.getNumber() - 2);
                index <= Math.min(page.getTotalPages() - 1, page.getNumber() + 2); index++) {
            links.add(Map.of("label", index + 1, "current", index == page.getNumber(),
                    "url", catalogUrl(request.getContextPath(), filter, index, false)));
        }
        model.addAttribute("pageLinks", links);
        if (page.hasPrevious()) {
            model.addAttribute("previousPageUrl", catalogUrl(request.getContextPath(), filter, page.getNumber() - 1, false));
        }
        if (page.hasNext()) {
            model.addAttribute("nextPageUrl", catalogUrl(request.getContextPath(), filter, page.getNumber() + 1, false));
        }

        return "client/products";
    }

    // Đường dẫn xem theo danh mục: /products/category/tivi
    @GetMapping("/category/{slug}")
    public String listByCategory(@PathVariable String slug, @ModelAttribute ProductFilterRequest filter,
            Model model, HttpServletRequest request) {
        filter.setCategorySlug(slug);
        return listProducts(filter, model, request);
    }

    private int filterCount(ProductFilterRequest filter) {
        int count = filter.getBrandIds() == null ? 0 : filter.getBrandIds().size();
        if (filter.getCategoryId() != null || hasText(filter.getCategorySlug())) count++;
        if (filter.getMinPrice() != null || filter.getMaxPrice() != null) count++;
        if (filter.getMinRating() != null && filter.getMinRating() > 0) count++;
        if (Boolean.TRUE.equals(filter.getInStockOnly())) count++;
        if (filter.getBranchId() != null) count++;
        return count;
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    private String catalogUrl(String contextPath, ProductFilterRequest filter, int page, boolean clear) {
        var url = UriComponentsBuilder.fromPath(contextPath + "/products");
        if (hasText(filter.getKeyword())) url.queryParam("keyword", filter.getKeyword());
        url.queryParam("sortBy", filter.getSortBy());
        url.queryParam("size", filter.getSize());
        if (!clear) {
            if (filter.getCategoryId() != null) url.queryParam("categoryId", filter.getCategoryId());
            if (hasText(filter.getCategorySlug())) url.queryParam("categorySlug", filter.getCategorySlug());
            if (filter.getBrandIds() != null) {
                filter.getBrandIds().forEach(id -> url.queryParam("brandIds", id));
            }
            if (filter.getMinPrice() != null) url.queryParam("minPrice", filter.getMinPrice());
            if (filter.getMaxPrice() != null) url.queryParam("maxPrice", filter.getMaxPrice());
            if (filter.getMinRating() != null && filter.getMinRating() > 0) url.queryParam("minRating", filter.getMinRating());
            if (Boolean.TRUE.equals(filter.getInStockOnly())) url.queryParam("inStockOnly", true);
            if (filter.getBranchId() != null) url.queryParam("branchId", filter.getBranchId());
        }
        if (page > 0) url.queryParam("page", page);
        return url.build().encode().toUriString();
    }
    
    // Xem chi tiết sản phẩm: /products/{slug}
    @GetMapping("/{slug}")
    public String productDetail(
            @PathVariable String slug,
            Principal principal,
            Model model) {
        Product product = productService.getProductBySlug(slug);
        List<BranchInventory> branchStocks =
                productService.getBranchStock(product.getId());

        List<Product> relatedProducts = productService.getRelatedProducts(product.getCategory().getId(), product.getId());
        
        // Tính tổng số lượng hàng còn lại trên toàn hệ thống
        int totalStock = branchStocks.stream()
                .mapToInt(BranchInventory::getAvailableQuantity)
                .sum();

        // Lấy danh sách đánh giá & thống kê sao
        String userEmail = principal != null ? principal.getName() : null;
        boolean canReview = reviewService.canUserReviewProduct(userEmail, product.getId());
        ProductReviewStatsDto reviewStats = reviewService.getReviewStats(product.getId());
        List<ReviewResponse> reviews = reviewService.getReviewsByProductId(product.getId());

        model.addAttribute("product", product);
        model.addAttribute("branchStocks", branchStocks);
        model.addAttribute("totalStock", totalStock);
        model.addAttribute("relatedProducts", relatedProducts);
        model.addAttribute("canReview", canReview);
        model.addAttribute("reviewStats", reviewStats);
        model.addAttribute("reviews", reviews);

        return "client/product-detail";
    }
}
