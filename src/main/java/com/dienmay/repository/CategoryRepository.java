package com.dienmay.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.Category;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long>{
	List<Category> findByActiveTrue();
	Optional<Category> findBySlug(String slug);
}
