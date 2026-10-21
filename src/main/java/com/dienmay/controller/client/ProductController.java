package com.dienmay.controller.client;

import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

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
    public String listProducts(@ModelAttribute ProductFilterRequest filter, Model model) {
        List<Product> products = productService.filterProducts(filter);

        model.addAttribute("products", products);
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("brands", productService.getAllBrands());
        model.addAttribute("filter", filter);

        return "client/products";
    }

    // Đường dẫn xem theo danh mục: /products/category/tivi
    @GetMapping("/category/{slug}")
    public String listByCategory(@PathVariable String slug, @ModelAttribute ProductFilterRequest filter, Model model) {
        filter.setCategorySlug(slug);
        return listProducts(filter, model);
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