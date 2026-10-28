package com.dienmay.service.catalog;

import java.util.Comparator;
import java.util.stream.Collectors;

import com.dienmay.dto.product.ProductFilterRequest;

public final class CustomerCatalogCacheKey {
	private CustomerCatalogCacheKey() {}

	public static String productPage(ProductFilterRequest filter) {
		if (filter == null) return "default";
		String brands = filter.getBrandIds() == null ? "" : filter.getBrandIds().stream()
				.filter(java.util.Objects::nonNull).sorted(Comparator.naturalOrder())
				.map(String::valueOf).collect(Collectors.joining(","));
		return String.join("|", value(filter.getCategoryId()), value(filter.getCategorySlug()), brands,
				value(filter.getMinPrice()), value(filter.getMaxPrice()), value(filter.getMinRating()),
				value(filter.getKeyword()), value(filter.getInStockOnly()), value(filter.getBranchId()),
				value(filter.getSortBy()), value(filter.getPage()), value(filter.getSize()));
	}

	private static String value(Object value) {
		return value == null ? "" : value.toString().trim().toLowerCase(java.util.Locale.ROOT);
	}
}
