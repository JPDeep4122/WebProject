package com.dienmay.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.Branch;

@Repository
public interface BranchRepository extends JpaRepository<Branch, Long>{
	List<Branch> findByActiveTrue();
}
