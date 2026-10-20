<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!-- Nhúng Header -->
<jsp:include page="fragments/header.jsp" />

<c:choose>
	<c:when test="${not empty topBestseller}">
		<c:set var="heroProduct" value="${topBestseller[0]}" />
	</c:when>
	<c:when test="${not empty topNewest}">
		<c:set var="heroProduct" value="${topNewest[0]}" />
	</c:when>
</c:choose>

<section class="sf-home-hero">
	<div class="storefront-container">
		<div class="sf-hero-grid">

			<div class="sf-hero-main">
				<div>
					<p class="sf-eyebrow">Điện máy cho mọi nhà</p>

					<h1>
						Chọn thiết bị tốt.<br>Sống tiện nghi hơn.
					</h1>

					<p class="sf-hero-description">Khám phá tivi, tủ lạnh, máy giặt
						và thiết bị gia dụng phù hợp với không gian sống của bạn.</p>

					<a class="sf-primary-action"
						href="${pageContext.request.contextPath}/products"> Khám phá
						sản phẩm </a>
				</div>

				<div class="sf-hero-visual">
					<c:choose>
						<c:when test="${not empty heroProduct.mainImageUrl}">
							<img src="<c:out value='${heroProduct.mainImageUrl}'/>"
								alt="<c:out value='${heroProduct.name}'/>" fetchpriority="high">
						</c:when>
						<c:otherwise>
							<i class="bi bi-tv" aria-hidden="true"></i>
						</c:otherwise>
					</c:choose>
				</div>
			</div>

			<aside class="sf-hero-side" aria-label="Gợi ý mua sắm">
				<p class="sf-eyebrow">Khám phá ngay</p>
				<h2>Gợi ý mua sắm</h2>

				<div class="sf-shortcuts">
					<a
						href="${pageContext.request.contextPath}/products?sortBy=bestseller">
						<i class="bi bi-fire" aria-hidden="true"></i> Sản phẩm bán chạy
					</a> <a
						href="${pageContext.request.contextPath}/products?sortBy=newest">
						<i class="bi bi-stars" aria-hidden="true"></i> Sản phẩm mới nhất
					</a> <a
						href="${pageContext.request.contextPath}/products?sortBy=rating">
						<i class="bi bi-star" aria-hidden="true"></i> Đánh giá cao
					</a> <a href="${pageContext.request.contextPath}/vouchers"> <i
						class="bi bi-ticket-perforated" aria-hidden="true"></i> Khám phá
						voucher
					</a>
				</div>
			</aside>

		</div>
	</div>
</section>

<section class="sf-category-section">
	<div class="storefront-container">

		<div class="sf-section-heading">
			<h2>Mua sắm theo danh mục</h2>

			<a href="${pageContext.request.contextPath}/products"> Xem tất cả
			</a>
		</div>

		<div class="sf-category-grid">
			<c:forEach items="${categories}" var="cat">
				<c:if test="${cat.active}">
					<c:url var="categoryUrl" value="/products/category/${cat.slug}" />

					<a class="sf-category-card" href="<c:out value='${categoryUrl}'/>">
						<i class="bi <c:out value='${cat.icon}'/>" aria-hidden="true"></i>
						<span><c:out value="${cat.name}" /></span>
					</a>
				</c:if>
			</c:forEach>
		</div>

	</div>
</section>


