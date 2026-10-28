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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.util.List;
import java.util.ArrayList;
import java.util.TreeSet;
import java.util.Objects;
import java.util.Set;

@Controller
@RequestMapping("/admin/users")
public class AdminUserController {
	private static final String ROLE_ADMIN = "ROLE_ADMIN";
	private static final String ROLE_BRANCH_MANAGER = "ROLE_BRANCH_MANAGER";
	private static final String ROLE_STAFF = "ROLE_STAFF";
	private static final String ROLE_SHIPPER = "ROLE_SHIPPER";
	private static final Set<String> MANAGER_ALLOWED_TARGET_ROLES = Set.of(ROLE_STAFF, ROLE_SHIPPER);

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
			@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size,
			Principal principal, Model model) {
		if (id != null && id < 0) {
			id = 0L;
		}
		final Long selectedId = id;
		User actor = requireActor(principal);
		boolean admin = hasRole(actor, ROLE_ADMIN);

		Sort order = Sort.by("desc".equalsIgnoreCase(direction) ? Sort.Direction.DESC : Sort.Direction.ASC,
				List.of("id", "email", "fullName", "createdAt", "active").contains(sort) ? sort : "id");
		int safePage = Math.max(0, page);
		int safeSize = List.of(10, 20, 50).contains(size) ? size : 20;
		Pageable pageable = PageRequest.of(safePage, safeSize, order);
		Page<User> result;
		if (admin) {
			if (id != null) {
				List<User> matches = users.findById(id).map(List::of).orElse(List.of());
				result = new PageImpl<>(matches, PageRequest.of(0, safeSize, order), matches.size());
			}
			else if (type != null && !type.isBlank())
				result = users.findByRoles_Name(normalizeRole(type), pageable);
			else
				result = users.findAll(pageable);
		} else {
			Long branchId = requireManagerBranch(actor).getId();
			if (type != null && !type.isBlank()) {
				String normalizedType = normalizeRole(type);
				result = MANAGER_ALLOWED_TARGET_ROLES.contains(normalizedType)
						? users.findByBranch_IdAndRoles_Name(branchId, normalizedType, pageable)
						: Page.empty(pageable);
			} else {
				result = users.findDistinctByBranch_IdAndRoles_NameIn(branchId,
						List.of(ROLE_STAFF, ROLE_SHIPPER), pageable);
			}
			if (id != null) {
				List<User> matches = users.findById(id)
						.filter(u -> Objects.equals(u.getBranch().getId(), branchId) && isStaffOrShipper(u))
						.map(List::of).orElse(List.of());
				result = new PageImpl<>(matches, PageRequest.of(0, safeSize, order), matches.size());
			}
		}

		model.addAttribute("usersPage", result);
		model.addAttribute("branches", admin ? branches.findAll(Sort.by("name")) : List.of(requireManagerBranch(actor)));
		model.addAttribute("isAdminActor", admin);
		model.addAttribute("actorBranch", actor.getBranch());
		model.addAttribute("newUser", new AdminUserRequest());
		model.addAttribute("selectedId", id);
		model.addAttribute("selectedType", type);
		model.addAttribute("selectedSort", sort);
		model.addAttribute("selectedDirection", direction);
		model.addAttribute("pageSize", safeSize);
		model.addAttribute("paginationPages", paginationPages(result.getNumber(), result.getTotalPages()));
		return "admin/users";
	}

	private List<PageNumber> paginationPages(int currentPage, int totalPages) {
		if (totalPages <= 0) return List.of();
		TreeSet<Integer> visible = new TreeSet<>();
		int start = currentPage == 0 ? 0 : currentPage;
		for (int index = start; index < Math.min(start + 3, totalPages); index++) visible.add(index);
		if (totalPages > 3) for (int index = Math.max(0, totalPages - 3); index < totalPages; index++) visible.add(index);
		List<PageNumber> result = new ArrayList<>();
		int previous = -1;
		for (int index : visible) {
			result.add(new PageNumber(index, previous >= 0 && index - previous > 1));
			previous = index;
		}
		return result;
	}

	public record PageNumber(int index, boolean gapBefore) { }

	@PostMapping
	public String create(@Valid @ModelAttribute("newUser") AdminUserRequest request, BindingResult errors,
			Principal principal, RedirectAttributes flash) {
		if (errors.hasErrors()) {
			flash.addFlashAttribute("error", "Thông tin tài khoản không hợp lệ.");
			return "redirect:/admin/users";
		}
		try {
			User actor = requireActor(principal);
			if (users.existsByEmail(request.getEmail().trim()))
				throw new IllegalArgumentException("Email đã tồn tại.");
			User user = new User();
			apply(actor, user, request, true);
			users.save(user);
			flash.addFlashAttribute("success", "Đã mở tài khoản và phân quyền.");
		} catch (RuntimeException e) {
			flash.addFlashAttribute("error", e.getMessage());
		}
		return "redirect:/admin/users";
	}

	@PostMapping("/{id}/update")
	public String update(@PathVariable Long id, @Valid @ModelAttribute AdminUserRequest request, BindingResult errors,
			Principal principal, RedirectAttributes flash) {
		if (errors.hasErrors()) {
			flash.addFlashAttribute("error", "Thông tin tài khoản không hợp lệ.");
			return "redirect:/admin/users";
		}
		try {
			User actor = requireActor(principal);
			User user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
			authorizeTargetUserForManager(actor, user);
			users.findByEmail(request.getEmail().trim()).ifPresent(existing -> {
				if (!existing.getId().equals(id))
					throw new IllegalArgumentException("Email đã tồn tại.");
			});
			apply(actor, user, request, false);
			users.save(user);
			flash.addFlashAttribute("success", "Đã cập nhật tài khoản.");
		} catch (RuntimeException e) {
			flash.addFlashAttribute("error", e.getMessage());
		}
		return "redirect:/admin/users";
	}

	@PostMapping("/{id}/toggle")
	public String toggle(@PathVariable Long id, Principal principal, RedirectAttributes flash) {
		try {
			User actor = requireActor(principal);
			User user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
			if (Objects.equals(actor.getId(), user.getId())) {
				throw new IllegalArgumentException("Không thể tự khóa tài khoản đang đăng nhập.");
			}
			authorizeTargetUserForManager(actor, user);

			boolean enable = user.isBlocked() || !user.isActive();
			if (enable && hasRole(user, ROLE_BRANCH_MANAGER) && user.getBranch() != null) {
				ensureSingleActiveBranchManager(user.getBranch().getId(), user.getId());
			}

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
			@RequestParam(required = false) Long branchId, Principal principal, RedirectAttributes flash) {
		try {
			User actor = requireActor(principal);
			if (!hasRole(actor, ROLE_ADMIN)) {
				throw new AccessDeniedException("Chỉ Admin tổng mới được thay đổi vai trò hoặc điều chuyển chi nhánh.");
			}
			User user = users.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
			String roleName = normalizeRole(role);
			Role selected = roles.findByName(roleName)
					.orElseGet(() -> roles.save(Role.builder().name(roleName).build()));
			user.getRoles().clear();
			user.getRoles().add(selected);
			if (requiresBranch(roleName)) {
				if (branchId == null)
					throw new IllegalArgumentException("Quản lý, nhân viên và shipper phải thuộc một chi nhánh.");
				Branch targetBranch = branches.findById(branchId)
						.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh."));
				if (ROLE_BRANCH_MANAGER.equals(roleName) && user.isActive() && !user.isBlocked()) {
					ensureSingleActiveBranchManager(targetBranch.getId(), user.getId());
				}
				user.setBranch(targetBranch);
			} else {
				user.setBranch(null);
			}
			users.save(user);
			flash.addFlashAttribute("success", "Đã cập nhật phân quyền.");
		} catch (RuntimeException e) {
			flash.addFlashAttribute("error", e.getMessage());
		}
		return "redirect:/admin/users";
	}

	private void apply(User actor, User user, AdminUserRequest request, boolean creating) {
		boolean admin = hasRole(actor, ROLE_ADMIN);
		user.setEmail(request.getEmail().trim());
		user.setFullName(request.getFullName().trim());
		user.setPhoneNumber(request.getPhoneNumber());
		if (creating && (request.getPassword() == null || request.getPassword().isBlank()))
			throw new IllegalArgumentException("Tài khoản mới cần có mật khẩu.");
		if (request.getPassword() != null && !request.getPassword().isBlank())
			user.setPassword(encoder.encode(request.getPassword()));

		boolean requestedActive = request.getActive() == null || request.getActive();
		if (creating || requestedActive != user.isActive()) {
			user.setActive(requestedActive);
			user.setBlocked(!requestedActive);
		}

		if (admin) {
			String roleName = normalizeRole(request.getRole());
			Role role = roles.findByName(roleName).orElseGet(() -> roles.save(Role.builder().name(roleName).build()));
			user.getRoles().clear();
			user.getRoles().add(role);
			if (requiresBranch(roleName)) {
				Branch targetBranch;
				if (request.getBranchId() != null) {
					targetBranch = branches.findById(request.getBranchId())
							.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh."));
				} else if (!creating && user.getBranch() != null) {
					targetBranch = user.getBranch();
				} else {
					throw new IllegalArgumentException("Quản lý, nhân viên và shipper phải thuộc một chi nhánh.");
				}
				if (ROLE_BRANCH_MANAGER.equals(roleName) && user.isActive() && !user.isBlocked()) {
					ensureSingleActiveBranchManager(targetBranch.getId(), user.getId());
				}
				user.setBranch(targetBranch);
			} else {
				user.setBranch(null);
			}
		} else {
			// Quản lý chi nhánh: lấy chi nhánh từ chính người quản lý đang đăng nhập, không tin branchId từ client
			Branch managerBranch = requireManagerBranch(actor);
			if (creating) {
				String roleName = normalizeRole(request.getRole());
				if (!MANAGER_ALLOWED_TARGET_ROLES.contains(roleName)) {
					throw new AccessDeniedException("Quản lý chi nhánh chỉ được tạo tài khoản Nhân viên hoặc Shipper.");
				}
				Role role = roles.findByName(roleName).orElseGet(() -> roles.save(Role.builder().name(roleName).build()));
				user.getRoles().clear();
				user.getRoles().add(role);
			}
			user.setBranch(managerBranch);
		}
	}

	private void ensureSingleActiveBranchManager(Long branchId, Long excludeUserId) {
		List<User> activeManagers = users.findByBranch_IdAndRoles_NameAndActiveTrueAndBlockedFalse(
				branchId, ROLE_BRANCH_MANAGER);
		boolean conflict = activeManagers.stream()
				.anyMatch(existing -> excludeUserId == null || !Objects.equals(existing.getId(), excludeUserId));
		if (conflict) {
			throw new IllegalArgumentException(
					"Chi nhánh này đã có một Quản lý đang hoạt động. Vui lòng khóa hoặc đổi vai trò Quản lý cũ trước.");
		}
	}

	private User requireActor(Principal principal) {
		if (principal == null) {
			throw new AccessDeniedException("Vui lòng đăng nhập.");
		}
		User actor = users.findByEmail(principal.getName())
				.orElseThrow(() -> new AccessDeniedException("Không tìm thấy tài khoản đang đăng nhập."));
		if (!actor.isActive() || actor.isBlocked()
				|| (!hasRole(actor, ROLE_ADMIN) && !hasRole(actor, ROLE_BRANCH_MANAGER))) {
			throw new AccessDeniedException("Bạn không có quyền quản lý nhân sự.");
		}
		return actor;
	}

	private Branch requireManagerBranch(User actor) {
		if (actor.getBranch() == null) {
			throw new AccessDeniedException("Tài khoản quản lý chưa được gán chi nhánh.");
		}
		return actor.getBranch();
	}

	private void authorizeTargetUserForManager(User actor, User target) {
		if (hasRole(actor, ROLE_ADMIN)) {
			return;
		}
		Branch managerBranch = requireManagerBranch(actor);
		if (target.getBranch() == null
				|| !Objects.equals(managerBranch.getId(), target.getBranch().getId())
				|| !isStaffOrShipper(target)) {
			throw new AccessDeniedException(
					"Quản lý chi nhánh chỉ được phép quản lý Nhân viên và Shipper thuộc chi nhánh của mình.");
		}
	}

	private boolean isStaffOrShipper(User user) {
		return (hasRole(user, ROLE_STAFF) || hasRole(user, ROLE_SHIPPER))
				&& !hasRole(user, ROLE_ADMIN)
				&& !hasRole(user, ROLE_BRANCH_MANAGER);
	}

	private boolean hasRole(User user, String roleName) {
		return user.getRoles().stream().anyMatch(r -> roleName.equals(r.getName()));
	}

	private String normalizeRole(String role) {
		String value = role == null ? "ROLE_CUSTOMER" : role.trim().toUpperCase();
		return value.startsWith("ROLE_") ? value : "ROLE_" + value;
	}

	private boolean requiresBranch(String roleName) {
		return ROLE_BRANCH_MANAGER.equals(roleName)
				|| ROLE_STAFF.equals(roleName)
				|| ROLE_SHIPPER.equals(roleName);
	}
}
