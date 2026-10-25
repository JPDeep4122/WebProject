package com.dienmay.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import com.dienmay.dto.product.ProductFilterRequest;
import com.dienmay.entity.auth.User;
import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.product.Brand;
import com.dienmay.entity.product.Category;
import com.dienmay.entity.product.Product;
import com.dienmay.entity.review.Review;
import com.dienmay.service.impl.ProductServiceImpl;

import jakarta.persistence.EntityManager;

@DataJpaTest(showSql = false, properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@Import(ProductServiceImpl.class)
class ProductCatalogFilterTests {
    @Autowired EntityManager em;
    @Autowired ProductServiceImpl service;
    @MockitoBean CloudinaryService cloudinary;

    Brand alpha, beta;
    Branch first, second, closed;

    @BeforeEach
    void seed() {
        var tv = persist(Category.builder().name("Tivi").slug("tivi").build());
        var kitchen = persist(Category.builder().name("Bep").slug("bep").build());
        alpha = persist(Brand.builder().name("Alpha").build());
        beta = persist(Brand.builder().name("Beta").build());
        var gamma = persist(Brand.builder().name("Gamma").build());
        first = persist(Branch.builder().name("A").address("A").build());
        second = persist(Branch.builder().name("B").address("B").build());
        closed = persist(Branch.builder().name("Closed").address("C").active(false).build());
        var a = product("Tivi Alpha", tv, alpha, "8000000", "6000000", "6000000", true);
        var b = product("Tivi Beta", tv, beta, "10000000", "9000000", "9000000", true);
        var legacy = product("Tivi Legacy", tv, alpha, "5000000", null, "4000000", true);
        var rice = product("Rice Beta", kitchen, beta, "3000000", "2000000", "2000000", true);
        product("Tivi Original", tv, gamma, "7000000", null, null, true);
        var inactive = product("Tivi Inactive", tv, alpha, "1000000", null, null, false);
        stock(a, first, 5, 1);
        stock(a, second, 4, 0);
        stock(b, first, 2, 2);
        stock(b, second, 3, 0);
        stock(legacy, closed, 10, 0);
        stock(rice, second, 8, 0);
        stock(inactive, first, 9, 0);
        var user = persist(User.builder().email("catalog@example.test").password("test")
                .fullName("Catalog tester").active(true).build());
        persist(Review.builder().product(a).user(user).rating(5).comment("Good").build());
        persist(Review.builder().product(b).user(user).rating(3).comment("Okay").build());
        persist(Review.builder().product(b).user(user).rating(5).comment("Hidden").active(false).build());
        em.flush();
        em.clear();
    }

    @Test
    void stockFilterCountsEachProductOnceAndExcludesReservedOrClosedStock() {
        var filter = new ProductFilterRequest();
        filter.setInStockOnly(true);
        filter.setSize(2);
        var page = service.filterProductsPage(filter);
        assertThat(page.getTotalElements()).isEqualTo(3);
        assertThat(page.getContent()).hasSize(2);
        filter.setSize(12);
        assertThat(service.filterProducts(filter)).extracting(Product::getName)
                .containsExactlyInAnyOrder("Tivi Alpha", "Tivi Beta", "Rice Beta");
    }

    @Test
    void branchSelectionUsesAvailableStockAtThatActiveBranch() {
        var filter = new ProductFilterRequest();
        filter.setBranchId(first.getId());
        assertThat(service.filterProducts(filter)).extracting(Product::getName).containsExactly("Tivi Alpha");
        filter.setBranchId(closed.getId());
        assertThat(service.filterProducts(filter)).isEmpty();
        assertThat(service.getActiveBranches()).extracting(Branch::getName).containsExactly("A", "B");
    }

    @Test
    void combinesCategoryMultipleBrandsKeywordAndPrice() {
        var filter = new ProductFilterRequest();
        filter.setCategorySlug("tivi");
        filter.setBrandIds(List.of(alpha.getId(), beta.getId()));
        filter.setKeyword("tIvI");
        filter.setMinPrice(new BigDecimal("5000000"));
        filter.setMaxPrice(new BigDecimal("10000000"));
        assertThat(service.filterProducts(filter)).extracting(Product::getName)
                .containsExactlyInAnyOrder("Tivi Alpha", "Tivi Beta");
    }

    @Test
    void priceFilterAndBothSortDirectionsUseDisplayedPriceIncludingLegacyFallbacks() {
        var filter = new ProductFilterRequest();
        filter.setCategorySlug("tivi");
        filter.setMaxPrice(new BigDecimal("7000000"));
        filter.setSortBy("price_asc");
        assertThat(service.filterProducts(filter)).extracting(Product::getName)
                .containsExactly("Tivi Legacy", "Tivi Alpha", "Tivi Original");
        filter.setSortBy("price_desc");
        assertThat(service.filterProducts(filter)).extracting(Product::getName)
                .containsExactly("Tivi Original", "Tivi Alpha", "Tivi Legacy");
    }

    @Test
    void ratingFilterIgnoresHiddenReviewsAndUnreviewedProducts() {
        var filter = new ProductFilterRequest();
        filter.setMinRating(4.0);
        assertThat(service.filterProducts(filter)).extracting(Product::getName).containsExactly("Tivi Alpha");
    }

    @Test
    void paginationReportsFullTotalAndNormalizesUnsafePageSettings() {
        var filter = new ProductFilterRequest();
        filter.setSize(2);
        filter.setPage(1);
        var page = service.filterProductsPage(filter);
        assertThat(page.getTotalElements()).isEqualTo(5);
        assertThat(page.getTotalPages()).isEqualTo(3);
        assertThat(page.getContent()).hasSize(2);
        filter.setSize(999);
        filter.setPage(-1);
        filter.setSortBy("unknown");
        var safe = service.filterProductsPage(filter);
        assertThat(safe.getSize()).isEqualTo(48);
        assertThat(safe.getNumber()).isZero();
        assertThat(filter.getSortBy()).isEqualTo("newest");
    }

    private Product product(String name, Category category, Brand brand, String original,
            String discount, String price, boolean active) {
        return persist(Product.builder().name(name).slug(name.replace(' ', '-')).sku(name)
                .category(category).brand(brand).originalPrice(new BigDecimal(original))
                .discountPrice(discount == null ? null : new BigDecimal(discount))
                .price(price == null ? null : new BigDecimal(price)).active(active).build());
    }

    private void stock(Product product, Branch branch, int quantity, int reserved) {
        persist(BranchInventory.builder().product(product).branch(branch)
                .stockQuantity(quantity).reservedQuantity(reserved).build());
    }

    private <T> T persist(T entity) {
        em.persist(entity);
        return entity;
    }
}