<!-- TOP 20 SẢN PHẨM: 4 TAB -->
<section class="py-5 bg-white" id="top20-section">
	<div class="storefront-container">
		<!-- TIÊU ĐỀ VÀ TAB NAVIGATION -->
		<div
			class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3 border-bottom pb-3">
			<div>
				<h3 class="fw-bold mb-1 text-primary">
					<i class="bi bi-trophy-fill text-warning me-2"></i>TOP 20 SẢN PHẨM
					HÀNG ĐẦU
				</h3>
				<p class="text-muted small mb-0">Các dòng thiết bị điện máy được
					quan tâm nhiều nhất</p>
			</div>

			<!-- 4 TAB PILLS -->
			<ul class="nav nav-pills gap-2" id="top20Tabs" role="tablist">
				<li class="nav-item" role="presentation">
					<button class="nav-link active rounded-pill fw-bold"
						id="newest-tab" data-bs-toggle="pill" data-bs-target="#tab-newest"
						type="button" role="tab">
						<i class="bi bi-stars me-1"></i> Mới Nhất
					</button>
				</li>
				<li class="nav-item" role="presentation">
					<button class="nav-link rounded-pill fw-bold" id="bestseller-tab"
						data-bs-toggle="pill" data-bs-target="#tab-bestseller"
						type="button" role="tab">
						<i class="bi bi-fire text-danger me-1"></i> Bán Chạy
					</button>
				</li>
				<li class="nav-item" role="presentation">
					<button class="nav-link rounded-pill fw-bold" id="rating-tab"
						data-bs-toggle="pill" data-bs-target="#tab-rating" type="button"
						role="tab">
						<i class="bi bi-star-fill text-warning me-1"></i> Đánh Giá Cao
					</button>
				</li>
				<li class="nav-item" role="presentation">
					<button class="nav-link rounded-pill fw-bold" id="favorite-tab"
						data-bs-toggle="pill" data-bs-target="#tab-favorite" type="button"
						role="tab">
						<i class="bi bi-heart-fill text-danger me-1"></i> Yêu Thích
					</button>
				</li>
			</ul>
		</div>

		<!-- NỘI DUNG CÁC TAB -->
		<div class="tab-content" id="top20TabsContent">

			<!-- TAB 1: MỚI NHẤT -->
			<div class="tab-pane fade show active" id="tab-newest"
				role="tabpanel">
				<div
					class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
					<c:forEach items="${topNewest}" var="prod" varStatus="loop">
						<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
							<!-- CARD SẢN PHẨM -->
							<div
								class="card h-100 border shadow-sm rounded-4 overflow-hidden position-relative hover-shadow">
								<span
									class="position-absolute top-0 start-0 bg-primary text-white px-2 py-1 m-2 rounded-pill small fw-bold z-1">
									Mới </span> <a
									href="${pageContext.request.contextPath}/products/${prod.slug}"
									class="text-center p-3 d-block" style="height: 220px;"> <img
									src="${prod.mainImageUrl}"
									class="img-fluid h-100 object-fit-contain" alt="${prod.name}">
								</a>
								<div class="card-body d-flex flex-column p-3">
									<small class="text-muted text-uppercase fw-bold">${prod.brand.name}
										• ${prod.category.name}</small> <a
										href="${pageContext.request.contextPath}/products/${prod.slug}"
										class="text-decoration-none text-dark">
										<h6 class="card-title fw-bold mt-1 text-truncate-2"
											style="height: 48px;" title="${prod.name}">${prod.name}</h6>
									</a>
									<div class="d-flex align-items-center gap-2 mb-2">
										<span
											class="badge bg-warning-subtle text-warning-emphasis fw-bold">
											<i class="bi bi-star-fill text-warning"></i> ${prod.rating != null ? prod.rating : 5.0}
										</span> <small class="text-muted">Đã bán ${prod.soldQuantity != null ? prod.soldQuantity : 0}</small>
									</div>
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
										<button type="button"
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm"
											onclick="addToCart(${prod.id}, 1, this)">
											<i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ
										</button>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
				<c:if test="${topNewest.size() > 8}">
					<div class="text-center mt-4">
						<button class="btn btn-outline-primary px-4 rounded-pill fw-bold"
							onclick="loadMore(this)">
							Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
						</button>
					</div>
				</c:if>
			</div>

			<!-- TAB 2: BÁN CHẠY -->
			<div class="tab-pane fade" id="tab-bestseller" role="tabpanel">
				<div
					class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
					<c:forEach items="${topBestseller}" var="prod" varStatus="loop">
						<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
							<div
								class="card h-100 border shadow-sm rounded-4 overflow-hidden position-relative hover-shadow">
								<span
									class="position-absolute top-0 start-0 bg-danger text-white px-2 py-1 m-2 rounded-pill small fw-bold z-1">
									Hot 🔥 </span> <a
									href="${pageContext.request.contextPath}/products/${prod.slug}"
									class="text-center p-3 d-block" style="height: 220px;"> <img
									src="${prod.mainImageUrl}"
									class="img-fluid h-100 object-fit-contain" alt="${prod.name}">
								</a>
								<div class="card-body d-flex flex-column p-3">
									<small class="text-muted text-uppercase fw-bold">${prod.brand.name}
										• ${prod.category.name}</small> <a
										href="${pageContext.request.contextPath}/products/${prod.slug}"
										class="text-decoration-none text-dark">
										<h6 class="card-title fw-bold mt-1 text-truncate-2"
											style="height: 48px;" title="${prod.name}">${prod.name}</h6>
									</a>
									<div class="d-flex align-items-center gap-2 mb-2">
										<span
											class="badge bg-warning-subtle text-warning-emphasis fw-bold">
											<i class="bi bi-star-fill text-warning"></i> ${prod.rating != null ? prod.rating : 5.0}
										</span> <small class="text-muted">Đã bán ${prod.soldQuantity != null ? prod.soldQuantity : 0}</small>
									</div>
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
										<button type="button"
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm"
											onclick="addToCart(${prod.id}, 1, this)">
											<i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ
										</button>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
				<c:if test="${topBestseller.size() > 8}">
					<div class="text-center mt-4">
						<button class="btn btn-outline-primary px-4 rounded-pill fw-bold"
							onclick="loadMore(this)">
							Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
						</button>
					</div>
				</c:if>
			</div>

			<!-- TAB 3: ĐÁNH GIÁ CAO -->
			<div class="tab-pane fade" id="tab-rating" role="tabpanel">
				<div
					class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
					<c:forEach items="${topRating}" var="prod" varStatus="loop">
						<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
							<div
								class="card h-100 border shadow-sm rounded-4 overflow-hidden position-relative hover-shadow">
								<span
									class="position-absolute top-0 start-0 bg-warning text-dark px-2 py-1 m-2 rounded-pill small fw-bold z-1">
									⭐ ${prod.rating} </span> <a
									href="${pageContext.request.contextPath}/products/${prod.slug}"
									class="text-center p-3 d-block" style="height: 220px;"> <img
									src="${prod.mainImageUrl}"
									class="img-fluid h-100 object-fit-contain" alt="${prod.name}">
								</a>
								<div class="card-body d-flex flex-column p-3">
									<small class="text-muted text-uppercase fw-bold">${prod.brand.name}
										• ${prod.category.name}</small> <a
										href="${pageContext.request.contextPath}/products/${prod.slug}"
										class="text-decoration-none text-dark">
										<h6 class="card-title fw-bold mt-1 text-truncate-2"
											style="height: 48px;" title="${prod.name}">${prod.name}</h6>
									</a>
									<div class="d-flex align-items-center gap-2 mb-2">
										<span
											class="badge bg-warning-subtle text-warning-emphasis fw-bold">
											<i class="bi bi-star-fill text-warning"></i> ${prod.rating != null ? prod.rating : 5.0}
										</span> <small class="text-muted">Đã bán ${prod.soldQuantity != null ? prod.soldQuantity : 0}</small>
									</div>
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
										<button type="button"
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm"
											onclick="addToCart(${prod.id}, 1, this)">
											<i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ
										</button>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
				<c:if test="${topRating.size() > 8}">
					<div class="text-center mt-4">
						<button class="btn btn-outline-primary px-4 rounded-pill fw-bold"
							onclick="loadMore(this)">
							Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
						</button>
					</div>
				</c:if>
			</div>

			<!-- TAB 4: YÊU THÍCH -->
			<div class="tab-pane fade" id="tab-favorite" role="tabpanel">
				<div
					class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
					<c:forEach items="${topFavorite}" var="prod" varStatus="loop">
						<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
							<div
								class="card h-100 border shadow-sm rounded-4 overflow-hidden position-relative hover-shadow">
								<span
									class="position-absolute top-0 start-0 bg-danger text-white px-2 py-1 m-2 rounded-pill small fw-bold z-1">
									❤️ ${prod.favoriteCount} </span> <a
									href="${pageContext.request.contextPath}/products/${prod.slug}"
									class="text-center p-3 d-block" style="height: 220px;"> <img
									src="${prod.mainImageUrl}"
									class="img-fluid h-100 object-fit-contain" alt="${prod.name}">
								</a>
								<div class="card-body d-flex flex-column p-3">
									<small class="text-muted text-uppercase fw-bold">${prod.brand.name}
										• ${prod.category.name}</small> <a
										href="${pageContext.request.contextPath}/products/${prod.slug}"
										class="text-decoration-none text-dark">
										<h6 class="card-title fw-bold mt-1 text-truncate-2"
											style="height: 48px;" title="${prod.name}">${prod.name}</h6>
									</a>
									<div class="d-flex align-items-center gap-2 mb-2">
										<span
											class="badge bg-warning-subtle text-warning-emphasis fw-bold">
											<i class="bi bi-star-fill text-warning"></i> ${prod.rating != null ? prod.rating : 5.0}
										</span> <small class="text-muted">Đã bán ${prod.soldQuantity != null ? prod.soldQuantity : 0}</small>
									</div>
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
										<button type="button"
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm"
											onclick="addToCart(${prod.id}, 1, this)">
											<i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ
										</button>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
				<c:if test="${topFavorite.size() > 8}">
					<div class="text-center mt-4">
						<button class="btn btn-outline-primary px-4 rounded-pill fw-bold"
							onclick="loadMore(this)">
							Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
						</button>
					</div>
				</c:if>
			</div>

		</div>
	</div>
</section>

<!-- SCRIPT XỬ LÝ LAZY LOAD-->
<script>
	function loadMore(btn) {
		const tabPane = btn.closest('.tab-pane');
		const hiddenItems = tabPane.querySelectorAll('.product-item.d-none');

		// Mở khóa thêm 8 sản phẩm tiếp theo (lazy loading)
		for (let i = 0; i < Math.min(8, hiddenItems.length); i++) {
			hiddenItems[i].classList.remove('d-none');
		}

		// Nếu đã hiển thị hết cả 20 sản phẩm thì ẩn nút Xem thêm
		if (tabPane.querySelectorAll('.product-item.d-none').length === 0) {
			btn.parentElement.style.display = 'none';
		}
	}
</script>

<!-- Nhúng Footer -->
<jsp:include page="fragments/footer.jsp" />