package com.dienmay.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.entity.branch.BranchProduct;
import com.dienmay.entity.product.Brand;
import com.dienmay.entity.product.Category;
import com.dienmay.entity.product.Product;
import com.dienmay.repository.branch.BranchProductRepository;
import com.dienmay.repository.product.BrandRepository;
import com.dienmay.repository.product.CategoryRepository;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.service.product.ProductService;

@Service
public class ProductServiceImpl implements ProductService {

    @Autowired private CategoryRepository categoryRepo;
    @Autowired private ProductRepository productRepo;

    @Override
    @Transactional(readOnly = true)
    public List<Category> getAllCategories() {
        return categoryRepo.findByActiveTrue();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getFeaturedProducts() {
        return productRepo.findTop8ByActiveTrueAndFeaturedTrueOrderByCreatedAtDesc();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getLatestProducts() {
        return productRepo.findTop8ByActiveTrueOrderByCreatedAtDesc();
    }
    
    @Autowired private BrandRepository brandRepo;

    @Override
    @Transactional(readOnly = true)
    public List<Brand> getAllBrands() {
        return brandRepo.findByActiveTrue();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> filterProducts(com.dienmay.dto.product.ProductFilterRequest request) {
        // 1. Tạo Specification từ request
        org.springframework.data.jpa.domain.Specification<Product> spec = 
                com.dienmay.repository.specification.ProductSpecification.filter(request);

        // 2. Xử lý sắp xếp (Sort)
        org.springframework.data.domain.Sort sort = org.springframework.data.domain.Sort.by(
                org.springframework.data.domain.Sort.Direction.DESC, "createdAt"); // Mặc định: mới nhất

        if ("price_asc".equalsIgnoreCase(request.getSortBy())) {
            sort = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC, "discountPrice");
        } else if ("price_desc".equalsIgnoreCase(request.getSortBy())) {
            sort = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC, "discountPrice");
        }

        return productRepo.findAll(spec, sort);
    }
    
    @Autowired 
    private BranchProductRepository branchProductRepo;

    @Override
    @Transactional(readOnly = true)
    public Product getProductBySlug(String slug) {
        return productRepo.findBySlugAndActiveTrue(slug)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm có đường dẫn: " + slug));
    }

    @Override
    @Transactional(readOnly = true)
    public List<BranchProduct> getBranchStock(Long productId) {
        return branchProductRepo.findByProduct_Id(productId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getRelatedProducts(Long categoryId, Long currentProductId) {
        return productRepo.findTop4ByCategory_IdAndIdNotAndActiveTrue(categoryId, currentProductId);
    }
}