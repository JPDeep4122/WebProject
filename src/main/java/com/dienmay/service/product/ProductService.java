package com.dienmay.service.product;

import java.util.List;

import com.dienmay.dto.product.AdminProductRequest;
import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.product.Brand;
import com.dienmay.entity.product.Category;
import com.dienmay.entity.product.Product;

public interface ProductService {

	List<BranchInventory> getBranchStock(Long productId);
	
    List<Category> getAllCategories();

    List<Brand> getAllBrands();

    List<Product> getFeaturedProducts();

    List<Product> getLatestProducts();

    Product getProductBySlug(String slug);


    List<Product> getRelatedProducts(Long categoryId, Long currentProductId);

    // Lọc sản phẩm theo Specification (Danh mục, Thương hiệu, Giá, Tìm kiếm)
    List<Product> filterProducts(ProductFilterRequest request);

    // Top 20 sản phẩm theo 4 Tab (newest, bestseller, rating, favorite)
    List<Product> getTop20ByTab(String tab);

    List<Product> getAllProductsForAdmin();

    Product saveProduct(Long id, AdminProductRequest request);

    void deleteProduct(Long id);
}
