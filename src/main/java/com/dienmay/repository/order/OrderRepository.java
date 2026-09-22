package com.dienmay.repository.order;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

	Optional<Order> findByOrderCode(String orderCode);

	Page<Order> findByUserId(Long userId, Pageable pageable);

	Page<Order> findByBranchId(Long branchId, Pageable pageable);

	Page<Order> findByBranchIdAndStatus(Long branchId, OrderStatus status, Pageable pageable);

	List<Order> findByStatus(OrderStatus status);

	List<Order> findByUserIdOrderByCreatedAtDesc(Long userId);

	List<Order> findByUserIdAndStatusOrderByCreatedAtDesc(Long userId, OrderStatus status);

	Optional<Order> findByOrderCodeAndRecipientPhone(String orderCode, String recipientPhone);
}
