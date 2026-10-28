package com.dienmay.dto.catalog;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

import com.dienmay.entity.product.Product;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Detached, serializable product data used by customer-facing catalog pages. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerProductView implements Serializable {
	@Serial private static final long serialVersionUID = 1L;

	private Long id;
	private String name;
	private String slug;
	private String sku;
	private String shortDescription;
	private String description;
	private String specifications;
	private BigDecimal originalPrice;
	private BigDecimal discountPrice;
	private BigDecimal price;
	private BigDecimal sellingPrice;
	private String mainImageUrl;
	private boolean active;
	private boolean featured;
	private Integer soldQuantity;
	private Double rating;
	private Long reviewCount;
	private Integer favoriteCount;
	private CustomerReferenceView category;
	private CustomerReferenceView brand;
	private List<CustomerImageView> images;

	public static CustomerProductView from(Product product) {
		return new CustomerProductView(
				product.getId(), product.getName(), product.getSlug(), product.getSku(),
				product.getShortDescription(), product.getDescription(), product.getSpecifications(),
				product.getOriginalPrice(), product.getDiscountPrice(), product.getPrice(), product.getSellingPrice(),
				product.getMainImageUrl(), product.isActive(), product.isFeatured(), product.getSoldQuantity(),
				product.getRating(), product.getReviewCount(), product.getFavoriteCount(),
				CustomerReferenceView.from(product.getCategory()), CustomerReferenceView.from(product.getBrand()),
				product.getImages() == null ? List.of() : product.getImages().stream()
						.map(image -> new CustomerImageView(image.getId(), image.getImageUrl())).toList());
	}
}
