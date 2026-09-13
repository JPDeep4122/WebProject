package com.dienmay.controller.client;

import java.security.Principal;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.dienmay.dto.cart.AddToCartRequest;
import com.dienmay.dto.cart.CartResponse;
import com.dienmay.dto.common.ApiResponse;
import com.dienmay.service.cart.CartService;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartApiController {

    private final CartService cartService;

    // 1. Thêm vào giỏ hàng (AJAX)
    @PostMapping("/add")
    public ResponseEntity<ApiResponse<CartResponse>> addToCart(
            @Valid @RequestBody AddToCartRequest request, 
            Principal principal, 
            HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CartResponse cart = cartService.addToCart(request, email, session);
        return ResponseEntity.ok(ApiResponse.<CartResponse>builder()
                .success(true)
                .message("Đã thêm sản phẩm vào giỏ hàng thành công!")
                .data(cart)
                .build());
    }

    // 2. Cập nhật số lượng (+ / -)
    @PutMapping("/items/{id}/quantity")
    public ResponseEntity<ApiResponse<CartResponse>> updateQuantity(
            @PathVariable Long id, 
            @RequestParam int quantity, 
            Principal principal, 
            HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CartResponse cart = cartService.updateQuantity(id, quantity, email, session);
        return ResponseEntity.ok(ApiResponse.<CartResponse>builder()
                .success(true)
                .data(cart)
                .build());
    }

    // 3. Xóa sản phẩm khỏi giỏ
    @DeleteMapping("/items/{id}")
    public ResponseEntity<ApiResponse<CartResponse>> removeItem(
            @PathVariable Long id, 
            Principal principal, 
            HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CartResponse cart = cartService.removeItem(id, email, session);
        return ResponseEntity.ok(ApiResponse.<CartResponse>builder()
                .success(true)
                .message("Đã xóa sản phẩm khỏi giỏ hàng")
                .data(cart)
                .build());
    }

    // 4. Chọn / Bỏ chọn sản phẩm thanh toán
    @PutMapping("/items/{id}/select")
    public ResponseEntity<ApiResponse<CartResponse>> toggleSelect(
            @PathVariable Long id, 
            @RequestParam boolean selected, 
            Principal principal, 
            HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CartResponse cart = cartService.toggleSelect(id, selected, email, session);
        return ResponseEntity.ok(ApiResponse.<CartResponse>builder()
                .success(true)
                .data(cart)
                .build());
    }

    // 5. Chọn tất cả / Bỏ chọn tất cả
    @PutMapping("/select-all")
    public ResponseEntity<ApiResponse<CartResponse>> selectAll(
            @RequestParam boolean selected, 
            Principal principal, 
            HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        CartResponse cart = cartService.selectAll(selected, email, session);
        return ResponseEntity.ok(ApiResponse.<CartResponse>builder()
                .success(true)
                .data(cart)
                .build());
    }

    // 6. Lấy tổng số lượng để cập nhật Badge ở Header
    @GetMapping("/count")
    public ResponseEntity<ApiResponse<Integer>> getCartCount(Principal principal, HttpSession session) {
        String email = (principal != null) ? principal.getName() : null;
        int count = cartService.getCartTotalQuantity(email, session);
        return ResponseEntity.ok(ApiResponse.<Integer>builder()
                .success(true)
                .data(count)
                .build());
    }
}