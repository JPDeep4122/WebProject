package com.dienmay.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.ui.ExtendedModelMap;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.web.util.UriUtils;
import java.nio.charset.StandardCharsets;

import com.dienmay.controller.client.ProductController;
import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.product.Product;
import com.dienmay.service.product.ProductService;

class ProductCatalogControllerTests {
    @Test
    void paginationKeepsSearchAndEverySelectedFilterWhileClearKeepsOnlySearchAndSort() {
        var service = mock(ProductService.class);
        var controller = new ProductController();
        ReflectionTestUtils.setField(controller, "productService", service);
        when(service.filterProductsPage(any())).thenReturn(new PageImpl<>(
                java.util.Collections.nCopies(12, Product.builder().name("Product").build()),
                PageRequest.of(0, 12), 25));
        var filter = new ProductFilterRequest();
        filter.setKeyword("Tivi & gia re");
        filter.setBrandIds(List.of(1L, 2L));
        filter.setCategorySlug("tivi");
        filter.setMinPrice(new BigDecimal("5000000"));
        filter.setBranchId(3L);
        filter.setMinRating(4.0);
        filter.setSortBy("price_asc");
        var model = new ExtendedModelMap();
        assertThat(controller.listProducts(filter, model, new MockHttpServletRequest()))
                .isEqualTo("client/products");
        var next = UriComponentsBuilder.fromUriString((String) model.get("nextPageUrl"))
                .build().getQueryParams();
        assertThat(next.get("brandIds")).containsExactly("1", "2");
        assertThat(UriUtils.decode(next.getFirst("keyword"), StandardCharsets.UTF_8)).isEqualTo("Tivi & gia re");
        assertThat(next.getFirst("categorySlug")).isEqualTo("tivi");
        assertThat(next.getFirst("minPrice")).isEqualTo("5000000");
        assertThat(next.getFirst("branchId")).isEqualTo("3");
        assertThat(next.getFirst("inStockOnly")).isEqualTo("true");
        assertThat(next.getFirst("page")).isEqualTo("1");
        var clear = UriComponentsBuilder.fromUriString((String) model.get("clearFiltersUrl"))
                .build().getQueryParams();
        assertThat(clear.keySet()).containsExactlyInAnyOrder("keyword", "sortBy", "size");
        assertThat(UriUtils.decode(clear.getFirst("keyword"), StandardCharsets.UTF_8)).isEqualTo("Tivi & gia re");
    }

    @Test
    void categoryRouteKeepsItsCategoryAndOutOfRangePageFallsBackToLastPage() {
        var service = mock(ProductService.class);
        var controller = new ProductController();
        ReflectionTestUtils.setField(controller, "productService", service);
        when(service.filterProductsPage(any())).thenReturn(
                new PageImpl<>(List.of(), PageRequest.of(99, 12), 25),
                new PageImpl<>(List.of(Product.builder().name("Last product").build()), PageRequest.of(2, 12), 25));
        var filter = new ProductFilterRequest();
        filter.setPage(99);
        var model = new ExtendedModelMap();
        controller.listByCategory("tivi", filter, model, new MockHttpServletRequest());
        assertThat(filter.getCategorySlug()).isEqualTo("tivi");
        assertThat(filter.getPage()).isEqualTo(2);
        assertThat(model.get("products")).asList().hasSize(1);
    }
}
