package com.dienmay.controller.client;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.dienmay.service.product.ProductService;

@Controller
public class HomeController {

    @Autowired
    private ProductService productService;

    @GetMapping("/")
    public String index(Model model) {
        // Truyền danh sách Danh mục và Sản phẩm nổi bật sang trang JSP
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("featuredProducts", productService.getFeaturedProducts());
        model.addAttribute("latestProducts", productService.getLatestProducts());

        return "client/home";
    }
}