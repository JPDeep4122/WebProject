package com.dienmay.entity.order;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum DeliveryStatus {
    ASSIGNED("Chờ nhận hàng"),
    PICKED_UP("Đã lấy hàng"),
    DELIVERING("Đang giao"),
    DELIVERED_SUCCESS("Giao thành công"),
    DELIVERED_FAILED("Giao thất bại"),
    REJECTED("Đã từ chối");

    private final String label;
}