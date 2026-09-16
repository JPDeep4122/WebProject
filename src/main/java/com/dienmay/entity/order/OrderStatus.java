package com.dienmay.entity.order;

/**
 * Trạng thái của đơn hàng trong quy trình bán hàng & giao hàng
 */
public enum OrderStatus {
    PENDING,          // Đơn hàng mới tạo (chờ xác nhận)
    CONFIRMED,        // Đã xác nhận đơn hàng
    PROCESSING,       // Chi nhánh đang chuẩn bị hàng
    SHIPPING,         // Đã phân công shipper & đang giao hàng
    DELIVERED,        // Giao hàng thành công
    CANCELLED,        // Đã hủy đơn
    RETURN_REQUESTED, // Yêu cầu trả hàng / hoàn tiền
    RETURNED          // Đã trả hàng & hoàn tiền thành công
}
