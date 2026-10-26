package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
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
import com.dienmay.entity.order.DeliveryStatus;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.repository.order.DeliveryAssignmentRepository;
import com.dienmay.service.order.DeliveryAssignmentService;

import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
@Import(DeliveryAssignmentService.class)
class DeliveryAssignmentServiceTests {
    @Autowired DeliveryAssignmentService service;
    @Autowired DeliveryAssignmentRepository assignments;
    @Autowired EntityManager em;

    Branch branch;
    Branch otherBranch;
    User staff;
    User shipper;
    Role shipperRole;
    Long orderId;

    @BeforeEach
    void seed() {
        branch = Branch.builder().name("Main " + UUID.randomUUID()).address("Main").build();
        otherBranch = Branch.builder().name("Other " + UUID.randomUUID()).address("Other").build();
        em.persist(branch);
        em.persist(otherBranch);

        var staffRole = Role.builder().name("ROLE_STAFF").build();
        shipperRole = Role.builder().name("ROLE_SHIPPER").build();
        em.persist(staffRole);
        em.persist(shipperRole);

        staff = user("staff", branch, staffRole, true);
        shipper = user("shipper", branch, shipperRole, true);
        var order = Order.builder().orderCode(UUID.randomUUID().toString())
                .user(staff).branch(branch).status(OrderStatus.PROCESSING)
                .totalAmount(BigDecimal.TEN).finalAmount(BigDecimal.TEN)
                .recipientName("Customer").recipientPhone("0123456789")
                .shippingAddress("Test address").build();
        em.persist(order);
        orderId = order.getId();
        em.flush();
    }

    @Test
    void assignsAndReassignsShipperWithoutCreatingDuplicate() {
        service.assign(orderId, shipper.getId(), staff.getEmail());
        var replacement = user("replacement", branch, shipperRole, true);

        service.assign(orderId, replacement.getId(), staff.getEmail());
        em.flush();
        em.clear();

        var assignment = assignments.findByOrderId(orderId).orElseThrow();
        assertEquals(1, assignments.count());
        assertEquals(replacement.getId(), assignment.getShipper().getId());
        assertEquals(DeliveryStatus.ASSIGNED, assignment.getStatus());
        assertNotNull(assignment.getAssignedAt());
    }

    @Test
    void rejectsShipperFromAnotherBranch() {
        var otherShipper = user("other-shipper", otherBranch, shipperRole, true);
        assertThrows(IllegalArgumentException.class,
                () -> service.assign(orderId, otherShipper.getId(), staff.getEmail()));
        assertEquals(0, assignments.count());
    }

    @Test
    void rejectsInactiveAndNonShipperAccounts() {
        var inactive = user("inactive", branch, shipperRole, false);
        var customerRole = Role.builder().name("ROLE_CUSTOMER").build();
        em.persist(customerRole);
        var customer = user("customer", branch, customerRole, true);

        assertThrows(IllegalArgumentException.class,
                () -> service.assign(orderId, inactive.getId(), staff.getEmail()));
        assertThrows(IllegalArgumentException.class,
                () -> service.assign(orderId, customer.getId(), staff.getEmail()));
        assertEquals(0, assignments.count());
    }

    @Test
    void onlyProcessingOrdersCanBeAssigned() {
        em.find(Order.class, orderId).setStatus(OrderStatus.CONFIRMED);
        em.flush();
        assertThrows(IllegalArgumentException.class,
                () -> service.assign(orderId, shipper.getId(), staff.getEmail()));
        assertEquals(0, assignments.count());
    }

    @Test
    void staffCannotAssignOrderFromAnotherBranch() {
        staff.setBranch(otherBranch);
        em.flush();
        assertThrows(AccessDeniedException.class,
                () -> service.assign(orderId, shipper.getId(), staff.getEmail()));
        assertEquals(0, assignments.count());
    }

    @Test
    void adminCanAssignAnOrderWithoutBelongingToItsBranch() {
        var adminRole = Role.builder().name("ROLE_ADMIN").build();
        em.persist(adminRole);
        var admin = user("admin", null, adminRole, true);

        service.assign(orderId, shipper.getId(), admin.getEmail());

        assertEquals(shipper.getId(), assignments.findByOrderId(orderId)
                .orElseThrow().getShipper().getId());
    }

    private User user(String prefix, Branch userBranch, Role role, boolean active) {
        var user = User.builder().email(prefix + "-" + UUID.randomUUID() + "@example.test")
                .password("test").fullName(prefix).active(active)
                .branch(userBranch).roles(Set.of(role)).build();
        em.persist(user);
        return user;
    }
}
