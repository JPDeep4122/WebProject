package com.dienmay.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.cart.AddToCartRequest;
import com.dienmay.dto.cart.CartItemResponse;
import com.dienmay.dto.cart.CartResponse;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.cart.Cart;
import com.dienmay.entity.cart.CartItem;
import com.dienmay.entity.product.Product;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.cart.CartItemRepository;
import com.dienmay.repository.cart.CartRepository;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.service.cart.CartService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
@Transactional
public class CartServiceImpl implements CartService {

	private final CartRepository cartRepository;
	private final CartItemRepository cartItemRepository;
	private final ProductRepository productRepository;
	private final UserRepository userRepository;

	// Helper: Lấy hoặc tạo Giỏ hàng (hỗ trợ cả đã đăng nhập hoặc khách vãng lai qua
	// session)
	private Cart getOrCreateCart(String userEmail, HttpSession session) {
		if (userEmail != null && !userEmail.equalsIgnoreCase("anonymousUser")) {
			User user = userRepository.findByEmail(userEmail).orElse(null);
			if (user != null) {
				return cartRepository.findByUser_Email(userEmail)
						.orElseGet(() -> cartRepository.save(Cart.builder().user(user).build()));
			}
		}

		// Khách vãng lai
		String sessionId = (String) session.getAttribute("GUEST_CART_SESSION");
		if (sessionId == null) {
			sessionId = UUID.randomUUID().toString();
			session.setAttribute("GUEST_CART_SESSION", sessionId);
		}

		final String currentSessionId = sessionId;
		return cartRepository.findBySessionId(sessionId)
				.orElseGet(() -> cartRepository.save(Cart.builder().sessionId(currentSessionId).build()));
	}

	@Override
	@Transactional(readOnly = true)
	public CartResponse getCart(String userEmail, HttpSession session) {
		Cart cart = getOrCreateCart(userEmail, session);
		return toCartResponse(cart);
	}

	@Override
	public CartResponse addToCart(AddToCartRequest request, String userEmail, HttpSession session) {
		Cart cart = getOrCreateCart(userEmail, session);
		Product product = productRepository.findById(request.getProductId())
				.orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm ID: " + request.getProductId()));

		CartItem item = cartItemRepository.findByCart_IdAndProduct_Id(cart.getId(), product.getId()).orElse(null);

		if (item != null) {
			item.setQuantity(item.getQuantity() + request.getQuantity());
		} else {
			item = CartItem.builder().cart(cart).product(product).quantity(request.getQuantity()).selected(true)
					.build();
			cart.getItems().add(item);
		}

		cartRepository.save(cart);
		return toCartResponse(cart);
	}

	@Override
	public CartResponse buyNow(
	        AddToCartRequest request,
	        String userEmail,
	        HttpSession session) {

	    if (request.getProductId() == null
	            || request.getProductId() <= 0) {
	        throw new ResponseStatusException(
	                HttpStatus.BAD_REQUEST,
	                "Sản phẩm không hợp lệ.");
	    }

	    Integer quantity = request.getQuantity();

	    if (quantity == null || quantity < 1) {
	        throw new ResponseStatusException(
	                HttpStatus.BAD_REQUEST,
	                "Số lượng phải lớn hơn hoặc bằng 1.");
	    }

	    Product product = productRepository
	            .findById(request.getProductId())
	            .orElseThrow(() -> new ResponseStatusException(
	                    HttpStatus.NOT_FOUND,
	                    "Không tìm thấy sản phẩm."));

	    if (!product.isActive()) {
	        throw new ResponseStatusException(
	                HttpStatus.BAD_REQUEST,
	                "Sản phẩm đã ngừng kinh doanh.");
	    }

	    BigDecimal price = product.getDiscountPrice() != null
	            ? product.getDiscountPrice()
	            : product.getPrice();

	    if (price == null || price.signum() < 0) {
	        throw new ResponseStatusException(
	                HttpStatus.BAD_REQUEST,
	                "Sản phẩm chưa có giá bán hợp lệ.");
	    }

	    long availableQuantity = product.getBranchInventories()
	            .stream()
	            .filter(stock -> stock.getBranch() != null
	                    && stock.getBranch().isActive())
	            .mapToLong(stock -> stock.getAvailableQuantity() == null
	                    ? 0L
	                    : Math.max(0, stock.getAvailableQuantity()))
	            .sum();

	    if (quantity > availableQuantity) {
	        throw new ResponseStatusException(
	                HttpStatus.BAD_REQUEST,
	                "Số lượng yêu cầu vượt quá tồn kho hiện tại.");
	    }

	    Cart cart = getOrCreateCart(userEmail, session);

	    CartItem target = cart.getItems().stream()
	            .filter(item -> product.getId()
	                    .equals(item.getProduct().getId()))
	            .findFirst()
	            .orElse(null);

	    // Giữ các món khác trong giỏ, chỉ bỏ chọn.
	    for (CartItem item : cart.getItems()) {
	        item.setSelected(false);
	    }

	    if (target == null) {
	        target = CartItem.builder()
	                .cart(cart)
	                .product(product)
	                .quantity(quantity)
	                .selected(true)
	                .build();

	        cart.getItems().add(target);
	    } else {
	        target.setQuantity(quantity);
	        target.setSelected(true);
	    }

	    cartRepository.saveAndFlush(cart);

	    return toCartResponse(cart);
	}
	
