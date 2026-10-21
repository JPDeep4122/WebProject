package com.dienmay.entity.payment;

/**
 * Trạng thái thanh toán của đơn hàng
 */
public enum PaymentStatus {
    PENDING,   // Chờ thanh toán
    SUCCESS,   // Thanh toán thành công
    FAILED,    // Thanh toán thất bại
    REFUNDED   // Đã hoàn tiền
}
