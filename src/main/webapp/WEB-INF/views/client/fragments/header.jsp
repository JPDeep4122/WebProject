<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Điện Máy Shop - Chuỗi Cửa Hàng Điện Máy Uy Tín</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- CSS của FoodMart -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.css">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/vendor.css">
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/style.css">

<!-- Google Fonts & Bootstrap Icons -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;700&family=Open+Sans:wght@400;600;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>

	<!-- SVG Icons của FoodMart -->
	<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
      <defs>
        <symbol id="search" viewBox="0 0 24 24">
		<path fill="currentColor"
			d="M21.71 20.29L18 16.61A9 9 0 1 0 16.61 18l3.68 3.68a1 1 0 0 0 1.42 0a1 1 0 0 0 0-1.39ZM11 18a7 7 0 1 1 7-7a7 7 0 0 1-7 7Z" /></symbol>
        <symbol id="user" viewBox="0 0 24 24">
		<path fill="currentColor"
			d="M15.71 12.71a6 6 0 1 0-7.42 0a10 10 0 0 0-6.22 8.18a1 1 0 0 0 2 .22a8 8 0 0 1 15.9 0a1 1 0 0 0 1 .89h.11a1 1 0 0 0 .88-1.1a10 10 0 0 0-6.25-8.19ZM12 12a4 4 0 1 1 4-4a4 4 0 0 1-4 4Z" /></symbol>
        <symbol id="heart" viewBox="0 0 24 24">
		<path fill="currentColor"
			d="M20.16 4.61A6.27 6.27 0 0 0 12 4a6.27 6.27 0 0 0-8.16 9.48l7.45 7.45a1 1 0 0 0 1.42 0l7.45-7.45a6.27 6.27 0 0 0 0-8.87Zm-1.41 7.46L12 18.81l-6.75-6.74a4.28 4.28 0 0 1 3-7.3a4.25 4.25 0 0 1 3 1.25a1 1 0 0 0 1.42 0a4.27 4.27 0 0 1 6 6.05Z" /></symbol>
        <symbol id="cart" viewBox="0 0 24 24">
		<path fill="currentColor"
			d="M8.5 19a1.5 1.5 0 1 0 1.5 1.5A1.5 1.5 0 0 0 8.5 19ZM19 16H7a1 1 0 0 1 0-2h8.491a3.013 3.013 0 0 0 2.885-2.176l1.585-5.55A1 1 0 0 0 19 5H6.74a3.007 3.007 0 0 0-2.82-2H3a1 1 0 0 0 0 2h.921a1.005 1.005 0 0 1 .962.725l.155.545v.005l1.641 5.742A3 3 0 0 0 7 18h12a1 1 0 0 0 0-2Zm-1.326-9l-1.22 4.274a1.005 1.005 0 0 1-.963.726H8.754l-.255-.892L7.326 7ZM16.5 19a1.5 1.5 0 1 0 1.5 1.5a1.5 1.5 0 0 0-1.5-1.5Z" /></symbol>
      </defs>
    </svg>

	<!-- HEADER CHÍNH -->
	<header>
		<div class="container-fluid">
			<div class="row py-3 border-bottom align-items-center">

				<!-- Logo -->
				<div class="col-sm-4 col-lg-3 text-center text-sm-start">
					<a href="${pageContext.request.contextPath}/"
						class="text-decoration-none">
						<h2 class="text-primary fw-bold mb-0">
							<i class="bi bi-lightning-charge-fill"></i> ĐIỆN MÁY SHOP
						</h2>
					</a>
				</div>

				<!-- Ô Tìm kiếm -->
				<div
					class="col-sm-6 offset-sm-2 offset-md-0 col-lg-5 d-none d-lg-block">
					<div class="search-bar row bg-light p-2 my-2 rounded-4">
						<div class="col-11">
							<form id="search-form" class="text-center" action="#"
								method="get">
								<input type="text" class="form-control border-0 bg-transparent"
									placeholder="Tìm kiếm tivi, tủ lạnh, máy giặt, điện thoại..." />
							</form>
						</div>
						<div class="col-1 text-end">
							<svg width="24" height="24">
								<use xlink:href="#search"></use></svg>
						</div>
					</div>
				</div>

				<!-- Khu vực Tài khoản & Giỏ hàng -->
				<div
					class="col-sm-8 col-lg-4 d-flex justify-content-end gap-3 align-items-center">

					<!-- Hotline -->
					<div class="support-box text-end d-none d-xl-block me-3">
						<span class="fs-6 text-muted">Hỗ trợ 24/7?</span>
						<h6 class="mb-0 text-primary fw-bold">1800-6789</h6>
					</div>

					<!-- Các nút icon -->
					<ul
						class="d-flex justify-content-end list-unstyled m-0 align-items-center">

						<!-- NÚT TÀI KHOẢN (Khi chưa đăng nhập thì bật Modal, khi đã đăng nhập thì hiện Dropdown Tên) -->
						<li class="dropdown" id="userAuthContainer"><a
							href="javascript:void(0)"
							class="rounded-circle bg-light p-2 mx-1 d-inline-block text-dark"
							data-bs-toggle="modal" data-bs-target="#authModal"
							title="Tài khoản"> <svg width="24" height="24">
									<use xlink:href="#user"></use></svg>
						</a></li>

						<!-- Yêu thích -->
						<li><a href="#"
							class="rounded-circle bg-light p-2 mx-1 d-inline-block text-dark"
							title="Yêu thích"> <svg width="24" height="24">
									<use xlink:href="#heart"></use></svg>
						</a></li>

						<!-- Giỏ hàng -->
						<li><a href="${pageContext.request.contextPath}/cart"
							class="rounded-circle bg-light p-2 mx-1 d-inline-block text-dark position-relative"
							title="Xem giỏ hàng"> <svg width="24" height="24">
									<use xlink:href="#cart"></use></svg> <!-- Gắn id="cartBadge" để JavaScript tự động cập nhật số lượng -->
								<span id="cartBadge"
								class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">0</span>
						</a></li>
					</ul>

				</div>
			</div>
		</div>

		<!-- Thanh Menu điều hướng -->
		<nav class="navbar navbar-expand-lg navbar-light bg-light py-2">
			<div class="container-fluid">
				<button class="navbar-toggler" type="button"
					data-bs-toggle="collapse" data-bs-target="#mainNav">
					<span class="navbar-toggler-icon"></span>
				</button>
				<div class="collapse navbar-collapse" id="mainNav">
					<ul class="navbar-nav me-auto mb-2 mb-lg-0 fw-bold">
						<li class="nav-item"><a class="nav-link text-primary"
							href="${pageContext.request.contextPath}/">Trang chủ</a></li>
						<li class="nav-item"><a class="nav-link" href="#">Tivi -
								Âm thanh</a></li>
						<li class="nav-item"><a class="nav-link" href="#">Tủ lạnh
								- Đông - Mát</a></li>
						<li class="nav-item"><a class="nav-link" href="#">Máy
								giặt - Máy sấy</a></li>
						<li class="nav-item"><a class="nav-link" href="#">Gia
								dụng - Bếp</a></li>
						<li class="nav-item"><a class="nav-link text-danger" href="#">Khuyến
								mãi Hot <i class="bi bi-fire"></i>
						</a></li>
					</ul>
				</div>
			</div>
		</nav>
	</header>

	<!-- MODAL XÁC THỰC: ĐĂNG NHẬP / ĐĂNG KÝ / OTP / QUÊN MẬT KHẨU -->
	<div class="modal fade" id="authModal" tabindex="-1" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content rounded-4 border-0 shadow">

				<div class="modal-header border-0 pb-0">
					<ul class="nav nav-pills w-100 nav-justified" id="authTabs"
						role="tablist">
						<li class="nav-item">
							<button class="nav-link active fw-bold" id="login-tab"
								data-bs-toggle="tab" data-bs-target="#login-pane" type="button">ĐĂNG
								NHẬP</button>
						</li>
						<li class="nav-item">
							<button class="nav-link fw-bold" id="register-tab"
								data-bs-toggle="tab" data-bs-target="#register-pane"
								type="button">ĐĂNG KÝ</button>
						</li>
					</ul>
					<button type="button" class="btn-close ms-2"
						data-bs-dismiss="modal"></button>
				</div>

				<div class="modal-body p-4">

					<!-- Vùng thông báo lỗi/thành công -->
					<div id="authAlert" class="alert d-none" role="alert"></div>

					<div class="tab-content" id="authTabsContent">

						<!-- TAB 1: FORM ĐĂNG NHẬP -->
						<div class="tab-pane fade show active" id="login-pane">
							<form id="loginForm">
								<div class="mb-3">
									<label class="form-label text-muted small fw-bold">Địa
										chỉ Email</label> <input type="email" class="form-control rounded-3"
										id="loginEmail" required placeholder="name@gmail.com">
								</div>
								<div class="mb-3">
									<div class="d-flex justify-content-between">
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

						<!-- TAB 2: FORM ĐĂNG KÝ -->
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

						<!-- FORM PHỤ: XÁC THỰC MÃ OTP KÍCH HOẠT -->
						<div class="d-none" id="otpPane">
							<div class="text-center mb-3">
								<i class="bi bi-shield-lock-fill text-warning fs-1"></i>
								<h5 class="fw-bold mt-2">Nhập Mã Xác Thực OTP</h5>
								<p class="text-muted small">
									Mã OTP đã được gửi đến email: <b id="otpEmailTarget"></b>
								</p>
							</div>
							<form id="otpForm">
								<div class="mb-3">
									<input type="text"
										class="form-control form-control-lg text-center fw-bold fs-4 rounded-3 letter-spacing-3"
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

						<!-- FORM PHỤ: QUÊN MẬT KHẨU -->
						<div class="d-none" id="forgotPane">
							<div class="text-center mb-3">
								<i class="bi bi-key-fill text-primary fs-1"></i>
								<h5 class="fw-bold mt-2">Khôi Phục Mật Khẩu</h5>
								<p class="text-muted small">Nhập email để nhận mã xác nhận
									đặt lại mật khẩu</p>
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

						<!-- FORM PHỤ: ĐẶT LẠI MẬT KHẨU MỚI (RESET PASSWORD) -->
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

	<div class="toast-container position-fixed bottom-0 end-0 p-3"
		style="z-index: 2000;">
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
					class="btn btn-primary btn-sm my-auto me-2 fw-bold rounded-pill px-3">
					Xem giỏ </a>
				<button type="button" class="btn-close btn-close-white me-2 m-auto"
					data-bs-dismiss="toast" aria-label="Close"></button>
			</div>
		</div>
	</div>

	<script>
  // Tự động tải số lượng giỏ hàng hiển thị lên badge khi mở trang web
  document.addEventListener("DOMContentLoaded", function() {
    fetch('${pageContext.request.contextPath}/api/cart/count')
      .then(res => res.json())
      .then(res => {
        if (res.success && document.getElementById('cartBadge')) {
          document.getElementById('cartBadge').innerText = res.data;
        }
      })
      .catch(() => {});
  });

  // Hàm thêm vào giỏ hàng AJAX hiện đại dùng chung cho toàn bộ website
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

    fetch('${pageContext.request.contextPath}/api/cart/add', {
      method: 'POST',
      headers: headers,
      body: JSON.stringify({ productId: productId, quantity: quantity })
    })
    .then(res => res.json())
    .then(res => {
      if (res.success) {
        // Cập nhật số lượng trên icon giỏ hàng ở Header
        if (document.getElementById('cartBadge')) {
          document.getElementById('cartBadge').innerText = res.data.totalQuantity;
        }

        // Hiện thông báo Toast góc dưới mượt mà
        const toastEl = document.getElementById('cartToast');
        if (toastEl) {
          const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
          toast.show();
        }

        // Đổi hiệu ứng nút bấm thành "Đã thêm" màu xanh
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