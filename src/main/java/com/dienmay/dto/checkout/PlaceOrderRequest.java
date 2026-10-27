package com.dienmay.dto.checkout;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import jakarta.validation.constraints.Pattern;

@Data
public class PlaceOrderRequest {
	@NotBlank(message = "Vui lòng nhập tên người nhận")
	@Size(max = 100, message = "Tên người nhận tối đa 100 ký tự")
	private String recipientName;

    @jakarta.validation.constraints.Email(message = "Email người nhận không hợp lệ")
    @Size(max = 100, message = "Email người nhận tối đa 100 ký tự")
    private String recipientEmail;

    @NotBlank(message = "Vui lòng nhập địa chỉ nhận hàng")
    private String shippingAddress;

    @NotBlank(message = "Vui lòng chọn tỉnh/thành phố nhận hàng")
    private String province;

    private String note;

    @NotBlank(message = "Vui lòng chọn phương thức thanh toán")
    @Pattern(
        regexp = "COD|VNPAY",
        message = "Phương thức thanh toán chưa được hỗ trợ"
    )
    private String paymentMethod = "COD";

    private String voucherCode;
    
	@NotBlank(message = "Vui lòng nhập số điện thoại")
	@Pattern(regexp = "^(0|\\+84)[0-9]{9}$", message = "Số điện thoại không hợp lệ (phải gồm 10 chữ số bắt đầu bằng 0)")
	private String recipientPhone;
}
