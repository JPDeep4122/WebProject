package com.dienmay.service.order;

import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;
import java.time.LocalDateTime;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;
import org.springframework.stereotype.Component;

import com.dienmay.dto.order.OrderStatusUpdate;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;

@Component
public class OrderStateMachine implements ApplicationEventPublisherAware {
    private final Map<OrderStatus, Set<OrderStatus>> allowedTransitions = new EnumMap<>(OrderStatus.class);
    private ApplicationEventPublisher eventPublisher;

    public OrderStateMachine() {
        allowedTransitions.put(OrderStatus.PENDING,
                EnumSet.of(OrderStatus.CONFIRMED, OrderStatus.CANCELLED));
        allowedTransitions.put(OrderStatus.CONFIRMED,
                EnumSet.of(OrderStatus.PROCESSING, OrderStatus.CANCELLED));
        allowedTransitions.put(OrderStatus.PROCESSING,
                EnumSet.of(OrderStatus.SHIPPING, OrderStatus.CANCELLED));
        allowedTransitions.put(OrderStatus.SHIPPING,
                EnumSet.of(OrderStatus.DELIVERED, OrderStatus.CANCELLED));
        allowedTransitions.put(OrderStatus.DELIVERED,
                EnumSet.of(OrderStatus.RETURN_REQUESTED));
        allowedTransitions.put(OrderStatus.RETURN_REQUESTED,
                EnumSet.of(OrderStatus.RETURNED));
    }

    public boolean canTransition(OrderStatus current, OrderStatus target) {
        return current != null && target != null
                && allowedTransitions.getOrDefault(current, Set.of()).contains(target);
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
        order.setStatus(target);
        publishStatusChanged(order, current, target);
    }

    @Override
    public void setApplicationEventPublisher(ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
    }

    private void publishStatusChanged(Order order, OrderStatus previousStatus, OrderStatus status) {
        if (eventPublisher == null || order.getUser() == null
                || order.getUser().getEmail() == null || order.getOrderCode() == null) {
            return;
        }
        var update = new OrderStatusUpdate(
                order.getOrderCode(), previousStatus, status, LocalDateTime.now());
        eventPublisher.publishEvent(new OrderStatusChangedEvent(order.getUser().getEmail(), update));
    }
}
