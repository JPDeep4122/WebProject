<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="fragments/header.jsp" />

<main class="storefront-container catalog-page">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb catalog-breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li class="breadcrumb-item active" aria-current="page">Danh sách sản phẩm</li>
        </ol>
    </nav>
    <div class="catalog-page-heading">
        <div>
            <p class="catalog-eyebrow">Khám phá TECHSEVEN</p>
            <h1><c:choose><c:when test="${not empty filter.keyword}">Kết quả tìm kiếm</c:when><c:otherwise>Danh sách sản phẩm</c:otherwise></c:choose></h1>
            <c:if test="${not empty filter.keyword}"><p class="catalog-search-term">Từ khóa: <strong><c:out value="${filter.keyword}"/></strong></p></c:if>
        </div>
        <span class="catalog-total"><fmt:formatNumber value="${productPage.totalElements}"/> sản phẩm</span>
    </div>

    <div class="catalog-layout">
        <jsp:include page="fragments/catalog-filters.jsp" />
        <section class="catalog-results" aria-label="Kết quả sản phẩm">
            <div class="catalog-toolbar">
                <p role="status">
                    <c:choose>
                        <c:when test="${not empty products}">
                            Hiển thị <strong>${productPage.number * productPage.size + 1} - ${productPage.number * productPage.size + productPage.numberOfElements}</strong>
                            trong <strong>${productPage.totalElements}</strong> sản phẩm
                        </c:when>
                        <c:otherwise>Không có sản phẩm phù hợp</c:otherwise>
                    </c:choose>
                </p>
                <label for="catalogSort">Sắp xếp
                    <select class="catalog-select" id="catalogSort" name="sortBy" form="catalogFiltersForm">
                        <option value="newest" ${filter.sortBy == 'newest' ? 'selected' : ''}>Mới nhất</option>
                        <option value="price_asc" ${filter.sortBy == 'price_asc' ? 'selected' : ''}>Giá thấp đến cao</option>
                        <option value="price_desc" ${filter.sortBy == 'price_desc' ? 'selected' : ''}>Giá cao đến thấp</option>
                        <option value="bestseller" ${filter.sortBy == 'bestseller' ? 'selected' : ''}>Bán chạy</option>
                        <option value="rating" ${filter.sortBy == 'rating' ? 'selected' : ''}>Đánh giá cao</option>
                        <option value="favorite" ${filter.sortBy == 'favorite' ? 'selected' : ''}>Được yêu thích</option>
                    </select>
                </label>
            </div>


	<c:choose>
		<c:when test="${empty products}">
			<div class="text-center py-5 bg-white rounded-4 shadow-sm border">
				<i class="bi bi-emoji-frown fs-1 text-muted"></i>
				<h5 class="mt-3 fw-bold">Không tìm thấy sản phẩm phù hợp</h5>
				<p class="text-muted small">Thử thay đổi mức giá, thương hiệu hoặc tình trạng hàng.</p>
				<a href="${pageContext.request.contextPath}/products"
					class="btn btn-primary rounded-pill btn-sm px-4">Xem tất cả sản phẩm</a>
			</div>
		</c:when>

		<c:otherwise>
			<div
				class="catalog-products-grid">
				<c:forEach items="${products}" var="prod">
                    <c:set var="sellingPrice" value="${prod.sellingPrice}"/>
                    <c:url var="productUrl" value="/products/${prod.slug}"/>
					<div class="col">
						<div
							class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden position-relative">

							
							<c:if
								test="${sellingPrice < prod.originalPrice}">
								<span
									class="position-absolute top-0 start-0 bg-danger text-white px-2 py-1 m-2 rounded-pill small fw-bold z-2">
									Ưu đãi </span>
							</c:if>

							
							<a
								href="<c:out value='${productUrl}'/>"
								class="catalog-product-image" aria-label="<c:out value='${prod.name}'/>">
                                <span class="catalog-image-fallback" aria-hidden="true"><i class="bi bi-image"></i></span>
                                <img
								data-catalog-product-image src="<c:out value='${prod.mainImageUrl}'/>"
								class="img-fluid h-100 object-fit-contain rounded-3" loading="lazy" decoding="async"
								alt="<c:out value='${prod.name}'/>">
							</a>

							
							<div class="card-body d-flex flex-column p-3">
								<small class="text-muted text-uppercase fw-bold"><c:out value='${prod.brand.name}'/>
									• <c:out value='${prod.category.name}'/></small> <a
									href="<c:out value='${productUrl}'/>"
									class="text-decoration-none text-dark">
									<h6 class="card-title fw-bold mt-1" style="min-height: 48px;"
										title="<c:out value='${prod.name}'/>"><c:out value='${prod.name}'/></h6>
								</a>

								
								<div class="mt-auto pt-2">
									<div class="d-flex align-items-baseline gap-2">
										<span class="text-danger fs-5 fw-bold"> <fmt:formatNumber
												value="${sellingPrice}" type="number"
												groupingUsed="true" /> ₫
										</span>
										<c:if test="${sellingPrice < prod.originalPrice}">
											<span class="text-muted text-decoration-line-through small">
												<fmt:formatNumber value="${prod.originalPrice}"
													type="number" groupingUsed="true" /> ₫
											</span>
										</c:if>
									</div>

									
									<div class="d-flex align-items-center gap-2 mb-2">

										<c:choose>
											<c:when test="${prod.reviewCount gt 0}">
												<span class="badge bg-warning-subtle text-warning-emphasis">
													<i class="bi bi-star-fill text-warning"></i> <fmt:formatNumber
														value="${prod.rating}" minFractionDigits="1"
														maxFractionDigits="1" /> (<c:out
														value="${prod.reviewCount}" />)
												</span>
											</c:when>

											<c:otherwise>
												<span class="small text-muted"> Chưa có đánh giá </span>
											</c:otherwise>
										</c:choose>

										<small class="text-muted"> Đã bán ${prod.soldQuantity != null ? prod.soldQuantity : 0}
										</small>

									</div>

									
									<button
										class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm"
										type="button" onclick="addToCart(${prod.id}, 1, this)">
										<i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ
									</button>
								</div>

							</div>
						</div>
					</div>
				</c:forEach>
			</div>
		</c:otherwise>
	</c:choose>

            <c:if test="${productPage.totalPages gt 1}">
                <nav class="catalog-pagination" aria-label="Phân trang sản phẩm">
                    <c:if test="${not empty previousPageUrl}"><a href="<c:out value='${previousPageUrl}'/>" aria-label="Trang trước"><i class="bi bi-chevron-left" aria-hidden="true"></i></a></c:if>
                    <c:forEach items="${pageLinks}" var="pageLink">
                        <a class="${pageLink.current ? 'is-current' : ''}" href="<c:out value='${pageLink.url}'/>"
                           aria-current="${pageLink.current ? 'page' : 'false'}"><c:out value="${pageLink.label}"/></a>
                    </c:forEach>
                    <c:if test="${not empty nextPageUrl}"><a href="<c:out value='${nextPageUrl}'/>" aria-label="Trang sau"><i class="bi bi-chevron-right" aria-hidden="true"></i></a></c:if>
                </nav>
            </c:if>
        </section>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/catalog-filters.js" defer></script>
<jsp:include page="fragments/footer.jsp" />
