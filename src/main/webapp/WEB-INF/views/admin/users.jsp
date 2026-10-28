<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Quản lý tài khoản</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp" />
<jsp:include page="fragments/theme.jsp" />
<style>
	/* Keep the dense account table readable; scroll it on narrow viewports instead of
	   squeezing buttons and breaking every word onto a separate line. */
	.admin-users-main { min-width: 0; }
	.admin-users-table { width: 100%; min-width: 1450px; table-layout: fixed; }
	.admin-sidebar + main .admin-users-table th,
	.admin-sidebar + main .admin-users-table td {
		vertical-align: middle;
		word-break: normal;
		overflow-wrap: normal;
	}
	.admin-users-table .user-email-cell { overflow-wrap: anywhere; }
	.admin-users-table .user-role-cell .badge { white-space: nowrap; }
	.admin-users-table .user-permission-form { min-width: 175px; }
	.admin-users-table .user-update-form { min-width: 305px; flex-wrap: nowrap; }
	.admin-users-table .user-update-form input[name="fullName"] { flex: 0 0 125px; width: 125px !important; }
	.admin-users-table .user-update-form input[type="password"] { flex: 1 0 150px; min-width: 150px; }
	.admin-users-table .user-action-form { min-width: 88px; }
	.admin-sidebar + main .admin-users-table .btn {
		flex-shrink: 0;
		white-space: nowrap;
	}
	.admin-user-create-form select[name="role"] { min-width: 125px; }
	.admin-user-create-form select[name="branchId"] { min-width: 235px; }
	@media (max-width: 767.98px) {
		.admin-users-main { padding: 1rem !important; }
		.admin-user-create-form > div { flex: 0 0 100%; max-width: 100%; }
	}
