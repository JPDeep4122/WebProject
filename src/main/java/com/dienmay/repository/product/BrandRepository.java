package com.dienmay.repository.product;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.product.Brand;

@Repository
public interface BrandRepository extends JpaRepository<Brand, Long>{
	
	List<Brand> findByActiveTrue();
}
