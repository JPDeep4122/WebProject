<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<aside class="catalog-sidebar" aria-labelledby="catalogFilterTitle">
    <div class="catalog-filter-card">
        <div class="catalog-filter-heading">
            <div>
                <span class="catalog-filter-eyebrow">Chọn theo nhu cầu</span>
                <h2 id="catalogFilterTitle">Bộ lọc sản phẩm
                    <c:if test="${filterCount gt 0}"><span class="catalog-filter-count"><c:out value="${filterCount}"/></span></c:if>
                </h2>
            </div>
            <button class="catalog-filter-toggle" id="catalogFilterToggle" type="button"
                    aria-expanded="false" aria-controls="catalogFilterContent">
                <i class="bi bi-sliders" aria-hidden="true"></i>
                <span>Hiện bộ lọc</span>
            </button>
        </div>

        <form id="catalogFiltersForm" action="<c:out value='${productsUrl}'/>" method="get">
            <c:if test="${not empty filter.keyword}">
                <input type="hidden" name="keyword" value="${fn:escapeXml(filter.keyword)}">
            </c:if>
            <input type="hidden" name="size" value="${filter.size}">

            <div class="catalog-filter-content" id="catalogFilterContent">
                <div class="catalog-filter-scroll">
                    <details class="catalog-filter-section" open>
                        <summary>Tình trạng hàng <i class="bi bi-chevron-down" aria-hidden="true"></i></summary>
                        <div class="catalog-filter-section-body">
                            <label class="catalog-option" for="filterInStock">
                                <input type="checkbox" id="filterInStock" name="inStockOnly" value="true"
                                       ${filter.inStockOnly ? 'checked' : ''}>
                                <span>Chỉ hiện sản phẩm còn hàng</span>
                            </label>
                            <c:if test="${not empty branches}">
                                <label class="catalog-field-label" for="filterBranch">Hàng tại chi nhánh</label>
                                <select class="catalog-select" id="filterBranch" name="branchId">
                                    <option value="">Tất cả chi nhánh</option>
                                    <c:forEach items="${branches}" var="branch">
                                        <option value="${branch.id}" ${filter.branchId == branch.id ? 'selected' : ''}>
                                            <c:out value="${branch.name}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                                <p class="catalog-field-help">Chọn chi nhánh để xem sản phẩm còn bán được tại đó.</p>
                            </c:if>
                        </div>
                    </details>

                    <details class="catalog-filter-section" open>
                        <summary>Danh mục <i class="bi bi-chevron-down" aria-hidden="true"></i></summary>
                        <div class="catalog-filter-section-body catalog-options">
                            <label class="catalog-option" for="filterCategoryAll">
                                <input type="radio" name="categorySlug" id="filterCategoryAll" value=""
                                       ${empty filter.categorySlug && empty filter.categoryId ? 'checked' : ''}>
                                <span>Tất cả danh mục</span>
                            </label>
                            <c:forEach items="${categories}" var="category">
                                <c:if test="${category.active}">
                                    <label class="catalog-option" for="filterCategory${category.id}">
                                        <input type="radio" name="categorySlug" id="filterCategory${category.id}"
                                               value="${fn:escapeXml(category.slug)}"
                                               ${filter.categorySlug == category.slug || (empty filter.categorySlug && filter.categoryId == category.id) ? 'checked' : ''}>
                                        <span><c:out value="${category.name}"/></span>
                                    </label>
                                </c:if>
                            </c:forEach>
                        </div>
                    </details>

                    <details class="catalog-filter-section" open>
                        <summary>Thương hiệu <i class="bi bi-chevron-down" aria-hidden="true"></i></summary>
                        <div class="catalog-filter-section-body catalog-options">
                            <c:forEach items="${brands}" var="brand">
                                <c:if test="${brand.active}">
                                    <label class="catalog-option" for="filterBrand${brand.id}">
                                        <input type="checkbox" name="brandIds" id="filterBrand${brand.id}" value="${brand.id}"
                                               ${filter.brandIds != null && filter.brandIds.contains(brand.id) ? 'checked' : ''}>
                                        <span><c:out value="${brand.name}"/></span>
                                    </label>
                                </c:if>
                            </c:forEach>
                        </div>
                    </details>

                    <details class="catalog-filter-section" open>
                        <summary>Khoảng giá <i class="bi bi-chevron-down" aria-hidden="true"></i></summary>
                        <div class="catalog-filter-section-body">
                            <div class="catalog-price-inputs">
                                <label for="filterMinPrice">Từ
                                    <span><input type="number" id="filterMinPrice" name="minPrice" min="0" step="1"
                                                 inputmode="numeric" placeholder="Thấp nhất" value="${filter.minPrice}"><b>₫</b></span>
                                </label>
                                <label for="filterMaxPrice">Đến
                                    <span><input type="number" id="filterMaxPrice" name="maxPrice" min="0" step="1"
                                                 inputmode="numeric" placeholder="Cao nhất" value="${filter.maxPrice}"><b>₫</b></span>
                                </label>
                            </div>
                            <div class="catalog-options catalog-price-presets">
                                <label class="catalog-option"><input type="radio" name="pricePreset" value=":"
                                    ${filter.minPrice == null && filter.maxPrice == null ? 'checked' : ''}><span>Tất cả mức giá</span></label>
                                <label class="catalog-option"><input type="radio" name="pricePreset" value=":5000000"
                                    ${filter.minPrice == null && filter.maxPrice == 5000000 ? 'checked' : ''}><span>Đến 5 triệu</span></label>
                                <label class="catalog-option"><input type="radio" name="pricePreset" value="5000000:10000000"
                                    ${filter.minPrice == 5000000 && filter.maxPrice == 10000000 ? 'checked' : ''}><span>5 - 10 triệu</span></label>
                                <label class="catalog-option"><input type="radio" name="pricePreset" value="10000000:20000000"
                                    ${filter.minPrice == 10000000 && filter.maxPrice == 20000000 ? 'checked' : ''}><span>10 - 20 triệu</span></label>
                                <label class="catalog-option"><input type="radio" name="pricePreset" value="20000000:"
                                    ${filter.minPrice == 20000000 && filter.maxPrice == null ? 'checked' : ''}><span>Từ 20 triệu</span></label>
                            </div>
                        </div>
                    </details>

                    <details class="catalog-filter-section" open>
                        <summary>Đánh giá <i class="bi bi-chevron-down" aria-hidden="true"></i></summary>
                        <div class="catalog-filter-section-body catalog-options">
                            <label class="catalog-option"><input type="radio" name="minRating" value=""
                                ${filter.minRating == null || filter.minRating <= 0 ? 'checked' : ''}><span>Tất cả đánh giá</span></label>
                            <label class="catalog-option"><input type="radio" name="minRating" value="5"
                                ${filter.minRating == 5 ? 'checked' : ''}><span><i class="bi bi-star-fill catalog-rating-star" aria-hidden="true"></i> 5 sao</span></label>
                            <label class="catalog-option"><input type="radio" name="minRating" value="4"
                                ${filter.minRating == 4 ? 'checked' : ''}><span><i class="bi bi-star-fill catalog-rating-star" aria-hidden="true"></i> Từ 4 sao</span></label>
                            <label class="catalog-option"><input type="radio" name="minRating" value="3"
                                ${filter.minRating == 3 ? 'checked' : ''}><span><i class="bi bi-star-fill catalog-rating-star" aria-hidden="true"></i> Từ 3 sao</span></label>
                        </div>
                    </details>
                </div>

                <div class="catalog-filter-actions">
                    <button class="catalog-apply" type="submit"><i class="bi bi-funnel" aria-hidden="true"></i> Áp dụng bộ lọc</button>
                    <a class="catalog-clear" href="<c:out value='${clearFiltersUrl}'/>">Xóa các bộ lọc</a>
                </div>
            </div>
        </form>
    </div>
</aside>
<noscript><style>.catalog-sidebar .catalog-filter-content{display:flex!important}.catalog-filter-toggle{display:none!important}</style></noscript>
