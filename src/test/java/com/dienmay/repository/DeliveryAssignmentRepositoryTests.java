package com.dienmay.repository;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.order.DeliveryAssignment;
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.order.DeliveryAssignmentRepository;

import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
class DeliveryAssignmentRepositoryTests {
    @Autowired DeliveryAssignmentRepository assignments;
    @Autowired EntityManager em;

    User firstShipper;
    User secondShipper;

    @BeforeEach
    void seed() {
        var branch = Branch.builder().name("Branch " + UUID.randomUUID()).address("Pickup address").build();
        em.persist(branch);
        var customerRole = Role.builder().name("ROLE_CUSTOMER").build();
        var shipperRole = Role.builder().name("ROLE_SHIPPER").build();
        em.persist(customerRole);
        em.persist(shipperRole);
        var customer = user("customer", branch, customerRole);
        firstShipper = user("first", branch, shipperRole);
        secondShipper = user("second", branch, shipperRole);

        createAssignment(customer, firstShipper, branch, DeliveryStatus.ASSIGNED,
                LocalDateTime.of(2026, 10, 20, 8, 0));
        createAssignment(customer, firstShipper, branch, DeliveryStatus.DELIVERING,
                LocalDateTime.of(2026, 10, 20, 9, 0));
        createAssignment(customer, secondShipper, branch, DeliveryStatus.ASSIGNED,
                LocalDateTime.of(2026, 10, 20, 10, 0));
        em.flush();
        em.clear();
    }

    @Test
    void returnsOnlyAssignmentsOwnedBySignedInShipper() {
        var page = assignments.findAssignedTo(firstShipper.getEmail().toUpperCase(),
                PageRequest.of(0, 20, Sort.by(Sort.Direction.DESC, "assignedAt")));

        assertEquals(2, page.getTotalElements());
        assertEquals(DeliveryStatus.DELIVERING, page.getContent().get(0).getStatus());
        assertEquals(firstShipper.getId(), page.getContent().get(0).getShipper().getId());
        assertEquals("Pickup address", page.getContent().get(0).getOrder().getBranch().getAddress());
    }

    @Test
    void filtersAssignmentsByDeliveryStatus() {
        var page = assignments.findAssignedToByStatus(firstShipper.getEmail(),
                DeliveryStatus.ASSIGNED, PageRequest.of(0, 10));

        assertEquals(1, page.getTotalElements());
        assertEquals(DeliveryStatus.ASSIGNED, page.getContent().get(0).getStatus());
    }

    private User user(String prefix, Branch branch, Role role) {
        var user = User.builder().email(prefix + "-" + UUID.randomUUID() + "@example.test")
                .password("test").fullName(prefix).active(true).branch(branch)
                .roles(Set.of(role)).build();
        em.persist(user);
        return user;
    }

    private void createAssignment(User customer, User shipper, Branch branch,
            DeliveryStatus status, LocalDateTime assignedAt) {
        var order = Order.builder().orderCode(UUID.randomUUID().toString())
                .user(customer).branch(branch).status(OrderStatus.PROCESSING)
                .totalAmount(BigDecimal.TEN).finalAmount(BigDecimal.TEN)
                .recipientName("Recipient").recipientPhone("0123456789")
                .shippingAddress("Delivery address").build();
        em.persist(order);
        var assignment = DeliveryAssignment.builder().order(order).shipper(shipper)
                .status(status).assignedAt(assignedAt).build();
        em.persist(assignment);
        order.setDeliveryAssignment(assignment);
    }
}
