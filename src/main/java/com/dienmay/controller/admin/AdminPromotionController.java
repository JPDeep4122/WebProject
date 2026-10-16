package com.dienmay.controller.admin;

import com.dienmay.dto.promotion.PromotionRequest;
import com.dienmay.entity.promotion.Promotion;
import com.dienmay.event.PromotionEvent;
import com.dienmay.repository.promotion.PromotionRepository;
import jakarta.validation.Valid;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.security.Principal;
import java.time.LocalDateTime;

@Controller @RequestMapping("/admin/promotions")
public class AdminPromotionController {
    private final PromotionRepository promotions; private final ApplicationEventPublisher events;
    public AdminPromotionController(PromotionRepository promotions, ApplicationEventPublisher events){this.promotions=promotions;this.events=events;}
    @GetMapping public String list(Model model){model.addAttribute("promotions",promotions.findAll());model.addAttribute("newPromotion",new PromotionRequest());return "admin/promotions";}
    @PostMapping public String create(@Valid @ModelAttribute("newPromotion") PromotionRequest req, BindingResult errors, Principal principal, RedirectAttributes flash){
        if(errors.hasErrors()){flash.addFlashAttribute("error","Thông tin khuyến mãi không hợp lệ.");return "redirect:/admin/promotions";}
        try { if(req.getStartsAt()!=null&&req.getEndsAt()!=null&&req.getEndsAt().isBefore(req.getStartsAt())) throw new IllegalArgumentException("Thời gian kết thúc phải sau thời gian bắt đầu."); if(promotions.existsByCodeIgnoreCase(req.getCode().trim())) throw new IllegalArgumentException("Mã khuyến mãi đã tồn tại."); Promotion p=Promotion.builder().name(req.getName().trim()).code(req.getCode().trim().toUpperCase()).discountPercent(req.getDiscountPercent()).startsAt(req.getStartsAt()).endsAt(req.getEndsAt()).maxUses(req.getMaxUses()).active(req.getActive()==null||req.getActive()).build(); p=promotions.save(p); events.publishEvent(new PromotionEvent(p.getId(),"PROMOTION_CREATED",actor(principal),"Tạo mã "+p.getCode()+" - giảm "+p.getDiscountPercent()+"%"));flash.addFlashAttribute("success","Đã tạo khuyến mãi và ghi audit log."); }
        catch(RuntimeException e){flash.addFlashAttribute("error",e.getMessage());} return "redirect:/admin/promotions";
    }
    @PostMapping("/{id}/toggle") public String toggle(@PathVariable Long id, Principal principal, RedirectAttributes flash){try{Promotion p=promotions.findById(id).orElseThrow(()->new IllegalArgumentException("Không tìm thấy khuyến mãi."));p.setActive(!p.isActive());promotions.save(p);events.publishEvent(new PromotionEvent(id,p.isActive()?"PROMOTION_ACTIVATED":"PROMOTION_DEACTIVATED",actor(principal),"Mã "+p.getCode()));flash.addFlashAttribute("success","Đã cập nhật trạng thái khuyến mãi.");}catch(RuntimeException e){flash.addFlashAttribute("error",e.getMessage());}return "redirect:/admin/promotions";}
    @PostMapping("/{id}/update") public String update(@PathVariable Long id,@Valid @ModelAttribute PromotionRequest req,BindingResult errors,Principal principal,RedirectAttributes flash){try{if(errors.hasErrors())throw new IllegalArgumentException("Thông tin không hợp lệ.");Promotion p=promotions.findById(id).orElseThrow(()->new IllegalArgumentException("Không tìm thấy khuyến mãi."));p.setName(req.getName().trim());p.setDiscountPercent(req.getDiscountPercent());p.setStartsAt(req.getStartsAt());p.setEndsAt(req.getEndsAt());p.setMaxUses(req.getMaxUses());p.setActive(req.getActive()==null||req.getActive());promotions.save(p);events.publishEvent(new PromotionEvent(id,"PROMOTION_UPDATED",actor(principal),"Cập nhật mã "+p.getCode()));flash.addFlashAttribute("success","Đã cập nhật khuyến mãi.");}catch(RuntimeException e){flash.addFlashAttribute("error",e.getMessage());}return "redirect:/admin/promotions";}
    private String actor(Principal p){return p==null?"system":p.getName();}
}