	@Override
	public CartResponse updateQuantity(Long cartItemId, int quantity, String userEmail, HttpSession session) {

		Cart cart = getOrCreateCart(userEmail, session);
		CartItem item = requireOwnedItem(cartItemId, cart);

		if (quantity <= 0) {
			cart.getItems().remove(item);
			cartItemRepository.delete(item);
		} else {
			item.setQuantity(quantity);
			cartItemRepository.save(item);
		}

		return toCartResponse(cart);
	}

	@Override
	public CartResponse removeItem(Long cartItemId, String userEmail, HttpSession session) {

		Cart cart = getOrCreateCart(userEmail, session);
		CartItem item = requireOwnedItem(cartItemId, cart);

		cart.getItems().remove(item);
		cartItemRepository.delete(item);

		return toCartResponse(cart);
	}

	@Override
	public CartResponse toggleSelect(Long cartItemId, boolean selected, String userEmail, HttpSession session) {

		Cart cart = getOrCreateCart(userEmail, session);
		CartItem item = requireOwnedItem(cartItemId, cart);

		item.setSelected(selected);
		cartItemRepository.save(item);

		return toCartResponse(cart);
	}

	@Override
	public CartResponse selectAll(boolean selected, String userEmail, HttpSession session) {
		Cart cart = getOrCreateCart(userEmail, session);
		for (CartItem item : cart.getItems()) {
			item.setSelected(selected);
		}
		cartRepository.save(cart);
		return toCartResponse(cart);
	}

	@Override
	@Transactional(readOnly = true)
	public int getCartTotalQuantity(String userEmail, HttpSession session) {
		Cart cart = getOrCreateCart(userEmail, session);
		return cart.getItems().stream().mapToInt(CartItem::getQuantity).sum();
	}

	// Helper: Map sang CartResponse DTO
	private CartResponse toCartResponse(Cart cart) {
		List<CartItemResponse> itemResponses = (cart.getItems() != null) ? cart.getItems().stream().map(item -> {
			BigDecimal price = (item.getProduct().getDiscountPrice() != null) ? item.getProduct().getDiscountPrice()
					: item.getProduct().getPrice();
			return CartItemResponse.builder().id(item.getId()).productId(item.getProduct().getId())
					.productName(item.getProduct().getName()).productSlug(item.getProduct().getSlug())
					.productImageUrl(item.getProduct().getMainImageUrl()).unitPrice(price).quantity(item.getQuantity())
					.subtotal(item.getSubtotal()).selected(item.getSelected()).build();
		}).collect(Collectors.toList()) : new ArrayList<>();

		int totalQty = itemResponses.stream().mapToInt(CartItemResponse::getQuantity).sum();

		BigDecimal totalSelected = itemResponses.stream().filter(CartItemResponse::getSelected)
				.map(CartItemResponse::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);

		return CartResponse.builder().cartId(cart.getId()).items(itemResponses).totalQuantity(totalQty)
				.totalSelectedAmount(totalSelected).build();
	}

	private CartItem requireOwnedItem(Long cartItemId, Cart cart) {
		return cartItemRepository.findByIdAndCart_Id(cartItemId, cart.getId())
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy mục giỏ hàng."));
	}
}