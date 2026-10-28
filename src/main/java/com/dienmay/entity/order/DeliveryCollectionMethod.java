package com.dienmay.entity.order;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum DeliveryCollectionMethod {
    PREPAID("Đã thanh toán trước (Không thu tiền)"),
    CASH("Thu tiền mặt (COD)"),
    BANK_TRANSFER("Khách chuyển khoản khi nhận hàng");

    private final String label;
}