package com.dienmay.repository.branch;

import com.dienmay.entity.branch.BranchInventory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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

    @Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @Query("select inventory from BranchInventory inventory where inventory.id = :id")
    Optional<BranchInventory> findByIdForUpdate(@Param("id") Long id);

    @EntityGraph(attributePaths = {"branch", "product"})
    @Query("select inventory from BranchInventory inventory "
            + "where (:branchId is null or inventory.branch.id = :branchId) "
            + "and (:keyword = '' "
            + "or lower(inventory.product.name) like lower(concat('%', :keyword, '%')) "
            + "or lower(inventory.product.sku) like lower(concat('%', :keyword, '%'))) ")
    Page<BranchInventory> search(@Param("branchId") Long branchId,
            @Param("keyword") String keyword, Pageable pageable);
}
