package com.dienmay.service.checkout;

import com.dienmay.dto.checkout.ShippingQuoteResponse;

public interface ShippingService {
    ShippingQuoteResponse quote(String shippingAddress, String province);
}
