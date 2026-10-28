package com.dienmay.service.impl;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.server.ResponseStatusException;

import com.dienmay.dto.checkout.CheckoutItemDto;
import com.dienmay.dto.checkout.CheckoutPageDto;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.ShippingQuoteResponse;
import com.dienmay.dto.checkout.VoucherResponse;
import com.dienmay.entity.auth.Address;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.cart.Cart;
import com.dienmay.entity.cart.CartItem;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderItem;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.entity.promotion.Promotion;
import com.dienmay.event.PromotionEvent;
import com.dienmay.repository.auth.AddressRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.cart.CartRepository;
import com.dienmay.repository.order.OrderItemRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.repository.promotion.PromotionRepository;
import com.dienmay.service.cart.CartService;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.checkout.PurchaseValidator;
import com.dienmay.service.checkout.ShippingService;
import com.dienmay.service.order.OrderCodeGenerator;
import com.dienmay.service.payment.VnPayService;

import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class CheckoutServiceImpl implements CheckoutService {

	private final CartRepository cartRepository;
	private final AddressRepository addressRepository;
	private final UserRepository userRepository;
	private final OrderRepository orderRepository;
	private final OrderItemRepository orderItemRepository;
	private final PaymentRepository paymentRepository;
	private final PromotionRepository promotionRepository;
	private final ApplicationEventPublisher eventPublisher;
	private final ShippingService shippingService;
	private final BranchRepository branchRepository;
	private final TransactionTemplate transactionTemplate;
	private final PurchaseValidator purchaseValidator;
	private final VnPayService vnPayService;
	private final CartService cartService;
	private final OrderCodeGenerator orderCodeGenerator;
	
	@PersistenceContext
	private EntityManager entityManager;

	@Override
	@Transactional
	public CheckoutPageDto getCheckoutData(String userEmail, HttpSession session) {
		requireCustomer(userEmail);
		Cart cart = getCart(userEmail, session);
		List<CartItem> selectedItems = (cart != null && cart.getItems() != null)
				? cart.getItems().stream().filter(item -> Boolean.TRUE.equals(item.getSelected())).collect(Collectors.toList())
				: new ArrayList<>();

		List<CheckoutItemDto> items = selectedItems.stream().map(item -> {
			BigDecimal price = item.getProduct().getSellingPrice();
			return CheckoutItemDto.builder().productId(item.getProduct().getId())
					.productName(item.getProduct().getName()).productSlug(item.getProduct().getSlug())
					.imageUrl(item.getProduct().getMainImageUrl()).price(price).quantity(item.getQuantity())
					.subtotal(item.getSubtotal()).build();
		}).collect(Collectors.toList());

		BigDecimal subtotal = items.stream().map(CheckoutItemDto::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);

		BigDecimal shippingFee = BigDecimal.ZERO; // Sẽ được báo giá sau khi khách nhập địa chỉ.
		BigDecimal discount = BigDecimal.ZERO;
		BigDecimal finalAmount = subtotal.add(shippingFee).subtract(discount);

		List<Address> savedAddresses = new ArrayList<>();
		if (userEmail != null && !userEmail.equalsIgnoreCase("anonymousUser")) {
			User user = userRepository.findByEmail(userEmail).orElse(null);
			if (user != null) {
				savedAddresses = addressRepository.findByUser_Id(user.getId());
			}
		}

		return CheckoutPageDto.builder().items(items).savedAddresses(savedAddresses).subtotal(subtotal)
				.shippingFee(shippingFee).discountAmount(discount).finalAmount(finalAmount).build();
	}

	@Override
	public VoucherResponse applyVoucher(String code, BigDecimal subtotal) {
		if (code == null || code.isBlank()) {
			return VoucherResponse.builder().valid(false).message("Vui lòng nhập mã giảm giá.").build();
		}

		if (subtotal == null || subtotal.signum() < 0) {
			return VoucherResponse.builder().valid(false).message("Giá trị đơn hàng không hợp lệ.").build();
		}

		String normalizedCode = code.trim().toUpperCase(java.util.Locale.ROOT);

		Promotion promotion = promotionRepository.findByCodeIgnoreCase(normalizedCode).orElse(null);

		return promotion != null ? calculatePromotionVoucher(promotion, subtotal)
				: calculateLegacyVoucher(normalizedCode, subtotal);
	}

	private VoucherResponse calculatePromotionVoucher(Promotion promotion, BigDecimal subtotal) {

		LocalDateTime now = LocalDateTime.now();
		int usedCount = promotion.getUsedCount() == null ? 0 : promotion.getUsedCount();

		if (!promotion.isActive() || (promotion.getStartsAt() != null && now.isBefore(promotion.getStartsAt()))
				|| (promotion.getEndsAt() != null && now.isAfter(promotion.getEndsAt()))) {
			return VoucherResponse.builder().valid(false).message("Khuyến mãi chưa bắt đầu, đã hết hạn hoặc đã tắt.")
					.build();
		}

		if (promotion.getMaxUses() != null && usedCount >= promotion.getMaxUses()) {
			return VoucherResponse.builder().valid(false).message("Khuyến mãi đã hết lượt sử dụng.").build();
		}

		BigDecimal percent = promotion.getDiscountPercent();

		if (percent == null || percent.signum() <= 0 || percent.compareTo(BigDecimal.valueOf(100)) > 0) {
			return VoucherResponse.builder().valid(false).message("Cấu hình mức giảm không hợp lệ.").build();
		}

		BigDecimal discount = subtotal.multiply(percent).divide(BigDecimal.valueOf(100)).setScale(2,
				java.math.RoundingMode.HALF_UP);

		return VoucherResponse.builder().valid(true).code(promotion.getCode())
				.message("Áp dụng thành công khuyến mãi " + promotion.getName()).discountAmount(discount)
				.newFinalAmount(subtotal.subtract(discount).max(BigDecimal.ZERO)).build();
	}

	private VoucherResponse calculateLegacyVoucher(String code, BigDecimal subtotal) {

		BigDecimal discount;

		switch (code) {
		case "DIENMAY50K":
			if (subtotal.compareTo(BigDecimal.valueOf(500000)) < 0) {
				return VoucherResponse.builder().valid(false).message("Mã DIENMAY50K áp dụng cho đơn từ 500.000₫.")
						.build();
			}
			discount = BigDecimal.valueOf(50000);
			break;

		case "SALE10":
			discount = subtotal.multiply(new BigDecimal("0.10"));
			break;

		case "FREESHIP":
			discount = BigDecimal.valueOf(30000);
			break;

		default:
			return VoucherResponse.builder().valid(false).message("Mã giảm giá không tồn tại.").build();
		}

		return VoucherResponse.builder().valid(true).code(code).message("Đã áp dụng mã " + code)
				.discountAmount(discount).newFinalAmount(subtotal.subtract(discount).max(BigDecimal.ZERO)).build();
	}

	@Override
	@Transactional(propagation = Propagation.NOT_SUPPORTED)
	public Order placeOrder(PlaceOrderRequest request, String userEmail, HttpSession session,
			HttpServletRequest servletRequest) {
		requireCustomer(userEmail);

		PaymentMethod method = requireSupportedPaymentMethod(request.getPaymentMethod());
		if (method == PaymentMethod.VNPAY) {
			vnPayService.requireConfigured();
		}
		ShippingQuoteResponse shippingQuote = shippingService.quote(request.getShippingAddress(),
				request.getProvince());

		Order order = transactionTemplate
				.execute(status -> createOrder(request, userEmail, session, shippingQuote, method, servletRequest));

		if (order == null) {
			throw new IllegalStateException("Không thể tạo đơn hàng.");
		}

		return order;
	}

	private Order createOrder(PlaceOrderRequest request, String userEmail, HttpSession session,
			ShippingQuoteResponse shippingQuote, PaymentMethod method, HttpServletRequest servletRequest) {
		User user = requireCustomer(userEmail);
		Cart cart = getCart(userEmail, session);
		if (cart == null) {
			throw new IllegalArgumentException("Giỏ hàng của bạn đang trống!");
		}
		Long cartId = cart.getId();
		// A checkout page may already have loaded this cart via OpenEntityManagerInView.
		// Reload under the database lock before reading any selected items.
		entityManager.detach(cart);
		cart = cartRepository.findForUpdate(cartId)
				.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy giỏ hàng."));
		if (cart.getItems() == null || cart.getItems().isEmpty()) {
			throw new IllegalArgumentException("Giỏ hàng của bạn đang trống!");
		}

		List<CartItem> selectedItems = cart.getItems().stream().filter(item -> Boolean.TRUE.equals(item.getSelected()))
				.collect(Collectors.toList());

		if (selectedItems.isEmpty()) {
			throw new IllegalArgumentException("Vui lòng chọn ít nhất 1 sản phẩm để thanh toán!");
		}

		// 1. Xác định User đặt hàng
		Branch branch = validateCheckoutItems(selectedItems, shippingQuote.getBranchId());

		// 2. Tính toán tổng tiền
		BigDecimal subtotal = selectedItems.stream().map(CartItem::getSubtotal).reduce(BigDecimal.ZERO,
				BigDecimal::add);

		BigDecimal discount = BigDecimal.ZERO;

		if (request.getVoucherCode() != null && !request.getVoucherCode().isBlank()) {

			String code = request.getVoucherCode().trim().toUpperCase(java.util.Locale.ROOT);

			Promotion promotion = promotionRepository.findByCodeForUpdate(code).orElse(null);

			VoucherResponse voucher = promotion != null ? calculatePromotionVoucher(promotion, subtotal)
					: calculateLegacyVoucher(code, subtotal);

			if (!voucher.isValid()) {
				throw new IllegalArgumentException(voucher.getMessage());
			}

			discount = voucher.getDiscountAmount();

			if (promotion != null) {
				int usedCount = promotion.getUsedCount() == null ? 0 : promotion.getUsedCount();

				promotion.setUsedCount(Math.addExact(usedCount, 1));
				promotionRepository.save(promotion);

				eventPublisher.publishEvent(new PromotionEvent(promotion.getId(), "PROMOTION_REDEEMED", userEmail,
						"Sử dụng mã " + promotion.getCode()));
			}
		}

		BigDecimal shippingFee = shippingQuote.getShippingFee();
		BigDecimal finalAmount = subtotal.add(shippingFee).subtract(discount);
		if (finalAmount.compareTo(BigDecimal.ZERO) < 0)
			finalAmount = BigDecimal.ZERO;

		// 3. Tạo mã đơn hàng duy nhất
		String orderCode = orderCodeGenerator.nextCandidate();

		// 4. Lưu Entity Order
		Order order = Order.builder().orderCode(orderCode).user(user)
				.branch(branch).totalAmount(subtotal)
				.shippingFee(shippingFee).discountAmount(discount).finalAmount(finalAmount).status(OrderStatus.PENDING)
				.recipientName(request.getRecipientName()).recipientPhone(request.getRecipientPhone())
				.recipientEmail(request.getRecipientEmail() == null || request.getRecipientEmail().isBlank()
						? null : request.getRecipientEmail().trim())
				.shippingAddress(request.getShippingAddress()).note(request.getNote()).build();

		Order savedOrder = orderRepository.save(order);

		// 5. Lưu OrderItems
		List<OrderItem> orderItems = selectedItems.stream().map(item -> {
			BigDecimal price = item.getProduct().getSellingPrice();
			return OrderItem.builder().order(savedOrder).product(item.getProduct()).quantity(item.getQuantity())
					.price(price).subtotal(item.getSubtotal()).build();
		}).collect(Collectors.toList());

		orderItemRepository.saveAll(orderItems);
		savedOrder.getOrderItems().addAll(orderItems);

		Payment payment = Payment.builder().order(savedOrder).paymentMethod(method).paymentStatus(PaymentStatus.PENDING)
				.amount(finalAmount).build();

		paymentRepository.save(payment);
		savedOrder.setPayment(payment);
		if (method == PaymentMethod.VNPAY) {
			Instant expiresAt = Instant.now().plusSeconds(15 * 60).truncatedTo(ChronoUnit.SECONDS);
			String paymentUrl = vnPayService.createPaymentUrl(savedOrder, servletRequest, expiresAt);
			if (paymentUrl == null || paymentUrl.isBlank()) {
				throw new IllegalStateException("Không thể tạo đường dẫn thanh toán VNPay.");
			}
			payment.setPaymentUrl(paymentUrl);
			payment.setPaymentExpiresAt(expiresAt);
		}

		// 7. XÓA CÁC MÓN ĐÃ ĐẶT RA KHỎI GIỎ HÀNG
		cart.getItems().removeAll(selectedItems);
		cartRepository.save(cart);

		return savedOrder;
	}

	@Override
	@Transactional(readOnly = true)
	public Order getOrderByCode(String orderCode, String userEmail, HttpSession session) {
		requireCustomer(userEmail);

		if (orderCode == null || orderCode.isBlank()) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng.");
		}

		String cleanCode = orderCode.trim();

		Order order = orderRepository.findByOrderCode(cleanCode).orElseGet(() -> orderRepository
				.findByPaymentReference(cleanCode.replace("-", "").toUpperCase(java.util.Locale.ROOT))
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng.")));

		boolean owner = order.getUser() != null
				&& userEmail.equalsIgnoreCase(order.getUser().getEmail());
		if (!owner) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng.");
		}

		return order;
	}

	@Override
	@Transactional
	public String continuePayment(String orderCode, String userEmail, HttpSession session) {
		Order visibleOrder = getOrderByCode(orderCode, userEmail, session);
		Order order = orderRepository.findForUpdate(visibleOrder.getId())
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng."));
		entityManager.refresh(order, LockModeType.PESSIMISTIC_WRITE);
		Payment payment = paymentRepository.findByOrderIdForUpdate(order.getId())
				.orElseThrow(() -> new IllegalArgumentException("Đơn hàng chưa có thông tin thanh toán."));
		entityManager.refresh(payment);
		order.setPayment(payment);
		if (!payment.isPaymentLinkAvailable()) {
			throw new IllegalArgumentException("Đường dẫn thanh toán đã hết hạn hoặc đơn không còn chờ thanh toán.");
		}
		return payment.getPaymentUrl();
	}

	private Branch validateCheckoutItems(List<CartItem> items, Long branchId) {
		if (branchId == null) {
			throw new IllegalArgumentException("Chưa xác định được chi nhánh giao hàng.");
		}
		Branch branch = branchRepository.findById(branchId)
				.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh giao hàng."));
		entityManager.refresh(branch);
		if (!branch.isActive()) {
			throw new IllegalArgumentException("Chi nhánh giao hàng đang ngừng hoạt động.");
		}
		var quantities = new TreeMap<Long, Integer>();
		for (CartItem item : items) {
			if (item.getProduct() == null || item.getProduct().getId() == null) {
				throw new IllegalArgumentException("Sản phẩm trong giỏ không hợp lệ.");
			}
			purchaseValidator.requireQuantity(item.getQuantity());
			quantities.merge(item.getProduct().getId(), item.getQuantity(), (left, right) -> {
				long total = (long) left + right;
				if (total > Integer.MAX_VALUE) {
					throw new IllegalArgumentException("Số lượng sản phẩm vượt giới hạn.");
				}
				return (int) total;
			});
		}
		for (var entry : quantities.entrySet()) {
			var product = purchaseValidator.requireProduct(entry.getKey(), entry.getValue());
			purchaseValidator.requireBranchStock(branchId, entry.getKey(), entry.getValue());
			for (CartItem item : items) {
				if (entry.getKey().equals(item.getProduct().getId())) {
					item.setProduct(product);
				}
			}
		}
		return branch;
	}

	private Cart getCart(String userEmail, HttpSession session) {
		cartService.getCart(userEmail, session);
		return cartRepository.findByUser_Email(userEmail).orElse(null);
	}

	private User requireCustomer(String email) {
		if (email == null || email.isBlank() || email.equalsIgnoreCase("anonymousUser")) {
			throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập để mua hàng.");
		}
		User user = userRepository.findByEmail(email)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));
		if (!user.isActive() || user.isBlocked()) {
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Tài khoản hiện không được phép sử dụng.");
		}
		return user;
	}

	private PaymentMethod requireSupportedPaymentMethod(String value) {
		if ("COD".equals(value)) {
			return PaymentMethod.COD;
		}

		if ("VNPAY".equals(value)) {
			return PaymentMethod.VNPAY;
		}

		throw new IllegalArgumentException("Phương thức thanh toán chưa được hỗ trợ.");
	}
}
