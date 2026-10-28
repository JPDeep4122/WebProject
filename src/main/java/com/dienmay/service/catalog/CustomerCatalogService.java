package com.dienmay.service.catalog;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.dto.catalog.CustomerProductView;
import com.dienmay.dto.catalog.CustomerProductPageView;
import com.dienmay.dto.catalog.CustomerReferenceView;
import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.product.Product;
import com.dienmay.service.product.ProductService;

import lombok.RequiredArgsConstructor;

/** Redis-backed, detached views for frequently read customer catalog data. */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CustomerCatalogService {
	private final ProductService productService;

	@Cacheable(cacheNames = "customerHomeCategories", key = "'all'")
	public List<CustomerReferenceView> homeCategories() {
		return productService.getAllCategories().stream().map(CustomerReferenceView::from).toList();
	}

	@Cacheable(cacheNames = "customerHomeProducts", key = "#tab == null ? 'newest' : #tab.toLowerCase()")
	public List<CustomerProductView> homeProducts(String tab) {
		return productService.getTop20ByTab(tab).stream().map(CustomerProductView::from).toList();
	}

	@Cacheable(cacheNames = "customerProductDetails", key = "#slug")
	public CustomerProductView productDetails(String slug) {
		Product product = productService.getProductBySlug(slug);
		return product == null ? null : CustomerProductView.from(product);
	}

	@Cacheable(cacheNames = "customerCatalogPages",
			key = "T(com.dienmay.service.catalog.CustomerCatalogCacheKey).productPage(#request)")
	public CustomerProductPageView filteredProducts(ProductFilterRequest request) {
		return CustomerProductPageView.from(productService.filterProductsPage(request));
	}

	@Cacheable(cacheNames = "customerBrands", key = "'all'")
	public List<CustomerReferenceView> brands() {
		return productService.getAllBrands().stream().map(CustomerReferenceView::from).toList();
	}

	@Cacheable(cacheNames = "customerFilteredBrands",
			key = "T(com.dienmay.service.catalog.CustomerCatalogCacheKey).productPage(#request)")
	public List<CustomerReferenceView> brandsForFilter(ProductFilterRequest request) {
		return productService.getBrandsForFilter(request).stream().map(CustomerReferenceView::from).toList();
	}

	@Cacheable(cacheNames = "customerBranches", key = "'active'")
	public List<CustomerReferenceView> activeBranches() {
		return productService.getActiveBranches().stream().map(CustomerReferenceView::from).toList();
	}
}
