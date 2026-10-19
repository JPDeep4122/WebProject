package com.dienmay.service.order;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;

public interface OrderService {

    List<Order> getOrdersByUser(String userEmail, OrderStatus status);

    Order getOrderDetail(String orderCode, String userEmail);

    boolean cancelOrder(String orderCode, String userEmail, String cancelReason);

    Order trackOrder(String orderCode, String phone);

    Page<Order> getOrdersForBranch(Long branchId, OrderStatus status, Pageable pageable);
}
