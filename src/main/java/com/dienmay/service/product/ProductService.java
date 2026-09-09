package com.dienmay.service.product;

import java.util.List;

import com.dienmay.entity.product.Category;
import com.dienmay.entity.product.Product;

public interface ProductService {

	List<Category> getAllCategories();

	List<Product> getFeaturedProducts();

	List<Product> getLatestProducts();

	List<com.dienmay.entity.product.Brand> getAllBrands();

	List<Product> filterProducts(com.dienmay.dto.product.ProductFilterRequest request);

	com.dienmay.entity.product.Product getProductBySlug(String slug);

	List<com.dienmay.entity.branch.BranchProduct> getBranchStock(Long productId);

	List<com.dienmay.entity.product.Product> getRelatedProducts(Long categoryId, Long currentProductId);
}