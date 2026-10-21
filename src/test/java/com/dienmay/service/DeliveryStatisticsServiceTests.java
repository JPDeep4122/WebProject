package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.access.AccessDeniedException;

import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.service.order.DeliveryStatisticsPeriod;
import com.dienmay.service.order.DeliveryStatisticsService;

import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
@Import(DeliveryStatisticsService.class)
class DeliveryStatisticsServiceTests {
    @Autowired DeliveryStatisticsService service;
    @Autowired EntityManager em;

    User shipper;
    User otherShipper;
    User customer;
    Branch branch;

    @BeforeEach
    void seed() {
        branch = Branch.builder().name("Branch " + UUID.randomUUID()).address("Pickup").build();
        em.persist(branch);
        var customerRole = Role.builder().name("ROLE_CUSTOMER").build();
        var shipperRole = Role.builder().name("ROLE_SHIPPER").build();
        em.persist(customerRole);
        em.persist(shipperRole);
        customer = user("customer", customerRole);
        shipper = user("shipper", shipperRole);
        otherShipper = user("other", shipperRole);

        assignment(shipper, DeliveryStatus.DELIVERED_SUCCESS,
                LocalDateTime.of(2026, 10, 19, 9, 0), "100000");
        assignment(shipper, DeliveryStatus.DELIVERED_SUCCESS,
                LocalDateTime.of(2026, 10, 20, 10, 0), "200000");
        assignment(shipper, DeliveryStatus.DELIVERED_SUCCESS,
                LocalDateTime.of(2026, 10, 20, 12, 0), "300000");
        assignment(shipper, DeliveryStatus.DELIVERED_FAILED,
                LocalDateTime.of(2026, 10, 20, 13, 0), "900000");
        assignment(otherShipper, DeliveryStatus.DELIVERED_SUCCESS,
                LocalDateTime.of(2026, 10, 20, 14, 0), "800000");
        em.flush();
        em.clear();
    }

    @Test
    void summarizesSuccessfulDeliveriesForSelectedDayAndOwner() {
        var report = service.summarize(shipper.getEmail(), DeliveryStatisticsPeriod.DAY,
                LocalDate.of(2026, 10, 20));

        assertEquals(2, report.getDeliveredOrders());
        assertEquals(0, new BigDecimal("500000").compareTo(report.getDeliveredValue()));
        assertEquals(0, new BigDecimal("250000").compareTo(report.getAverageOrderValue()));
        assertEquals(1, report.getPoints().size());
        assertEquals(2, report.getPoints().get(0).getOrderCount());
        assertEquals(100, report.getPoints().get(0).getPercentage());
    }

    @Test
    void buildsSevenDailyPointsForWeek() {
        var report = service.summarize(shipper.getEmail(), DeliveryStatisticsPeriod.WEEK,
                LocalDate.of(2026, 10, 20));

        assertEquals(LocalDate.of(2026, 10, 19), report.getStartDate());
        assertEquals(LocalDate.of(2026, 10, 25), report.getEndDate());
        assertEquals(7, report.getPoints().size());
        assertEquals(3, report.getDeliveredOrders());
        assertEquals(1, report.getPoints().get(0).getOrderCount());
        assertEquals(2, report.getPoints().get(1).getOrderCount());
    }

    @Test
    void buildsEveryDayOfSelectedMonth() {
        var report = service.summarize(shipper.getEmail(), DeliveryStatisticsPeriod.MONTH,
                LocalDate.of(2026, 10, 20));

        assertEquals(31, report.getPoints().size());
        assertEquals(LocalDate.of(2026, 10, 1), report.getStartDate());
        assertEquals(LocalDate.of(2026, 10, 31), report.getEndDate());
        assertEquals(3, report.getDeliveredOrders());
    }

    @Test
    void inactiveShipperCannotViewStatistics() {
        var managed = em.find(User.class, shipper.getId());
        managed.setActive(false);
        em.flush();

        assertThrows(AccessDeniedException.class, () -> service.summarize(
                shipper.getEmail(), DeliveryStatisticsPeriod.DAY, LocalDate.of(2026, 10, 20)));
    }

    private User user(String prefix, Role role) {
        var user = User.builder().email(prefix + "-" + UUID.randomUUID() + "@example.test")
                .password("test").fullName(prefix).active(true).branch(branch)
                .roles(Set.of(role)).build();
        em.persist(user);
        return user;
    }

    private void assignment(User assignedShipper, DeliveryStatus status,
            LocalDateTime completedAt, String amount) {
        var order = Order.builder().orderCode(UUID.randomUUID().toString())
                .user(customer).branch(branch).status(OrderStatus.DELIVERED)
                .totalAmount(new BigDecimal(amount)).finalAmount(new BigDecimal(amount))
                .recipientName("Recipient").recipientPhone("0123456789")
                .shippingAddress("Delivery address").build();
        em.persist(order);
        var assignment = DeliveryAssignment.builder().order(order).shipper(assignedShipper)
                .status(status).assignedAt(completedAt.minusDays(1)).completedAt(completedAt).build();
        em.persist(assignment);
        order.setDeliveryAssignment(assignment);
    }
}
