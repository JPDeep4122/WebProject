package com.dienmay.entity.order;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum DeliveryFailureCode {
    CUSTOMER_UNREACHABLE("Không liên hệ được khách", false),
    CUSTOMER_ABSENT("Khách không có tại địa chỉ", false),
    CUSTOMER_RESCHEDULED("Khách yêu cầu giao lại", false),
    CUSTOMER_REFUSED("Khách từ chối nhận hàng", false),
    WRONG_OR_INCOMPLETE_ADDRESS("Địa chỉ sai hoặc thiếu", false),
    INSUFFICIENT_COD_PAYMENT("Khách không thanh toán đủ COD", false),
    GOODS_DAMAGED("Hàng hư hỏng khi vận chuyển", true),
    WRONG_OR_MISSING_GOODS("Sai hoặc thiếu hàng", true),
    TRANSPORT_DISRUPTION("Sự cố xe, đường hoặc thời tiết", false),
    OTHER("Lý do khác", false);

    private final String label;
    private final boolean requiresStaffReview;
}