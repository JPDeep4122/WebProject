package com.dienmay.dto.branch;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InventoryStockRequest {
    @NotNull(message = "Vui lòng nhập tồn thực tế mới.")
    @Min(value = 0, message = "Tồn thực tế không được âm.")
    private Integer newStock;

    @NotNull(message = "Vui lòng tải lại trang tồn kho trước khi lưu.")
    @Min(value = 0, message = "Số tồn trước khi sửa không hợp lệ.")
    private Integer expectedStock;

    @NotBlank(message = "Vui lòng nhập lý do cập nhật tồn kho.")
    @Size(max = 500, message = "Lý do không được vượt quá 500 ký tự.")
    private String reason;
}
