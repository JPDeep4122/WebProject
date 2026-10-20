package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.math.BigDecimal;
import java.util.Set;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;

import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.order.ReturnRequestStatus;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.order.OrderReturnRequestRepository;
import com.dienmay.service.order.OrderStateMachine;
import com.dienmay.service.order.ReturnRequestService;

import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
@Import({ReturnRequestService.class, OrderStateMachine.class})
class ReturnRequestServiceTests {
    @Autowired ReturnRequestService service;
    @Autowired OrderReturnRequestRepository requests;
    @Autowired OrderRepository orders;
    @Autowired EntityManager em;

    Branch firstBranch;
    Branch secondBranch;
    User customer;
    User otherCustomer;
    User firstStaff;
    User secondStaff;
    User admin;
    Order firstOrder;
    Order secondOrder;

    @BeforeEach
    void seed() {
        firstBranch = branch("First");
        secondBranch = branch("Second");
        var customerRole = role("ROLE_CUSTOMER");
        var staffRole = role("ROLE_STAFF");
        var adminRole = role("ROLE_ADMIN");
        customer = user("customer", firstBranch, customerRole);
        otherCustomer = user("other", secondBranch, customerRole);
        firstStaff = user("staff-one", firstBranch, staffRole);
        secondStaff = user("staff-two", secondBranch, staffRole);
        admin = user("admin", null, adminRole);
        firstOrder = order(customer, firstBranch, "500000");
        secondOrder = order(otherCustomer, secondBranch, "700000");
        em.flush();
        em.clear();
    }

    @Test
    void customerSubmitsPendingRequestWithoutChangingOrderState() {
        var request = service.submit(firstOrder.getOrderCode(),
                "Sản phẩm bị lỗi màn hình", customer.getEmail());
        em.flush();

        assertEquals(ReturnRequestStatus.PENDING, request.getStatus());
        assertEquals(0, new BigDecimal("500000").compareTo(request.getRequestedRefundAmount()));
        assertEquals(OrderStatus.DELIVERED, orders.findById(firstOrder.getId()).orElseThrow().getStatus());
    }

    @Test
    void customerCannotRequestReturnForAnotherUsersOrder() {
        assertThrows(AccessDeniedException.class, () -> service.submit(
                firstOrder.getOrderCode(), "Sản phẩm không hoạt động", otherCustomer.getEmail()));
        assertEquals(0, requests.count());
    }

    @Test
    void preventsDuplicateActiveRequest() {
        service.submit(firstOrder.getOrderCode(), "Sản phẩm bị lỗi màn hình", customer.getEmail());
        assertThrows(IllegalArgumentException.class, () -> service.submit(
                firstOrder.getOrderCode(), "Tôi vẫn muốn trả sản phẩm", customer.getEmail()));
        assertEquals(1, requests.count());
    }

    @Test
    void staffOnlyListsRequestsFromAssignedBranch() {
        service.submit(firstOrder.getOrderCode(), "Sản phẩm bị lỗi màn hình", customer.getEmail());
        service.submit(secondOrder.getOrderCode(), "Sản phẩm bị lỗi nguồn điện", otherCustomer.getEmail());

        var overview = service.loadForManagement(firstStaff.getEmail(), secondBranch.getId(), null,
                PageRequest.of(0, 20));
        assertEquals(firstBranch.getId(), overview.getSelectedBranchId());
        assertEquals(1, overview.getRequests().getTotalElements());
        assertEquals(firstOrder.getId(), overview.getRequests().getContent().get(0).getOrder().getId());
    }

    @Test
    void approvalMovesOrderToReturnRequested() {
        var request = service.submit(firstOrder.getOrderCode(),
                "Sản phẩm bị lỗi màn hình", customer.getEmail());
        service.review(request.getId(), ReturnRequestStatus.APPROVED,
                "Đủ điều kiện tiếp nhận", firstStaff.getEmail());
        em.flush();
        em.clear();

        var saved = requests.findById(request.getId()).orElseThrow();
        assertEquals(ReturnRequestStatus.APPROVED, saved.getStatus());
        assertEquals(OrderStatus.RETURN_REQUESTED,
                orders.findById(firstOrder.getId()).orElseThrow().getStatus());
        assertEquals(firstStaff.getId(), saved.getReviewedBy().getId());
    }

    @Test
    void rejectionRequiresNoteAndKeepsDeliveredState() {
        var request = service.submit(firstOrder.getOrderCode(),
                "Sản phẩm bị lỗi màn hình", customer.getEmail());
        assertThrows(IllegalArgumentException.class, () -> service.review(
                request.getId(), ReturnRequestStatus.REJECTED, " ", firstStaff.getEmail()));

        service.review(request.getId(), ReturnRequestStatus.REJECTED,
                "Không đủ bằng chứng lỗi", firstStaff.getEmail());
        em.flush();
        assertEquals(ReturnRequestStatus.REJECTED,
                requests.findById(request.getId()).orElseThrow().getStatus());
        assertEquals(OrderStatus.DELIVERED,
                orders.findById(firstOrder.getId()).orElseThrow().getStatus());
    }

    @Test
    void staffCannotReviewAnotherBranchButAdminCan() {
        var request = service.submit(secondOrder.getOrderCode(),
                "Sản phẩm bị lỗi nguồn điện", otherCustomer.getEmail());
        assertThrows(AccessDeniedException.class, () -> service.review(
                request.getId(), ReturnRequestStatus.APPROVED, null, firstStaff.getEmail()));

        service.review(request.getId(), ReturnRequestStatus.APPROVED, null, admin.getEmail());
        assertEquals(ReturnRequestStatus.APPROVED,
                requests.findById(request.getId()).orElseThrow().getStatus());
    }

    private Branch branch(String prefix) {
        var branch = Branch.builder().name(prefix + " " + UUID.randomUUID()).address("Address").build();
        em.persist(branch);
        return branch;
    }

    private Role role(String name) {
        var role = Role.builder().name(name).build();
        em.persist(role);
        return role;
    }

    private User user(String prefix, Branch branch, Role role) {
        var user = User.builder().email(prefix + "-" + UUID.randomUUID() + "@example.test")
                .password("test").fullName(prefix).active(true).branch(branch).roles(Set.of(role)).build();
        em.persist(user);
        return user;
    }

    private Order order(User customer, Branch branch, String amount) {
        var order = Order.builder().orderCode("ORD-" + UUID.randomUUID())
                .user(customer).branch(branch).status(OrderStatus.DELIVERED)
                .totalAmount(new BigDecimal(amount)).finalAmount(new BigDecimal(amount))
                .recipientName("Recipient").recipientPhone("0123456789")
                .shippingAddress("Delivery address").build();
        em.persist(order);
        return order;
    }
}
