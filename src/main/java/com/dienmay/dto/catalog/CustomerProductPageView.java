package com.dienmay.dto.catalog;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import com.dienmay.entity.product.Product;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Serializable page payload so filtered catalog pages can be cached safely. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerProductPageView implements Serializable {
	@Serial private static final long serialVersionUID = 1L;
	private List<CustomerProductView> content;
	private long totalElements;
	private int number;
	private int size;

	public static CustomerProductPageView from(Page<Product> page) {
		return new CustomerProductPageView(page.getContent().stream().map(CustomerProductView::from).toList(),
				page.getTotalElements(), page.getNumber(), page.getSize());
	}

	public int getTotalPages() {
		return size <= 0 ? 0 : (int) Math.ceil((double) totalElements / size);
	}

	public int getNumberOfElements() {
		return content == null ? 0 : content.size();
	}

	public boolean hasPrevious() {
		return number > 0;
	}

	public boolean hasNext() {
		return number + 1 < getTotalPages();
	}

	public Page<CustomerProductView> toPage() {
		return new PageImpl<>(content == null ? List.of() : content,
				PageRequest.of(Math.max(0, number), Math.max(1, size)), totalElements);
	}
}
