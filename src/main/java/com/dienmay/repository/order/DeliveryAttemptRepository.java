package com.dienmay.repository.order;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.order.DeliveryAttempt;

@Repository
public interface DeliveryAttemptRepository extends JpaRepository<DeliveryAttempt, Long> {

    List<DeliveryAttempt> findByAssignmentIdOrderByAttemptNoAsc(Long assignmentId);

    Optional<DeliveryAttempt> findTopByAssignmentIdOrderByAttemptNoDesc(Long assignmentId);

    @Query("select coalesce(max(a.attemptNo), 0) from DeliveryAttempt a where a.assignment.id = :assignmentId")
    int findMaxAttemptNoByAssignmentId(@Param("assignmentId") Long assignmentId);
}