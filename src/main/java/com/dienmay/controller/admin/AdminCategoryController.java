package com.dienmay.controller.admin;

import com.dienmay.dto.category.CategoryCreateRequest;
import com.dienmay.dto.category.CategoryUpdateRequest;
import com.dienmay.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/categories")
public class AdminCategoryController {
    private final CategoryService categoryService;
    public AdminCategoryController(CategoryService categoryService) { this.categoryService = categoryService; }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("categories", categoryService.getAll());
        model.addAttribute("newCategory", new CategoryCreateRequest());
        model.addAttribute("editCategory", new CategoryUpdateRequest());
        return "admin/categories";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute("newCategory") CategoryCreateRequest request, BindingResult result, RedirectAttributes flash, Model model) {
        if (result.hasErrors()) { model.addAttribute("categories", categoryService.getAll()); model.addAttribute("editCategory", new CategoryUpdateRequest()); return "admin/categories"; }
        try { categoryService.create(request); flash.addFlashAttribute("success", "Đã tạo danh mục."); }
        catch (RuntimeException ex) { flash.addFlashAttribute("error", ex.getMessage()); }
        return "redirect:/admin/categories";
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id, @Valid @ModelAttribute("editCategory") CategoryUpdateRequest request, BindingResult result, RedirectAttributes flash) {
        if (result.hasErrors()) { flash.addFlashAttribute("error", "Dữ liệu cập nhật không hợp lệ."); return "redirect:/admin/categories"; }
        try { categoryService.update(id, request); flash.addFlashAttribute("success", "Đã cập nhật danh mục."); }
        catch (RuntimeException ex) { flash.addFlashAttribute("error", ex.getMessage()); }
        return "redirect:/admin/categories";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes flash) {
        try { categoryService.delete(id); flash.addFlashAttribute("success", "Đã xóa danh mục."); }
        catch (RuntimeException ex) { flash.addFlashAttribute("error", ex.getMessage()); }
        return "redirect:/admin/categories";
    }
}
