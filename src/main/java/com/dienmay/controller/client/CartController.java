package com.dienmay.controller.client;

import java.security.Principal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.dienmay.dto.cart.CartResponse;
import com.dienmay.service.cart.CartService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping
    public String viewCart(Model model, Principal principal, HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CartResponse cart = cartService.getCart(email, session);
        model.addAttribute("cart", cart);
        long selectedItemCount = cart.getItems().stream()
                .filter(item -> Boolean.TRUE.equals(item.getSelected()))
                .count();
        model.addAttribute("allItemsSelected", !cart.getItems().isEmpty()
                && selectedItemCount == cart.getItems().size());
        model.addAttribute("someItemsSelected", selectedItemCount > 0
                && selectedItemCount < cart.getItems().size());
        return "client/cart";
    }
}
