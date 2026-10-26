package com.dienmay.dto.cart;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddToCartRequest {
	@NotNull(message = "ID sản phẩm không được để trống")
	@Min(value = 1, message = "ID sản phẩm không hợp lệ")
	private Long productId;

	@NotNull(message = "Số lượng không được để trống")
	@Min(value = 1, message = "Số lượng phải lớn hơn hoặc bằng 1")
	private Integer quantity = 1;
}