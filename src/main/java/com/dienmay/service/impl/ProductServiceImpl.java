package com.dienmay.service.impl;

import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.dto.product.AdminProductRequest;
import com.dienmay.entity.branch.BranchProduct;
import com.dienmay.entity.product.Brand;
import com.dienmay.entity.product.Category;
import com.dienmay.entity.product.Product;
import com.dienmay.entity.product.ProductImage;
import com.dienmay.repository.branch.BranchProductRepository;
import com.dienmay.repository.product.BrandRepository;
import com.dienmay.repository.product.CategoryRepository;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.repository.product.ProductImageRepository;
import com.dienmay.service.CloudinaryService;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import com.dienmay.repository.specification.ProductSpecification;
import com.dienmay.service.product.ProductService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final BranchProductRepository branchProductRepository;
    private final ProductImageRepository productImageRepository;
    private final CloudinaryService cloudinaryService;

    @Override
    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    @Override
    public List<Brand> getAllBrands() {
        return brandRepository.findAll();
    }

    @Override
    public List<Product> getLatestProducts() {
        Pageable pageable = PageRequest.of(0, 8, Sort.by(Sort.Direction.DESC, "createdAt"));
        return productRepository.findAll((root, query, cb) -> cb.isTrue(root.get("active")), pageable).getContent();
    }

    @Override
    public List<Product> getFeaturedProducts() {
        Pageable pageable = PageRequest.of(0, 8, Sort.by(Sort.Direction.DESC, "soldQuantity"));
        return productRepository.findAll((root, query, cb) -> cb.isTrue(root.get("active")), pageable).getContent();
    }

    @Override
    public Product getProductBySlug(String slug) {
        return productRepository.findBySlugAndActiveTrue(slug)
                .orElse(null);
    }

    @Override
    public List<BranchProduct> getBranchStock(Long productId) {
        // Dùng method có sẵn trong repository thay vì Specification
        return branchProductRepository.findByProduct_Id(productId);
    }

    @Override
    public List<Product> getRelatedProducts(Long categoryId, Long currentProductId) {
        return productRepository.findTop4ByCategory_IdAndIdNotAndActiveTrue(categoryId, currentProductId);
    }

    // LỌC SẢN PHẨM BẰNG ProductSpecification (MỤC 6)
    @Override
    public List<Product> filterProducts(ProductFilterRequest request) {
        Sort sort = Sort.by(Sort.Direction.DESC, "createdAt"); // Mặc định: mới nhất

        if (request.getSortBy() != null) {
            switch (request.getSortBy().toLowerCase()) {
                case "price_asc":
                    sort = Sort.by(Sort.Direction.ASC, "discountPrice");
                    break;
                case "price_desc":
                    sort = Sort.by(Sort.Direction.DESC, "discountPrice");
                    break;
                case "bestseller":
                    sort = Sort.by(Sort.Direction.DESC, "soldQuantity");
                    break;
                case "rating":
                    sort = Sort.by(Sort.Direction.DESC, "rating");
                    break;
                case "newest":
                default:
                    sort = Sort.by(Sort.Direction.DESC, "createdAt");
                    break;
            }
        }

        int page = (request.getPage() != null && request.getPage() >= 0) ? request.getPage() : 0;
        int size = (request.getSize() != null && request.getSize() > 0) ? request.getSize() : 12;
        Pageable pageable = PageRequest.of(page, size, sort);

        Specification<Product> spec = ProductSpecification.filter(request);
        return productRepository.findAll(spec, pageable).getContent();
    }

    // TOP 20 SẢN PHẨM THEO 4 TAB (MỤC 7)
    @Override
    public List<Product> getTop20ByTab(String tab) {
        Sort sort;
        if (tab == null) tab = "newest";

        switch (tab.toLowerCase()) {
            case "bestseller": // Bán chạy
                sort = Sort.by(Sort.Direction.DESC, "soldQuantity");
                break;
            case "rating":     // Đánh giá cao
                sort = Sort.by(Sort.Direction.DESC, "rating");
                break;
            case "favorite":   // Yêu thích
                sort = Sort.by(Sort.Direction.DESC, "favoriteCount");
                break;
            case "newest":     // Mới nhất
            default:
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
                break;
        }

        Specification<Product> activeSpec = (root, query, cb) -> cb.isTrue(root.get("active"));
        Pageable top20 = PageRequest.of(0, 20, sort);

        return productRepository.findAll(activeSpec, top20).getContent();
    }

    @Override
    public List<Product> getAllProductsForAdmin() {
        return productRepository.findAll(Sort.by(Sort.Direction.DESC, "id"));
    }

    @Override
    @Transactional
    public Product saveProduct(Long id, AdminProductRequest request) {
        Product product = id == null ? new Product() : productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));
        productRepository.findBySlug(request.getSlug().trim()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) throw new IllegalArgumentException("Slug đã được sử dụng");
        });
        productRepository.findBySku(request.getSku().trim()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) throw new IllegalArgumentException("SKU đã được sử dụng");
        });
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục"));
        Brand brand = brandRepository.findById(request.getBrandId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thương hiệu"));
        product.setName(request.getName().trim());
        product.setSlug(request.getSlug().trim());
        product.setSku(request.getSku().trim());
        product.setShortDescription(request.getShortDescription());
        product.setDescription(request.getDescription());
        product.setSpecifications(request.getSpecifications());
        product.setOriginalPrice(request.getOriginalPrice());
        product.setDiscountPrice(request.getDiscountPrice());
        product.setPrice(request.getDiscountPrice() != null ? request.getDiscountPrice() : request.getOriginalPrice());
        if (request.getMainImageUrl() != null && !request.getMainImageUrl().isBlank()) {
            product.setMainImageUrl(request.getMainImageUrl());
        }
        product.setCategory(category);
        product.setBrand(brand);
        product.setActive(request.getActive() == null || request.getActive());
        product.setFeatured(request.getFeatured() != null && request.getFeatured());
        try {
            if (request.getMainImage() != null && !request.getMainImage().isEmpty()) {
                product.setMainImageUrl(cloudinaryService.uploadFile(request.getMainImage(), "products/main"));
            }
            Product saved = productRepository.save(product);
            if (request.getGalleryImages() != null) {
                for (MultipartFile file : request.getGalleryImages()) {
                    if (file != null && !file.isEmpty()) {
                        String url = cloudinaryService.uploadFile(file, "products/" + saved.getId());
                        productImageRepository.save(ProductImage.builder().product(saved).imageUrl(url).build());
                    }
                }
            }
            return saved;
        } catch (IOException ex) {
            throw new IllegalArgumentException("Không thể tải ảnh sản phẩm lên: " + ex.getMessage(), ex);
        }
    }

    @Override
    @Transactional
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));
        product.setActive(false);
        productRepository.save(product);
    }
}
