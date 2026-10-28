package com.dienmay.controller.client;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.dienmay.service.catalog.CustomerCatalogService;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class HomeController {

	@Autowired
	private CustomerCatalogService catalogService;

	@Value("${google.auth.client-id:}")
	private String googleClientId;

	@GetMapping("/")
	public String index(Model model) {
		// 1. Danh mục sản phẩm
		model.addAttribute("categories", catalogService.homeCategories());

		// 2. Dữ liệu Top 20 Sản Phẩm cho 4 Tab
		model.addAttribute("topNewest", catalogService.homeProducts("newest"));
		model.addAttribute("topBestseller", catalogService.homeProducts("bestseller"));
		model.addAttribute("topRating", catalogService.homeProducts("rating"));
		model.addAttribute("topFavorite", catalogService.homeProducts("favorite"));

		return "client/home";
	}

	@GetMapping("/login")
	public String loginPage(Model model) {
		model.addAttribute("googleClientId", googleClientId);
		return "client/login";
	}

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
	public String vouchersPage(Model model) {
	    model.addAttribute(
	            "vouchers", voucherService.listAvailable());

	    return "client/vouchers";
	}
	
	@Autowired
	private com.dienmay.service.promotion.VoucherService voucherService;
}
