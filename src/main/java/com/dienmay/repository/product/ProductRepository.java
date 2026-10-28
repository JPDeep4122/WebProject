package com.dienmay.repository.product;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.product.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long>, JpaSpecificationExecutor<Product> {
	@Override
	@EntityGraph(attributePaths = {"category", "brand"})
	List<Product> findAll(Sort sort);
	boolean existsBySlug(String slug);
	boolean existsBySku(String sku);
	Optional<Product> findBySlug(String slug);
	Optional<Product> findBySku(String sku);
	
	//Top sản phẩm nổi bật
	List<Product> findTop8ByActiveTrueAndFeaturedTrueOrderByCreatedAtDesc();
	
	List<Product> findTop8ByActiveTrueOrderByCreatedAtDesc();
	
	List<Product> findByCategory_SlugAndActiveTrue(String slug);
	
	
    Optional<Product> findBySlugAndActiveTrue(String slug);
    
   
    List<Product> findTop4ByCategory_IdAndIdNotAndActiveTrue(Long categoryId, Long currentProductId);
    
	
	List<Product> findTop5ByActiveTrueOrderBySoldQuantityDesc();
}
