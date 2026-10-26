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
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.product.Product;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.branch.InventoryAdjustmentRepository;
import com.dienmay.service.branch.BranchInventoryManagementService;

import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = {"spring.jpa.hibernate.ddl-auto=create-drop"})
@Import(BranchInventoryManagementService.class)
class BranchInventoryManagementServiceTests {
    @Autowired BranchInventoryManagementService service;
    @Autowired BranchInventoryRepository inventories;
    @Autowired InventoryAdjustmentRepository adjustments;
    @Autowired EntityManager em;

    Branch firstBranch;
    Branch secondBranch;
    User staff;
    User admin;
    Role staffRole;
    Long firstInventoryId;
    Long secondInventoryId;

    @BeforeEach
    void seed() {
        firstBranch = branch("First");
        secondBranch = branch("Second");
        staffRole = role("ROLE_STAFF");
        var adminRole = role("ROLE_ADMIN");
        staff = user("staff", firstBranch, staffRole);
        admin = user("admin", null, adminRole);
        firstInventoryId = inventory(firstBranch, product("TV", "TV-001"), 10, 3).getId();
        secondInventoryId = inventory(secondBranch, product("Fridge", "FR-001"), 8, 1).getId();
        em.flush();
        em.clear();
    }

    @Test
    void staffOnlySeesAssignedBranchInventory() {
        var overview = service.load(staff.getEmail(), secondBranch.getId(), "",
                PageRequest.of(0, 20));

        assertEquals(firstBranch.getId(), overview.getSelectedBranchId());
        assertEquals(1, overview.getInventories().getTotalElements());
        assertEquals(firstBranch.getId(), overview.getInventories().getContent().get(0).getBranch().getId());
        assertEquals(false, overview.isCanChooseBranch());
    }

    @Test
    void adjustsStockAndWritesAuditHistory() {
        service.adjust(firstInventoryId, 15, "Kiểm kê thực tế", staff.getEmail());
        em.flush();
        em.clear();

        var inventory = inventories.findById(firstInventoryId).orElseThrow();
        assertEquals(15, inventory.getStockQuantity());
        assertEquals(12, inventory.getAvailableQuantity());
        var history = adjustments.findAll();
        assertEquals(1, history.size());
        assertEquals(10, history.get(0).getPreviousStock());
        assertEquals(15, history.get(0).getNewStock());
        assertEquals("Kiểm kê thực tế", history.get(0).getReason());
    }

    @Test
    void rejectsStockBelowReservedQuantityWithoutAudit() {
        assertThrows(IllegalArgumentException.class,
                () -> service.adjust(firstInventoryId, 2, "Giảm kho", staff.getEmail()));

        assertEquals(10, inventories.findById(firstInventoryId).orElseThrow().getStockQuantity());
        assertEquals(0, adjustments.count());
    }

    @Test
    void staffCannotAdjustAnotherBranch() {
        assertThrows(AccessDeniedException.class,
                () -> service.adjust(secondInventoryId, 9, "Kiểm kê", staff.getEmail()));
        assertEquals(8, inventories.findById(secondInventoryId).orElseThrow().getStockQuantity());
    }

    @Test
    void adminCanAdjustAnyBranch() {
        service.adjust(secondInventoryId, 12, "Bổ sung hàng", admin.getEmail());
        em.flush();

        assertEquals(12, inventories.findById(secondInventoryId).orElseThrow().getStockQuantity());
        assertEquals(1, adjustments.count());
    }

    @Test
    void searchesByProductSku() {
        var overview = service.load(admin.getEmail(), null, "FR-001", PageRequest.of(0, 20));
        assertEquals(1, overview.getInventories().getTotalElements());
        assertEquals("FR-001", overview.getInventories().getContent().get(0).getProduct().getSku());
    }

    @Test
    void staffWithoutBranchSeesNeitherInventoryNorHistory() {
        var unassigned = user("unassigned", null, staffRole);
        service.adjust(firstInventoryId, 11, "Kiểm kê", admin.getEmail());
        em.flush();

        var overview = service.load(unassigned.getEmail(), null, "", PageRequest.of(0, 20));
        assertEquals(0, overview.getInventories().getTotalElements());
        assertEquals(0, overview.getRecentAdjustments().size());
        assertEquals("Tài khoản nhân viên chưa được gán chi nhánh.", overview.getWarning());
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

    private Product product(String name, String sku) {
        var product = Product.builder().name(name).slug(sku.toLowerCase())
                .sku(sku).originalPrice(BigDecimal.TEN).active(true).build();
        em.persist(product);
        return product;
    }

    private BranchInventory inventory(Branch branch, Product product, int stock, int reserved) {
        var inventory = BranchInventory.builder().branch(branch).product(product)
                .stockQuantity(stock).reservedQuantity(reserved)
                .availableQuantity(stock - reserved).build();
        em.persist(inventory);
        em.flush();
        return inventory;
    }
}
