package com.dienmay.service.branch;

import static org.junit.jupiter.api.Assertions.*;

import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.function.BiFunction;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;

import com.dienmay.dto.branch.InventoryStockRequest;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.branch.InventoryAdjustment;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.branch.InventoryAdjustmentRepository;

class BranchInventoryManagementServiceTest {
    private BranchInventoryManagementService service;
    private User actor;
    private Branch branch;
    private BranchInventory inventory;
    private List<InventoryAdjustment> history;
    private int savedInventories;

    @BeforeEach
    void setup() {
        branch = Branch.builder().id(1L).active(true).build();
        actor = User.builder().id(7L).email("staff@example.test").active(true).branch(branch)
                .roles(Set.of(Role.builder().name("ROLE_STAFF").build())).build();
        inventory = BranchInventory.builder().id(9L).branch(branch).stockQuantity(10)
                .reservedQuantity(2).transferReservedQuantity(1).quarantineQuantity(1).build();
        inventory.recalculateAvailable();
        history = new ArrayList<>();
        service = new BranchInventoryManagementService(
                repository(BranchInventoryRepository.class, (name, args) -> switch (name) {
                    case "findByIdForUpdate" -> Optional.of(inventory);
                    case "save" -> { savedInventories++; yield args[0]; }
                    case "search" -> Page.empty((org.springframework.data.domain.Pageable) args[2]);
                    default -> throw new UnsupportedOperationException(name);
                }),
                repository(BranchRepository.class, (name, args) -> switch (name) {
                    case "existsById" -> true;
                    case "findByActiveTrue" -> List.of(branch);
                    default -> throw new UnsupportedOperationException(name);
                }),
                repository(UserRepository.class, (name, args) -> Optional.of(actor)),
                repository(InventoryAdjustmentRepository.class, (name, args) -> {
                    history.add((InventoryAdjustment) args[0]);
                    return args[0];
                }));
    }

    @ParameterizedTest
    @ValueSource(strings = {"ROLE_STAFF", "ROLE_BRANCH_MANAGER", "ROLE_ADMIN"})
    void personnelCanUpdateOwnStockAndRecordActorAndReason(String role) {
        actor.setRoles(Set.of(Role.builder().name(role).build()));
        service.updateStock(9L, request(15, 10, "  Nhập thêm hàng  "), actor.getEmail());
        assertEquals(15, inventory.getStockQuantity());
        assertEquals(11, inventory.getAvailableQuantity());
        assertEquals(2, inventory.getReservedQuantity());
        assertEquals(1, inventory.getTransferReservedQuantity());
        assertEquals(1, inventory.getQuarantineQuantity());
        assertEquals(1, savedInventories);
        assertEquals(1, history.size());
        InventoryAdjustment entry = history.getFirst();
        assertEquals(10, entry.getPreviousStock());
        assertEquals(15, entry.getNewStock());
        assertEquals(5, entry.getDeltaQuantity());
        assertSame(actor, entry.getAdjustedBy());
        assertEquals("Nhập thêm hàng", entry.getReason());
        assertEquals("APPROVED", entry.getStatus());
    }

    @ParameterizedTest
    @ValueSource(strings = {"ROLE_STAFF", "ROLE_BRANCH_MANAGER"})
    void crossBranchWriteIsRejectedEvenWithForgedInventoryId(String role) {
        actor.setRoles(Set.of(Role.builder().name(role).build()));
        actor.setBranch(Branch.builder().id(2L).build());
        assertThrows(AccessDeniedException.class,
                () -> service.updateStock(9L, request(20, 10, "Kiểm kê"), actor.getEmail()));
        assertUnchanged();
    }

    @Test
    void adminCanUpdateAnotherBranch() {
        actor.setRoles(Set.of(Role.builder().name("ROLE_ADMIN").build()));
        actor.setBranch(null);
        service.updateStock(9L, request(4, 10, "Kiểm kê"), actor.getEmail());
        assertEquals(0, inventory.getAvailableQuantity());
        assertEquals(-6, history.getFirst().getDeltaQuantity());
    }

    @Test
    void stalePageCannotOverwriteChangedStock() {
        assertThrows(IllegalArgumentException.class,
                () -> service.updateStock(9L, request(20, 8, "Kiểm kê"), actor.getEmail()));
        assertUnchanged();
    }

    @ParameterizedTest
    @ValueSource(ints = {-1, 0, 3})
    void cannotReduceBelowAllHeldAndQuarantinedStock(int stock) {
        assertThrows(IllegalArgumentException.class,
                () -> service.updateStock(9L, request(stock, 10, "Kiểm kê"), actor.getEmail()));
        assertUnchanged();
    }

    @Test
    void invalidReasonAndUnchangedQuantityAreRejected() {
        for (String reason : new String[]{"", "   ", "x".repeat(501)}) {
            assertThrows(IllegalArgumentException.class,
                    () -> service.updateStock(9L, request(15, 10, reason), actor.getEmail()));
        }
        assertThrows(IllegalArgumentException.class,
                () -> service.updateStock(9L, request(10, 10, "Kiểm kê"), actor.getEmail()));
        assertUnchanged();
    }

    @Test
    void blockedInactiveUnassignedAndNonPersonnelCannotUpdate() {
        actor.setBlocked(true);
        assertDenied();
        actor.setBlocked(false);
        actor.setActive(false);
        assertDenied();
        actor.setActive(true);
        actor.setBranch(null);
        assertDenied();
        actor.setBranch(branch);
        for (String role : new String[]{"ROLE_CUSTOMER", "ROLE_SHIPPER"}) {
            actor.setRoles(Set.of(Role.builder().name(role).build()));
            assertDenied();
        }
        assertUnchanged();
    }

    @Test
    void inactiveBranchCannotBeUpdated() {
        branch.setActive(false);
        assertThrows(IllegalArgumentException.class,
                () -> service.updateStock(9L, request(15, 10, "Kiểm kê"), actor.getEmail()));
        assertUnchanged();
    }

    @Test
    void editFormIsOnlyEnabledForOwnBranchOrAdmin() {
        var pageable = PageRequest.of(0, 20);
        assertTrue(service.load(actor.getEmail(), 1L, "", pageable).isCanEditInventory());
        assertFalse(service.load(actor.getEmail(), 2L, "", pageable).isCanEditInventory());
        actor.setBranch(null);
        assertFalse(service.load(actor.getEmail(), null, "", pageable).isCanEditInventory());
        actor.setRoles(Set.of(Role.builder().name("ROLE_ADMIN").build()));
        assertTrue(service.load(actor.getEmail(), 2L, "", pageable).isCanEditInventory());
    }

    private void assertDenied() {
        assertThrows(AccessDeniedException.class,
                () -> service.updateStock(9L, request(15, 10, "Kiểm kê"), actor.getEmail()));
    }

    private void assertUnchanged() {
        assertEquals(10, inventory.getStockQuantity());
        assertEquals(0, savedInventories);
        assertTrue(history.isEmpty());
    }

    private InventoryStockRequest request(int stock, int expected, String reason) {
        InventoryStockRequest request = new InventoryStockRequest();
        request.setNewStock(stock);
        request.setExpectedStock(expected);
        request.setReason(reason);
        return request;
    }

    // Repository fakes keep these service rule tests isolated from the live database.
    private static <T> T repository(Class<T> type, BiFunction<String, Object[], Object> handler) {
        return type.cast(Proxy.newProxyInstance(type.getClassLoader(), new Class<?>[]{type},
                (proxy, method, args) -> handler.apply(method.getName(), args)));
    }
}
