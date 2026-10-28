package com.dienmay.dto.catalog;

import java.io.Serial;
import java.io.Serializable;

import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.product.Brand;
import com.dienmay.entity.product.Category;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Small detached reference object for categories, brands, and branches. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerReferenceView implements Serializable {
	@Serial private static final long serialVersionUID = 1L;
	private Long id;
	private String name;
	private String slug;
	private String icon;
	private String logoUrl;
	private String province;
	private boolean active;

	public static CustomerReferenceView from(Category category) {
		return category == null ? null : new CustomerReferenceView(category.getId(), category.getName(),
				category.getSlug(), category.getIcon(), null, null, category.isActive());
	}

	public static CustomerReferenceView from(Brand brand) {
		return brand == null ? null : new CustomerReferenceView(brand.getId(), brand.getName(),
				null, null, brand.getLogoUrl(), null, brand.isActive());
	}

	public static CustomerReferenceView from(Branch branch) {
		return branch == null ? null : new CustomerReferenceView(branch.getId(), branch.getName(),
				null, null, null, branch.getProvince(), branch.isActive());
	}
}
