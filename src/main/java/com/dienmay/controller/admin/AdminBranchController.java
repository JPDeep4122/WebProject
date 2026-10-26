package com.dienmay.controller.admin;

import java.util.Comparator;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.entity.branch.Branch;
import com.dienmay.repository.branch.BranchRepository;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/branches")
@RequiredArgsConstructor
public class AdminBranchController {

    private final BranchRepository branchRepository;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("branches", branchRepository.findAll().stream()
                .sorted(Comparator.comparing(Branch::getName, String.CASE_INSENSITIVE_ORDER))
                .toList());
        return "admin/branches";
    }

    @PostMapping
    public String create(@RequestParam String name,
            @RequestParam String address,
            @RequestParam(required = false) String province,
            @RequestParam(required = false) String phone,
            RedirectAttributes flash) {
        try {
            Branch branch = new Branch();
            applyFields(branch, name, address, province, phone);
            branch.setActive(true);
            branchRepository.save(branch);
            flash.addFlashAttribute("success", "Đã thêm chi nhánh.");
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/branches";
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id,
            @RequestParam String name,
            @RequestParam String address,
            @RequestParam(required = false) String province,
            @RequestParam(required = false) String phone,
            @RequestParam(defaultValue = "false") boolean active,
            RedirectAttributes flash) {
        try {
            Branch branch = branchRepository.findById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh."));
            applyFields(branch, name, address, province, phone);
            branch.setActive(active);
            branchRepository.save(branch);
            flash.addFlashAttribute("success", "Đã cập nhật chi nhánh.");
        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/branches";
    }

    private void applyFields(Branch branch, String name, String address, String province, String phone) {
        String cleanName = name == null ? "" : name.trim();
        String cleanAddress = address == null ? "" : address.trim();
        String cleanProvince = province == null ? "" : province.trim();
        String cleanPhone = phone == null ? "" : phone.trim();

        if (cleanName.isEmpty() || cleanAddress.isEmpty()) {
            throw new IllegalArgumentException("Tên và địa chỉ chi nhánh không được để trống.");
        }
        if (cleanName.length() > 150 || cleanAddress.length() > 255
                || cleanProvince.length() > 100 || cleanPhone.length() > 20) {
            throw new IllegalArgumentException("Một số thông tin vượt quá độ dài cho phép.");
        }

        branch.setName(cleanName);
        branch.setAddress(cleanAddress);
        branch.setProvince(cleanProvince.isEmpty() ? null : cleanProvince);
        branch.setPhone(cleanPhone.isEmpty() ? null : cleanPhone);
    }
}
