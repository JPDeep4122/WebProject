package com.dienmay.controller.admin;

import java.security.Principal;
import java.util.HashSet;
import java.util.Locale;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.dienmay.dto.promotion.PromotionRequest;
import com.dienmay.entity.promotion.*;
import com.dienmay.event.PromotionEvent;
import com.dienmay.repository.product.CategoryRepository;
import com.dienmay.repository.promotion.PromotionRepository;
import com.dienmay.service.promotion.*;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/promotions")
@RequiredArgsConstructor
public class AdminPromotionController {

    private final PromotionRepository promotions;
    private final CategoryRepository categories;
    private final VoucherService vouchers;
    private final VoucherExpiryService expiry;
    private final ApplicationEventPublisher events;
    private final TransactionTemplate transactions;

    @GetMapping
    public String list(Model model) {
        var list = transactions.execute(status -> {
            var result = promotions.findAll();
            result.forEach(p -> p.getCategories().size());
            return result;
        });

        model.addAttribute("promotions", list);
        model.addAttribute("categories", categories.findByActiveTrue());
        model.addAttribute("newPromotion", new PromotionRequest());
        return "admin/promotions";
    }

    @PostMapping({"", "/{id}/update"})
    public String save(
            @PathVariable(name = "id", required = false) Long id,
            @Valid @ModelAttribute PromotionRequest req,
            BindingResult errors,
            Principal principal,
            RedirectAttributes flash) {

        if (errors.hasErrors()) {
            flash.addFlashAttribute(
                    "error", "Thông tin voucher không hợp lệ.");
            return "redirect:/admin/promotions";
        }

        try {
            transactions.executeWithoutResult(status -> {
                Promotion p = id == null
                        ? Promotion.builder().build()
                        : promotions.findByIdForUpdate(id)
                            .orElseThrow(() ->
                                new IllegalArgumentException(
                                    "Không tìm thấy voucher."));

                String code = req.getCode().trim()
                        .toUpperCase(Locale.ROOT);

                if (id == null
                        && promotions.existsByCodeIgnoreCase(code)) {
                    throw new IllegalArgumentException(
                            "Mã voucher đã tồn tại.");
                }

                if (id != null && !code.equals(p.getCode())) {
                    throw new IllegalArgumentException(
                            "Không đổi mã của voucher đã tạo.");
                }

                var categoryIds = req.getCategoryIds() == null
                        ? java.util.Set.<Long>of()
                        : req.getCategoryIds();

                var selected = categories.findAllById(categoryIds);

                if (selected.size() != categoryIds.size()
                        || selected.stream().anyMatch(c -> !c.isActive())) {
                    throw new IllegalArgumentException(
                            "Danh mục không tồn tại hoặc đã tắt.");
                }

                p.setName(req.getName().trim());
                p.setCode(code);
                p.setDiscountType(req.getDiscountType());

                p.setDiscountPercent(
                        req.getDiscountType() == VoucherType.PERCENT
                            ? req.getDiscountPercent() : null);

                p.setDiscountAmount(
                        req.getDiscountType() == VoucherType.FIXED
                            ? req.getDiscountAmount() : null);

                p.setMaxDiscountAmount(req.getMaxDiscountAmount());
                p.setMinOrderAmount(req.getMinOrderAmount());
                p.setRequiredPaymentMethod(req.getRequiredPaymentMethod());
                p.setNewCustomerOnly(
                        Boolean.TRUE.equals(req.getNewCustomerOnly()));
                p.setPerUserLimit(req.getPerUserLimit());
                p.setMaxUses(req.getMaxUses());
                p.setStartsAt(req.getStartsAt());
                p.setEndsAt(req.getEndsAt());
                p.setActive(Boolean.TRUE.equals(req.getActive()));
                p.setCategories(new HashSet<>(selected));

                vouchers.validateConfiguration(p);

                int used = p.getUsedCount() == null
                        ? 0 : p.getUsedCount();

                if (p.getMaxUses() != null
                        && p.getMaxUses() < used) {
                    throw new IllegalArgumentException(
                            "Giới hạn không được nhỏ hơn lượt đã dùng.");
                }

                promotions.saveAndFlush(p);

                events.publishEvent(new PromotionEvent(
                        p.getId(),
                        id == null
                            ? "PROMOTION_CREATED"
                            : "PROMOTION_UPDATED",
                        principal.getName(),
                        "Mã " + p.getCode()));
            });

            flash.addFlashAttribute("success", "Đã lưu voucher.");

        } catch (IllegalArgumentException ex) {
            flash.addFlashAttribute("error", ex.getMessage());

        } catch (RuntimeException ex) {
            flash.addFlashAttribute(
                    "error",
                    "Chưa lưu được voucher. Kiểm tra mã trùng và cấu hình.");
        }

        return "redirect:/admin/promotions";
    }

    @PostMapping("/{id}/toggle")
    public String toggle(
            @PathVariable Long id,
            Principal principal,
            RedirectAttributes flash) {

        transactions.executeWithoutResult(status -> {
            Promotion p = promotions.findByIdForUpdate(id)
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Không tìm thấy voucher."));

            p.setActive(!p.isActive());

            events.publishEvent(new PromotionEvent(
                    p.getId(),
                    "PROMOTION_TOGGLED",
                    principal.getName(),
                    "Mã " + p.getCode()));
        });

        flash.addFlashAttribute("success", "Đã đổi trạng thái.");
        return "redirect:/admin/promotions";
    }

    @PostMapping("/expire-unpaid")
    public String expire(RedirectAttributes flash) {
        int count = expiry.expireBatch();

        flash.addFlashAttribute(
                "success",
                "Đã hủy " + count
                    + " đơn chờ VNPay hết hạn và hoàn lượt voucher tương ứng.");

        return "redirect:/admin/promotions";
    }
}