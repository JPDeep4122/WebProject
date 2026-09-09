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
        // 1. Danh mục sản phẩm
        model.addAttribute("categories", productService.getAllCategories());

        // 2. Dữ liệu Top 20 Sản Phẩm cho 4 Tab 
        model.addAttribute("topNewest", productService.getTop20ByTab("newest"));
        model.addAttribute("topBestseller", productService.getTop20ByTab("bestseller"));
        model.addAttribute("topRating", productService.getTop20ByTab("rating"));
        model.addAttribute("topFavorite", productService.getTop20ByTab("favorite"));

        return "client/home";
    }
}