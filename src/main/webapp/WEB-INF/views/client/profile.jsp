<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags"%>

<jsp:include page="fragments/header.jsp" />

<main class="storefront-container py-4" id="accountProfilePage">
	<nav aria-label="Điều hướng">
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/" class="text-decoration-none">Trang chủ</a></li>
			<li class="breadcrumb-item active" aria-current="page">Hồ sơ của
				tôi</li>
		</ol>
	</nav>

	
	<div class="bg-white border rounded-4 p-3 p-md-4 mb-4 shadow-sm d-flex flex-wrap align-items-center justify-content-between gap-3">
		<div class="d-flex align-items-center gap-3">
			<div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center fw-bold fs-3"
				style="width: 60px; height: 60px; flex-shrink: 0;">
				<i class="bi bi-person-check-fill"></i>
			</div>
			<div>
				<div class="d-flex align-items-center gap-2 flex-wrap">
					<h1 class="h4 fw-bold mb-0">Hồ sơ của tôi</h1>
					<span class="badge rounded-pill bg-success bg-opacity-10 text-success border border-success border-opacity-25">
						<i class="bi bi-patch-check-fill me-1"></i>Thành viên TECHSEVEN
					</span>
				</div>
				<p class="text-muted small mb-0 mt-1">
					Xin chào <strong><c:out value="${accountProfile.fullName}" /></strong> (<c:out value="${accountProfile.email}" />) — Quản lý thông tin cá nhân và bảo mật tài khoản.
				</p>
			</div>
		</div>

		<div class="d-flex flex-wrap gap-2">
			<a href="${pageContext.request.contextPath}/orders" class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-medium">
				<i class="bi bi-box-seam me-1"></i>Đơn hàng của tôi
			</a>
			<a href="${pageContext.request.contextPath}/vouchers" class="btn btn-outline-warning text-dark btn-sm rounded-pill px-3 fw-medium">
				<i class="bi bi-ticket-perforated me-1 text-warning"></i>Kho Voucher
			</a>
			<a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary btn-sm rounded-pill px-3 fw-medium">
				<i class="bi bi-cart3 me-1"></i>Giỏ hàng
			</a>
		</div>
	</div>

	<div class="row g-4 align-items-start">
		<section class="col-lg-6" aria-labelledby="profileHeading">
			<div class="bg-white border rounded-4 p-3 p-md-4 shadow-sm">
				<h2 class="h5 fw-bold mb-4 pb-2 border-bottom" id="profileHeading">
					<i class="bi bi-person-circle me-2 text-primary" aria-hidden="true"></i>Thông
					tin cá nhân
				</h2>
				<c:if test="${not empty profileSuccess}">
					<div class="alert alert-success d-flex align-items-center gap-2" role="status">
						<i class="bi bi-check-circle-fill"></i>
						<span><c:out value="${profileSuccess}" /></span>
					</div>
				</c:if>
				<c:if test="${not empty profileError}">
					<div class="alert alert-danger" role="alert" tabindex="-1"
						data-account-error>
						<c:out value="${profileError}" />
					</div>
				</c:if>

				<form method="post"
					action="${pageContext.request.contextPath}/account/profile"
					data-account-form>
					<input type="hidden" name="${_csrf.parameterName}"
						value="${_csrf.token}">
					<div class="mb-3">
						<label for="accountEmail" class="form-label fw-bold">Email</label>
						<input id="accountEmail" class="form-control bg-light" type="email"
							readonly value="${fn:escapeXml(accountProfile.email)}"
							aria-describedby="emailHelp">
						<div class="form-text" id="emailHelp">Email đăng nhập không
							thay đổi tại đây.</div>
					</div>
					<div class="mb-3">
						<label for="accountFullName" class="form-label fw-bold">Họ
							và tên <span class="text-danger">*</span>
						</label> <input id="accountFullName" class="form-control" name="fullName"
							type="text" required maxlength="100" autocomplete="name"
							value="${fn:escapeXml(profileForm.fullName)}">
					</div>
					<div class="mb-4">
						<label for="accountPhone" class="form-label fw-bold">Số
							điện thoại</label> <input id="accountPhone" class="form-control"
							name="phoneNumber" type="tel" maxlength="15" autocomplete="tel"
							inputmode="tel"
							oninput="this.value = this.value.replace(/[^0-9+]/g, '')"
							aria-describedby="phoneHelp"
							value="${fn:escapeXml(profileForm.phoneNumber)}">
						<div class="form-text" id="phoneHelp">Nhập 9–15 chữ số, có
							thể bắt đầu bằng dấu +.</div>
					</div>
					<button class="btn btn-primary px-4 rounded-3 fw-medium" type="submit">
						<i class="bi bi-floppy me-1"></i>Lưu thông tin
					</button>
				</form>

				<hr class="my-4">

				<h3 class="h6 fw-bold">Số điện thoại đăng nhập</h3>
				<p class="small text-muted">Xác minh số điện thoại để sử dụng
					OTP khi đăng nhập.</p>

				<ui:phone-auth mode="link" />
			</div>
		</section>

		<section class="col-lg-6" id="change-password"
			aria-labelledby="passwordHeading">
			<div class="bg-white border rounded-4 p-3 p-md-4 shadow-sm">
				<h2 class="h5 fw-bold mb-4 pb-2 border-bottom" id="passwordHeading">
					<i class="bi bi-shield-lock me-2 text-primary" aria-hidden="true"></i>Đổi
					mật khẩu
				</h2>
				<c:if test="${not empty passwordSuccess}">
					<div class="alert alert-success d-flex align-items-center gap-2" role="status">
						<i class="bi bi-check-circle-fill"></i>
						<span><c:out value="${passwordSuccess}" /></span>
					</div>
				</c:if>
				<c:if test="${not empty passwordError}">
					<div class="alert alert-danger" role="alert" tabindex="-1"
						data-account-error>
						<c:out value="${passwordError}" />
					</div>
				</c:if>

				<form method="post"
					action="${pageContext.request.contextPath}/account/password"
					data-account-form>
					<input type="hidden" name="${_csrf.parameterName}"
						value="${_csrf.token}">
					<div class="mb-3">
						<label for="currentPassword" class="form-label fw-bold">Mật
							khẩu hiện tại <span class="text-danger">*</span>
						</label>
						<div class="input-group">
							<input id="currentPassword" class="form-control"
								name="currentPassword" type="password" required maxlength="72"
								autocomplete="current-password">
							<button class="btn btn-outline-secondary" type="button"
								onclick="toggleProfilePwd('currentPassword', this)"
								aria-label="Hiện hoặc ẩn mật khẩu hiện tại">
								<i class="bi bi-eye"></i>
							</button>
						</div>
					</div>
					<div class="mb-3">
						<label for="newPassword" class="form-label fw-bold">Mật
							khẩu mới <span class="text-danger">*</span>
						</label>
						<div class="input-group">
							<input id="newPassword" class="form-control" name="newPassword"
								type="password" required minlength="8" maxlength="72"
								autocomplete="new-password" aria-describedby="passwordHelp">
							<button class="btn btn-outline-secondary" type="button"
								onclick="toggleProfilePwd('newPassword', this)"
								aria-label="Hiện hoặc ẩn mật khẩu mới">
								<i class="bi bi-eye"></i>
							</button>
						</div>
						<div class="form-text" id="passwordHelp">Ít nhất 8 ký tự và
							không quá 72 byte UTF-8. Nên kết hợp chữ, số và ký tự đặc biệt.</div>
					</div>
					<div class="mb-4">
						<label for="confirmPassword" class="form-label fw-bold">Xác
							nhận mật khẩu mới <span class="text-danger">*</span>
						</label>
						<div class="input-group">
							<input id="confirmPassword" class="form-control"
								name="confirmPassword" type="password" required minlength="8"
								maxlength="72" autocomplete="new-password">
							<button class="btn btn-outline-secondary" type="button"
								onclick="toggleProfilePwd('confirmPassword', this)"
								aria-label="Hiện hoặc ẩn xác nhận mật khẩu mới">
								<i class="bi bi-eye"></i>
							</button>
						</div>
					</div>
					<button class="btn btn-primary px-4 rounded-3 fw-medium" type="submit">
						<i class="bi bi-key me-1"></i>Đổi mật khẩu
					</button>
				</form>
			</div>
		</section>
	</div>

	<span id="savedProfileEmail" hidden><c:out
			value="${accountProfile.email}" /></span> <span id="savedProfileName"
		hidden><c:out value="${accountProfile.fullName}" /></span>
</main>

<script>
function toggleProfilePwd(inputId, btn) {
	const input = document.getElementById(inputId);
	const icon = btn.querySelector('i');
	if (!input) return;
	if (input.type === 'password') {
		input.type = 'text';
		icon.className = 'bi bi-eye-slash';
	} else {
		input.type = 'password';
		icon.className = 'bi bi-eye';
	}
}
</script>
<script src="${pageContext.request.contextPath}/js/account-profile.js"
	defer></script>
<script type="module"
	src="${pageContext.request.contextPath}/js/phone-auth.js"></script>
<jsp:include page="fragments/footer.jsp" />