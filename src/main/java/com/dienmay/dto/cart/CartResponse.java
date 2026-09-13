package com.dienmay.dto.cart;

import java.math.BigDecimal;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CartResponse {
    private Long cartId;
    private List<CartItemResponse> items;
    private int totalQuantity;          // Tổng số lượng sản phẩm (để hiển thị badge ở header)
    private BigDecimal totalSelectedAmount; // Tổng tiền các sản phẩm được tích chọn mua
}