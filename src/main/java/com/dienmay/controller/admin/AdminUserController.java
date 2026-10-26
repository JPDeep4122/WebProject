package com.dienmay.controller.admin;

import com.dienmay.dto.auth.AdminUserRequest;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.repository.auth.RoleRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import jakarta.validation.Valid;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.List;

@Controller
@RequestMapping("/admin/users")
public class AdminUserController {
	private final UserRepository users;
	private final RoleRepository roles;
	private final BranchRepository branches;
	private final PasswordEncoder encoder;

	public AdminUserController(UserRepository users, RoleRepository roles, BranchRepository branches,
			PasswordEncoder encoder) {
		this.users = users;
		this.roles = roles;
		this.branches = branches;
		this.encoder = encoder;
	}

	@GetMapping
	public String list(@RequestParam(required = false) Long id, @RequestParam(required = false) String type,
			@RequestParam(defaultValue = "id") String sort, @RequestParam(defaultValue = "asc") String direction,
			Model model) {
		Sort order = Sort.by("desc".equalsIgnoreCase(direction) ? Sort.Direction.DESC : Sort.Direction.ASC,
				List.of("id", "email", "fullName", "createdAt", "active").contains(sort) ? sort : "id");
		List<User> result;
		if (id != null)
			result = users.findById(id).map(List::of).orElse(List.of());
		else if (type != null && !type.isBlank())
			result = users.findByRoles_Name(normalizeRole(type), order);
		else
			result = users.findAll(order);
		model.addAttribute("users", result);
		model.addAttribute("branches", branches.findAll(Sort.by("name")));
		model.addAttribute("newUser", new AdminUserRequest());
		model.addAttribute("selectedId", id);
		model.addAttribute("selectedType", type);
		model.addAttribute("selectedSort", sort);
		model.addAttribute("selectedDirection", direction);
		return "admin/users";
	}

	@PostMapping
	public String create(@Valid @ModelAttribute("newUser") AdminUserRequest request, BindingResult errors,
			RedirectAttributes flash) {
		if (errors.hasErrors()) {
			flash.addFlashAttribute("error", "Thông tin tài khoản không hợp lệ.");
			return "redirect:/admin/users";
		}
		try {
			if (users.existsByEmail(request.getEmail().trim()))
				throw new IllegalArgumentException("Email đã tồn tại.");
			User user = new User();
			apply(user, request, true);
			users.save(user);
			flash.addFlashAttribute("success", "Đã mở tài khoản và phân quyền.");
		} catch (RuntimeException e) {
			flash.addFlashAttribute("error", e.getMessage());
		}
		return "redirect:/admin/users";
	}

	@PostMapping("/{id}/update")
	public String update(@PathVariable Long id, @Valid @ModelAttribute AdminUserRequest request, BindingResult errors,
			RedirectAttributes flash) {
		if (errors.hasErrors()) {
			flash.addFlashAttribute("error", "Thông tin tài khoản không hợp lệ.");
			return "redirect:/admin/users";
		}
		try {
			User user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
			users.findByEmail(request.getEmail().trim()).ifPresent(existing -> {
				if (!existing.getId().equals(id))
					throw new IllegalArgumentException("Email đã tồn tại.");
			});
			apply(user, request, false);
			users.save(user);
			flash.addFlashAttribute("success", "Đã cập nhật tài khoản.");
		} catch (RuntimeException e) {
			flash.addFlashAttribute("error", e.getMessage());
		}
		return "redirect:/admin/users";
	}

	@PostMapping("/{id}/toggle")
	public String toggle(@PathVariable Long id, RedirectAttributes flash) {

		try {
			User user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));

			boolean enable = user.isBlocked() || !user.isActive();

			user.setActive(enable);
			user.setBlocked(!enable);

			users.save(user);

			flash.addFlashAttribute("success", enable ? "Đã mở tài khoản." : "Đã khóa tài khoản.");

		} catch (RuntimeException ex) {
			flash.addFlashAttribute("error", ex.getMessage());
		}

		return "redirect:/admin/users";
	}

	@PostMapping("/{id}/permission")
	public String permission(@PathVariable Long id, @RequestParam String role,
			@RequestParam(required = false) Long branchId, RedirectAttributes flash) {
		try {
			User user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
			String roleName = normalizeRole(role);
			Role selected = roles.findByName(roleName)
					.orElseGet(() -> roles.save(Role.builder().name(roleName).build()));
			user.getRoles().clear();
			user.getRoles().add(selected);
			if (requiresBranch(roleName)) {
				if (branchId == null)
					throw new IllegalArgumentException("Nhân viên và shipper phải thuộc một chi nhánh.");
				user.setBranch(branches.findById(branchId)
						.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh.")));
			} else
				user.setBranch(null);
			users.save(user);
			flash.addFlashAttribute("success", "Đã cập nhật phân quyền.");
		} catch (RuntimeException e) {
			flash.addFlashAttribute("error", e.getMessage());
		}
		return "redirect:/admin/users";
	}

	private void apply(User user, AdminUserRequest request, boolean creating) {
		user.setEmail(request.getEmail().trim());
		user.setFullName(request.getFullName().trim());
		user.setPhoneNumber(request.getPhoneNumber());
		if (creating && (request.getPassword() == null || request.getPassword().isBlank()))
			throw new IllegalArgumentException("Tài khoản mới cần có mật khẩu.");
		if (request.getPassword() != null && !request.getPassword().isBlank())
			user.setPassword(encoder.encode(request.getPassword()));
		boolean requestedActive =
		        request.getActive() == null || request.getActive();

		if (creating || requestedActive != user.isActive()) {
		    user.setActive(requestedActive);
		    user.setBlocked(!requestedActive);
		}
		String roleName = normalizeRole(request.getRole());
		Role role = roles.findByName(roleName).orElseGet(() -> roles.save(Role.builder().name(roleName).build()));
		user.getRoles().clear();
		user.getRoles().add(role);
		if (requiresBranch(roleName)) {
			if (request.getBranchId() != null)
				user.setBranch(branches.findById(request.getBranchId())
						.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh.")));
			else if (creating || user.getBranch() == null)
				throw new IllegalArgumentException("Nhân viên và shipper phải thuộc một chi nhánh.");
		} else
			user.setBranch(null);
	}

	private String normalizeRole(String role) {
		String value = role == null ? "ROLE_CUSTOMER" : role.trim().toUpperCase();
		return value.startsWith("ROLE_") ? value : "ROLE_" + value;
	}

	private boolean requiresBranch(String roleName) {
		return "ROLE_STAFF".equals(roleName) || "ROLE_SHIPPER".equals(roleName);
	}
}
