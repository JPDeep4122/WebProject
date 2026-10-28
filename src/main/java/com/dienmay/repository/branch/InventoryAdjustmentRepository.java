package com.dienmay.repository.branch;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.dienmay.entity.branch.InventoryAdjustment;

import jakarta.persistence.LockModeType;

public interface InventoryAdjustmentRepository extends JpaRepository<InventoryAdjustment, Long> {
    @EntityGraph(attributePaths = {"branch", "product", "adjustedBy", "reviewedBy"})
    List<InventoryAdjustment> findTop20ByOrderByCreatedAtDesc();

    @EntityGraph(attributePaths = {"branch", "product", "adjustedBy", "reviewedBy"})
    List<InventoryAdjustment> findTop20ByBranchIdOrderByCreatedAtDesc(Long branchId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select a from InventoryAdjustment a join fetch a.adjustedBy join fetch a.branch join fetch a.inventory where a.id = :id")
    Optional<InventoryAdjustment> findByIdForUpdate(@Param("id") Long id);
}