package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.*;
import java.math.BigDecimal;
import java.util.UUID;
import java.util.Set;
import java.util.concurrent.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import com.dienmay.entity.auth.*;
import com.dienmay.entity.branch.*;
import com.dienmay.entity.order.*;
import com.dienmay.entity.product.Product;
import com.dienmay.service.order.OrderConfirmationService;
import com.dienmay.service.order.OrderFulfillmentService;
import com.dienmay.service.order.OrderPickingService;
import com.dienmay.service.order.OrderStateMachine;
import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
@Import({OrderConfirmationService.class, OrderPickingService.class, OrderFulfillmentService.class,
        OrderStateMachine.class})
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class OrderConfirmationTests {
    @Autowired OrderConfirmationService service;
    @Autowired OrderPickingService pickingService;
    @Autowired OrderFulfillmentService fulfillmentService;
    @Autowired EntityManager em;
    @Autowired PlatformTransactionManager manager;
    TransactionTemplate tx;
    Long orderId, inventoryId, branchId, userId, productId;
    String email;

    @BeforeEach
    void seed() {
        tx = new TransactionTemplate(manager);
        email = UUID.randomUUID() + "@example.test";
        tx.executeWithoutResult(s -> {
            var branch = Branch.builder().name("Test").address("Test address").build();
            em.persist(branch); branchId = branch.getId();
            var role = em.createQuery("select r from Role r where r.name = 'ROLE_STAFF'", Role.class)
                    .getResultStream().findFirst().orElseGet(() -> {
                        var r = Role.builder().name("ROLE_STAFF").build(); em.persist(r); return r;
                    });
            var user = User.builder().email(email).password("test").fullName("Staff").active(true)
                    .branch(branch).roles(Set.of(role)).build();
            em.persist(user); userId = user.getId();
            var product = Product.builder().name("Test").slug(email).sku(email.substring(0, 36))
                    .originalPrice(BigDecimal.TEN).price(BigDecimal.TEN).build();
            em.persist(product); productId = product.getId();
            var inventory = BranchInventory.builder().branch(branch).product(product)
                    .stockQuantity(10).reservedQuantity(2).build();
            em.persist(inventory); inventoryId = inventory.getId();
            orderId = createOrder(3);
        });
    }

    private Long createOrder(int quantity) {
        var order = Order.builder().orderCode(UUID.randomUUID().toString())
                .user(em.find(User.class, userId)).branch(em.find(Branch.class, branchId))
                .totalAmount(BigDecimal.TEN).finalAmount(BigDecimal.TEN)
                .recipientName("Customer").recipientPhone("0123456789").shippingAddress("Test").build();
        var item = OrderItem.builder().order(order).product(em.find(Product.class, productId))
                .quantity(quantity).price(BigDecimal.TEN).build();
        order.getOrderItems().add(item); em.persist(order); return order.getId();
    }

    private void assertState(Long id, OrderStatus status, int stock) {
        tx.executeWithoutResult(s -> {
            assertEquals(status, em.find(Order.class, id).getStatus());
            var inventory = em.find(BranchInventory.class, inventoryId);
            assertEquals(stock, inventory.getStockQuantity());
            assertEquals(stock - 2, inventory.getAvailableQuantity());
        });
    }

    @Test void confirmsAndRejectsRepeat() {
        service.confirm(orderId, email);
        assertState(orderId, OrderStatus.CONFIRMED, 7);
        assertThrows(IllegalArgumentException.class, () -> service.confirm(orderId, email));
        assertState(orderId, OrderStatus.CONFIRMED, 7);
    }

    @Test void confirmedOrderCanStartPickingWithoutDeductingAgain() {
        service.confirm(orderId, email);
        pickingService.startPicking(orderId, email);
        assertState(orderId, OrderStatus.PROCESSING, 7);
        assertThrows(IllegalArgumentException.class, () -> pickingService.startPicking(orderId, email));
        assertState(orderId, OrderStatus.PROCESSING, 7);
    }

    @Test void pendingOrderCannotSkipConfirmation() {
        assertThrows(IllegalArgumentException.class, () -> pickingService.startPicking(orderId, email));
        assertState(orderId, OrderStatus.PENDING, 10);
    }

    @Test void completesDeliveryAndReturnRestoresStockOnlyOnce() {
        service.confirm(orderId, email);
        pickingService.startPicking(orderId, email);
        fulfillmentService.startShipping(orderId, email);
        fulfillmentService.markDelivered(orderId, email);
        fulfillmentService.requestReturn(orderId, email);
        assertState(orderId, OrderStatus.RETURN_REQUESTED, 7);

        fulfillmentService.completeReturn(orderId, email);
        assertState(orderId, OrderStatus.RETURNED, 10);
        assertThrows(IllegalArgumentException.class,
                () -> fulfillmentService.completeReturn(orderId, email));
        assertState(orderId, OrderStatus.RETURNED, 10);
    }

    @Test void cancellationAfterConfirmationRestoresStockOnlyOnce() {
        service.confirm(orderId, email);
        fulfillmentService.cancel(orderId, email);
        assertState(orderId, OrderStatus.CANCELLED, 10);
        assertThrows(IllegalArgumentException.class, () -> fulfillmentService.cancel(orderId, email));
        assertState(orderId, OrderStatus.CANCELLED, 10);
    }

    @Test void cancellationDuringShippingRestoresStock() {
        service.confirm(orderId, email);
        pickingService.startPicking(orderId, email);
        fulfillmentService.startShipping(orderId, email);
        fulfillmentService.cancel(orderId, email);
        assertState(orderId, OrderStatus.CANCELLED, 10);
    }

    @Test void deliveryFlowCannotSkipSteps() {
        assertThrows(IllegalArgumentException.class,
                () -> fulfillmentService.startShipping(orderId, email));
        service.confirm(orderId, email);
        assertThrows(IllegalArgumentException.class,
                () -> fulfillmentService.markDelivered(orderId, email));
        assertThrows(IllegalArgumentException.class,
                () -> fulfillmentService.requestReturn(orderId, email));
        assertState(orderId, OrderStatus.CONFIRMED, 7);
    }

    @Test void staffCannotShipOrderFromAnotherBranch() {
        service.confirm(orderId, email);
        pickingService.startPicking(orderId, email);
        tx.executeWithoutResult(s -> {
            var other = Branch.builder().name("Other shipping").address("Other").build();
            em.persist(other);
            em.find(User.class, userId).setBranch(other);
        });
        assertThrows(AccessDeniedException.class,
                () -> fulfillmentService.startShipping(orderId, email));
        assertState(orderId, OrderStatus.PROCESSING, 7);
    }

    @Test void missingInventoryRollsBackCancellation() {
        service.confirm(orderId, email);
        tx.executeWithoutResult(s -> em.remove(em.find(BranchInventory.class, inventoryId)));
        assertThrows(IllegalArgumentException.class, () -> fulfillmentService.cancel(orderId, email));
        tx.executeWithoutResult(s -> assertEquals(OrderStatus.CONFIRMED,
                em.find(Order.class, orderId).getStatus()));
    }

    @Test void staffCannotPickOrderFromAnotherBranch() {
        service.confirm(orderId, email);
        tx.executeWithoutResult(s -> {
            var other = Branch.builder().name("Other").address("Other").build();
            em.persist(other);
            em.find(User.class, userId).setBranch(other);
        });
        assertThrows(AccessDeniedException.class, () -> pickingService.startPicking(orderId, email));
        assertState(orderId, OrderStatus.CONFIRMED, 7);
    }

    @Test void cancelledOrderCannotDeductStock() {
        tx.executeWithoutResult(s -> em.find(Order.class, orderId).setStatus(OrderStatus.CANCELLED));
        assertThrows(IllegalArgumentException.class, () -> service.confirm(orderId, email));
        assertState(orderId, OrderStatus.CANCELLED, 10);
    }

    @Test void inactiveStaffCannotConfirm() {
        tx.executeWithoutResult(s -> em.find(User.class, userId).setActive(false));
        assertThrows(AccessDeniedException.class, () -> service.confirm(orderId, email));
        assertState(orderId, OrderStatus.PENDING, 10);
    }

    @Test void shortageRollsBackEntireOrder() {
        tx.executeWithoutResult(s -> em.find(Order.class, orderId).getOrderItems().get(0).setQuantity(9));
        assertThrows(IllegalArgumentException.class, () -> service.confirm(orderId, email));
        assertState(orderId, OrderStatus.PENDING, 10);
    }

    @Test void missingStockOnSecondProductLeavesFirstUntouched() {
        tx.executeWithoutResult(s -> {
            var p = Product.builder().name("Missing stock").slug(UUID.randomUUID().toString())
                    .sku(UUID.randomUUID().toString()).originalPrice(BigDecimal.TEN).build();
            em.persist(p);
            var order = em.find(Order.class, orderId);
            order.getOrderItems().add(OrderItem.builder().order(order).product(p).quantity(1).price(BigDecimal.TEN).build());
        });
        assertThrows(IllegalArgumentException.class, () -> service.confirm(orderId, email));
        assertState(orderId, OrderStatus.PENDING, 10);
    }

    @Test void rejectsOtherBranchAndUnassignedStaff() {
        tx.executeWithoutResult(s -> em.find(User.class, userId).setBranch(null));
        assertThrows(AccessDeniedException.class, () -> service.confirm(orderId, email));
        tx.executeWithoutResult(s -> {
            var b = Branch.builder().name("Other").address("Other").build(); em.persist(b);
            em.find(User.class, userId).setBranch(b);
        });
        assertThrows(AccessDeniedException.class, () -> service.confirm(orderId, email));
        assertState(orderId, OrderStatus.PENDING, 10);
    }

    @Test void duplicateProductLinesAreAddedTogether() {
        tx.executeWithoutResult(s -> {
            var order = em.find(Order.class, orderId);
            order.getOrderItems().add(OrderItem.builder().order(order).product(em.find(Product.class, productId))
                    .quantity(6).price(BigDecimal.TEN).build());
        });
        assertThrows(IllegalArgumentException.class, () -> service.confirm(orderId, email));
        assertState(orderId, OrderStatus.PENDING, 10);
    }

    @Test void simultaneousConfirmationsDeductOnlyOnce() throws Exception {
        race(orderId, orderId);
        assertState(orderId, OrderStatus.CONFIRMED, 7);
    }

    @Test void competingOrdersCannotOversell() throws Exception {
        Long other = tx.execute(s -> {
            em.find(Order.class, orderId).getOrderItems().get(0).setQuantity(5);
            return createOrder(5);
        });
        race(orderId, other);
        tx.executeWithoutResult(s -> {
            assertEquals(5, em.find(BranchInventory.class, inventoryId).getStockQuantity());
            assertNotEquals(em.find(Order.class, orderId).getStatus(), em.find(Order.class, other).getStatus());
        });
    }

    private void race(Long first, Long second) throws Exception {
        var start = new CountDownLatch(1);
        try (var pool = Executors.newFixedThreadPool(2)) {
            Callable<Boolean> a = () -> { start.await(); return attempt(first); };
            Callable<Boolean> b = () -> { start.await(); return attempt(second); };
            var left = pool.submit(a); var right = pool.submit(b); start.countDown();
            assertNotEquals(left.get(15, TimeUnit.SECONDS), right.get(15, TimeUnit.SECONDS));
        }
    }
    private boolean attempt(Long id) {
        try { service.confirm(id, email); return true; }
        catch (IllegalArgumentException ex) { return false; }
    }
}
