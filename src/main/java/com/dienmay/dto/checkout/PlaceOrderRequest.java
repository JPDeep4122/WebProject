package com.dienmay.dto.checkout;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class PlaceOrderRequest {
    @NotBlank(message = "Vui lòng nhập tên người nhận")
    private String recipientName;

    @NotBlank(message = "Vui lòng nhập số điện thoại")
    private String recipientPhone;

    private String recipientEmail;

    @NotBlank(message = "Vui lòng nhập địa chỉ nhận hàng")
    private String shippingAddress;

    @NotBlank(message = "Vui lòng chọn tỉnh/thành phố nhận hàng")
    private String province;

    private String note;

    // COD, VNPAY, MOMO
    private String paymentMethod = "COD";

    private String voucherCode;
}
