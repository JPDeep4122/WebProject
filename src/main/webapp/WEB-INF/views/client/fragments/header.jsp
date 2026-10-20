<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>TECH7 - SHOP ĐIỆN MÁY UY TÍNN</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap 5 & Bootstrap Icons -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap"
	rel="stylesheet">
<style>
body {
	font-family: 'Roboto', sans-serif !important;
}
</style>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<style>
:root {
	--dm-primary: #0b66c3; /* Xanh dương Điện Máy */
	--dm-primary-dark: #094e96;
	--dm-accent: #ffd400; /* Vàng điểm nhấn */
}

.bg-dienmay {
	background-color: var(--dm-primary) !important;
}

.text-dienmay {
	color: var(--dm-primary) !important;
}

.text-accent {
	color: var(--dm-accent) !important;
}

.mega-menu-wrapper {
	position: relative;
	display: inline-block;
}

/* Nút danh mục dạng con nhộng */
.mega-btn-trigger {
	background-color: #ffffff;
	color: #111827;
	font-weight: 600;
	border-radius: 50px;
	padding: 7px 16px;
	border: none;
	display: flex;
	align-items: center;
	gap: 8px;
	cursor: pointer;
	transition: all 0.2s ease;
	white-space: nowrap;
}

.mega-btn-trigger:hover {
	background-color: #f3f4f6;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* Khung Mega Menu Dropdown */
.mega-menu-panel {
	display: none;
	position: absolute;
	top: 100%;
	left: 0;
	width: 980px;
	max-width: 92vw;
	background: #ffffff;
	border-radius: 12px;
	box-shadow: 0 16px 40px rgba(0, 0, 0, 0.22);
	border: 1px solid #e5e7eb;
	z-index: 1060;
	overflow: hidden;
	margin-top: 8px;
}

/* CẦU NỐI VÔ HÌNH: Lấp đầy khoảng hở 14px để chuột di chuyển xuống không bao giờ bị tắt menu */
.mega-menu-panel::before {
	content: '';
	position: absolute;
	top: -14px;
	left: 0;
	width: 100%;
	height: 16px;
	background: transparent;
}

/* Mũi tên tam giác nhỏ trỏ lên nút Danh mục */
.mega-menu-panel::after {
	content: '';
	position: absolute;
	top: -6px;
	left: 42px;
	width: 12px;
	height: 12px;
	background: #ffffff;
	transform: rotate(45deg);
	border-top: 1px solid #e5e7eb;
	border-left: 1px solid #e5e7eb;
}

/* Giữ menu hiển thị khi chuột nằm trong wrapper hoặc trong panel */
.mega-menu-wrapper:hover .mega-menu-panel, .mega-menu-panel:hover,
	.mega-menu-panel.show {
	display: block !important;
	animation: megaFadeIn 0.2s ease-in-out;
}

/* Lớp đệm vô hình đón chuột khi lướt xuống */
.mega-menu-panel::before {
	content: '';
	position: absolute;
	top: -18px;
	left: 0;
	width: 100%;
	height: 22px;
	background: rgba(0, 0, 0, 0.001);
}

@
keyframes megaFadeIn {from { opacity:0;
	transform: translateY(4px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}

/* CỘT TRÁI: DANH SÁCH CÁC NGÀNH HÀNG */
.mega-sidebar {
	width: 240px;
	min-width: 240px;
	background-color: #f8fafc;
	border-right: 1px solid #e2e8f0;
	padding: 8px 0;
}

.mega-sidebar .nav-link {
	color: #334155;
	font-size: 0.88rem;
	padding: 10px 16px;
	border-radius: 0;
	text-align: left;
	font-weight: 500;
	width: 100%;
	display: flex;
	align-items: center;
	justify-content: space-between;
	transition: all 0.15s ease;
	border-left: 3px solid transparent;
	background: none;
	border-top: none;
	border-right: none;
	border-bottom: none;
}

.mega-sidebar .nav-link:hover, .mega-sidebar .nav-link.active {
	background-color: #ffffff !important;
	color: #0b66c3 !important;
	font-weight: 700;
	border-left: 3px solid #0b66c3;
}

/* CỘT PHẢI: NỘI DUNG DANH MỤC CON */
.mega-content {
	background-color: #ffffff;
	height: 480px;
	overflow-y: auto;
	padding: 20px 24px;
}

.mega-grid {
	display: grid;
	grid-template-columns: repeat(6, 1fr);
	gap: 16px 12px;
}

@media ( max-width : 1200px) {
	.mega-grid {
		grid-template-columns: repeat(4, 1fr);
	}
}

/* Thẻ item con (icon + chữ) */
.mega-sub-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	text-align: center;
	text-decoration: none;
	padding: 10px 6px;
	border-radius: 10px;
	transition: all 0.2s ease;
}

.mega-sub-item:hover {
	background-color: #eff6ff;
	transform: translateY(-2px);
}

.mega-sub-icon {
	width: 56px;
	height: 56px;
	border-radius: 12px;
	background-color: #f1f5f9;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 8px;
	font-size: 1.5rem;
	color: #0b66c3;
	transition: all 0.2s;
}

.mega-sub-item:hover .mega-sub-icon {
	background-color: #dbeafe;
	color: #0284c7;
	transform: scale(1.08);
}

.mega-sub-item span {
	font-size: 0.8rem;
	color: #334155;
	line-height: 1.35;
	font-weight: 500;
}

.mega-sub-item:hover span {
	color: #0b66c3;
	font-weight: 600;
}

/* Các thành phần khác trên header*/
.search-pill {
	max-width: 480px;
	background-color: #ffffff;
	border-radius: 50px;
	transition: box-shadow 0.2s;
}

.search-pill:focus-within {
	box-shadow: 0 0 0 3px rgba(255, 212, 0, 0.45);
}

.header-btn {
	color: #ffffff;
	text-decoration: none;
	display: flex;
	align-items: center;
	gap: 6px;
	padding: 6px 10px;
	border-radius: 8px;
	font-size: 0.9rem;
	font-weight: 500;
	transition: background-color 0.2s;
	white-space: nowrap;
}

.header-btn:hover {
	background-color: rgba(255, 255, 255, 0.15);
	color: var(--dm-accent);
}

.location-pill {
	background-color: rgba(255, 255, 255, 0.18);
	border: 1px solid rgba(255, 255, 255, 0.35);
	color: #ffffff;
	font-size: 0.85rem;
	padding: 5px 12px;
	border-radius: 50px;
	text-decoration: none;
	transition: all 0.2s;
}

.location-pill:hover {
	background-color: #ffffff;
	color: var(--dm-primary);
}

/* Tầng 2: Thanh từ khóa nhanh */
.quick-keywords {
	background-color: #f8fafc;
	border-bottom: 1px solid #e2e8f0;
	scrollbar-width: none;
}

.quick-keywords::-webkit-scrollbar {
	display: none;
}

.quick-keyword-item {
	color: #475569;
	font-size: 0.82rem;
	text-decoration: none;
	transition: color 0.15s;
}

.quick-keyword-item:hover {
	color: var(--dm-primary);
	font-weight: 600;
}
</style>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/storefront.css">
	
<jsp:include page="/WEB-INF/views/shared/security.jsp"/>
</head>
<body>

	<!-- MAIN HEADER CHÍNH (Nền Xanh Dương)  -->
	<header class="sf-header sticky-top">

		<div class="storefront-container sf-main-row">

			<a class="sf-brand" href="${pageContext.request.contextPath}/"> <span
				class="sf-brand-mark"> <i class="bi bi-lightning-charge-fill"
					aria-hidden="true"></i>
			</span> <span>TECHSEVEN</span>
			</a>

			<form class="sf-search"
				action="${pageContext.request.contextPath}/products" method="get"
				role="search">

				<label class="visually-hidden" for="storeSearch"> Tìm kiếm
					sản phẩm </label> <input id="storeSearch" type="search" name="keyword"
					value="<c:out value='${param.keyword}'/>"
					placeholder="Bạn đang tìm sản phẩm gì?">

				<button type="submit" aria-label="Tìm kiếm">
					<i class="bi bi-search" aria-hidden="true"></i>
				</button>
			</form>

			<div class="sf-actions">

				<button class="sf-location" type="button" data-bs-toggle="modal"
					data-bs-target="#branchSelectModal" aria-label="Chọn chi nhánh">

					<i class="bi bi-geo-alt" aria-hidden="true"></i> <span
						class="sf-location-text"> <small>Chi nhánh của bạn</small>
						<strong id="currentBranchLabel">Hồ Chí Minh</strong>
					</span>
				</button>

				<div id="userAuthContainer">
					<a href="${pageContext.request.contextPath}/login"
						class="header-btn" aria-label="Tài khoản"> <i
						class="bi bi-person-circle" aria-hidden="true"></i> <span>Tài
							khoản</span>
					</a>
				</div>

				<a href="${pageContext.request.contextPath}/cart"
					class="header-btn sf-cart" aria-label="Giỏ hàng"> <i
					class="bi bi-cart3" aria-hidden="true"></i> <span
					class="sf-action-label">Giỏ hàng</span> <span id="cartBadge"
					class="sf-cart-count" aria-live="polite">0</span>
				</a>

			</div>
		</div>

		<nav class="sf-navigation" aria-label="Điều hướng chính">
			<div class="storefront-container sf-nav-row">

				<jsp:include page="mega-menu.jsp" />

				<!-- Menu dùng trên điện thoại -->
				<div class="dropdown d-md-none">
					<button class="sf-nav-trigger dropdown-toggle" type="button"
						data-bs-toggle="dropdown" aria-expanded="false">
						<i class="bi bi-list" aria-hidden="true"></i> Danh mục
					</button>

					<ul class="dropdown-menu">
						<li><a class="dropdown-item"
							href="${pageContext.request.contextPath}/products"> Tất cả
								sản phẩm </a></li>
						<li><a class="dropdown-item"
							href="${pageContext.request.contextPath}/products/category/tivi">
								Tivi </a></li>
						<li><a class="dropdown-item"
							href="${pageContext.request.contextPath}/products/category/tu-lanh">
								Tủ lạnh </a></li>
						<li><a class="dropdown-item"
							href="${pageContext.request.contextPath}/products/category/may-giat">
								Máy giặt </a></li>
						<li><a class="dropdown-item"
							href="${pageContext.request.contextPath}/products/category/may-lanh">
								Máy lạnh </a></li>
					</ul>
				</div>

				<div class="sf-nav-links">
					<a href="${pageContext.request.contextPath}/products"> Tất cả
						sản phẩm </a> <a
						href="${pageContext.request.contextPath}/products?sortBy=bestseller">
						Bán chạy </a> <a
						href="${pageContext.request.contextPath}/products?sortBy=newest">
						Mới nhất </a> <a href="${pageContext.request.contextPath}/vouchers">
						Voucher </a> <a href="${pageContext.request.contextPath}/orders">
						Đơn hàng </a>
				</div>

			</div>
		</nav>
	</header>

	<!-- CÁC MODAL HỆ THỐNG: AUTH, VOUCHER, CHI NHÁNH-->

	<!-- Login / Register / Forgot Pass (AUTH MODAL) -->
	<div class="modal fade" id="authModal" tabindex="-1" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content rounded-4 border-0 shadow">
				<div class="modal-header border-bottom-0 pb-0">
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>
				<div class="modal-body p-4 pt-0">

					<div id="authAlert" class="alert d-none py-2 small" role="alert"></div>


					<ul class="nav nav-pills nav-fill mb-3" id="authTabs"
						role="tablist">
						<li class="nav-item">
							<button class="nav-link active fw-bold" id="login-tab"
								data-bs-toggle="pill" data-bs-target="#login-pane">ĐĂNG
								NHẬP</button>
						</li>
						<li class="nav-item">
							<button class="nav-link fw-bold" id="register-tab"
								data-bs-toggle="pill" data-bs-target="#register-pane">ĐĂNG
								KÝ</button>
						</li>
					</ul>

					<div class="tab-content">
						<div class="tab-pane fade show active" id="login-pane">
							<form id="loginForm">
								<div class="mb-3">
									<label class="form-label text-muted small fw-bold">Email</label>
									<input type="email" class="form-control rounded-3"
										id="loginEmail" required placeholder="name@example.com">
								</div>
								<div class="mb-3">
									<div class="d-flex justify-content-between align-items-center">
										<label class="form-label text-muted small fw-bold">Mật
											khẩu</label> <a href="javascript:void(0)"
											onclick="showForgotPasswordView()"
											class="small text-decoration-none">Quên mật khẩu?</a>
									</div>
									<input type="password" class="form-control rounded-3"
										id="loginPassword" required placeholder="Nhập mật khẩu">
								</div>
								<button type="submit"
									class="btn btn-primary w-100 py-2 rounded-3 fw-bold">ĐĂNG
									NHẬP</button>
							</form>
						</div>

						<div class="tab-pane fade" id="register-pane">
							<form id="registerForm">
								<div class="mb-2">
									<label class="form-label text-muted small fw-bold">Họ
										và tên</label> <input type="text" class="form-control rounded-3"
										id="regFullName" required placeholder="Nguyễn Văn A">
								</div>
								<div class="mb-2">
									<label class="form-label text-muted small fw-bold">Số
										điện thoại</label> <input type="tel" class="form-control rounded-3"
										id="regPhone" required placeholder="0987654321">
								</div>
								<div class="mb-2">
									<label class="form-label text-muted small fw-bold">Email</label>
									<input type="email" class="form-control rounded-3"
										id="regEmail" required placeholder="name@gmail.com">
								</div>
								<div class="mb-3">
									<label class="form-label text-muted small fw-bold">Mật
										khẩu (tối thiểu 6 ký tự)</label> <input type="password"
										class="form-control rounded-3" id="regPassword" required
										placeholder="••••••••">
								</div>
								<button type="submit"
									class="btn btn-success w-100 py-2 rounded-3 fw-bold">TẠO
									TÀI KHOẢN</button>
							</form>
						</div>

						<div class="d-none" id="otpPane">
							<div class="text-center mb-3">
								<i class="bi bi-shield-lock-fill text-warning fs-1"></i>
								<h5 class="fw-bold mt-2">Nhập Mã Xác Thực OTP</h5>
								<p class="text-muted small">
									Mã đã gửi đến email: <b id="otpEmailTarget"></b>
								</p>
							</div>
							<form id="otpForm">
								<div class="mb-3">
									<input type="text"
										class="form-control form-control-lg text-center fw-bold fs-4 rounded-3"
										id="otpInput" maxlength="6" required placeholder="000000">
								</div>
								<button type="submit"
									class="btn btn-primary w-100 py-2 rounded-3 fw-bold">KÍCH
									HOẠT TÀI KHOẢN</button>
								<div class="text-center mt-2">
									<a href="javascript:void(0)" onclick="resendOtpCode()"
										class="small text-muted text-decoration-none">Chưa nhận
										được mã? Gửi lại</a>
								</div>
							</form>
						</div>

						<div class="d-none" id="forgotPane">
							<div class="text-center mb-3">
								<i class="bi bi-key-fill text-primary fs-1"></i>
								<h5 class="fw-bold mt-2">Khôi Phục Mật Khẩu</h5>
								<p class="text-muted small">Nhập email để nhận mã đặt lại
									mật khẩu</p>
							</div>
							<form id="forgotForm">
								<div class="mb-3">
									<input type="email" class="form-control rounded-3"
										id="forgotEmail" required placeholder="Nhập email của bạn">
								</div>
								<button type="submit"
									class="btn btn-primary w-100 py-2 rounded-3 fw-bold">GỬI
									MÃ OTP</button>
								<div class="text-center mt-2">
									<a href="javascript:void(0)" onclick="backToLoginView()"
										class="small text-muted text-decoration-none">Quay lại
										Đăng nhập</a>
								</div>
							</form>
						</div>

						<div class="d-none" id="resetPane">
							<div class="text-center mb-3">
								<i class="bi bi-check2-circle text-success fs-1"></i>
								<h5 class="fw-bold mt-2">Đặt Mật Khẩu Mới</h5>
							</div>
							<form id="resetForm">
								<div class="mb-2">
									<input type="text"
										class="form-control text-center fw-bold rounded-3"
										id="resetOtp" maxlength="6" required
										placeholder="Nhập mã OTP 6 số">
								</div>
								<div class="mb-3">
									<input type="password" class="form-control rounded-3"
										id="resetNewPassword" minlength="6" required
										placeholder="Nhập mật khẩu mới">
								</div>
								<button type="submit"
									class="btn btn-success w-100 py-2 rounded-3 fw-bold">LƯU
									MẬT KHẨU MỚI</button>
							</form>
						</div>

					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="voucherModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content rounded-4 border-0 shadow">
				<div class="modal-header">
					<h5 class="modal-title fw-bold text-primary">
						<i class="bi bi-ticket-perforated-fill me-2"></i>Mã Giảm Giá & Ưu
						Đãi
					</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body p-3">
					<div class="card border-primary border-dashed mb-2 p-2">
						<div class="d-flex justify-content-between align-items-center">
							<div>
								<span class="badge bg-danger">GIẢM 50.000đ</span>
								<div class="fw-bold mt-1 text-dark">Mã: GIAM50K</div>
								<small class="text-muted">Cho đơn hàng từ 2.000.000đ</small>
							</div>
							<button class="btn btn-outline-primary btn-sm rounded-pill"
								onclick="navigator.clipboard.writeText('GIAM50K'); alert('Đã sao chép mã!');">Sao
								chép</button>
						</div>
					</div>
					<div class="card border-success border-dashed p-2">
						<div class="d-flex justify-content-between align-items-center">
							<div>
								<span class="badge bg-success">MIỄN PHÍ SHIP</span>
								<div class="fw-bold mt-1 text-dark">Mã: FREESHIP</div>
								<small class="text-muted">Áp dụng đơn hàng toàn quốc</small>
							</div>
							<button class="btn btn-outline-success btn-sm rounded-pill"
								onclick="navigator.clipboard.writeText('FREESHIP'); alert('Đã sao chép mã!');">Sao
								chép</button>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="branchSelectModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content rounded-4 border-0 shadow">
				<div class="modal-header">
					<h5 class="modal-title fw-bold text-primary">
						<i class="bi bi-geo-alt-fill me-2"></i>Chọn Chi Nhánh Xem Tồn Kho
					</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body p-3">
					<p class="text-muted small">Chọn siêu thị gần bạn để kiểm tra
						chính xác lượng hàng có sẵn và nhận hàng nhanh trong 2 giờ:</p>
					<div class="list-group">
						<button type="button"
							class="list-group-item list-group-item-action d-flex justify-content-between align-items-center active"
							onclick="selectBranch('Chi nhánh Quận 1')">
							<div>
								<div class="fw-bold">Chi nhánh Quận 1</div>
								<small class="text-light">123 Lê Lợi, Bến Nghé, Q1,
									TP.HCM</small>
							</div>
							<span class="badge bg-light text-dark rounded-pill">Đang
								chọn</span>
						</button>
						<button type="button"
							class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
							onclick="selectBranch('Chi nhánh Bình Thạnh')">
							<div>
								<div class="fw-bold">Chi nhánh Bình Thạnh</div>
								<small class="text-muted">456 Điện Biên Phủ, P25, Bình
									Thạnh, TP.HCM</small>
							</div>
							<span class="badge bg-primary rounded-pill">Xem hàng</span>
						</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="toast-container position-fixed bottom-0 end-0 p-3"
		style="z-index: 2050;">
		<div id="cartToast"
			class="toast align-items-center text-bg-dark border-0 shadow-lg rounded-4"
			role="alert" aria-live="assertive" aria-atomic="true">
			<div class="d-flex p-2">
				<div class="toast-body d-flex align-items-center gap-3 text-white">
					<div
						class="bg-success text-white rounded-circle p-2 d-flex align-items-center justify-content-center"
						style="width: 38px; height: 38px;">
						<i class="bi bi-check-lg fs-5"></i>
					</div>
					<div>
						<div class="fw-bold">Đã thêm vào giỏ hàng!</div>
						<small class="text-white-50">Sản phẩm đã sẵn sàng trong
							giỏ.</small>
					</div>
				</div>
				<a href="${pageContext.request.contextPath}/cart"
					class="btn btn-primary btn-sm my-auto me-2 fw-bold rounded-pill px-3">Xem
					giỏ</a>
				<button type="button" class="btn-close btn-close-white me-2 m-auto"
					data-bs-dismiss="toast" aria-label="Close"></button>
			</div>
		</div>
	</div>

	<!-- JAVASCRIPT HỆ THỐNG XỬ LÝ HEADER VÀ MEGA MENU -->
	<script>
    document.addEventListener('DOMContentLoaded', function () {
        
        // 1. XỬ LÝ MEGA MENU: Rê chuột chuyển tab + Giữ menu không bị tắt đột ngột
        const wrapper = document.querySelector('.mega-menu-wrapper');
        const panel = document.querySelector('.mega-menu-panel');
        let hideTimeout;

        if (wrapper && panel) {
            // Khi chuột vào nút hoặc bảng menu: Giữ mở và hủy lệnh đóng
            const showMenu = () => {
                clearTimeout(hideTimeout);
                panel.classList.add('show');
            };

            // Khi chuột rời đi: Chờ 300ms mới đóng (đủ thời gian lướt chuột thoải mái)
            const hideMenu = () => {
                hideTimeout = setTimeout(() => {
                    panel.classList.remove('show');
                }, 300);
            };

            wrapper.addEventListener('mouseenter', showMenu);
            wrapper.addEventListener('mouseleave', hideMenu);
            panel.addEventListener('mouseenter', showMenu);
            panel.addEventListener('mouseleave', hideMenu);
        }

        // Tự động chuyển tab danh mục con khi rê chuột qua cột trái
        const tabButtons = document.querySelectorAll('#megaMenuTabs button[data-bs-toggle="pill"]');
        tabButtons.forEach(button => {
            button.addEventListener('mouseenter', function () {
                const tabInstance = bootstrap.Tab.getOrCreateInstance(this);
                tabInstance.show();
            });
        });

        // 2. Tự động nạp số lượng Badge giỏ hàng từ server
        csrfFetch('${pageContext.request.contextPath}/api/cart/count')
            .then(res => res.json())
            .then(res => {
                if (res.success && document.getElementById('cartBadge')) {
                    document.getElementById('cartBadge').innerText = res.data;
                }
            })
            .catch(() => {});
    });

    // 3. Hàm chọn chi nhánh
    function selectBranch(branchName) {
        const branchLabel = document.getElementById('currentBranchLabel');
        if (branchLabel) branchLabel.innerText = branchName;
        const modal = bootstrap.Modal.getInstance(document.getElementById('branchSelectModal'));
        if (modal) modal.hide();
    }

    // 4. Hàm thêm vào giỏ hàng AJAX dùng chung toàn website
    function addToCart(productId, qty, btnElement) {
        const quantity = qty || 1;
        const token = localStorage.getItem('accessToken');
        const headers = { 'Content-Type': 'application/json' };
        if (token) headers['Authorization'] = 'Bearer ' + token;

        let originalHtml = '';
        if (btnElement) {
            originalHtml = btnElement.innerHTML;
            btnElement.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>';
            btnElement.disabled = true;
        }

        csrfFetch('${pageContext.request.contextPath}/api/cart/add', {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ productId: productId, quantity: quantity })
        })
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                if (document.getElementById('cartBadge')) {
                    document.getElementById('cartBadge').innerText = res.data.totalQuantity;
                }
                const toastEl = document.getElementById('cartToast');
                if (toastEl) {
                    const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
                    toast.show();
                }
                if (btnElement) {
                    btnElement.classList.replace('btn-outline-primary', 'btn-success');
                    btnElement.innerHTML = '<i class="bi bi-check-lg me-1"></i> Đã thêm!';
                    setTimeout(() => {
                        btnElement.classList.replace('btn-success', 'btn-outline-primary');
                        btnElement.innerHTML = originalHtml;
                        btnElement.disabled = false;
                    }, 1500);
                }
            }
        })
        .catch(err => {
            console.error(err);
            if (btnElement) {
                btnElement.innerHTML = originalHtml;
                btnElement.disabled = false;
            }
        });
    }
</script>
