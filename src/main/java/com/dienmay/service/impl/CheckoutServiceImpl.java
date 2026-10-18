package com.dienmay.service.impl;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.support.TransactionTemplate;

import com.dienmay.dto.checkout.CheckoutItemDto;
import com.dienmay.dto.checkout.CheckoutPageDto;
import com.dienmay.dto.checkout.PlaceOrderRequest;
import com.dienmay.dto.checkout.VoucherResponse;
import com.dienmay.dto.checkout.ShippingQuoteResponse;
import com.dienmay.entity.auth.Address;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.cart.Cart;
import com.dienmay.entity.cart.CartItem;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderItem;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.repository.auth.AddressRepository;
import com.dienmay.repository.auth.RoleRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.cart.CartItemRepository;
import com.dienmay.repository.cart.CartRepository;
import com.dienmay.repository.order.OrderItemRepository;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.checkout.ShippingService;
import com.dienmay.entity.promotion.Promotion;
import com.dienmay.repository.promotion.PromotionRepository;

import jakarta.servlet.http.HttpSession;
import org.springframework.context.ApplicationEventPublisher;
import com.dienmay.event.PromotionEvent;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class CheckoutServiceImpl implements CheckoutService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final AddressRepository addressRepository;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PaymentRepository paymentRepository;
    private final PromotionRepository promotionRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final ShippingService shippingService;
    private final BranchRepository branchRepository;
    private final TransactionTemplate transactionTemplate;

    @Override
    @Transactional(readOnly = true)
    public CheckoutPageDto getCheckoutData(String userEmail, HttpSession session) {
        Cart cart = getCart(userEmail, session);
        List<CartItem> selectedItems = (cart != null && cart.getItems() != null)
                ? cart.getItems().stream().filter(CartItem::getSelected).collect(Collectors.toList())
                : new ArrayList<>();

        List<CheckoutItemDto> items = selectedItems.stream().map(item -> {
            BigDecimal price = (item.getProduct().getDiscountPrice() != null)
                    ? item.getProduct().getDiscountPrice()
                    : item.getProduct().getPrice();
            return CheckoutItemDto.builder()
                    .productId(item.getProduct().getId())
                    .productName(item.getProduct().getName())
                    .productSlug(item.getProduct().getSlug())
                    .imageUrl(item.getProduct().getMainImageUrl())
                    .price(price)
                    .quantity(item.getQuantity())
                    .subtotal(item.getSubtotal())
                    .build();
        }).collect(Collectors.toList());

        BigDecimal subtotal = items.stream()
                .map(CheckoutItemDto::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

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

        return CheckoutPageDto.builder()
                .items(items)
                .savedAddresses(savedAddresses)
                .subtotal(subtotal)
                .shippingFee(shippingFee)
                .discountAmount(discount)
                .finalAmount(finalAmount)
                .build();
    }

    @Override
    public VoucherResponse applyVoucher(String code, BigDecimal subtotal) {
        if (code == null || code.trim().isEmpty()) {
            return VoucherResponse.builder().valid(false).message("Vui lòng nhập mã giảm giá").build();
        }

        String c = code.trim().toUpperCase();
        Promotion promotion = promotionRepository.findByCodeIgnoreCase(c).orElse(null);
        if (promotion != null) {
            LocalDateTime now = LocalDateTime.now();
            if (!promotion.isActive() || (promotion.getStartsAt()!=null && now.isBefore(promotion.getStartsAt())) || (promotion.getEndsAt()!=null && now.isAfter(promotion.getEndsAt())))
                return VoucherResponse.builder().valid(false).message("Khuyến mãi chưa bắt đầu, đã hết hạn hoặc đã tắt").build();
            if (promotion.getMaxUses()!=null && promotion.getUsedCount() >= promotion.getMaxUses())
                return VoucherResponse.builder().valid(false).message("Khuyến mãi đã hết lượt sử dụng").build();
            BigDecimal discount = subtotal.multiply(promotion.getDiscountPercent()).divide(BigDecimal.valueOf(100));
            BigDecimal newFinal = subtotal.subtract(discount).max(BigDecimal.ZERO);
            return VoucherResponse.builder().valid(true).code(c).message("Áp dụng thành công khuyến mãi " + promotion.getName()).discountAmount(discount).newFinalAmount(newFinal).build();
        }
        BigDecimal discount = BigDecimal.ZERO;
        String msg = "";

        if (c.equals("DIENMAY50K")) {
            if (subtotal.compareTo(BigDecimal.valueOf(500000)) >= 0) {
                discount = BigDecimal.valueOf(50000);
                msg = "Áp dụng thành công mã giảm 50.000₫!";
            } else {
                return VoucherResponse.builder().valid(false).message("Mã DIENMAY50K chỉ áp dụng cho đơn từ 500.000₫").build();
            }
        } else if (c.equals("SALE10")) {
            discount = subtotal.multiply(BigDecimal.valueOf(0.10));
            msg = "Áp dụng thành công mã giảm 10%!";
        } else if (c.equals("FREESHIP")) {
            discount = BigDecimal.valueOf(30000);
            msg = "Miễn phí vận chuyển 30.000₫!";
        } else {
            return VoucherResponse.builder().valid(false).message("Mã giảm giá không tồn tại hoặc đã hết hạn").build();
        }

        BigDecimal newFinal = subtotal.subtract(discount);
        if (newFinal.compareTo(BigDecimal.ZERO) < 0) newFinal = BigDecimal.ZERO;

        return VoucherResponse.builder()
                .valid(true)
                .code(c)
                .message(msg)
                .discountAmount(discount)
                .newFinalAmount(newFinal)
                .build();
    }

    @Override
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public Order placeOrder(PlaceOrderRequest request, String userEmail, HttpSession session) {
        // Google Maps must not hold a database transaction open while it responds.
        ShippingQuoteResponse shippingQuote = shippingService.quote(request.getShippingAddress(), request.getProvince());
        return transactionTemplate.execute(status -> createOrder(request, userEmail, session, shippingQuote));
    }

    private Order createOrder(PlaceOrderRequest request, String userEmail, HttpSession session,
            ShippingQuoteResponse shippingQuote) {
        Cart cart = getCart(userEmail, session);
        if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
            throw new RuntimeException("Giỏ hàng của bạn đang trống!");
        }

        List<CartItem> selectedItems = cart.getItems().stream()
                .filter(CartItem::getSelected)
                .collect(Collectors.toList());

        if (selectedItems.isEmpty()) {
            throw new RuntimeException("Vui lòng chọn ít nhất 1 sản phẩm để thanh toán!");
        }

        // 1. Xác định User đặt hàng
        User user = null;
        if (userEmail != null && !userEmail.equalsIgnoreCase("anonymousUser")) {
            user = userRepository.findByEmail(userEmail).orElse(null);
        }
        if (user == null) {
            String guestEmail = (request.getRecipientEmail() != null && !request.getRecipientEmail().trim().isEmpty())
                    ? request.getRecipientEmail().trim().toLowerCase()
                    : "guest_" + System.currentTimeMillis() + "@dienmay.com";

            user = userRepository.findByEmail(guestEmail).orElseGet(() -> {
                Role customerRole = roleRepository.findByName("ROLE_CUSTOMER").orElse(null);
                User newUser = User.builder()
                        .email(guestEmail)
                        .fullName(request.getRecipientName())
                        .phoneNumber(request.getRecipientPhone())
                        .password("NO_PASSWORD_GUEST")
                        .active(true)
                        .build();
                if (customerRole != null) newUser.getRoles().add(customerRole);
                return userRepository.save(newUser);
            });
        }

        // 2. Tính toán tổng tiền
        BigDecimal subtotal = selectedItems.stream()
                .map(CartItem::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal discount = BigDecimal.ZERO;
        if (request.getVoucherCode() != null && !request.getVoucherCode().trim().isEmpty()) {
            VoucherResponse vRes = applyVoucher(request.getVoucherCode(), subtotal);
            if (vRes.isValid()) {
                discount = vRes.getDiscountAmount();
                promotionRepository.findByCodeIgnoreCase(request.getVoucherCode().trim()).ifPresent(p -> { p.setUsedCount(p.getUsedCount() + 1); promotionRepository.save(p); eventPublisher.publishEvent(new PromotionEvent(p.getId(), "PROMOTION_REDEEMED", userEmail, "Sử dụng mã " + p.getCode())); });
            }
        }

        BigDecimal shippingFee = shippingQuote.getShippingFee();
        BigDecimal finalAmount = subtotal.add(shippingFee).subtract(discount);
        if (finalAmount.compareTo(BigDecimal.ZERO) < 0) finalAmount = BigDecimal.ZERO;

        // 3. Tạo mã đơn hàng duy nhất
        String orderCode = "ORD-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "-" + (1000 + new Random().nextInt(9000));

        // 4. Lưu Entity Order
        Order order = Order.builder()
                .orderCode(orderCode)
                .user(user)
                .branch(branchRepository.findById(shippingQuote.getBranchId()).orElse(null))
                .totalAmount(subtotal)
                .shippingFee(shippingFee)
                .discountAmount(discount)
                .finalAmount(finalAmount)
                .status(OrderStatus.PENDING)
                .recipientName(request.getRecipientName())
                .recipientPhone(request.getRecipientPhone())
                .shippingAddress(request.getShippingAddress())
                .note(request.getNote())
                .build();

        Order savedOrder = orderRepository.save(order);

        // 5. Lưu OrderItems
        List<OrderItem> orderItems = selectedItems.stream().map(item -> {
            BigDecimal price = (item.getProduct().getDiscountPrice() != null)
                    ? item.getProduct().getDiscountPrice()
                    : item.getProduct().getPrice();
            return OrderItem.builder()
                    .order(savedOrder)
                    .product(item.getProduct())
                    .quantity(item.getQuantity())
                    .price(price)
                    .subtotal(item.getSubtotal())
                    .build();
        }).collect(Collectors.toList());

        orderItemRepository.saveAll(orderItems);

        // 6. Lưu Payment
        PaymentMethod method = PaymentMethod.COD;
        try {
            if (request.getPaymentMethod() != null) {
                method = PaymentMethod.valueOf(request.getPaymentMethod().toUpperCase());
            }
        } catch (Exception ignored) {}

        Payment payment = Payment.builder()
                .order(savedOrder)
                .paymentMethod(method)
                .paymentStatus(PaymentStatus.PENDING)
                .amount(finalAmount)
                .build();

        paymentRepository.save(payment);

        // 7. XÓA CÁC MÓN ĐÃ ĐẶT RA KHỎI GIỎ HÀNG
        cart.getItems().removeAll(selectedItems);
        cartItemRepository.deleteAll(selectedItems);
        cartRepository.save(cart);

        return savedOrder;
    }

    @Override
    @Transactional(readOnly = true)
    public Order getOrderByCode(String orderCode) {
        return orderRepository.findByOrderCode(orderCode)
                .orElseGet(() -> orderRepository.findAll().stream()
                        .filter(o -> o.getOrderCode() != null && o.getOrderCode().replace("-", "").equalsIgnoreCase(orderCode.replace("-", "")))
                        .findFirst()
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + orderCode)));
    }

    private Cart getCart(String userEmail, HttpSession session) {
        if (userEmail != null && !userEmail.equalsIgnoreCase("anonymousUser")) {
            Cart cart = cartRepository.findByUser_Email(userEmail).orElse(null);
            if (cart != null) return cart;
        }
        String sessionId = (String) session.getAttribute("GUEST_CART_SESSION");
        if (sessionId != null) {
            return cartRepository.findBySessionId(sessionId).orElse(null);
        }
        return null;
    }
}
