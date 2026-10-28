package com.dienmay.service.order;

import java.math.BigDecimal;

public record OrderRefundConfirmedEvent(
        String recipientEmail,
        String orderCode,
        BigDecimal amount,
        String branchName,
        String branchAddress,
        String refundMethod) {
}
