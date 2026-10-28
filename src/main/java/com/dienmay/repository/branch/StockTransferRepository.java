package com.dienmay.repository.branch;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.dienmay.entity.branch.StockTransfer;

import jakarta.persistence.LockModeType;

public interface StockTransferRepository extends JpaRepository<StockTransfer, Long> {

    @EntityGraph(attributePaths = {"fromBranch", "toBranch", "product", "requestedBy", "approvedBy", "shippedBy", "receivedBy"})
    List<StockTransfer> findTop50ByOrderByRequestedAtDesc();

    @EntityGraph(attributePaths = {"fromBranch", "toBranch", "product", "requestedBy", "approvedBy", "shippedBy", "receivedBy"})
    @Query("select t from StockTransfer t where t.fromBranch.id = :branchId or t.toBranch.id = :branchId order by t.requestedAt desc")
    List<StockTransfer> findForBranch(@Param("branchId") Long branchId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from StockTransfer t join fetch t.fromBranch join fetch t.toBranch join fetch t.product join fetch t.requestedBy where t.id = :id")
    Optional<StockTransfer> findByIdForUpdate(@Param("id") Long id);
}