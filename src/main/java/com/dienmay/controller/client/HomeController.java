package com.dienmay.controller.client;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.dienmay.service.product.ProductService;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class HomeController {

	@Autowired
	private ProductService productService;

	@Value("${google.auth.client-id:}")
	private String googleClientId;

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

	@GetMapping("/login")
	public String loginPage(Model model) {
		model.addAttribute("googleClientId", googleClientId);
		return "client/login";
	}

	// XỬ LÝ ĐĂNG XUẤT SẠCH SẼ COOKIE JWT & SESSION CHO MỌI VAI TRÒ
	@GetMapping("/logout")
	public String logoutPage(HttpServletRequest request, HttpServletResponse response) {
		SecurityContextHolder.clearContext();
		HttpSession session = request.getSession(false);
		if (session != null) {
			session.invalidate();
		}

		Cookie accessCookie = new Cookie("accessToken", "");
		accessCookie.setPath("/");
		accessCookie.setMaxAge(0);
		response.addCookie(accessCookie);

		Cookie jwtCookie = new Cookie("jwtToken", "");
		jwtCookie.setPath("/");
		jwtCookie.setMaxAge(0);
		response.addCookie(jwtCookie);

		return "redirect:/login?logout=true";
	}

	@GetMapping("/vouchers")
	public String vouchersPage() {
		return "client/vouchers";
	}
}