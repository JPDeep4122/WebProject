package com.dienmay.service.promotion;

import java.time.Instant;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.service.order.OrderStateMachine;

import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VoucherExpiryService {

    private final OrderRepository orders;
    private final PaymentRepository payments;
    private final OrderStateMachine stateMachine;
    private final TransactionTemplate transactions;
    private final com.dienmay.repository.branch.BranchInventoryRepository inventories;

    @PersistenceContext
    private EntityManager entityManager;

    public int expireBatch() {
        var ids = orders.findExpiredPendingOrderIds(
                OrderStatus.PENDING,
                PaymentMethod.VNPAY,
                PaymentStatus.PENDING,
                Instant.now(),
                PageRequest.of(0, 50));

        int expired = 0;

        for (Long id : ids) {
            Boolean changed = transactions.execute(status -> {
                var order = orders.findForUpdate(id).orElse(null);

                if (order == null) {
                    return false;
                }

                entityManager.refresh(
                        order, LockModeType.PESSIMISTIC_WRITE);

                var payment = payments.findByOrderIdForUpdate(id)
                        .orElse(null);

                if (payment == null) {
                    return false;
                }

                entityManager.refresh(
                        payment, LockModeType.PESSIMISTIC_WRITE);

                if (order.getStatus() != OrderStatus.PENDING
                        || payment.getPaymentMethod()
                            != PaymentMethod.VNPAY
                        || payment.getPaymentStatus()
                            != PaymentStatus.PENDING
                        || payment.getPaymentExpiresAt() == null
                        || payment.getPaymentExpiresAt()
                            .isAfter(Instant.now())) {
                    return false;
                }

                order.setPayment(payment);

                if (order.getBranch() != null && order.getOrderItems() != null) {
                    var quantities = new java.util.TreeMap<Long, Integer>();
                    for (var item : order.getOrderItems()) {
                        if (item.getProduct() != null && item.getQuantity() != null && item.getQuantity() > 0) {
                            quantities.merge(item.getProduct().getId(), item.getQuantity(), Math::addExact);
                        }
                    }
                    for (var entry : quantities.entrySet()) {
                        inventories.findForUpdate(order.getBranch().getId(), entry.getKey()).ifPresent(inv -> {
                            int newReserved = Math.max(0, inv.getReservedQuantity() - entry.getValue());
                            inv.setReservedQuantity(newReserved);
                            inv.setAvailableQuantity(inv.getStockQuantity() - newReserved);
                        });
                    }
                }
                
                stateMachine.transition(
                        order, OrderStatus.CANCELLED);

                return true;
            });

            if (Boolean.TRUE.equals(changed)) {
                expired++;
            }
        }

        return expired;
    }
}