</style>
</head>
<body>
	<div class="d-flex"><jsp:include page="fragments/sidebar.jsp" /><main
			class="admin-users-main flex-grow-1 bg-light p-4">
			<h3>Quản lý tài khoản</h3>
			<c:if test="${not empty success}">
				<div class="alert alert-success">${success}</div>
			</c:if>
			<c:if test="${not empty error}">
				<div class="alert alert-danger">${error}</div>
			</c:if>
			<div class="card mb-3">
				<div class="card-header">Tìm kiếm và lọc</div>
				<div class="card-body">
					<form method="get" action="/admin/users"
						class="row g-2 align-items-end">
						<div class="col-md-2">
							<label class="form-label">ID tài khoản</label><input
								class="form-control" type="number" name="id"
								value="${selectedId}" placeholder="Ví dụ: 15">
						</div>
						<div class="col-md-2">
							<label class="form-label">Loại tài khoản</label><select
								class="form-select" name="type"><option value="">Tất
									cả</option>
								<option value="STAFF"
									${selectedType eq 'STAFF' ? 'selected' : ''}>Nhân viên</option>
								<option value="SHIPPER"
									${selectedType eq 'SHIPPER' ? 'selected' : ''}>Shipper</option>
								<option value="CUSTOMER"
									${selectedType eq 'CUSTOMER' ? 'selected' : ''}>Khách
									hàng</option>
								<option value="ADMIN"
									${selectedType eq 'ADMIN' ? 'selected' : ''}>Quản trị
									viên</option></select>
						</div>
						<div class="col-md-2">
							<label class="form-label">Sắp xếp theo</label><select
								class="form-select" name="sort"><option value="id">ID</option>
								<option value="fullName"
									${selectedSort eq 'fullName' ? 'selected' : ''}>Họ tên</option>
								<option value="email"
									${selectedSort eq 'email' ? 'selected' : ''}>Email</option>
								<option value="createdAt"
									${selectedSort eq 'createdAt' ? 'selected' : ''}>Ngày
									tạo</option>
								<option value="active"
									${selectedSort eq 'active' ? 'selected' : ''}>Trạng
									thái</option></select>
						</div>
						<div class="col-md-2">
							<label class="form-label">Thứ tự</label><select
								class="form-select" name="direction"><option
									value="asc">Tăng dần</option>
								<option value="desc"
									${selectedDirection eq 'desc' ? 'selected' : ''}>Giảm
									dần</option></select>
						</div>
						<div class="col-md-2">
							<button class="btn btn-primary">Lọc tài khoản</button>
							<a class="btn btn-outline-secondary" href="/admin/users">Đặt
								lại</a>
						</div>
					</form>
				</div>
			</div>
			<div class="card mb-3">
				<div class="card-header">Mở tài khoản và phân quyền</div>
				<div class="card-body">
					<form method="post" action="/admin/users" class="row g-2 admin-user-create-form">
						<input type="hidden" name="${_csrf.parameterName}"
							value="${_csrf.token}">
						<div class="col-md-3">
							<input class="form-control" name="email" type="email"
								placeholder="Email" required>
						</div>
						<div class="col-md-2">
							<input class="form-control" name="fullName" placeholder="Họ tên"
								required>
						</div>
						<div class="col-md-2">
							<input class="form-control" name="password" type="password"
								placeholder="Mật khẩu" minlength="6" required>
						</div>
						<div class="col-md-2">
							<input class="form-control" name="phoneNumber"
								placeholder="Số điện thoại">
						</div>
						<div class="col-md-1">
							<select class="form-select" name="role"><option
									value="ROLE_CUSTOMER">Khách hàng</option>
								<option value="ROLE_STAFF">Nhân viên</option>
								<option value="ROLE_SHIPPER">Shipper</option>
								<option value="ROLE_ADMIN">Admin</option></select>
						</div>
						<div class="col-md-2">
							<select class="form-select" name="branchId"><option
									value="">Chi nhánh (nhân viên/shipper)</option>
								<c:forEach items="${branches}" var="b">
									<option value="${b.id}">${b.name}</option>
								</c:forEach></select>
						</div>
						<div class="col-12">
							<button class="btn btn-success">Mở tài khoản</button>
						</div>
					</form>
				</div>
			</div>
			<div class="card">
				<div class="table-responsive">
					<table class="table table-striped align-middle mb-0 admin-users-table">
						<colgroup>
							<col style="width: 55px"><col style="width: 205px"><col style="width: 150px">
							<col style="width: 135px"><col style="width: 190px"><col style="width: 175px">
							<col style="width: 145px"><col style="width: 310px"><col style="width: 90px">
						</colgroup>
						<thead>
							<tr>
								<th>ID</th>
								<th>Tài khoản</th>
								<th>Họ tên</th>
								<th>Vai trò</th>
								<th>Phân quyền</th>
								<th>Chi nhánh</th>
								<th>Trạng thái</th>
								<th>Đổi thông tin</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${users}" var="u">
								<tr>
									<td>${u.id}</td>
									<td class="user-email-cell">${u.email}<br> <small>${u.phoneNumber}</small></td>
									<td>${u.fullName}</td>
									<td class="user-role-cell"><c:forEach items="${u.roles}" var="r">
											<span class="badge bg-secondary">${r.name}</span>
										</c:forEach></td>
									<td>
										<form method="post" action="/admin/users/${u.id}/permission"
											class="d-flex flex-column gap-1 user-permission-form">
											<input type="hidden" name="${_csrf.parameterName}"
												value="${_csrf.token}">
											<select class="form-select form-select-sm user-role-select"
												name="role" aria-label="Vai trò mới cho ${u.email}">
												<option value="ROLE_CUSTOMER" ${u.roles.iterator().next().name eq 'ROLE_CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
												<option value="ROLE_STAFF" ${u.roles.iterator().next().name eq 'ROLE_STAFF' ? 'selected' : ''}>Nhân viên</option>
												<option value="ROLE_SHIPPER" ${u.roles.iterator().next().name eq 'ROLE_SHIPPER' ? 'selected' : ''}>Shipper</option>
												<option value="ROLE_ADMIN" ${u.roles.iterator().next().name eq 'ROLE_ADMIN' ? 'selected' : ''}>Admin</option>
											</select>
											<select class="form-select form-select-sm user-branch-select"
												name="branchId" aria-label="Chi nhánh của ${u.email}">
												<option value="">Chọn chi nhánh</option>
												<c:forEach items="${branches}" var="b">
													<option value="${b.id}" ${u.branch.id eq b.id ? 'selected' : ''}>${b.name}</option>
												</c:forEach>
											</select>
											<button type="submit" class="btn btn-sm btn-outline-primary">Lưu quyền</button>
										</form>
									</td>
									<td>${u.branch.name}</td>
									<td><span
										class="badge ${u.blocked ? 'bg-danger'
            : (u.active ? 'bg-success' : 'bg-warning text-dark')}">
											${u.blocked ? 'Đã khóa'
            : (u.active ? 'Đang hoạt động' : 'Chờ xác thực')}
									</span></td>
									<td><form method="post"
											action="/admin/users/${u.id}/update" class="d-flex gap-1 user-update-form">
											<input type="hidden" name="${_csrf.parameterName}"
												value="${_csrf.token}"> <input type="hidden"
												name="email" value="${fn:escapeXml(u.email)}"> <input
												class="form-control form-control-sm" name="fullName"
												value="${fn:escapeXml(u.fullName)}" required
												style="width: 130px"> <input type="hidden"
												name="role" value="${u.roles.iterator().next().name}">
											<input type="hidden" name="active" value="${u.active}">
											<input type="password" class="form-control form-control-sm"
												placeholder="Mật khẩu mới" autocomplete="new-password"
												minlength="6" maxlength="100"
												oninput="this.name = this.value ? 'password' : ''">
											<button class="btn btn-sm btn-outline-primary">Lưu
												tên</button>
										</form></td>
									<td><form method="post" class="user-action-form"
											action="/admin/users/${u.id}/toggle">
											<input type="hidden" name="${_csrf.parameterName}"
												value="${_csrf.token}">
											<button type="submit" class="btn btn-sm btn-outline-warning">
												${u.blocked ? 'Mở khóa' : (u.active ? 'Khóa' : 'Kích hoạt')}
											</button>
										</form></td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>
			</div>
		</main>
	</div>
	<script>
		(function () {
			function updateBranchField(form) {
				const role = form.querySelector('.user-role-select').value;
				const branch = form.querySelector('.user-branch-select');
				const needsBranch = role === 'ROLE_STAFF' || role === 'ROLE_SHIPPER';
				branch.classList.toggle('d-none', !needsBranch);
				branch.disabled = !needsBranch;
				branch.required = needsBranch;
			}
			document.querySelectorAll('.user-permission-form').forEach(function (form) {
				updateBranchField(form);
				form.querySelector('.user-role-select').addEventListener('change', function () {
					updateBranchField(form);
				});
			});
		})();
	</script>
</body>
</html>
