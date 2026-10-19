package com.dienmay.repository.branch;

import com.dienmay.entity.branch.BranchInventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BranchInventoryRepository extends JpaRepository<BranchInventory, Long> {

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select i from BranchInventory i where i.branch.id = :branchId and i.product.id = :productId")
    Optional<BranchInventory> findForUpdate(
            @org.springframework.data.repository.query.Param("branchId") Long branchId,
            @org.springframework.data.repository.query.Param("productId") Long productId);

    Optional<BranchInventory> findByBranchIdAndProductId(Long branchId, Long productId);

    List<BranchInventory> findByBranchId(Long branchId);

    List<BranchInventory> findByProductId(Long productId);
}
