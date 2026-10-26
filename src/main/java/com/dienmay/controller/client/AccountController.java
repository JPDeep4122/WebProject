package com.dienmay.controller.client;

import java.security.Principal;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.dto.auth.AccountProfile;
import com.dienmay.dto.auth.ChangePasswordRequest;
import com.dienmay.dto.auth.ProfileUpdateRequest;
import com.dienmay.service.auth.AccountService;

import jakarta.validation.Valid;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/account")
@RequiredArgsConstructor
public class AccountController {
    private final AccountService accounts;

    @ModelAttribute
    void preventCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store");
    }

    @InitBinder("profileForm")
    void bindProfile(WebDataBinder binder) {
        binder.setAllowedFields("fullName", "phoneNumber");
    }

    @InitBinder("passwordForm")
    void bindPassword(WebDataBinder binder) {
        binder.setAllowedFields("currentPassword", "newPassword", "confirmPassword");
    }

    @GetMapping("/profile")
    public String profile(Principal principal, Model model) {
        return preparePage(principal, model);
    }

    @PostMapping("/profile")
    public String updateProfile(@Valid @ModelAttribute("profileForm") ProfileUpdateRequest request,
            BindingResult errors, Principal principal, Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("profileError", errors.getAllErrors().getFirst().getDefaultMessage());
            return preparePage(principal, model);
        }
        accounts.updateProfile(principal.getName(), request);
        flash.addFlashAttribute("profileSuccess", "Đã cập nhật thông tin cá nhân.");
        return "redirect:/account/profile";
    }

    @PostMapping("/password")
    public String changePassword(@Valid @ModelAttribute("passwordForm") ChangePasswordRequest request,
            BindingResult errors, Principal principal, Model model, RedirectAttributes flash) {
        try {
            if (errors.hasErrors()) {
                model.addAttribute("passwordError", errors.getAllErrors().getFirst().getDefaultMessage());
                return preparePage(principal, model);
            }
            try {
                accounts.changePassword(principal.getName(), request);
            } catch (IllegalArgumentException ex) {
                model.addAttribute("passwordError", ex.getMessage());
                return preparePage(principal, model);
            }
            flash.addFlashAttribute("passwordSuccess", "Đổi mật khẩu thành công. Hãy dùng mật khẩu mới cho lần đăng nhập tiếp theo.");
            return "redirect:/account/profile#change-password";
        } finally {
            request.setCurrentPassword(null);
            request.setNewPassword(null);
            request.setConfirmPassword(null);
        }
    }

    private String preparePage(Principal principal, Model model) {
        AccountProfile profile = accounts.getProfile(principal.getName());
        model.addAttribute("accountProfile", profile);
        if (!model.containsAttribute("profileForm")) {
            ProfileUpdateRequest form = new ProfileUpdateRequest();
            form.setFullName(profile.getFullName());
            form.setPhoneNumber(profile.getPhoneNumber());
            model.addAttribute("profileForm", form);
        }
        return "client/profile";
    }
}
