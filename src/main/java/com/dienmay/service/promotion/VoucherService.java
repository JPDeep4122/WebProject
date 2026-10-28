package com.dienmay.service.promotion;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.cart.CartItem;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.entity.product.Category;
import com.dienmay.entity.promotion.*;
import com.dienmay.event.PromotionEvent;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.promotion.*;

import jakarta.persistence.*;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VoucherService {

    private static final ZoneId VN =
            ZoneId.of("Asia/Ho_Chi_Minh");

    private final PromotionRepository promotions;
    private final VoucherUsageRepository usages;
    private final OrderRepository orders;
    private final ApplicationEventPublisher events;

    @PersistenceContext
    private EntityManager entityManager;

    public record Quote(
            Promotion promotion,
            BigDecimal discountAmount) {
    }

    public void validateConfiguration(Promotion p) {
        if (p.getDiscountType() == null) {
            throw new IllegalArgumentException("Thiếu loại voucher.");
        }

        if (p.getMinOrderAmount() == null
                || p.getMinOrderAmount().signum() < 0) {
            throw new IllegalArgumentException(
                    "Giá trị đơn tối thiểu không hợp lệ.");
        }

        if (p.getMaxDiscountAmount() != null
                && p.getMaxDiscountAmount().signum() <= 0) {
            throw new IllegalArgumentException(
                    "Mức giảm tối đa phải lớn hơn 0.");
        }

        if (p.getMaxUses() != null && p.getMaxUses() < 0) {
            throw new IllegalArgumentException(
                    "Giới hạn lượt dùng không hợp lệ.");
        }

        if (p.getPerUserLimit() != null
                && p.getPerUserLimit() < 1) {
            throw new IllegalArgumentException(
                    "Giới hạn mỗi khách phải từ 1.");
        }

        if (p.getStartsAt() != null && p.getEndsAt() != null
                && !p.getEndsAt().isAfter(p.getStartsAt())) {
            throw new IllegalArgumentException(
                    "Thời gian kết thúc phải sau thời gian bắt đầu.");
        }

        switch (p.getDiscountType()) {
            case PERCENT -> {
                BigDecimal percent = p.getDiscountPercent();
                if (percent == null || percent.signum() <= 0
                        || percent.compareTo(
                                BigDecimal.valueOf(100)) > 0) {
                    throw new IllegalArgumentException(
                            "Phần trăm giảm phải lớn hơn 0 và không quá 100.");
                }
            }

            case FIXED -> {
                if (p.getDiscountAmount() == null
                        || p.getDiscountAmount().signum() <= 0) {
                    throw new IllegalArgumentException(
                            "Số tiền giảm phải lớn hơn 0.");
                }
            }

            case SHIPPING -> {
                // Giảm theo phí vận chuyển thực tế.
            }
        }
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public Quote prepare(
            String rawCode,
            List<CartItem> items,
            User user,
            PaymentMethod method,
            BigDecimal shippingFee,
            boolean lock) {

        if (rawCode == null || rawCode.isBlank()) {
            return new Quote(null, BigDecimal.ZERO);
        }

        String code = rawCode.trim()
                .toUpperCase(java.util.Locale.ROOT);

        if (code.length() > 50) {
            throw new IllegalArgumentException("Mã voucher quá dài.");
        }

        Promotion p = (lock
                ? promotions.findByCodeForUpdate(code)
                : promotions.findByCodeIgnoreCase(code))
                .orElseThrow(() -> new IllegalArgumentException(
                        "Mã voucher không tồn tại."));

        if (lock) {
            entityManager.refresh(
                    p, LockModeType.PESSIMISTIC_WRITE);
        }

        validateConfiguration(p);

        LocalDateTime now = LocalDateTime.now(VN);

        if (!p.isActive()
                || (p.getStartsAt() != null
                    && now.isBefore(p.getStartsAt()))
                || (p.getEndsAt() != null
                    && !now.isBefore(p.getEndsAt()))) {
            throw new IllegalArgumentException(
                    "Voucher chưa bắt đầu, đã hết hạn hoặc đã tắt.");
        }

        int used = p.getUsedCount() == null
                ? 0 : p.getUsedCount();

        if (p.getMaxUses() != null && used >= p.getMaxUses()) {
            throw new IllegalArgumentException(
                    "Voucher đã hết lượt sử dụng.");
        }

        if (p.getRequiredPaymentMethod() != null
                && p.getRequiredPaymentMethod() != method) {
            throw new IllegalArgumentException(
                    "Voucher chỉ áp dụng khi thanh toán bằng "
                    + p.getRequiredPaymentMethod() + ".");
        }

        if (p.isNewCustomerOnly()
                && orders.countExistingPurchases(
                        user.getId(),
                        OrderStatus.CANCELLED,
                        PaymentStatus.FAILED) > 0) {
            throw new IllegalArgumentException(
                    "Voucher chỉ dành cho khách chưa có đơn mua hàng.");
        }

        if (p.getPerUserLimit() != null
                && usages.countActiveUses(p.getId(), user.getId())
                    >= p.getPerUserLimit()) {
            throw new IllegalArgumentException(
                    "Bạn đã dùng hết số lượt của voucher này.");
        }

        Set<Long> allowedCategoryIds = p.getCategoryIds();

        BigDecimal eligibleTotal = items.stream()
                .filter(item -> categoryMatches(
                        item.getProduct().getCategory(),
                        allowedCategoryIds))
                .map(CartItem::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        if (eligibleTotal.signum() <= 0) {
            throw new IllegalArgumentException(
                    "Giỏ hàng chưa có sản phẩm thuộc phạm vi voucher.");
        }

        if (eligibleTotal.compareTo(p.getMinOrderAmount()) < 0) {
            throw new IllegalArgumentException(
                    "Tiền sản phẩm đủ điều kiện chưa đạt mức tối thiểu "
                    + p.getMinOrderAmount().toPlainString() + "đ.");
        }

        BigDecimal base = p.getDiscountType() == VoucherType.SHIPPING
                ? shippingFee : eligibleTotal;

        if (base == null || base.signum() <= 0) {
            throw new IllegalArgumentException(
                    "Đơn này không có phí vận chuyển để giảm.");
        }

        BigDecimal discount = switch (p.getDiscountType()) {
            case PERCENT -> eligibleTotal
                    .multiply(p.getDiscountPercent())
                    .divide(BigDecimal.valueOf(100));

            case FIXED -> p.getDiscountAmount();

            case SHIPPING -> shippingFee;
        };

        if (p.getMaxDiscountAmount() != null) {
            discount = discount.min(p.getMaxDiscountAmount());
        }

        discount = discount
                .setScale(2, RoundingMode.HALF_UP)
                .min(base);

        return new Quote(p, discount);
    }

    private boolean categoryMatches(
            Category category, Set<Long> allowed) {

        if (allowed.isEmpty()) {
            return true;
        }

        Set<Long> visited = new HashSet<>();
        boolean matched = false;

        // Cho phép chọn danh mục cha để áp dụng cho danh mục con.
        while (category != null
                && visited.add(category.getId())) {

            if (!category.isActive()) {
                return false;
            }

            matched |= allowed.contains(category.getId());
            category = category.getParent();
        }

        return matched;
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void recordUsage(Order order, Quote quote, User user) {
        Promotion p = quote.promotion();

        if (p == null) {
            return;
        }

        int used = p.getUsedCount() == null
                ? 0 : p.getUsedCount();

        p.setUsedCount(Math.addExact(used, 1));
        order.setVoucherCode(p.getCode());

        usages.save(VoucherUsage.builder()
                .order(order)
                .promotion(p)
                .user(user)
                .discountAmount(quote.discountAmount())
                .build());

        events.publishEvent(new PromotionEvent(
                p.getId(),
                "PROMOTION_REDEEMED",
                user.getEmail(),
                "Đơn " + order.getOrderCode()
                        + " dùng mã " + p.getCode()));
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void release(Long orderId, String reason) {
        VoucherUsage usage =
                usages.findForRelease(orderId).orElse(null);

        if (usage == null) {
            return; // Đơn cũ hoặc đơn không dùng voucher.
        }

        entityManager.refresh(
                usage, LockModeType.PESSIMISTIC_WRITE);

        if (usage.getReleasedAt() != null) {
            return; // Đã hoàn lượt, không hoàn lần hai.
        }

        Promotion p = promotions.findByIdForUpdate(
                usage.getPromotion().getId()).orElseThrow();

        entityManager.refresh(
                p, LockModeType.PESSIMISTIC_WRITE);

        int used = p.getUsedCount() == null
                ? 0 : p.getUsedCount();

        if (used < 1) {
            throw new IllegalStateException(
                    "Lượt dùng voucher không khớp lịch sử.");
        }

        p.setUsedCount(used - 1);
        usage.setReleasedAt(Instant.now());
        usage.setReleaseReason(reason);

        events.publishEvent(new PromotionEvent(
                p.getId(),
                "PROMOTION_RELEASED",
                "system",
                "Hoàn lượt cho đơn #" + orderId
                        + ": " + reason));
    }

    @Transactional(readOnly = true)
    public List<Promotion> listAvailable() {
        LocalDateTime now = LocalDateTime.now(VN);

        return promotions.findAll().stream()
                .filter(Promotion::isActive)
                .filter(p -> p.getStartsAt() == null
                        || !now.isBefore(p.getStartsAt()))
                .filter(p -> p.getEndsAt() == null
                        || now.isBefore(p.getEndsAt()))
                .filter(p -> p.getMaxUses() == null
                        || (p.getUsedCount() == null
                            ? 0 : p.getUsedCount()) < p.getMaxUses())
                .peek(p -> p.getCategories().size())
                .toList();
    }
}