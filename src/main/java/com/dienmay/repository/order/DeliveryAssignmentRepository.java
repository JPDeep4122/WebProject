package com.dienmay.repository.order;

import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.DeliveryStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryAssignmentRepository extends JpaRepository<DeliveryAssignment, Long> {

    Optional<DeliveryAssignment> findByOrderId(Long orderId);

    Page<DeliveryAssignment> findByShipperId(Long shipperId, Pageable pageable);

    List<DeliveryAssignment> findByShipperIdAndStatus(Long shipperId, DeliveryStatus status);
}
