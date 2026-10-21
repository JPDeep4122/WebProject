package com.dienmay.repository.order;

import java.util.Collection;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.dienmay.entity.order.OrderReturnRequest;
import com.dienmay.entity.order.ReturnRequestStatus;

public interface OrderReturnRequestRepository extends JpaRepository<OrderReturnRequest, Long> {
    boolean existsByOrderIdAndStatusIn(Long orderId, Collection<ReturnRequestStatus> statuses);

    @EntityGraph(attributePaths = {"order", "requestedBy", "reviewedBy", "completedBy"})
    Optional<OrderReturnRequest> findFirstByOrderIdOrderByRequestedAtDesc(Long orderId);

    @Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @EntityGraph(attributePaths = {"order", "order.branch", "order.user", "requestedBy"})
    @Query("select request from OrderReturnRequest request where request.id = :id")
    Optional<OrderReturnRequest> findByIdForUpdate(@Param("id") Long id);

    @EntityGraph(attributePaths = {"order", "order.branch", "order.user", "order.payment", "requestedBy", "reviewedBy", "completedBy"})
    @Query("select request from OrderReturnRequest request "
            + "where (:branchId is null or request.order.branch.id = :branchId) "
            + "and (:status is null or request.status = :status)")
    Page<OrderReturnRequest> search(@Param("branchId") Long branchId,
            @Param("status") ReturnRequestStatus status, Pageable pageable);
}
