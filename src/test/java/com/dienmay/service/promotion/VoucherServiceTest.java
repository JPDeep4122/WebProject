package com.dienmay.service.promotion;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.verify;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import com.dienmay.entity.auth.User;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.promotion.Promotion;
import com.dienmay.entity.promotion.VoucherUsage;
import com.dienmay.repository.promotion.VoucherUsageRepository;

class VoucherServiceTest {

    @Test
    void recordsVoucherUseAndIncrementsUsedCountWhenOrderUsesVoucher() {
        VoucherUsageRepository usages = org.mockito.Mockito.mock(VoucherUsageRepository.class);
        ApplicationEventPublisher events = org.mockito.Mockito.mock(ApplicationEventPublisher.class);
        VoucherService service = new VoucherService(null, usages, null, events);
        Promotion promotion = Promotion.builder()
                .id(12L)
                .code("BLACKFRIDAY")
                .usedCount(4)
                .build();
        Order order = Order.builder().id(123L).orderCode("ORD-123").build();
        User user = User.builder().id(7L).email("customer@example.test").build();

        service.recordUsage(order,
                new VoucherService.Quote(promotion, new BigDecimal("100000")), user);

        assertEquals(5, promotion.getUsedCount());
        assertEquals("BLACKFRIDAY", order.getVoucherCode());
        ArgumentCaptor<VoucherUsage> usage = ArgumentCaptor.forClass(VoucherUsage.class);
        verify(usages).save(usage.capture());
        assertEquals(123L, usage.getValue().getOrder().getId());
        assertEquals(12L, usage.getValue().getPromotion().getId());
        assertEquals(7L, usage.getValue().getUser().getId());
        assertEquals(0, new BigDecimal("100000").compareTo(usage.getValue().getDiscountAmount()));
    }
}
