package com.dienmay.service.order;

import java.time.LocalDateTime;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;
import org.springframework.stereotype.Component;

import com.dienmay.dto.order.OrderStatusUpdate;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.service.promotion.VoucherService;

@Component
public class OrderStateMachine implements ApplicationEventPublisherAware {
	private final Map<OrderStatus, Set<OrderStatus>> allowedTransitions = new EnumMap<>(OrderStatus.class);
	private ApplicationEventPublisher eventPublisher;
	private final VoucherService voucherService;

	public OrderStateMachine(VoucherService voucherService) {
		this.voucherService = voucherService;

		allowedTransitions.put(OrderStatus.PENDING, EnumSet.of(OrderStatus.CONFIRMED, OrderStatus.CANCELLED));
		allowedTransitions.put(OrderStatus.CONFIRMED, EnumSet.of(OrderStatus.PROCESSING, OrderStatus.CANCELLED));
		allowedTransitions.put(OrderStatus.PROCESSING, EnumSet.of(OrderStatus.SHIPPING, OrderStatus.CANCELLED));
		allowedTransitions.put(OrderStatus.SHIPPING, EnumSet.of(OrderStatus.DELIVERED));
		allowedTransitions.put(OrderStatus.DELIVERED, EnumSet.of(OrderStatus.RETURN_REQUESTED));
		allowedTransitions.put(OrderStatus.RETURN_REQUESTED, EnumSet.of(OrderStatus.RETURNED));
	}

	public boolean canTransition(OrderStatus current, OrderStatus target) {
		return current != null && target != null && allowedTransitions.getOrDefault(current, Set.of()).contains(target);
	}

	public void transition(Order order, OrderStatus target) {
		if (order == null) {
			throw new IllegalArgumentException("Đơn hàng không hợp lệ.");
		}
		OrderStatus current = order.getStatus();
		if (!canTransition(current, target)) {
			throw new IllegalArgumentException(
					"Không thể chuyển trạng thái đơn từ " + current + " sang " + target + ".");
		}
		requirePaymentBeforeDelivery(order, target);

		order.setStatus(target);

		if (target == OrderStatus.CANCELLED) {
			voucherService.release(order.getId(), "ORDER_CANCELLED");
		}

		publishStatusChanged(order, current, target);
	}

	public void confirmCodPaymentCollected(Order order, LocalDateTime paidAt) {
		if (order == null || order.getPayment() == null) {
			throw new IllegalArgumentException("Đơn hàng chưa có thông tin thanh toán.");
		}
		Payment payment = order.getPayment();
		if (payment.getPaymentMethod() == PaymentMethod.COD && payment.getPaymentStatus() == PaymentStatus.PENDING) {
			payment.setPaymentStatus(PaymentStatus.SUCCESS);
			payment.setPaymentTime(paidAt != null ? paidAt : LocalDateTime.now());
		}
	}

	@Override
	public void setApplicationEventPublisher(ApplicationEventPublisher eventPublisher) {
		this.eventPublisher = eventPublisher;
	}

	private void publishStatusChanged(Order order, OrderStatus previousStatus, OrderStatus status) {
		if (eventPublisher == null || order.getOrderCode() == null) {
			return;
		}
		var update = new OrderStatusUpdate(order.getOrderCode(), previousStatus, status, LocalDateTime.now());
		Long branchId = order.getBranch() == null ? null : order.getBranch().getId();
		String accountEmail = order.getUser() == null ? null : order.getUser().getEmail();
		eventPublisher.publishEvent(new OrderStatusChangedEvent(accountEmail, branchId, update));
	}

	void requirePaymentBeforeDelivery(Order order, OrderStatus target) {

		if (target != OrderStatus.CONFIRMED && target != OrderStatus.PROCESSING && target != OrderStatus.SHIPPING
				&& target != OrderStatus.DELIVERED) {
			return;
		}

		Payment payment = order.getPayment();

		if (payment == null || payment.getPaymentMethod() == null || payment.getPaymentStatus() == null) {
			throw new IllegalArgumentException("Đơn hàng chưa có thông tin thanh toán hợp lệ.");
		}

		PaymentMethod method = payment.getPaymentMethod();
		PaymentStatus status = payment.getPaymentStatus();

		boolean allowed = switch (method) {
		case VNPAY -> status == PaymentStatus.SUCCESS;
		case COD -> status == PaymentStatus.PENDING || status == PaymentStatus.SUCCESS;
		default -> false;
		};

		if (!allowed) {
		    throw new IllegalArgumentException(
		            "Chưa thể xử lý đơn: phương thức hoặc trạng thái "
		                    + "thanh toán chưa hợp lệ.");
		}
	}
}