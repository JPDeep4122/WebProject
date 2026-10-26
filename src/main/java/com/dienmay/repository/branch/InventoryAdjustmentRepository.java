package com.dienmay.repository.branch;

import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.dienmay.entity.branch.InventoryAdjustment;

public interface InventoryAdjustmentRepository extends JpaRepository<InventoryAdjustment, Long> {
    @EntityGraph(attributePaths = {"branch", "product", "adjustedBy"})
    List<InventoryAdjustment> findTop20ByOrderByCreatedAtDesc();

    @EntityGraph(attributePaths = {"branch", "product", "adjustedBy"})
    List<InventoryAdjustment> findTop20ByBranchIdOrderByCreatedAtDesc(Long branchId);
}
