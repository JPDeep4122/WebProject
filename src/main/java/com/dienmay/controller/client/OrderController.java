package com.dienmay.controller.client;

import java.security.Principal;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.dto.cart.AddToCartRequest;
import com.dienmay.dto.order.OrderStatusSnapshot;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderItem;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.service.cart.CartService;
import com.dienmay.service.order.OrderService;
import com.dienmay.service.order.ReturnRequestService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {

	private final OrderService orderService;
	private final CartService cartService;
	private final ReturnRequestService returnRequestService;

	// 1. DANH SÁCH ĐƠN HÀNG CỦA TÔI
	@GetMapping
	public String listOrders(@RequestParam(required = false) String status, Principal principal, Model model) {
		String userEmail = principal != null ? principal.getName() : null;
		if (userEmail == null || userEmail.equalsIgnoreCase("anonymousUser")) {
			return "redirect:/login?redirect=/orders";
		}

		OrderStatus orderStatus = null;
		if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("ALL")) {
			try {
				orderStatus = OrderStatus.valueOf(status.trim().toUpperCase());
			} catch (Exception ignored) {
			}
		}

		List<Order> orders = orderService.getOrdersByUser(userEmail, orderStatus);

		long countAll = orderService.getOrdersByUser(userEmail, null).size();
		long countPending = orderService.getOrdersByUser(userEmail, OrderStatus.PENDING).size();
		long countConfirmed = orderService.getOrdersByUser(userEmail, OrderStatus.CONFIRMED).size();
		long countShipping = orderService.getOrdersByUser(userEmail, OrderStatus.SHIPPING).size();
		long countDelivered = orderService.getOrdersByUser(userEmail, OrderStatus.DELIVERED).size();
		long countCancelled = orderService.getOrdersByUser(userEmail, OrderStatus.CANCELLED).size();

		model.addAttribute("orders", orders);
		model.addAttribute("currentStatus", (status != null && !status.isEmpty()) ? status.toUpperCase() : "ALL");
		model.addAttribute("countAll", countAll);
		model.addAttribute("countPending", countPending);
		model.addAttribute("countConfirmed", countConfirmed);
		model.addAttribute("countShipping", countShipping);
		model.addAttribute("countDelivered", countDelivered);
		model.addAttribute("countCancelled", countCancelled);

		return "client/order-history";
	}

	@GetMapping("/status-snapshot")
	@ResponseBody
	public List<OrderStatusSnapshot> statusSnapshot(
			@RequestParam(required = false) String orderCode,
			Principal principal) {
		if (principal == null) {
			throw new org.springframework.web.server.ResponseStatusException(
					org.springframework.http.HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập.");
		}
		if (orderCode != null && !orderCode.isBlank()) {
			return List.of(OrderStatusSnapshot.from(
					orderService.getOrderDetail(orderCode, principal.getName())));
		}
		return orderService.getOrdersByUser(principal.getName(), null).stream()
				.map(OrderStatusSnapshot::from).toList();
	}

	// 2. CHI TIẾT ĐƠN HÀNG
	@GetMapping("/{orderCode}")
	public String orderDetail(
	        @PathVariable String orderCode,
	        Principal principal,
	        Model model) {

	    if (principal == null) {
	        return "redirect:/login?redirect=/orders";
	    }

	    Order order = orderService.getOrderDetail(
	            orderCode, principal.getName());

	    model.addAttribute("order", order);
	    model.addAttribute("returnRequest",
	            returnRequestService.findLatestForCustomer(order.getId(), principal.getName()).orElse(null));
	    return "client/order-detail";
	}

	@PostMapping("/{orderCode}/return-request")
	public String requestReturn(@PathVariable String orderCode,
			@RequestParam String reason, Principal principal,
			RedirectAttributes redirectAttributes) {
		if (principal == null) {
			return "redirect:/login?redirect=/orders/" + orderCode;
		}
		try {
			returnRequestService.submit(orderCode, reason, principal.getName());
			redirectAttributes.addFlashAttribute("successMessage",
					"Đã gửi yêu cầu trả hàng. Cửa hàng sẽ kiểm tra và phản hồi.");
		} catch (IllegalArgumentException | org.springframework.security.access.AccessDeniedException ex) {
			redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
		}
		return "redirect:/orders/" + orderCode;
	}

	// 3. HỦY ĐƠN HÀNG (Dành cho đơn PENDING)
	@PostMapping("/{orderCode}/cancel")
	public String cancelOrder(@PathVariable String orderCode, @RequestParam(required = false) String cancelReason,
			Principal principal, RedirectAttributes redirectAttributes) {
		String email = (principal != null) ? principal.getName() : null;
		boolean success = orderService.cancelOrder(orderCode, email, cancelReason);
		if (success) {
			redirectAttributes.addFlashAttribute("successMessage", "Đã hủy đơn hàng thành công!");
		} else {
			redirectAttributes.addFlashAttribute("errorMessage",
					"Không thể hủy đơn hàng này (chỉ hỗ trợ hủy khi đơn đang ở trạng thái Chờ xác nhận)!");
		}
		return "redirect:/orders/" + orderCode;
	}

	// 4. MUA LẠI ĐƠN HÀNG (Thêm lại các món trong đơn vào giỏ)
	@PostMapping("/{orderCode}/reorder")
	public String reorder(@PathVariable String orderCode, Principal principal, HttpSession session) {
		String email = (principal != null) ? principal.getName() : null;
		try {
			Order order = orderService.getOrderDetail(orderCode, email);
			if (order.getOrderItems() != null) {
				for (OrderItem item : order.getOrderItems()) {
					AddToCartRequest req = new AddToCartRequest();
					req.setProductId(item.getProduct().getId());
					req.setQuantity(item.getQuantity());
					cartService.addToCart(req, email, session);
				}
			}
		} catch (Exception ignored) {
		}
		return "redirect:/cart";
	}

	// 5. TRA CỨU ĐƠN HÀNG NHANH CHO KHÁCH VÃNG LAI
	@GetMapping("/tracking")
	public String trackingPage() {
		return "client/order-tracking";
	}

	@PostMapping("/tracking")
	public String trackOrder(@RequestParam String orderCode, @RequestParam String phone, Model model) {
		Order order = orderService.trackOrder(orderCode, phone);
		if (order != null) {
		    model.addAttribute("order", order);
		    return "client/order-detail";
		} else {
			model.addAttribute("errorMessage",
					"Không tìm thấy đơn hàng với thông tin đã nhập. Vui lòng kiểm tra lại Mã đơn hàng và Số điện thoại!");
			model.addAttribute("orderCode", orderCode);
			model.addAttribute("phone", phone);
			return "client/order-tracking";
		}
	}
}
