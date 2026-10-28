<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<style>
.sf-footer-link {
	transition: color 0.15s ease, transform 0.15s ease;
	display: inline-block;
}
.sf-footer-link:hover {
	color: #0d6efd !important;
	transform: translateX(3px);
}
.sf-social-btn {
	width: 36px;
	height: 36px;
	border-radius: 50%;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	background: #f8fafc;
	border: 1px solid #e2e8f0;
	transition: all 0.2s ease;
	text-decoration: none;
}
.sf-social-btn:hover {
	background: #0d6efd;
	color: #ffffff !important;
	border-color: #0d6efd;
	transform: translateY(-2px);
}
</style>

<footer class="sf-footer mt-5 pt-5 pb-4 bg-white border-top">
	<div class="storefront-container">

		<div class="row g-3 pb-4 mb-4 border-bottom">
			<div class="col-6 col-lg-3">
				<div class="d-flex align-items-center gap-3 p-3 rounded-4 bg-light bg-opacity-50 h-100 border">
					<div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center fs-3 flex-shrink-0" style="width: 50px; height: 50px;">
						<i class="bi bi-patch-check-fill"></i>
					</div>
					<div>
						<div class="fw-bold text-dark small">100% Chính Hãng</div>
						<small class="text-muted" style="font-size: 0.75rem;">Phân phối chính ngạch, đủ VAT</small>
					</div>
				</div>
			</div>
			<div class="col-6 col-lg-3">
				<div class="d-flex align-items-center gap-3 p-3 rounded-4 bg-light bg-opacity-50 h-100 border">
					<div class="rounded-circle bg-success bg-opacity-10 text-success d-flex align-items-center justify-content-center fs-3 flex-shrink-0" style="width: 50px; height: 50px;">
						<i class="bi bi-truck"></i>
					</div>
					<div>
						<div class="fw-bold text-dark small">Giao Hàng Siêu Tốc</div>
						<small class="text-muted" style="font-size: 0.75rem;">Miễn phí ship cùng chi nhánh</small>
					</div>
				</div>
			</div>
			<div class="col-6 col-lg-3">
				<div class="d-flex align-items-center gap-3 p-3 rounded-4 bg-light bg-opacity-50 h-100 border">
					<div class="rounded-circle bg-warning bg-opacity-10 text-warning d-flex align-items-center justify-content-center fs-3 flex-shrink-0" style="width: 50px; height: 50px;">
						<i class="bi bi-arrow-repeat"></i>
					</div>
					<div>
						<div class="fw-bold text-dark small">Đổi Mới 30 Ngày</div>
						<small class="text-muted" style="font-size: 0.75rem;">Lỗi nhà sản xuất 1 đổi 1</small>
					</div>
				</div>
			</div>
			<div class="col-6 col-lg-3">
				<div class="d-flex align-items-center gap-3 p-3 rounded-4 bg-light bg-opacity-50 h-100 border">
					<div class="rounded-circle bg-info bg-opacity-10 text-info d-flex align-items-center justify-content-center fs-3 flex-shrink-0" style="width: 50px; height: 50px;">
						<i class="bi bi-headset"></i>
					</div>
					<div>
						<div class="fw-bold text-dark small">Hỗ Trợ 24/7</div>
						<small class="text-muted" style="font-size: 0.75rem;">Tư vấn kỹ thuật tận tâm</small>
					</div>
				</div>
			</div>
		</div>

		<div class="row g-4">
			<div class="col-lg-4 col-md-6">
				<a class="sf-brand sf-brand-footer d-inline-block mb-3"
					href="${pageContext.request.contextPath}/"
					aria-label="TECHSEVEN - Trang chủ">
					<img class="sf-brand-logo"
						src="${pageContext.request.contextPath}/images/brand/techseven-logo-dark.svg"
						alt="TECHSEVEN" width="220" height="48" style="height: 42px; width: auto;" loading="lazy">
				</a>
				<p class="text-muted small mb-3">
					Hệ thống chuỗi cửa hàng bán lẻ điện máy chính hãng hàng đầu Việt Nam. Cam kết 100% sản phẩm chính hãng, bảo hành toàn quốc.
				</p>
				<ul class="list-unstyled small text-muted d-flex flex-column gap-2 mb-3">
					<li class="d-flex align-items-start gap-2">
						<i class="bi bi-geo-alt-fill text-danger fs-6 flex-shrink-0 mt-1"></i>
						<span><strong>Địa chỉ:</strong> Số 1, Võ Văn Ngân, Phường Thủ Đức, TP. Hồ Chí Minh</span>
					</li>
					<li class="d-flex align-items-center gap-2">
						<i class="bi bi-telephone-fill text-primary fs-6 flex-shrink-0"></i>
						<span><strong>Hotline:</strong> <a href="tel:18006789" class="text-decoration-none fw-bold text-primary">1800.6789</a> <small class="text-muted">(08:00 - 21:30)</small></span>
					</li>
					<li class="d-flex align-items-center gap-2">
						<i class="bi bi-envelope-fill text-info fs-6 flex-shrink-0"></i>
						<span><strong>Email:</strong> <a href="mailto:cskh@techseven.vn" class="text-decoration-none text-muted">cskh@techseven.vn</a></span>
					</li>
				</ul>

				<div class="d-flex align-items-center gap-2 pt-1">
					<span class="small fw-semibold text-dark me-1">Kết nối:</span>
					<a href="#" class="sf-social-btn text-primary" title="Facebook"><i class="bi bi-facebook"></i></a>
					<a href="#" class="sf-social-btn text-danger" title="Youtube"><i class="bi bi-youtube"></i></a>
					<a href="#" class="sf-social-btn text-dark" title="TikTok"><i class="bi bi-tiktok"></i></a>
				</div>
			</div>

			<div class="col-lg-2 col-md-3 col-6">
				<h6 class="fw-bold mb-3 text-dark">Về chúng tôi</h6>
				<ul class="list-unstyled small text-muted d-flex flex-column gap-2">
					<li><a href="${pageContext.request.contextPath}/info/about" class="text-decoration-none text-muted sf-footer-link">Giới thiệu công ty</a></li>
					<li><a href="${pageContext.request.contextPath}/info/branches" class="text-decoration-none text-muted sf-footer-link">Hệ thống chi nhánh</a></li>
					<li><a href="${pageContext.request.contextPath}/info/warranty" class="text-decoration-none text-muted sf-footer-link">Thông tin bảo hành</a></li>
					<li><a href="${pageContext.request.contextPath}/vouchers" class="text-decoration-none text-muted sf-footer-link">Kho Voucher ưu đãi</a></li>
				</ul>
			</div>

			<div class="col-lg-2 col-md-3 col-6">
				<h6 class="fw-bold mb-3 text-dark">Hỗ trợ khách hàng</h6>
				<ul class="list-unstyled small text-muted d-flex flex-column gap-2">
					<li><a href="${pageContext.request.contextPath}/info/shopping-guide" class="text-decoration-none text-muted sf-footer-link">Hướng dẫn mua hàng</a></li>
					<li><a href="${pageContext.request.contextPath}/info/returns" class="text-decoration-none text-muted sf-footer-link">Hướng dẫn trả hàng</a></li>
					<li><a href="${pageContext.request.contextPath}/orders/tracking" class="text-decoration-none text-muted sf-footer-link">Tra cứu đơn hàng</a></li>
					<li><a href="${pageContext.request.contextPath}/info/privacy" class="text-decoration-none text-muted sf-footer-link">Chính sách bảo mật</a></li>
				</ul>
			</div>

			<div class="col-lg-4 col-md-12">
				<div class="p-3 rounded-4 bg-light bg-opacity-75 border mb-3">
					<h6 class="fw-bold mb-2 text-dark"><i class="bi bi-gift-fill text-warning me-2"></i>Trở thành thành viên TECHSEVEN</h6>
					<p class="text-muted small mb-3">
						Đăng ký tài khoản ngay hôm nay để theo dõi đơn hàng và nhận các chương trình ưu đãi dành riêng cho thành viên.
					</p>
					<a href="${pageContext.request.contextPath}/login?view=register" class="btn btn-primary btn-sm rounded-pill px-4 fw-medium shadow-sm">
						Đăng ký tài khoản ngay &rarr;
					</a>
				</div>

				<div>
					<span class="small fw-semibold text-dark d-block mb-2">Phương thức thanh toán an toàn:</span>
					<div class="d-flex align-items-center gap-2 flex-wrap">
						<span class="badge bg-white text-dark border px-2 py-1 small fw-semibold"><i class="bi bi-qr-code me-1 text-primary"></i>VNPay QR</span>
						<span class="badge bg-white text-dark border px-2 py-1 small fw-semibold"><i class="bi bi-credit-card-2-front me-1 text-success"></i>Thẻ ATM / Visa</span>
						<span class="badge bg-white text-dark border px-2 py-1 small fw-semibold"><i class="bi bi-cash me-1 text-danger"></i>Tiền mặt (COD)</span>
					</div>
				</div>
			</div>
		</div>

		<hr class="text-muted mt-4 mb-3 opacity-25">
		<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 small text-muted">
			<div>
				&copy; 2026 <strong>TECHSEVEN</strong>. Tất cả các quyền được bảo lưu.
			</div>
			<div>
				Hệ thống bán lẻ điện máy chính hãng uy tín số 1 Võ Văn Ngân.
			</div>
		</div>

	</div>
