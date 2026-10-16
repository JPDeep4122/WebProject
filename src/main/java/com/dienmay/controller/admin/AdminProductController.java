package com.dienmay.controller.admin;

import com.dienmay.dto.product.AdminProductRequest;
import com.dienmay.entity.product.Product;
import com.dienmay.service.product.ProductService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/products")
public class AdminProductController {
    private final ProductService productService;
    public AdminProductController(ProductService productService) { this.productService = productService; }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("products", productService.getAllProductsForAdmin());
        model.addAttribute("newProduct", new AdminProductRequest());
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("brands", productService.getAllBrands());
        return "admin/products";
    }

    @PostMapping(consumes = "multipart/form-data")
    public String create(@Valid @ModelAttribute("newProduct") AdminProductRequest request, BindingResult result, Model model, RedirectAttributes flash) {
        if (result.hasErrors()) {
            model.addAttribute("products", productService.getAllProductsForAdmin());
            model.addAttribute("categories", productService.getAllCategories());
            model.addAttribute("brands", productService.getAllBrands());
            return "admin/products";
        }
        try { productService.saveProduct(null, request); flash.addFlashAttribute("success", "Đã tạo sản phẩm."); }
        catch (RuntimeException ex) { flash.addFlashAttribute("error", ex.getMessage()); }
        return "redirect:/admin/products";
    }

    @GetMapping("/{id}/edit")
    public String edit(@PathVariable Long id, Model model) {
        Product product = productService.getAllProductsForAdmin().stream().filter(p -> p.getId().equals(id)).findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));
        AdminProductRequest form = new AdminProductRequest();
        form.setName(product.getName()); form.setSlug(product.getSlug()); form.setSku(product.getSku());
        form.setShortDescription(product.getShortDescription()); form.setDescription(product.getDescription());
        form.setSpecifications(product.getSpecifications());
        form.setOriginalPrice(product.getOriginalPrice()); form.setDiscountPrice(product.getDiscountPrice());
        form.setMainImageUrl(product.getMainImageUrl()); form.setCategoryId(product.getCategory().getId());
        form.setBrandId(product.getBrand().getId()); form.setActive(product.isActive()); form.setFeatured(product.isFeatured());
        model.addAttribute("productId", id); model.addAttribute("form", form);
        model.addAttribute("categories", productService.getAllCategories()); model.addAttribute("brands", productService.getAllBrands());
        return "admin/product-form";
    }

    @PostMapping(value = "/{id}/edit", consumes = "multipart/form-data")
    public String update(@PathVariable Long id, @Valid @ModelAttribute("form") AdminProductRequest request, BindingResult result, Model model, RedirectAttributes flash) {
        if (result.hasErrors()) {
            model.addAttribute("productId", id); model.addAttribute("categories", productService.getAllCategories());
            model.addAttribute("brands", productService.getAllBrands()); return "admin/product-form";
        }
        try { productService.saveProduct(id, request); flash.addFlashAttribute("success", "Đã cập nhật sản phẩm."); }
        catch (RuntimeException ex) { flash.addFlashAttribute("error", ex.getMessage()); }
        return "redirect:/admin/products";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes flash) {
        try { productService.deleteProduct(id); flash.addFlashAttribute("success", "Đã ẩn sản phẩm khỏi cửa hàng."); }
        catch (RuntimeException ex) { flash.addFlashAttribute("error", ex.getMessage()); }
        return "redirect:/admin/products";
    }
}
