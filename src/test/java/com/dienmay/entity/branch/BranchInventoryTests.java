package com.dienmay.entity.branch;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class BranchInventoryTests {

    @Test
    void calculatesAvailableQuantityBeforeSaving() {
        BranchInventory inventory = BranchInventory.builder()
                .stockQuantity(12)
                .reservedQuantity(5)
                .build();

        inventory.onSave();

        assertEquals(7, inventory.getAvailableQuantity());
        assertNotNull(inventory.getUpdatedAt());
    }

    @Test
    void rejectsNegativeOrOverReservedInventory() {
        BranchInventory negativeStock = BranchInventory.builder()
                .stockQuantity(-1)
                .reservedQuantity(0)
                .build();
        BranchInventory overReserved = BranchInventory.builder()
                .stockQuantity(4)
                .reservedQuantity(5)
                .build();

        assertThrows(IllegalStateException.class, negativeStock::onSave);
        assertThrows(IllegalStateException.class, overReserved::onSave);
    }
}
