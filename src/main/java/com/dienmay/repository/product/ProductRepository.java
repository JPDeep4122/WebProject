package com.dienmay.repository.product;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.product.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long>, JpaSpecificationExecutor<Product>{
	
	//Top sản phẩm nổi bật
	List<Product> findTop8ByActiveTrueAndFeaturedTrueOrderByCreatedAtDesc();
	
	List<Product> findTop8ByActiveTrueOrderByCreatedAtDesc();
	
	List<Product> findByCategory_SlugAndActiveTrue(String slug);
	
	// 1. Tìm sản phẩm theo đường dẫn thân thiện (slug)
    Optional<Product> findBySlugAndActiveTrue(String slug);
    
    // 2. Tìm top 4 sản phẩm liên quan cùng danh mục (trừ sản phẩm đang xem)
    List<Product> findTop4ByCategory_IdAndIdNotAndActiveTrue(Long categoryId, Long currentProductId);
}
