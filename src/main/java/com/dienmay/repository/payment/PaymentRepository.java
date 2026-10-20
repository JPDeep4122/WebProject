package com.dienmay.repository.payment;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.payment.Payment;

import jakarta.persistence.LockModeType;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    Optional<Payment> findByOrderId(Long orderId);

    Optional<Payment> findByTransactionNo(String transactionNo);
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
        select p from Payment p
        where upper(replace(p.order.orderCode, '-', '')) = :reference
        """)
    Optional<Payment> findByReferenceForUpdate(
            @Param("reference") String reference);
}
