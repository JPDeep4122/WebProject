package com.dienmay.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long>{
	
	//Top sản phẩm nổi bật
	List<Product> findTop8ByActiveTrueAndFeaturedTrueOrderByCreatedAtDesc();
	
	List<Product> findTop8ByActiveTrueOrderByCreatedAtDesc();
	
	List<Product> findByCategory_SlugAndActiveTrue(String slug);
}
