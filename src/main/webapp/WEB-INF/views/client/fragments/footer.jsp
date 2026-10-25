<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!-- FOOTER CỦA FOODMART -->
<footer class="sf-footer mt-5">
	<div class="storefront-container">
		<div class="row">
			<div class="col-lg-4 col-md-6 mb-4">
				<a class="sf-brand sf-brand-footer"
					href="${pageContext.request.contextPath}/" aria-label="TECHSEVEN - Trang chủ">
					<img class="sf-brand-logo"
						src="${pageContext.request.contextPath}/images/brand/techseven-logo-dark.svg"
						alt="TECHSEVEN" width="323" height="72" loading="lazy" decoding="async">
				</a>
				<p class="text-muted small">Hệ thống chuỗi cửa hàng bán lẻ điện
					máy chính hãng hàng đầu Việt Nam. Cam kết 100% sản phẩm chính hãng,
					bảo hành toàn quốc.</p>
				<p class="text-muted small mb-1">
					<i class="bi bi-geo-alt-fill text-primary"></i> 123 Đường Điện Biên
					Phủ, Quận Bình Thạnh, TP.HCM
				</p>
				<p class="text-muted small mb-0">
					<i class="bi bi-telephone-fill text-primary"></i> Hotline:
					1800.6789
				</p>
			</div>
			<div class="col-lg-2 col-md-3 col-6 mb-4">
				<h6 class="fw-bold mb-3">Về chúng tôi</h6>

				<ul class="list-unstyled small text-muted">
					<li class="mb-2"><a
						href="${pageContext.request.contextPath}/info/about"
						class="text-decoration-none text-muted"> Giới thiệu công ty </a></li>

					<li class="mb-2"><a
						href="${pageContext.request.contextPath}/info/branches"
						class="text-decoration-none text-muted"> Hệ thống chi nhánh </a></li>

					<li class="mb-2"><a
						href="${pageContext.request.contextPath}/info/warranty"
						class="text-decoration-none text-muted"> Thông tin bảo hành </a></li>
				</ul>
			</div>

			<div class="col-lg-2 col-md-3 col-6 mb-4">
				<h6 class="fw-bold mb-3">Hỗ trợ khách hàng</h6>

				<ul class="list-unstyled small text-muted">
					<li class="mb-2"><a
						href="${pageContext.request.contextPath}/info/shopping-guide"
						class="text-decoration-none text-muted"> Hướng dẫn mua hàng </a></li>

					<li class="mb-2"><a
						href="${pageContext.request.contextPath}/info/returns"
						class="text-decoration-none text-muted"> Hướng dẫn trả hàng </a></li>

					<li class="mb-2"><a
						href="${pageContext.request.contextPath}/orders/tracking"
						class="text-decoration-none text-muted"> Tra cứu đơn hàng </a></li>
				</ul>
			</div>
			<div class="col-lg-4 col-md-12 mb-4">
				<h6 class="fw-bold mb-3">Trở thành thành viên TECHSEVEN</h6>

				<p class="text-muted small">Đăng ký tài khoản để theo dõi đơn
					hàng của bạn.</p>

				<a href="${pageContext.request.contextPath}/login?view=register"
					class="btn btn-primary"> Đăng ký tài khoản </a>
			</div>
		</div>
		<hr class="text-muted">
	</div>
</footer>

<!-- Các thư viện JS của FoodMart -->
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>

