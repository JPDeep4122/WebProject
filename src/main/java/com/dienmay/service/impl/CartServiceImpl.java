package com.dienmay.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

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
import com.dienmay.service.cart.CartService;
import com.dienmay.service.checkout.PurchaseValidator;

import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.PersistenceContext;
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
	private final UserRepository userRepository;
	private final PurchaseValidator purchaseValidator;

	@PersistenceContext
	private EntityManager entityManager;

	// Helper: Lấy hoặc tạo Giỏ hàng (hỗ trợ cả đã đăng nhập hoặc khách vãng lai qua
	// session)
	private Cart getOrCreateCart(String userEmail, HttpSession session) {
		if (userEmail != null && !userEmail.equalsIgnoreCase("anonymousUser")) {
			User user = userRepository.findForCart(userEmail)
					.orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập."));
			entityManager.refresh(user, LockModeType.PESSIMISTIC_WRITE);
			if (!user.isActive() || user.isBlocked()) {
				throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Tài khoản hiện không được phép sử dụng.");
			}
			return mergeGuestCart(user, session);
		}

		// Khách vãng lai
		String sessionId = (String) session.getAttribute("GUEST_CART_SESSION");
		if (sessionId == null) {
			sessionId = UUID.randomUUID().toString();
			session.setAttribute("GUEST_CART_SESSION", sessionId);
		}

		Cart existing = cartRepository.findBySessionId(sessionId).orElse(null);
		if (existing != null && existing.getUser() == null) return existing;
		if (existing != null) {
			sessionId = UUID.randomUUID().toString();
			session.setAttribute("GUEST_CART_SESSION", sessionId);
		}
		return cartRepository.save(Cart.builder().sessionId(sessionId).build());
	}

	private Cart mergeGuestCart(User user, HttpSession session) {
		String guestKey = session == null ? null : (String) session.getAttribute("GUEST_CART_SESSION");
		Cart guest = guestKey == null ? null : cartRepository.findBySessionId(guestKey).orElse(null);
		if (guest != null) {
			Long id = guest.getId();
			entityManager.detach(guest);
			guest = cartRepository.findForUpdate(id).orElse(null);
			if (guest != null) {
				entityManager.refresh(guest, LockModeType.PESSIMISTIC_WRITE);
				if (guest.getUser() != null || !guestKey.equals(guest.getSessionId())) guest = null;
			}
		}
		Cart cart = cartRepository.findByUser_Email(user.getEmail()).orElse(null);
		if (cart == null && guest != null) {
			guest.setUser(user);
			guest.setSessionId(null);
			cart = cartRepository.saveAndFlush(guest);
		} else {
			if (cart == null) cart = cartRepository.saveAndFlush(Cart.builder().user(user).build());
			if (guest != null) {
				Long id = cart.getId();
				entityManager.detach(cart);
				cart = cartRepository.findForUpdate(id).orElseThrow();
				entityManager.refresh(cart, LockModeType.PESSIMISTIC_WRITE);
				for (CartItem source : guest.getItems()) {
					CartItem target = cart.getItems().stream()
							.filter(item -> item.getProduct().getId().equals(source.getProduct().getId())).findFirst().orElse(null);
					if (target == null) {
						cart.getItems().add(CartItem.builder().cart(cart).product(source.getProduct())
								.quantity(source.getQuantity()).selected(source.getSelected()).build());
					} else {
						target.setQuantity((int) Math.min(Integer.MAX_VALUE, (long) target.getQuantity() + source.getQuantity()));
						target.setSelected(Boolean.TRUE.equals(target.getSelected()) || Boolean.TRUE.equals(source.getSelected()));
					}
				}
				cartRepository.saveAndFlush(cart);
				cartRepository.delete(guest);
				cartRepository.flush();
			}
		}
		if (guestKey != null && TransactionSynchronizationManager.isSynchronizationActive()) {
			TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
				@Override public void afterCommit() {
					if (guestKey.equals(session.getAttribute("GUEST_CART_SESSION"))) session.removeAttribute("GUEST_CART_SESSION");
				}
			});
		}
		return cart;
	}

	@Override
	public CartResponse getCart(String userEmail, HttpSession session) {
		Cart cart = getOrCreateCart(userEmail, session);
		return toCartResponse(cart);
	}

	@Override
	public CartResponse addToCart(AddToCartRequest request, String userEmail, HttpSession session) {

		Cart cart = getOrCreateCartForUpdate(userEmail, session);

		Product product = purchaseValidator.requireProduct(request.getProductId(), request.getQuantity());

		CartItem item = cart.getItems().stream()
				.filter(existing -> product.getId().equals(existing.getProduct().getId())).findFirst().orElse(null);

		long desiredQuantity = (item == null ? 0L : item.getQuantity().longValue()) + request.getQuantity();

		if (desiredQuantity > Integer.MAX_VALUE) {
			throw new IllegalArgumentException("Số lượng sản phẩm vượt giới hạn.");
		}

		int quantity = (int) desiredQuantity;

		purchaseValidator.requireTotalStock(product.getId(), quantity);

		if (item == null) {
			item = CartItem.builder().cart(cart).product(product).quantity(quantity).selected(true).build();

			cart.getItems().add(item);
		} else {
			item.setQuantity(quantity);
		}

		cartRepository.save(cart);
		return toCartResponse(cart);
	}

	@Override
	public CartResponse buyNow(AddToCartRequest request, String userEmail, HttpSession session) {
		Cart cart = getOrCreateCartForUpdate(userEmail, session);
		Integer quantity = request.getQuantity();
		Product product = purchaseValidator.requireProduct(request.getProductId(), quantity);
		purchaseValidator.requireTotalStock(product.getId(), quantity);

		CartItem target = cart.getItems().stream().filter(item -> product.getId().equals(item.getProduct().getId()))
				.findFirst().orElse(null);

		// Giữ các món khác trong giỏ, chỉ bỏ chọn.
		for (CartItem item : cart.getItems()) {
			item.setSelected(false);
		}

		if (target == null) {
			target = CartItem.builder().cart(cart).product(product).quantity(quantity).selected(true).build();

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

		Cart cart = getOrCreateCartForUpdate(userEmail, session);
		CartItem item = requireOwnedItem(cartItemId, cart);

		if (quantity <= 0) {
			cart.getItems().remove(item);
			cartItemRepository.delete(item);
		} else {
			Product product = purchaseValidator.requireProduct(item.getProduct().getId(), quantity);
			purchaseValidator.requireTotalStock(product.getId(), quantity);
			item.setQuantity(quantity);
			cartItemRepository.save(item);
		}

		return toCartResponse(cart);
	}

	@Override
	public CartResponse removeItem(Long cartItemId, String userEmail, HttpSession session) {

		Cart cart = getOrCreateCartForUpdate(userEmail, session);
		CartItem item = requireOwnedItem(cartItemId, cart);

		cart.getItems().remove(item);
		cartItemRepository.delete(item);

		return toCartResponse(cart);
	}

	@Override
	public CartResponse toggleSelect(Long cartItemId, boolean selected, String userEmail, HttpSession session) {

		Cart cart = getOrCreateCartForUpdate(userEmail, session);
		CartItem item = requireOwnedItem(cartItemId, cart);

		item.setSelected(selected);
		cartItemRepository.save(item);

		return toCartResponse(cart);
	}

	@Override
	public CartResponse selectAll(boolean selected, String userEmail, HttpSession session) {
		Cart cart = getOrCreateCartForUpdate(userEmail, session);
		for (CartItem item : cart.getItems()) {
			item.setSelected(selected);
		}
		cartRepository.save(cart);
		return toCartResponse(cart);
	}

	@Override
	public int getCartTotalQuantity(String userEmail, HttpSession session) {
		Cart cart = getOrCreateCart(userEmail, session);
		return cart.getItems().stream().mapToInt(CartItem::getQuantity).sum();
	}

	// Helper: Map sang CartResponse DTO
	private CartResponse toCartResponse(Cart cart) {
		List<CartItemResponse> itemResponses = (cart.getItems() != null) ? cart.getItems().stream().map(item -> {
			BigDecimal price = item.getProduct().getSellingPrice();
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

	private Cart getOrCreateCartForUpdate(String userEmail, HttpSession session) {
		Cart cart = getOrCreateCart(userEmail, session);
		Long cartId = cart.getId();
		// Discard an earlier page preview, then lock before loading the item collection.
		entityManager.detach(cart);
		Cart locked = cartRepository.findForUpdate(cartId)
				.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giỏ hàng."));
		entityManager.refresh(locked, LockModeType.PESSIMISTIC_WRITE);
		boolean signedIn = userEmail != null && !userEmail.isBlank() && !userEmail.equalsIgnoreCase("anonymousUser");
		if (signedIn ? locked.getUser() == null || !userEmail.equalsIgnoreCase(locked.getUser().getEmail())
				: locked.getUser() != null || !java.util.Objects.equals(locked.getSessionId(), session.getAttribute("GUEST_CART_SESSION"))) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Giỏ hàng đã thay đổi. Vui lòng tải lại trang.");
		}
		return locked;
	}
}
