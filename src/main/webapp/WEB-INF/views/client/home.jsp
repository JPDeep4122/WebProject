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

<!-- SẢN PHẨM NỔI BẬT (LẤY TỰ ĐỘNG TỪ CSDL QUA JSTL) -->
<section class="py-4" id="featured-section">
	<div class="container-fluid">
		<div class="d-flex justify-content-between align-items-center mb-4">
			<h3 class="fw-bold mb-0 text-primary">
				<i class="bi bi-fire text-danger"></i> Sản Phẩm Nổi Bật
			</h3>
			<span class="badge bg-danger px-3 py-2 rounded-pill">Hot nhất
				tuần</span>
		</div>

		<div
			class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
			<c:forEach items="${featuredProducts}" var="prod">
				<div class="col">
					<div
						class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden position-relative">

						<!-- Badge Giảm giá -->
						<c:if
							test="${prod.discountPrice != null && prod.discountPrice < prod.originalPrice}">
							<span
								class="position-absolute top-0 start-0 bg-danger text-white px-2 py-1 m-2 rounded-pill small fw-bold z-1">
								Giảm giá sốc </span>
						</c:if>

						<!-- Ảnh sản phẩm -->
						<div class="text-center p-3" style="height: 220px;">
							<img src="${prod.mainImageUrl}"
								class="img-fluid h-100 object-fit-contain rounded-3"
								alt="${prod.name}">
						</div>

						<!-- Nội dung sản phẩm -->
						<div class="card-body d-flex flex-column p-3">
							<small class="text-muted text-uppercase fw-bold">${prod.brand.name}
								• ${prod.category.name}</small> <a
								href="${pageContext.request.contextPath}/products/${prod.slug}"
								class="text-decoration-none text-dark">
								<h6 class="card-title fw-bold mt-1 text-truncate-2"
									style="height: 48px;" title="${prod.name}">${prod.name}</h6>
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
											<fmt:formatNumber value="${prod.originalPrice}" type="number"
												groupingUsed="true" /> ₫
										</span>
									</c:if>
								</div>

								<!-- Nút thao tác -->
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

	</div>
</section>

<!-- Nhúng Footer -->
<jsp:include page="fragments/footer.jsp" />