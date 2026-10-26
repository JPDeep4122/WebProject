package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.math.BigDecimal;
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
import com.dienmay.repository.order.DeliveryAssignmentRepository;
import com.dienmay.service.order.DeliveryStatusService;
import com.dienmay.service.order.OrderStateMachine;

import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
@Import({DeliveryStatusService.class, OrderStateMachine.class})
class DeliveryStatusServiceTests {
    @Autowired DeliveryStatusService service;
    @Autowired DeliveryAssignmentRepository assignments;
    @Autowired EntityManager em;

    User shipper;
    Role shipperRole;
    Long assignmentId;

    @BeforeEach
    void seed() {
        var branch = Branch.builder().name("Branch " + UUID.randomUUID()).address("Pickup").build();
        em.persist(branch);
        shipperRole = Role.builder().name("ROLE_SHIPPER").build();
        var customerRole = Role.builder().name("ROLE_CUSTOMER").build();
        em.persist(shipperRole);
        em.persist(customerRole);
        shipper = user("shipper", branch, shipperRole, true);
        var customer = user("customer", branch, customerRole, true);
        var order = Order.builder().orderCode(UUID.randomUUID().toString())
                .user(customer).branch(branch).status(OrderStatus.PROCESSING)
                .totalAmount(BigDecimal.TEN).finalAmount(BigDecimal.TEN)
                .recipientName("Recipient").recipientPhone("0123456789")
                .shippingAddress("Delivery address").build();
        em.persist(order);
        var assignment = DeliveryAssignment.builder().order(order).shipper(shipper)
                .status(DeliveryStatus.ASSIGNED).build();
        em.persist(assignment);
        order.setDeliveryAssignment(assignment);
        em.flush();
        assignmentId = assignment.getId();
    }

    @Test
    void startsDeliveryAndMovesOrderToShipping() {
        service.update(assignmentId, DeliveryStatus.DELIVERING, null, shipper.getEmail());
        em.flush();

        var assignment = assignments.findById(assignmentId).orElseThrow();
        assertEquals(DeliveryStatus.DELIVERING, assignment.getStatus());
        assertNotNull(assignment.getPickedUpAt());
        assertEquals(OrderStatus.SHIPPING, assignment.getOrder().getStatus());
    }

    @Test
    void completesDeliveryAndMovesOrderToDelivered() {
        service.update(assignmentId, DeliveryStatus.DELIVERING, null, shipper.getEmail());
        service.update(assignmentId, DeliveryStatus.DELIVERED_SUCCESS, null, shipper.getEmail());
        em.flush();

        var assignment = assignments.findById(assignmentId).orElseThrow();
        assertEquals(DeliveryStatus.DELIVERED_SUCCESS, assignment.getStatus());
        assertNotNull(assignment.getCompletedAt());
        assertNull(assignment.getFailureReason());
        assertEquals(OrderStatus.DELIVERED, assignment.getOrder().getStatus());
    }

    @Test
    void recordsFailureReasonAndAllowsRetry() {
        service.update(assignmentId, DeliveryStatus.DELIVERING, null, shipper.getEmail());
        service.update(assignmentId, DeliveryStatus.DELIVERED_FAILED,
                "Khách không nghe máy", shipper.getEmail());
        em.flush();

        var failed = assignments.findById(assignmentId).orElseThrow();
        assertEquals(DeliveryStatus.DELIVERED_FAILED, failed.getStatus());
        assertEquals("Khách không nghe máy", failed.getFailureReason());
        assertNotNull(failed.getCompletedAt());
        assertEquals(OrderStatus.SHIPPING, failed.getOrder().getStatus());

        service.update(assignmentId, DeliveryStatus.DELIVERING, null, shipper.getEmail());
        em.flush();
        assertEquals(DeliveryStatus.DELIVERING, failed.getStatus());
        assertNull(failed.getFailureReason());
        assertNull(failed.getCompletedAt());
    }

    @Test
    void rejectsSuccessBeforeDeliveryStarts() {
        assertThrows(IllegalArgumentException.class, () -> service.update(
                assignmentId, DeliveryStatus.DELIVERED_SUCCESS, null, shipper.getEmail()));
        assertEquals(DeliveryStatus.ASSIGNED,
                assignments.findById(assignmentId).orElseThrow().getStatus());
    }

    @Test
    void requiresFailureReason() {
        service.update(assignmentId, DeliveryStatus.DELIVERING, null, shipper.getEmail());
        assertThrows(IllegalArgumentException.class, () -> service.update(
                assignmentId, DeliveryStatus.DELIVERED_FAILED, "  ", shipper.getEmail()));
        assertEquals(DeliveryStatus.DELIVERING,
                assignments.findById(assignmentId).orElseThrow().getStatus());
    }

    @Test
    void shipperCannotUpdateAnotherShippersAssignment() {
        var other = user("other", shipper.getBranch(), shipperRole, true);
        assertThrows(AccessDeniedException.class, () -> service.update(
                assignmentId, DeliveryStatus.DELIVERING, null, other.getEmail()));
        assertEquals(DeliveryStatus.ASSIGNED,
                assignments.findById(assignmentId).orElseThrow().getStatus());
    }

    @Test
    void inactiveShipperCannotUpdateDelivery() {
        shipper.setActive(false);
        em.flush();
        assertThrows(AccessDeniedException.class, () -> service.update(
                assignmentId, DeliveryStatus.DELIVERING, null, shipper.getEmail()));
    }

    private User user(String prefix, Branch branch, Role role, boolean active) {
        var user = User.builder().email(prefix + "-" + UUID.randomUUID() + "@example.test")
                .password("test").fullName(prefix).active(active).branch(branch)
                .roles(Set.of(role)).build();
        em.persist(user);
        return user;
    }
}
