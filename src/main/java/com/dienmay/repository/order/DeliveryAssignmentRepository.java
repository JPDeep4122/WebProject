package com.dienmay.repository.order;

import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.DeliveryStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface DeliveryAssignmentRepository extends JpaRepository<DeliveryAssignment, Long> {

    Optional<DeliveryAssignment> findByOrderId(Long orderId);

    @Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @Query("select assignment from DeliveryAssignment assignment where assignment.id = :id")
    Optional<DeliveryAssignment> findForUpdate(@Param("id") Long id);

    Page<DeliveryAssignment> findByShipperId(Long shipperId, Pageable pageable);

    List<DeliveryAssignment> findByShipperIdAndStatus(Long shipperId, DeliveryStatus status);

    @EntityGraph(attributePaths = {"order", "order.user", "order.branch", "order.payment"})
    @Query("select assignment from DeliveryAssignment assignment "
            + "where lower(assignment.shipper.email) = lower(:email)")
    Page<DeliveryAssignment> findAssignedTo(@Param("email") String email, Pageable pageable);

    @EntityGraph(attributePaths = {"order", "order.user", "order.branch", "order.payment"})
    @Query("select assignment from DeliveryAssignment assignment "
            + "where lower(assignment.shipper.email) = lower(:email) "
            + "and assignment.status = :status")
    Page<DeliveryAssignment> findAssignedToByStatus(@Param("email") String email,
            @Param("status") DeliveryStatus status, Pageable pageable);

    @EntityGraph(attributePaths = {"order"})
    @Query("select assignment from DeliveryAssignment assignment "
            + "where lower(assignment.shipper.email) = lower(:email) "
            + "and assignment.status = :status "
            + "and assignment.completedAt >= :from "
            + "and assignment.completedAt < :to "
            + "order by assignment.completedAt")
    List<DeliveryAssignment> findCompletedInPeriod(@Param("email") String email,
            @Param("status") DeliveryStatus status,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to);
    
    @EntityGraph(attributePaths = {
            "shipper",
            "order",
            "order.user",
            "order.branch",
            "order.payment",
            "order.orderItems",
            "order.orderItems.product"
    })
    @Query("select distinct a from DeliveryAssignment a where a.id = :id")
    Optional<DeliveryAssignment> findDetailedById(@Param("id") Long id);
}