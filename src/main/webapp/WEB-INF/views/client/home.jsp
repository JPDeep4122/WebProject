<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!-- Nhúng Header -->
<jsp:include page="fragments/header.jsp" />

<!-- BANNER CHÍNH CỦA TRANG CHỦ -->
<section class="py-4">
	<div class="container-fluid">
		<div class="row g-3">

			<!-- Banner lớn bên trái -->
			<div class="col-lg-8">
				<div
					class="p-5 bg-primary text-white rounded-4 position-relative overflow-hidden"
					style="min-height: 420px; background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);">
					<div class="col-md-8">
						<span
							class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold mb-3">SIÊU
							SALE ĐIỆN MÁY 2026</span>
						<h1 class="display-5 fw-bold mb-3">Tivi OLED & Loa Soundbar
							Giảm Đến 40%</h1>
						<p class="lead mb-4">Trải nghiệm không gian rạp chiếu phim
							đỉnh cao ngay tại nhà với công nghệ hình ảnh sắc nét nhất.</p>
						<a href="#"
							class="btn btn-warning btn-lg px-4 fw-bold rounded-pill shadow">MUA
							NGAY BÂY GIỜ</a>
					</div>
				</div>
			</div>

			<!-- 2 Banner nhỏ bên phải -->
			<div class="col-lg-4 d-flex flex-column gap-3">
				<div
					class="p-4 bg-light rounded-4 border h-100 d-flex flex-column justify-content-center">
					<span class="text-danger fw-bold small">MÁY GIẶT CỬA TRƯỚC</span>
					<h4 class="fw-bold mt-1">Giặt Hơi Nước Diệt Khuẩn</h4>
					<p class="text-muted small mb-2">Tiết kiệm 50% điện nước</p>
					<a href="#" class="text-primary fw-bold text-decoration-none small">Xem
						chi tiết <i class="bi bi-arrow-right"></i>
					</a>
				</div>
				<div
					class="p-4 bg-light rounded-4 border h-100 d-flex flex-column justify-content-center">
					<span class="text-success fw-bold small">TỦ LẠNH SIDE BY
						SIDE</span>
					<h4 class="fw-bold mt-1">Làm Lạnh Đa Chiều Inverter</h4>
					<p class="text-muted small mb-2">Bảo hành động cơ 10 năm</p>
					<a href="#" class="text-primary fw-bold text-decoration-none small">Xem
						chi tiết <i class="bi bi-arrow-right"></i>
					</a>
				</div>
			</div>

		</div>
	</div>
</section>

<!-- DANH MỤC NỔI BẬT -->
<section class="py-4">
	<div class="container-fluid">
		<div class="d-flex justify-content-between align-items-center mb-3">
			<h3 class="fw-bold mb-0">Danh Mục Nổi Bật</h3>
			<a href="#" class="text-decoration-none fw-bold small">Xem tất cả
				<i class="bi bi-chevron-right"></i>
			</a>
		</div>

		<div
			class="row row-cols-2 row-cols-md-4 row-cols-lg-6 g-3 text-center">
			<div class="col">
				<div class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-light">
					<i class="bi bi-tv fs-1 text-primary mb-2"></i>
					<h6 class="fw-bold mb-0">Tivi</h6>
					<small class="text-muted">120+ mẫu</small>
				</div>
			</div>
			<div class="col">
				<div class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-light">
					<i class="bi bi-snow2 fs-1 text-info mb-2"></i>
					<h6 class="fw-bold mb-0">Tủ lạnh</h6>
					<small class="text-muted">85+ mẫu</small>
				</div>
			</div>
			<div class="col">
				<div class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-light">
					<i class="bi bi-water fs-1 text-primary mb-2"></i>
					<h6 class="fw-bold mb-0">Máy giặt</h6>
					<small class="text-muted">64+ mẫu</small>
				</div>
			</div>
			<div class="col">
				<div class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-light">
					<i class="bi bi-wind fs-1 text-success mb-2"></i>
					<h6 class="fw-bold mb-0">Máy lạnh</h6>
					<small class="text-muted">90+ mẫu</small>
				</div>
			</div>
			<div class="col">
				<div class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-light">
					<i class="bi bi-phone fs-1 text-warning mb-2"></i>
					<h6 class="fw-bold mb-0">Gia dụng</h6>
					<small class="text-muted">250+ mẫu</small>
				</div>
			</div>
			<div class="col">
				<div class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-light">
					<i class="bi bi-speaker fs-1 text-danger mb-2"></i>
					<h6 class="fw-bold mb-0">Loa & Âm thanh</h6>
					<small class="text-muted">45+ mẫu</small>
				</div>
			</div>
		</div>
	</div>
</section>

<!-- Nhúng Footer -->
<jsp:include page="fragments/footer.jsp" />