<!-- JAVASCRIPT XỬ LÝ AUTH, JWT TOKEN & CẬP NHẬT HEADER        -->
<script>
      const CONTEXT_PATH = "${pageContext.request.contextPath}";
      let currentPendingEmail = "";

      // Hiển thị thông báo trong Modal
      function showAlert(type, message) {
        const alertBox = document.getElementById('authAlert');
        alertBox.className = "alert alert-" + type;
        alertBox.innerText = message;
        alertBox.classList.remove('d-none');
      }

      function hideAlert() {
        document.getElementById('authAlert').classList.add('d-none');
      }

      // Chuyển đổi qua lại giữa các Form
      function showForgotPasswordView() {
        hideAlert();
        document.getElementById('authTabs').classList.add('d-none');
        document.getElementById('login-pane').classList.remove('show', 'active');
        document.getElementById('forgotPane').classList.remove('d-none');
      }

      function backToLoginView() {
        hideAlert();
        document.getElementById('authTabs').classList.remove('d-none');
        document.getElementById('forgotPane').classList.add('d-none');
        document.getElementById('otpPane').classList.add('d-none');
        document.getElementById('resetPane').classList.add('d-none');
        document.getElementById('login-pane').classList.add('show', 'active');
      }

      // 1. XỬ LÝ ĐĂNG NHẬP
      document.getElementById('loginForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
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
            // Lưu Token và Thông tin người dùng vào LocalStorage
            localStorage.setItem('jwtToken', data.data.token);
            localStorage.setItem('currentUser', JSON.stringify(data.data));

            showAlert('success', 'Đăng nhập thành công! Đang tải lại...');
            setTimeout(() => {
              bootstrap.Modal.getInstance(document.getElementById('authModal')).hide();
              checkLoginStatus();
            }, 800);
          } else {
            showAlert('danger', data.message);
          }
        } catch (err) {
          showAlert('danger', 'Lỗi kết nối máy chủ!');
        }
      });

      // 2. XỬ LÝ ĐĂNG KÝ
      document.getElementById('registerForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
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
            showAlert('success', data.message);
          } else {
            showAlert('danger', data.message);
          }
        } catch (err) {
          showAlert('danger', 'Lỗi kết nối!');
        }
      });

      // 3. XỬ LÝ NHẬP MÃ OTP KÍCH HOẠT
      document.getElementById('otpForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
        const otpCode = document.getElementById('otpInput').value;

        try {
          const res = await csrfFetch(CONTEXT_PATH + '/api/auth/verify-otp', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({email: currentPendingEmail, otpCode})
          });
          const data = await res.json();

          if (data.success) {
            showAlert('success', data.message + ' Vui lòng đăng nhập!');
            setTimeout(() => {
              backToLoginView();
              document.getElementById('loginEmail').value = currentPendingEmail;
            }, 1500);
          } else {
            showAlert('danger', data.message);
          }
        } catch (err) {
          showAlert('danger', 'Lỗi kết nối!');
        }
      });

      // 4. XỬ LÝ QUÊN MẬT KHẨU
      document.getElementById('forgotForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
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
            showAlert('success', data.message);
          } else {
            showAlert('danger', data.message);
          }
        } catch (err) {
          showAlert('danger', 'Lỗi kết nối!');
        }
      });

      // 5. XỬ LÝ ĐẶT LẠI MẬT KHẨU
      document.getElementById('resetForm').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
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
            showAlert('success', data.message);
            setTimeout(() => {
              backToLoginView();
            }, 1500);
          } else {
            showAlert('danger', data.message);
          }
        } catch (err) {
          showAlert('danger', 'Lỗi kết nối!');
        }
      });

      
      function checkLoginStatus() {
        const token = localStorage.getItem('jwtToken') || localStorage.getItem('accessToken');
        const userJson = localStorage.getItem('currentUser');
        const container = document.getElementById('userAuthContainer');
        if (!container) return;

        if (token && userJson) {
          const user = JSON.parse(userJson);
          // Đồng bộ token sang cookie để các trang JSP Controller nhận diện được người dùng
          document.cookie = "accessToken=" + token + "; path=/; max-age=86400";

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
                <li><a class="dropdown-item" href="${CONTEXT_PATH}/orders/tracking"><i class="bi bi-search me-2"></i>Tra cứu đơn vãng lai</a></li>
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
          const isAdmin = Array.isArray(user.roles)
          && user.roles.includes('ROLE_ADMIN');

      if (isAdmin) {
          const adminItem = document.createElement('li');
          const adminLink = document.createElement('a');

          adminLink.className = 'dropdown-item fw-bold text-primary';
          adminLink.href = CONTEXT_PATH + '/admin';
          adminLink.innerHTML =
              '<i class="bi bi-speedometer2 me-2"></i>Trang quản trị';

          adminItem.appendChild(adminLink);

          const menu = container.querySelector('.dropdown-menu');
          const divider = menu.querySelector('.dropdown-divider');

          menu.insertBefore(adminItem, divider.closest('li'));
      }
        } else {
          document.cookie = "accessToken=; path=/; max-age=0";
          container.innerHTML = `
            <a href="${CONTEXT_PATH}/login" class="header-btn">
              <i class="bi bi-person-circle fs-5"></i>
              <span class="d-none d-xl-inline">Đăng nhập</span>
            </a>
          `;
        }
      }

      // ĐĂNG XUẤT
      function logout() {
        localStorage.removeItem('jwtToken');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('currentUser');
        document.cookie = "accessToken=; path=/; max-age=0";
        checkLoginStatus();
        window.location.reload();
      }

      // Tự động chạy khi mở trang
      document.addEventListener('DOMContentLoaded', checkLoginStatus);
    </script>
</body>
</html>
