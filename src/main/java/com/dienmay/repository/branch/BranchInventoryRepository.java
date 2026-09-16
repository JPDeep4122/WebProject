package com.dienmay.repository.branch;

import com.dienmay.entity.branch.BranchInventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BranchInventoryRepository extends JpaRepository<BranchInventory, Long> {

    Optional<BranchInventory> findByBranchIdAndProductId(Long branchId, Long productId);

    List<BranchInventory> findByBranchId(Long branchId);

    List<BranchInventory> findByProductId(Long productId);
}
