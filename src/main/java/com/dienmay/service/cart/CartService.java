package com.dienmay.service.cart;

import com.dienmay.dto.cart.AddToCartRequest;
import com.dienmay.dto.cart.CartResponse;
import jakarta.servlet.http.HttpSession;

public interface CartService {
    CartResponse getCart(String userEmail, HttpSession session);
    CartResponse addToCart(AddToCartRequest request, String userEmail, HttpSession session);
    CartResponse updateQuantity(Long cartItemId, int quantity, String userEmail, HttpSession session);
    CartResponse removeItem(Long cartItemId, String userEmail, HttpSession session);
    CartResponse toggleSelect(Long cartItemId, boolean selected, String userEmail, HttpSession session);
    CartResponse selectAll(boolean selected, String userEmail, HttpSession session);
    int getCartTotalQuantity(String userEmail, HttpSession session);
}