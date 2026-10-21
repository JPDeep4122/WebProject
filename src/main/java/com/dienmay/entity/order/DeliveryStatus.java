package com.dienmay.entity.order;

/**
 * Trạng thái phân công & giao hàng của Shipper
 */
public enum DeliveryStatus {
    ASSIGNED,          // Đã phân công cho shipper
    PICKED_UP,         // Shipper đã lấy hàng từ chi nhánh
    DELIVERING,        // Đang trên đường giao tới khách
    DELIVERED_SUCCESS, // Giao hàng thành công
    DELIVERED_FAILED,  // Giao hàng thất bại (khách không nghe máy/hủy)
    REJECTED           // Shipper từ chối nhận đơn
}
