package com.dienmay.entity.payment;

/**
 * Phương thức thanh toán
 */
public enum PaymentMethod {
    COD,           // Thanh toán khi nhận hàng (Cash On Delivery)
    VNPAY,         // Thanh toán qua cổng VNPAY
    MOMO,          // Thanh toán qua ví MoMo
    BANK_TRANSFER  // Chuyển khoản ngân hàng trực tiếp
}
