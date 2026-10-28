package com.dienmay.service.impl;

import java.io.IOException;
import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.dienmay.dto.product.AdminProductRequest;
import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.product.Brand;
import com.dienmay.entity.product.Category;
import com.dienmay.entity.product.Product;
import com.dienmay.entity.product.ProductImage;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.product.BrandRepository;
import com.dienmay.repository.product.CategoryRepository;
import com.dienmay.repository.product.ProductImageRepository;
import com.dienmay.repository.product.ProductRepository;
import com.dienmay.repository.specification.ProductSpecification;
import com.dienmay.service.CloudinaryService;
import com.dienmay.service.product.ProductService;

import lombok.RequiredArgsConstructor;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.Join;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductServiceImpl implements ProductService {

	private final ProductRepository productRepository;
	private final CategoryRepository categoryRepository;
	private final BrandRepository brandRepository;
	private final BranchInventoryRepository branchInventoryRepository;
	private final BranchRepository branchRepository;
	private final ProductImageRepository productImageRepository;
	private final CloudinaryService cloudinaryService;

	@PersistenceContext
	private EntityManager entityManager;

	@Override
	public List<Category> getAllCategories() {
		return categoryRepository.findAll();
	}

	@Override
	public List<Brand> getAllBrands() {
		return brandRepository.findAll();
	}

	@Override
	public List<Brand> getBrandsForFilter(ProductFilterRequest request) {
		var cb = entityManager.getCriteriaBuilder();
		var query = cb.createQuery(Brand.class);
		var product = query.from(Product.class);
		Join<Product, Brand> brand = product.join("brand");
		var scope = ProductSpecification.filter(request, false)
				.and(rankingFilter(request.getSortBy()));
		query.select(brand).distinct(true)
				.where(cb.and(scope.toPredicate(product, query, cb), cb.isTrue(brand.get("active"))))
				.orderBy(cb.asc(brand.get("name")), cb.asc(brand.get("id")));
		return entityManager.createQuery(query).getResultList();
	}

	@Override
	public List<Branch> getActiveBranches() {
		return branchRepository.findByActiveTrue().stream()
				.sorted(java.util.Comparator.comparing(Branch::getName)).toList();
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
		return productRepository.findBySlugAndActiveTrue(slug).orElse(null);
	}

	@Override
	public List<BranchInventory> getBranchStock(Long productId) {
		return branchInventoryRepository.findByProductId(productId);
	}

	@Override
	public List<Product> getRelatedProducts(Long categoryId, Long currentProductId) {
		return productRepository.findTop4ByCategory_IdAndIdNotAndActiveTrue(categoryId, currentProductId);
	}

	// LỌC SẢN PHẨM BẰNG ProductSpecification (MỤC 6)
	@Override
	public List<Product> filterProducts(ProductFilterRequest request) {
		return filterProductsPage(request).getContent();
	}

	@Override
	public Page<Product> filterProductsPage(ProductFilterRequest request) {
		String key = request.getSortBy() == null ? "newest"
				: request.getSortBy().toLowerCase(java.util.Locale.ROOT);
		if (!List.of("newest", "price_asc", "price_desc", "bestseller", "rating", "favorite").contains(key)) {
			key = "newest";
		}
		request.setSortBy(key);
		int page = request.getPage() == null ? 0 : Math.max(0, Math.min(request.getPage(), 1_000_000));
		int size = request.getSize() == null || request.getSize() <= 0 ? 12 : Math.min(request.getSize(), 48);
		request.setPage(page);
		request.setSize(size);
		boolean priceSort = key.startsWith("price_");
		Sort sort = switch (key) {
		case "bestseller" -> Sort.by(Sort.Direction.DESC, "soldQuantity");
		case "rating" -> Sort.by(Sort.Direction.DESC, "rating");
		case "favorite" -> Sort.by(Sort.Direction.DESC, "favoriteCount");
		default -> Sort.by(Sort.Direction.DESC, "createdAt");
		};
		String selectedSort = key;
		Specification<Product> spec = ProductSpecification.filter(request).and(rankingFilter(key));
		if (priceSort) {
			spec = spec.and((root, query, cb) -> {
				if (query != null && query.getResultType() != Long.class && query.getResultType() != long.class) {
					var price = ProductSpecification.sellingPrice(root, cb);
					query.orderBy(selectedSort.equals("price_asc") ? cb.asc(price) : cb.desc(price),
							cb.desc(root.get("id")));
				}
				return cb.conjunction();
			});
		}
		Pageable pageable = PageRequest.of(page, size,
				priceSort ? Sort.unsorted() : sort.and(Sort.by(Sort.Direction.DESC, "id")));
		return productRepository.findAll(spec, pageable);
	}

	// TOP 20 SẢN PHẨM THEO 4 TAB (MỤC 7)
	@Override
	public List<Product> getTop20ByTab(String tab) {
		String key = tab == null ? "newest" : tab.toLowerCase(java.util.Locale.ROOT);

		Sort sort = switch (key) {
		case "bestseller" -> Sort.by(Sort.Direction.DESC, "soldQuantity");

		case "rating" -> Sort.by(Sort.Direction.DESC, "rating");

		case "favorite" -> Sort.by(Sort.Direction.DESC, "favoriteCount");

		default -> Sort.by(Sort.Direction.DESC, "createdAt");
		};

		sort = sort.and(Sort.by(Sort.Direction.DESC, "id"));

		Specification<Product> activeSpec = (root, query, cb) -> cb.isTrue(root.get("active"));

		return productRepository.findAll(activeSpec.and(rankingFilter(key)), PageRequest.of(0, 20, sort)).getContent();
	}

	@Override
	public List<Product> getAllProductsForAdmin() {
		return productRepository.findAll(Sort.by(Sort.Direction.DESC, "id"));
	}

	@Override
	@Transactional
	@CacheEvict(cacheNames = { "customerHomeProducts", "customerProductDetails", "customerCatalogPages" }, allEntries = true)
	public Product saveProduct(Long id, AdminProductRequest request) {
		Product product = id == null ? new Product()
				: productRepository.findById(id)
						.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));
		productRepository.findBySlug(request.getSlug().trim()).ifPresent(existing -> {
			if (!existing.getId().equals(id))
				throw new IllegalArgumentException("Slug đã được sử dụng");
		});
		productRepository.findBySku(request.getSku().trim()).ifPresent(existing -> {
			if (!existing.getId().equals(id))
				throw new IllegalArgumentException("SKU đã được sử dụng");
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
	@CacheEvict(cacheNames = { "customerHomeProducts", "customerProductDetails", "customerCatalogPages" }, allEntries = true)
	public void deleteProduct(Long id) {
		Product product = productRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));
		product.setActive(false);
		productRepository.save(product);
	}

	private Specification<Product> rankingFilter(String tab) {
		String key = tab == null ? "" : tab.toLowerCase(java.util.Locale.ROOT);

		return (root, query, cb) -> switch (key) {
		case "bestseller" -> cb.greaterThan(root.<Integer>get("soldQuantity"), 0);

		case "rating" -> cb.and(cb.greaterThan(root.<Long>get("reviewCount"), 0L),
				cb.greaterThanOrEqualTo(root.<Double>get("rating"), 4.0));

		case "favorite" -> cb.greaterThan(root.<Integer>get("favoriteCount"), 0);

		default -> cb.conjunction();
		};
	}
}
