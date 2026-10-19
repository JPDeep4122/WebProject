package com.dienmay.repository.order;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.math.BigDecimal;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

	Optional<Order> findByOrderCode(String orderCode);

	Page<Order> findByUserId(Long userId, Pageable pageable);

	@EntityGraph(attributePaths = {"user", "branch"})
	Page<Order> findByBranchId(Long branchId, Pageable pageable);

	@EntityGraph(attributePaths = {"user", "branch"})
	Page<Order> findByBranchIdAndStatus(Long branchId, OrderStatus status, Pageable pageable);

	@EntityGraph(attributePaths = {"user", "branch"})
	Page<Order> findByStatus(OrderStatus status, Pageable pageable);

	@Override
	@EntityGraph(attributePaths = {"user", "branch"})
	Page<Order> findAll(Pageable pageable);

	List<Order> findByStatus(OrderStatus status);

	List<Order> findByUserIdOrderByCreatedAtDesc(Long userId);

	List<Order> findByUserIdAndStatusOrderByCreatedAtDesc(Long userId, OrderStatus status);

	Optional<Order> findByOrderCodeAndRecipientPhone(String orderCode, String recipientPhone);

	@Query("select coalesce(sum(o.finalAmount), 0) from Order o where o.payment.paymentStatus = com.dienmay.entity.payment.PaymentStatus.SUCCESS and o.status <> com.dienmay.entity.order.OrderStatus.CANCELLED")
	BigDecimal sumSuccessfulRevenue();

	@Query("select coalesce(sum(o.finalAmount), 0) from Order o where o.branch.id = :branchId and o.payment.paymentStatus = com.dienmay.entity.payment.PaymentStatus.SUCCESS and o.status <> com.dienmay.entity.order.OrderStatus.CANCELLED")
	BigDecimal sumSuccessfulRevenueByBranch(@Param("branchId") Long branchId);
}
