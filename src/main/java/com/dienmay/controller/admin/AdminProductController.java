package com.dienmay.controller.admin;

import com.dienmay.dto.product.AdminProductRequest;
import com.dienmay.entity.product.Product;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.service.product.ProductService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.criteria.Predicate;

@Controller
@RequestMapping("/admin/products")
public class AdminProductController {
    private final ProductService productService;
    private final ProductRepository productRepository;

    public AdminProductController(ProductService productService, ProductRepository productRepository) {
        this.productService = productService;
        this.productRepository = productRepository;
    }

    @GetMapping
    public String list(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long brandId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "15") int size,
            @RequestParam(defaultValue = "id") String sort,
            @RequestParam(defaultValue = "desc") String direction,
            Model model) {

        int safePage = Math.max(0, page);
        int safeSize = List.of(10, 15, 20, 50).contains(size) ? size : 15;

        Sort order = Sort.by("desc".equalsIgnoreCase(direction) ? Sort.Direction.DESC : Sort.Direction.ASC,
                List.of("id", "name", "originalPrice", "discountPrice", "createdAt").contains(sort) ? sort : "id");
        Pageable pageable = PageRequest.of(safePage, safeSize, order);

        Specification<Product> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (keyword != null && !keyword.isBlank()) {
                String kw = "%" + keyword.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("name")), kw),
                        cb.like(cb.lower(root.get("sku")), kw)
                ));
            }
            if (categoryId != null) {
                predicates.add(cb.equal(root.get("category").get("id"), categoryId));
            }
            if (brandId != null) {
                predicates.add(cb.equal(root.get("brand").get("id"), brandId));
            }
            if (status != null && !status.isBlank()) {
                if ("ACTIVE".equalsIgnoreCase(status)) {
                    predicates.add(cb.isTrue(root.get("active")));
                } else if ("INACTIVE".equalsIgnoreCase(status)) {
                    predicates.add(cb.isFalse(root.get("active")));
                }
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<Product> productsPage = productRepository.findAll(spec, pageable);

        model.addAttribute("products", productsPage.getContent());
        model.addAttribute("productsPage", productsPage);
        model.addAttribute("newProduct", new AdminProductRequest());
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("brands", productService.getAllBrands());
        model.addAttribute("selectedKeyword", keyword != null ? keyword.trim() : "");
        model.addAttribute("selectedCategoryId", categoryId);
        model.addAttribute("selectedBrandId", brandId);
        model.addAttribute("selectedStatus", status);
        model.addAttribute("selectedSort", sort);
        model.addAttribute("selectedDirection", direction);
        model.addAttribute("pageSize", safeSize);
        return "admin/products";
    }

    @PostMapping(consumes = "multipart/form-data")
    public String create(@Valid @ModelAttribute("newProduct") AdminProductRequest request, BindingResult result, Model model, RedirectAttributes flash) {
        if (result.hasErrors()) {
            flash.addFlashAttribute("error", result.getAllErrors().getFirst().getDefaultMessage());
            return "redirect:/admin/products";
        }
        try { 
            productService.saveProduct(null, request); 
            flash.addFlashAttribute("success", "Đã tạo sản phẩm thành công."); 
        } catch (RuntimeException ex) { 
            flash.addFlashAttribute("error", ex.getMessage()); 
        }
        return "redirect:/admin/products";
    }

    @GetMapping("/{id}/edit")
    public String edit(@PathVariable Long id, Model model) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));
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
            model.addAttribute("validationErrors", result.getAllErrors().stream()
                    .map(error -> error.getDefaultMessage()).toList());
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
