<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="fragments/header.jsp" />

<div class="container-fluid py-4">

	<!-- BREADCRUMB -->
	<nav aria-label="breadcrumb" class="mb-3">
		<ol class="breadcrumb small">
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/"
				class="text-decoration-none">Trang chủ</a></li>
			<li class="breadcrumb-item active">Danh sách sản phẩm</li>
		</ol>
	</nav>

	<!-- KHU VỰC BỘ LỌC PHONG CÁCH NÚT BẤM -->
	<div class="bg-white p-4 rounded-4 shadow-sm mb-4 border">

		<!-- 1. Lọc theo Thương hiệu -->
		<div class="mb-3">
			<div class="fw-bold text-dark mb-2 small text-uppercase">
				<i class="bi bi-tag-fill text-primary"></i> Thương hiệu:
			</div>
			<div class="d-flex flex-wrap gap-2">
				<button type="button" onclick="filterByBrand('')"
					class="btn btn-sm rounded-pill ${empty filter.brandIds ? 'btn-primary text-white' : 'btn-outline-secondary'}">
					Tất cả</button>
				<c:forEach items="${brands}" var="b">
					<button type="button" onclick="filterByBrand('${b.id}')"
						class="btn btn-sm rounded-pill ${filter.brandIds != null && filter.brandIds.contains(b.id) ? 'btn-primary text-white' : 'btn-outline-secondary'}">
						${b.name}</button>
				</c:forEach>
			</div>
		</div>

		<!-- 2. Lọc theo Phân khúc giá -->
		<div class="mb-3">
			<div class="fw-bold text-dark mb-2 small text-uppercase">
				<i class="bi bi-cash-stack text-success"></i> Mức giá:
			</div>
			<div class="d-flex flex-wrap gap-2">
				<button type="button" onclick="filterByPrice('', '')"
					class="btn btn-sm rounded-pill ${empty filter.minPrice && empty filter.maxPrice ? 'btn-success text-white' : 'btn-outline-secondary'}">
					Tất cả mức giá</button>
				<button type="button" onclick="filterByPrice('', '5000000')"
					class="btn btn-sm rounded-pill ${filter.maxPrice == 5000000 && empty filter.minPrice ? 'btn-success text-white' : 'btn-outline-secondary'}">
					Dưới 5 triệu</button>
				<button type="button" onclick="filterByPrice('5000000', '10000000')"
					class="btn btn-sm rounded-pill ${filter.minPrice == 5000000 && filter.maxPrice == 10000000 ? 'btn-success text-white' : 'btn-outline-secondary'}">
					5 - 10 triệu</button>
				<button type="button"
					onclick="filterByPrice('10000000', '15000000')"
					class="btn btn-sm rounded-pill ${filter.minPrice == 10000000 && filter.maxPrice == 15000000 ? 'btn-success text-white' : 'btn-outline-secondary'}">
					10 - 15 triệu</button>
				<button type="button" onclick="filterByPrice('15000000', '')"
					class="btn btn-sm rounded-pill ${filter.minPrice == 15000000 && empty filter.maxPrice ? 'btn-success text-white' : 'btn-outline-secondary'}">
					Trên 15 triệu</button>
			</div>
		</div>

		<!-- 3. Lọc theo Đánh giá sao -->
		<div class="mb-3">
			<div class="fw-bold text-dark mb-2 small text-uppercase">
				<i class="bi bi-star-fill text-warning"></i> Đánh giá:
			</div>
			<div class="d-flex flex-wrap gap-2">
				<button type="button" onclick="filterByRating('')"
					class="btn btn-sm rounded-pill ${empty filter.minRating ? 'btn-warning text-dark fw-bold' : 'btn-outline-secondary'}">
					Tất cả đánh giá</button>
				<button type="button" onclick="filterByRating('5.0')"
					class="btn btn-sm rounded-pill ${filter.minRating == 5.0 ? 'btn-warning text-dark fw-bold' : 'btn-outline-secondary'}">
					5 <i class="bi bi-star-fill text-warning"></i>
				</button>
				<button type="button" onclick="filterByRating('4.0')"
					class="btn btn-sm rounded-pill ${filter.minRating == 4.0 ? 'btn-warning text-dark fw-bold' : 'btn-outline-secondary'}">
					Từ 4 <i class="bi bi-star-fill text-warning"></i> trở lên
				</button>
				<button type="button" onclick="filterByRating('3.0')"
					class="btn btn-sm rounded-pill ${filter.minRating == 3.0 ? 'btn-warning text-dark fw-bold' : 'btn-outline-secondary'}">
					Từ 3 <i class="bi bi-star-fill text-warning"></i> trở lên
				</button>
			</div>
		</div>

		<!-- 4. Sắp xếp kết quả -->
		<div
			class="d-flex justify-content-between align-items-center pt-2 border-top">
			<div class="small text-muted">
				Tìm thấy <b class="text-primary">${products.size()}</b> sản phẩm
			</div>
			<div class="d-flex align-items-center gap-2">
				<span class="small text-muted">Sắp xếp theo:</span>
				<div class="btn-group btn-group-sm">
					<button type="button" onclick="filterBySort('newest')"
						class="btn ${filter.sortBy == 'newest' || empty filter.sortBy ? 'btn-dark' : 'btn-outline-dark'}">Mới
						nhất</button>
					<button type="button" onclick="filterBySort('price_asc')"
						class="btn ${filter.sortBy == 'price_asc' ? 'btn-dark' : 'btn-outline-dark'}">Giá
						thấp đến cao</button>
					<button type="button" onclick="filterBySort('price_desc')"
						class="btn ${filter.sortBy == 'price_desc' ? 'btn-dark' : 'btn-outline-dark'}">Giá
						cao đến thấp</button>
				</div>
			</div>
		</div>

	</div>

	<!-- LƯỚI DANH SÁCH SẢN PHẨM SAU KHI LỌC   -->
	<c:choose>
		<c:when test="${empty products}">
			<div class="text-center py-5 bg-white rounded-4 shadow-sm border">
				<i class="bi bi-emoji-frown fs-1 text-muted"></i>
				<h5 class="mt-3 fw-bold">Không tìm thấy sản phẩm phù hợp</h5>
				<p class="text-muted small">Hãy thử chọn lại mức giá hoặc thương
					hiệu khác</p>
				<a href="${pageContext.request.contextPath}/products"
					class="btn btn-primary rounded-pill btn-sm px-4">Xóa tất cả bộ
					lọc</a>
			</div>
		</c:when>

		<c:otherwise>
			<div
				class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
				<c:forEach items="${products}" var="prod">
					<div class="col">
						<div
							class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden position-relative">

							<!-- Badge Giảm giá -->
							<c:if
								test="${prod.discountPrice != null && prod.discountPrice < prod.originalPrice}">
								<span
									class="position-absolute top-0 start-0 bg-danger text-white px-2 py-1 m-2 rounded-pill small fw-bold z-1">
									Giảm sốc </span>
							</c:if>

							<!-- Ảnh sản phẩm (Bấm vào để mở trang chi tiết) -->
							<a
								href="${pageContext.request.contextPath}/products/${prod.slug}"
								class="text-center p-3 d-block" style="height: 220px;"> <img
								src="${prod.mainImageUrl}"
								class="img-fluid h-100 object-fit-contain rounded-3"
								alt="${prod.name}">
							</a>

							<!-- Nội dung sản phẩm (Bấm vào tên để mở trang chi tiết) -->
							<div class="card-body d-flex flex-column p-3">
								<small class="text-muted text-uppercase fw-bold">${prod.brand.name}
									• ${prod.category.name}</small> <a
									href="${pageContext.request.contextPath}/products/${prod.slug}"
									class="text-decoration-none text-dark">
									<h6 class="card-title fw-bold mt-1" style="min-height: 48px;"
										title="${prod.name}">${prod.name}</h6>
								</a>

								<!-- Giá tiền VNĐ -->
								<div class="mt-auto pt-2">
									<div class="d-flex align-items-baseline gap-2">
										<span class="text-danger fs-5 fw-bold"> <fmt:formatNumber
												value="${prod.discountPrice}" type="number"
												groupingUsed="true" /> ₫
										</span>
										<c:if test="${prod.discountPrice < prod.originalPrice}">
											<span class="text-muted text-decoration-line-through small">
												<fmt:formatNumber value="${prod.originalPrice}"
													type="number" groupingUsed="true" /> ₫
											</span>
										</c:if>
									</div>

									<!-- Đánh giá sao và Đã bán -->
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

									<!-- Nút thao tác -->
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

