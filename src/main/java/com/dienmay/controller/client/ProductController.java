package com.dienmay.controller.client;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.product.Product;
import com.dienmay.service.product.ProductService;

@Controller
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductService productService;

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
    public String productDetail(@PathVariable String slug, Model model) {
        Product product = productService.getProductBySlug(slug);
        List<com.dienmay.entity.branch.BranchProduct> branchStocks = productService.getBranchStock(product.getId());
        List<Product> relatedProducts = productService.getRelatedProducts(product.getCategory().getId(), product.getId());

        // Tính tổng số lượng hàng còn lại trên toàn hệ thống
        int totalStock = branchStocks.stream().mapToInt(bp -> bp.getQuantity()).sum();

        model.addAttribute("product", product);
        model.addAttribute("branchStocks", branchStocks);
        model.addAttribute("totalStock", totalStock);
        model.addAttribute("relatedProducts", relatedProducts);

        return "client/product-detail";
    }
    

}