<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!-- Nhúng Header -->
<jsp:include page="fragments/header.jsp" />

<!-- BANNER CHÍNH -->
<section class="py-4">
	<div class="container-fluid">
		<div class="row g-3">
			<div class="col-lg-8">
				<div
					class="p-5 text-white rounded-4 position-relative overflow-hidden"
					style="min-height: 380px; background: linear-gradient(135deg, #0d6efd 0%, #052c65 100%);">
					<div class="col-md-8">
						<span
							class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold mb-3">SIÊU
							SALE ĐIỆN MÁY 2026</span>
						<h1 class="display-5 fw-bold mb-3">Tivi OLED & Loa Soundbar
							Giảm Đến 40%</h1>
						<p class="lead mb-4">Trải nghiệm rạp chiếu phim đỉnh cao tại
							gia. Bảo hành 2 năm toàn quốc.</p>
						<a href="#featured-section"
							class="btn btn-warning btn-lg px-4 fw-bold rounded-pill shadow">MUA
							NGAY</a>
					</div>
				</div>
			</div>
			<div class="col-lg-4 d-flex flex-column gap-3">
				<div
					class="p-4 bg-light rounded-4 border h-100 d-flex flex-column justify-content-center">
					<span class="text-danger fw-bold small">MÁY GIẶT CỬA TRƯỚC</span>
					<h5 class="fw-bold mt-1">Giặt Hơi Nước Diệt Khuẩn AI</h5>
					<p class="text-muted small mb-0">Tiết kiệm 50% điện nước</p>
				</div>
				<div
					class="p-4 bg-light rounded-4 border h-100 d-flex flex-column justify-content-center">
					<span class="text-success fw-bold small">TỦ LẠNH SIDE BY
						SIDE</span>
					<h5 class="fw-bold mt-1">Làm Lạnh Đa Chiều Inverter</h5>
					<p class="text-muted small mb-0">Bảo hành động cơ 10 năm</p>
				</div>
			</div>
		</div>
	</div>
</section>

<!-- DANH MỤC SẢN PHẨM TỪ CSDL -->
<section class="py-3">
	<div class="container-fluid">
		<h4 class="fw-bold mb-3">Danh Mục Sản Phẩm</h4>
		<div
			class="row row-cols-2 row-cols-md-4 row-cols-lg-6 g-3 text-center">
			<c:forEach items="${categories}" var="cat">
				<div class="col">
					<a href="#" class="text-decoration-none text-dark">
						<div
							class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-light hover-shadow">
							<i class="bi ${cat.icon} fs-1 text-primary mb-2"></i>
							<h6 class="fw-bold mb-0">${cat.name}</h6>
						</div>
					</a>
				</div>
			</c:forEach>
		</div>
	</div>
</section>

<!-- TOP 20 SẢN PHẨM: 4 TAB -->
<section class="py-5 bg-white" id="top20-section">
	<div class="container-fluid">
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
										<button
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm">
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
										<button
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm">
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
										<button
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm">
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
										<button
											class="btn btn-outline-primary w-100 rounded-pill mt-3 fw-bold btn-sm">
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