</div>

<jsp:include page="fragments/footer.jsp" />

<!-- JAVASCRIPT XỬ LÝ URL FILTER -->
<script>
  function updateFilterParams(updaterCallback) {
    const url = new URL(window.location.href);
    updaterCallback(url.searchParams);
    window.location.href = url.pathname + '?' + url.searchParams.toString();
  }

  // 1. Lọc theo Thương hiệu
  function filterByBrand(brandId) {
    updateFilterParams(params => {
      if (brandId) {
        params.set('brandIds', brandId);
      } else {
        params.delete('brandIds');
      }
    });
  }

  // 2. Lọc theo Khoảng giá
  function filterByPrice(minPrice, maxPrice) {
    updateFilterParams(params => {
      if (minPrice) params.set('minPrice', minPrice); else params.delete('minPrice');
      if (maxPrice) params.set('maxPrice', maxPrice); else params.delete('maxPrice');
    });
  }

  // 3. Sắp xếp
  function filterBySort(sortBy) {
    updateFilterParams(params => {
      if (sortBy) params.set('sortBy', sortBy); else params.delete('sortBy');
    });
  }
  
  // Lọc theo Đánh giá sao
  function filterByRating(rating) {
    updateFilterParams(params => {
      if (rating) {
        params.set('minRating', rating);
      } else {
        params.delete('minRating');
      }
    });
  }
  
  
</script>