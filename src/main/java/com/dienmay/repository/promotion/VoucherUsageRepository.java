package com.dienmay.repository.promotion;

import java.util.Optional;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import com.dienmay.entity.promotion.VoucherUsage;

import jakarta.persistence.LockModeType;

public interface VoucherUsageRepository
        extends JpaRepository<VoucherUsage, Long> {

    @Query("""
        select count(u)
        from VoucherUsage u
        where u.promotion.id = :promotionId
          and u.user.id = :userId
          and u.releasedAt is null
        """)
    long countActiveUses(
            @Param("promotionId") Long promotionId,
            @Param("userId") Long userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
        select u
        from VoucherUsage u
        where u.order.id = :orderId
        """)
    Optional<VoucherUsage> findForRelease(
            @Param("orderId") Long orderId);
}