</footer>
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>

<script>
      window.CONTEXT_PATH = "${pageContext.request.contextPath}";
      const CONTEXT_PATH = window.CONTEXT_PATH;
      let currentPendingEmail = "";

      function showModalAuthAlert(type, message) {
        const alertBox = document.getElementById('authAlert');
        alertBox.className = "alert alert-" + type;
        alertBox.innerText = message;
        alertBox.classList.remove('d-none');
      }

      function hideModalAuthAlert() {
        document.getElementById('authAlert').classList.add('d-none');
      }

      function showForgotPasswordView() {
        hideModalAuthAlert();
        document.getElementById('authTabs').classList.add('d-none');
        document.getElementById('login-pane').classList.remove('show', 'active');
        document.getElementById('forgotPane').classList.remove('d-none');
      }

      function backToLoginView() {
        hideModalAuthAlert();
        document.getElementById('authTabs').classList.remove('d-none');
        document.getElementById('forgotPane').classList.add('d-none');
        document.getElementById('otpPane').classList.add('d-none');
        document.getElementById('resetPane').classList.add('d-none');
        document.getElementById('login-pane').classList.add('show', 'active');
      }

      document.getElementById('loginForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideModalAuthAlert();
        const email = document.getElementById('loginEmail').value;
        const password = document.getElementById('loginPassword').value;

        try {
          const res = await csrfFetch(CONTEXT_PATH + '/api/auth/login', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({email, password})
          });
          const data = await res.json();

          if (data.success) {
            localStorage.setItem('jwtToken', data.data.token);
            localStorage.setItem('accessToken', data.data.token);
            localStorage.setItem('currentUser', JSON.stringify(data.data));

            document.cookie = 'accessToken=' + encodeURIComponent(data.data.token)
                + '; path=/; max-age=86400; SameSite=Lax'
                + (location.protocol === 'https:' ? '; Secure' : '');
            showModalAuthAlert('success', 'Đăng nhập thành công! Đang tải lại...');
            setTimeout(() => {
              window.location.assign(window.loginDestination(data.data, CONTEXT_PATH));
            }, 800);
          } else {
            showModalAuthAlert('danger', data.message);
          }
        } catch (err) {
          showModalAuthAlert('danger', 'Lỗi kết nối máy chủ!');
        }
      });

      document.getElementById('registerForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideModalAuthAlert();
        const fullname = document.getElementById('regFullName').value;
        const phoneNumber = document.getElementById('regPhone').value;
        const email = document.getElementById('regEmail').value;
        const password = document.getElementById('regPassword').value;

        try {
          const res = await csrfFetch(CONTEXT_PATH + '/api/auth/register', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({fullname, phoneNumber, email, password})
          });
          const data = await res.json();

          if (data.success) {
            currentPendingEmail = email;
            document.getElementById('otpEmailTarget').innerText = email;
            document.getElementById('authTabs').classList.add('d-none');
            document.getElementById('register-pane').classList.remove('show', 'active');
            document.getElementById('otpPane').classList.remove('d-none');
            showModalAuthAlert('success', data.message);
          } else {
            showModalAuthAlert('danger', data.message);
          }
        } catch (err) {
          showModalAuthAlert('danger', 'Lỗi kết nối!');
        }
      });

      document.getElementById('otpForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideModalAuthAlert();
        const otpCode = document.getElementById('otpInput').value;

        try {
          const res = await csrfFetch(CONTEXT_PATH + '/api/auth/verify-otp', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({email: currentPendingEmail, otpCode})
          });
          const data = await res.json();

          if (data.success) {
            showModalAuthAlert('success', data.message + ' Vui lòng đăng nhập!');
            setTimeout(() => {
              backToLoginView();
              document.getElementById('loginEmail').value = currentPendingEmail;
            }, 1500);
          } else {
            showModalAuthAlert('danger', data.message);
          }
        } catch (err) {
          showModalAuthAlert('danger', 'Lỗi kết nối!');
        }
      });

      document.getElementById('forgotForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideModalAuthAlert();
        const email = document.getElementById('forgotEmail').value;
        currentPendingEmail = email;

        try {
          const res = await csrfFetch(CONTEXT_PATH + '/api/auth/forgot-password', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({email})
          });
          const data = await res.json();

          if (data.success) {
            document.getElementById('forgotPane').classList.add('d-none');
            document.getElementById('resetPane').classList.remove('d-none');
            showModalAuthAlert('success', data.message);
          } else {
            showModalAuthAlert('danger', data.message);
          }
        } catch (err) {
          showModalAuthAlert('danger', 'Lỗi kết nối!');
        }
      });

      document.getElementById('resetForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideModalAuthAlert();
        const otpCode = document.getElementById('resetOtp').value;
        const newPassword = document.getElementById('resetNewPassword').value;

        try {
          const res = await csrfFetch(CONTEXT_PATH + '/api/auth/reset-password', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({email: currentPendingEmail, otpCode, newPassword})
          });
          const data = await res.json();

          if (data.success) {
            showModalAuthAlert('success', data.message);
            setTimeout(() => {
              backToLoginView();
            }, 1500);
          } else {
            showModalAuthAlert('danger', data.message);
          }
        } catch (err) {
          showModalAuthAlert('danger', 'Lỗi kết nối!');
        }
      });

      function checkLoginStatus() {
          const userJson = localStorage.getItem('currentUser');
          const container = document.getElementById('userAuthContainer');
          if (!container) return;

          if (container.dataset.authenticated === 'true') {
            const user = {
              email: container.dataset.userEmail,
              fullName: container.dataset.userEmail,
              roles: container.dataset.isAdmin === 'true' ? ['ROLE_ADMIN'] : []
            };
            try {
              const saved = JSON.parse(userJson || 'null');
              if (saved?.email === user.email) {
                if (saved.fullName) user.fullName = saved.fullName;
                if (Array.isArray(saved.roles) && saved.roles.length > 0) {
                  user.roles = saved.roles;
                }
              }
            } catch (error) { }

            container.innerHTML = `
              <div class="dropdown">
                <button class="btn btn-outline-primary btn-sm rounded-pill dropdown-toggle fw-bold" type="button" data-bs-toggle="dropdown">
                <i class="bi bi-person-circle"></i> <span data-user-name></span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                <li>
                <h6 class="dropdown-header small text-muted" data-user-email></h6>
            </li>
                  <li><hr class="dropdown-divider"></li>
                  <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/profile"><i class="bi bi-person-circle me-2"></i>Hồ sơ của tôi</a></li>
                  <li><a class="dropdown-item" href="${CONTEXT_PATH}/orders"><i class="bi bi-bag-check me-2"></i>Đơn hàng của tôi</a></li>
                  <li><a class="dropdown-item" href="${CONTEXT_PATH}/orders/tracking"><i class="bi bi-search me-2"></i>Tra cứu đơn hàng của tôi</a></li>
                  <li><a class="dropdown-item" href="${CONTEXT_PATH}/vouchers"><i class="bi bi-ticket-perforated me-2"></i>Kho Voucher</a></li>
                  <li><hr class="dropdown-divider"></li>
                  <li><a class="dropdown-item text-danger" href="javascript:void(0)" onclick="logout()"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                </ul>
              </div>
            `;
            container.querySelector('[data-user-name]').textContent =
                user.fullName || 'Tài khoản';

            container.querySelector('[data-user-email]').textContent =
                user.email || '';

            const roles = Array.isArray(user.roles) ? user.roles : [];
            const isAdmin = roles.includes('ROLE_ADMIN') || container.dataset.isAdmin === 'true';
            const isStaff = roles.includes('ROLE_STAFF');
            const isShipper = roles.includes('ROLE_SHIPPER');

            if (isAdmin || isStaff || isShipper) {
                const workItem = document.createElement('li');
                const workLink = document.createElement('a');

                workLink.className = 'dropdown-item fw-bold text-primary';
                if (isAdmin) {
                    workLink.href = CONTEXT_PATH + '/admin';
                    workLink.innerHTML = '<i class="bi bi-speedometer2 me-2"></i>Trang quản trị';
                } else if (isStaff) {
                    workLink.href = CONTEXT_PATH + '/admin/orders';
                    workLink.innerHTML = '<i class="bi bi-briefcase-fill me-2"></i>Khu vực nhân viên';
                } else {
                    workLink.href = CONTEXT_PATH + '/shipper/orders';
                    workLink.innerHTML = '<i class="bi bi-truck me-2"></i>Đơn giao hàng';
                }

                workItem.appendChild(workLink);

                const menu = container.querySelector('.dropdown-menu');
                const divider = menu.querySelector('.dropdown-divider');

                menu.insertBefore(workItem, divider.closest('li'));
            }
          } else {
            container.innerHTML = `
              <a href="${CONTEXT_PATH}/login?redirect=/account/profile" class="header-btn">
                <i class="bi bi-person-circle fs-5"></i>
                <span class="d-none d-xl-inline">Đăng nhập</span>
              </a>
            `;
          }
        }

      async function logout() {
        try {
          const response = await csrfFetch(CONTEXT_PATH + '/api/auth/logout', { method: 'POST' });
          if (!response.ok) throw new Error('Logout failed');
        } catch (error) {
          window.alert('Chưa thể đăng xuất. Vui lòng tải lại trang và thử lại.');
          return;
        }
        localStorage.removeItem('jwtToken');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('currentUser');
        document.cookie = "accessToken=; path=/; max-age=0";
        document.cookie = "jwtToken=; path=/; max-age=0";
        window.location.assign(CONTEXT_PATH + '/');
      }

      document.addEventListener('DOMContentLoaded', checkLoginStatus);
    </script>
    <script src="${pageContext.request.contextPath}/js/customer-notifications.js" defer></script>
</body>
</html>
