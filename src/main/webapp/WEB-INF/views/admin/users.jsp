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
.admin-users-main {
	min-width: 0;
}

.admin-users-table {
	width: 100%;
	min-width: 1450px;
	table-layout: fixed;
}

.admin-sidebar+main .admin-users-table th, 
.admin-sidebar+main .admin-users-table td {
	vertical-align: middle;
	word-break: normal;
	overflow-wrap: normal;
}

.admin-users-table .user-email-cell {
	overflow-wrap: anywhere;
}

.admin-users-table .user-role-cell .badge {
	white-space: nowrap;
}

.admin-users-table .user-permission-form {
	min-width: 175px;
}

.admin-users-table .user-update-form {
	min-width: 285px;
	flex-wrap: nowrap;
}

.admin-users-table .user-update-form input[name="fullName"] {
	flex: 1 1 150px;
	min-width: 100px;
}

.admin-users-table .user-password-details {
	margin-top: .4rem;
}

.admin-users-table .user-password-details summary {
	cursor: pointer;
	list-style: none;
	width: fit-content;
}

.admin-users-table .user-password-details summary::-webkit-details-marker {
	display: none;
}

.admin-users-table .user-password-form {
	display: flex;
	flex-wrap: wrap;
	gap: .35rem;
	margin-top: .45rem;
}

.admin-users-table .user-password-form input[type="password"] {
	flex: 1 1 160px;
	min-width: 150px;
}

.admin-users-table .user-action-form {
	min-width: 88px;
}

.admin-sidebar+main .admin-users-table .btn {
	flex-shrink: 0;
	white-space: nowrap;
}

.admin-user-create-form select[name="role"] {
	min-width: 125px;
}

.admin-user-create-form select[name="branchId"] {
	min-width: 235px;
}

@media (max-width: 767.98px) {
	.admin-users-main {
		padding: 1rem !important;
	}
	.admin-user-create-form>div {
		flex: 0 0 100%;
		max-width: 100%;
	}
}
</style>
</head>
<body>
	<div class="d-flex">
		<jsp:include page="fragments/sidebar.jsp" />
		<main class="admin-users-main flex-grow-1 bg-light p-4">
			<h3>Quản lý tài khoản</h3>
			<c:if test="${not empty success}">
				<div class="alert alert-success">${success}</div>
			</c:if>
			<c:if test="${not empty error}">
				<div class="alert alert-danger">${error}</div>
			</c:if>

			<div class="card mb-3">
				<div class="card-header fw-bold">Tìm kiếm và lọc tài khoản</div>
				<div class="card-body">
					<form method="get" action="/admin/users" class="row g-2 align-items-end">
						<div class="col-md-3">
							<label class="form-label small">Từ khóa (Tên / Email / SĐT)</label>
							<input class="form-control" type="text" name="name"
								value="${fn:escapeXml(selectedName)}"
								placeholder="Nhập tên, email hoặc SĐT...">
						</div>
						<div class="col-md-2">
							<label class="form-label small">ID tài khoản</label>
							<input class="form-control" type="number" name="id"
								value="${selectedId}" placeholder="Ví dụ: 15" min="0">
						</div>
						<div class="col-md-2">
							<label class="form-label small">Loại tài khoản</label>
							<select class="form-select" name="type">
								<option value="">Tất cả vai trò</option>
								<option value="STAFF" ${selectedType eq 'STAFF' ? 'selected' : ''}>Nhân viên</option>
								<option value="SHIPPER" ${selectedType eq 'SHIPPER' ? 'selected' : ''}>Shipper</option>
								<c:if test="${isAdminActor}">
									<option value="BRANCH_MANAGER" ${selectedType eq 'BRANCH_MANAGER' ? 'selected' : ''}>Quản lý chi nhánh</option>
									<option value="CUSTOMER" ${selectedType eq 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
									<option value="ADMIN" ${selectedType eq 'ADMIN' ? 'selected' : ''}>Quản trị viên</option>
								</c:if>
							</select>
						</div>
						<c:if test="${isAdminActor}">
							<div class="col-md-2">
								<label class="form-label small">Chi nhánh</label>
								<select class="form-select" name="branchId">
									<option value="">Tất cả chi nhánh</option>
									<c:forEach items="${branches}" var="b">
										<option value="${b.id}" ${selectedBranchId eq b.id ? 'selected' : ''}>${b.name}</option>
									</c:forEach>
								</select>
							</div>
						</c:if>
						<div class="col-md-2">
							<label class="form-label small">Trạng thái</label>
							<select class="form-select" name="status">
								<option value="">Tất cả trạng thái</option>
								<option value="ACTIVE" ${selectedStatus eq 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
								<option value="BLOCKED" ${selectedStatus eq 'BLOCKED' ? 'selected' : ''}>Đã khóa</option>
								<option value="PENDING" ${selectedStatus eq 'PENDING' ? 'selected' : ''}>Chờ xác thực</option>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label small">Sắp xếp theo</label>
							<select class="form-select" name="sort">
								<option value="createdAt" ${empty selectedSort or selectedSort eq 'createdAt' ? 'selected' : ''}>Ngày tạo</option>
								<option value="id" ${selectedSort eq 'id' ? 'selected' : ''}>ID</option>
								<option value="fullName" ${selectedSort eq 'fullName' ? 'selected' : ''}>Họ tên</option>
								<option value="email" ${selectedSort eq 'email' ? 'selected' : ''}>Email</option>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label small">Thứ tự</label>
							<select class="form-select" name="direction">
								<option value="desc" ${empty selectedDirection or selectedDirection eq 'desc' ? 'selected' : ''}>Mới nhất (Giảm dần)</option>
								<option value="asc" ${selectedDirection eq 'asc' ? 'selected' : ''}>Cũ nhất (Tăng dần)</option>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label small">Hiển thị / trang</label>
							<select class="form-select" name="size">
								<option value="10" ${pageSize eq 10 ? 'selected' : ''}>10 tài khoản</option>
								<option value="15" ${empty pageSize or pageSize eq 15 ? 'selected' : ''}>15 tài khoản</option>
								<option value="20" ${pageSize eq 20 ? 'selected' : ''}>20 tài khoản</option>
								<option value="50" ${pageSize eq 50 ? 'selected' : ''}>50 tài khoản</option>
							</select>
						</div>
						<div class="col-md-3 d-flex gap-1">
							<button class="btn btn-primary flex-grow-1">
								<i class="bi bi-search"></i> Lọc tài khoản
							</button>
							<a class="btn btn-outline-secondary" href="/admin/users">Đặt lại</a>
						</div>
					</form>
				</div>
			</div>

			<div class="card mb-3">
				<div class="card-header fw-bold">Mở tài khoản và phân quyền</div>
				<div class="card-body">
					<form method="post" action="/admin/users" class="row g-2 admin-user-create-form" autocomplete="off">
						<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
						<div class="col-md-3">
							<input class="form-control" name="email" type="email" placeholder="Email" autocomplete="off" required>
						</div>
						<div class="col-md-2">
							<input class="form-control" name="fullName" placeholder="Họ tên" required>
						</div>
						<div class="col-md-2">
							<input class="form-control" name="password" type="password"
								placeholder="Mật khẩu" minlength="6" autocomplete="new-password" required>
						</div>
						<div class="col-md-2">
							<input class="form-control" name="phoneNumber" placeholder="Số điện thoại">
						</div>
						<div class="col-md-2">
							<select class="form-select" name="role">
								<c:if test="${isAdminActor}">
									<option value="ROLE_CUSTOMER">Khách hàng</option>
									<option value="ROLE_BRANCH_MANAGER">Quản lý chi nhánh</option>
								</c:if>
								<option value="ROLE_STAFF">Nhân viên</option>
								<option value="ROLE_SHIPPER">Shipper</option>
								<c:if test="${isAdminActor}">
									<option value="ROLE_ADMIN">Admin</option>
								</c:if>
							</select>
						</div>
						<div class="col-md-2">
							<c:choose>
								<c:when test="${isAdminActor}">
									<select class="form-select" name="branchId">
										<option value="">Chi nhánh (nhân viên/quản lý)</option>
										<c:forEach items="${branches}" var="b">
											<option value="${b.id}">${b.name}</option>
										</c:forEach>
									</select>
								</c:when>
								<c:otherwise>
									<input type="hidden" name="branchId" value="${actorBranchId}">
									<input class="form-control bg-light" value="Chi nhánh hiện tại của bạn" disabled>
								</c:otherwise>
							</c:choose>
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
							<col style="width: 55px">
							<col style="width: 200px">
							<col style="width: 150px">
							<col style="width: 125px">
							<col style="width: 185px">
							<col style="width: 165px">
							<col style="width: 140px">
							<col style="width: 130px">
							<col style="width: 300px">
							<col style="width: 85px">
						</colgroup>
						<thead>
							<tr>
								<th>ID</th>
								<th>Tài khoản</th>
								<th>Họ tên</th>
								<th>Vai trò</th>
								<th>Phân quyền</th>
								<th>Chi nhánh</th>
								<th>Ngày tạo</th>
								<th>Trạng thái</th>
								<th>Cập nhật thông tin</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${usersPage.content}" var="u">
								<tr>
									<td>${u.id}</td>
									<td class="user-email-cell">${u.email}<br> <small>${u.phoneNumber}</small></td>
									<td>
										<c:choose>
											<c:when test="${not empty u.fullName}">
												<strong>${u.fullName}</strong>
											</c:when>
											<c:otherwise>
												<span class="text-danger fst-italic">(Chưa có tên)</span>
											</c:otherwise>
										</c:choose>
									</td>
									<td class="user-role-cell">
										<c:forEach items="${u.roles}" var="r">
											<span class="badge bg-secondary">${r.name}</span>
										</c:forEach>
									</td>
									<td>
										<c:choose>
											<c:when test="${isAdminActor}">
												<form method="post" action="/admin/users/${u.id}/permission"
													class="d-flex flex-column gap-1 user-permission-form">
													<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
													<select class="form-select form-select-sm user-role-select"
														name="role" aria-label="Vai trò mới cho ${u.email}">
														<option value="ROLE_CUSTOMER" ${u.roles.iterator().next().name eq 'ROLE_CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
														<option value="ROLE_STAFF" ${u.roles.iterator().next().name eq 'ROLE_STAFF' ? 'selected' : ''}>Nhân viên</option>
														<option value="ROLE_SHIPPER" ${u.roles.iterator().next().name eq 'ROLE_SHIPPER' ? 'selected' : ''}>Shipper</option>
														<option value="ROLE_BRANCH_MANAGER" ${u.roles.iterator().next().name eq 'ROLE_BRANCH_MANAGER' ? 'selected' : ''}>Quản lý chi nhánh</option>
														<option value="ROLE_ADMIN" ${u.roles.iterator().next().name eq 'ROLE_ADMIN' ? 'selected' : ''}>Admin</option>
													</select>
													<div class="user-branch-picker ${requiresBranch ? '' : 'd-none'}">
														<select class="form-select form-select-sm user-branch-select" name="branchId"
															aria-label="Chi nhánh cho ${u.email}">
															<option value="">-- Chọn chi nhánh --</option>
															<c:forEach items="${branches}" var="b">
																<option value="${b.id}" ${u.branch != null && u.branch.id eq b.id ? 'selected' : ''}>${b.name}</option>
															</c:forEach>
														</select>
													</div>
													<button class="btn btn-sm btn-outline-primary" type="submit">Lưu quyền</button>
												</form>
											</c:when>
											<c:otherwise>
												<small class="text-muted">Chỉ Admin tổng được đổi vai trò/chi nhánh</small>
											</c:otherwise>
										</c:choose>
									</td>
									<td>${u.branch != null ? u.branch.name : '-'}</td>
									<td>
										<small class="text-muted">
											${u.createdAt != null ? u.createdAt.toString().substring(0, 16).replace('T', ' ') : '-'}
										</small>
									</td>
									<td>
										<span class="badge ${u.blocked ? 'bg-danger' : (u.active ? 'bg-success' : 'bg-warning text-dark')}">
											${u.blocked ? 'Đã khóa' : (u.active ? 'Đang hoạt động' : 'Chờ xác thực')}
										</span>
									</td>
									<td>
										<form method="post" action="/admin/users/${u.id}/update" class="d-flex gap-1 user-update-form">
											<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
											<input type="hidden" name="email" value="${fn:escapeXml(u.email)}">
											<input class="form-control form-control-sm" name="fullName"
												value="${fn:escapeXml(u.fullName)}" placeholder="Nhập họ tên" required aria-label="Họ tên ${u.email}">
											<input type="hidden" name="role" value="${u.roles.iterator().next().name}">
											<input type="hidden" name="active" value="${u.active}">
											<button class="btn btn-sm btn-outline-primary" type="submit">Lưu tên</button>
										</form>
										<details class="user-password-details">
											<summary class="btn btn-sm btn-outline-secondary">Đổi mật khẩu</summary>
											<form method="post" action="/admin/users/${u.id}/update" class="user-password-form">
												<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
												<input type="hidden" name="email" value="${fn:escapeXml(u.email)}">
												<input type="hidden" name="fullName" value="${fn:escapeXml(u.fullName)}">
												<input type="hidden" name="role" value="${u.roles.iterator().next().name}">
												<input type="hidden" name="active" value="${u.active}">
												<input type="password" class="form-control form-control-sm" name="password"
													placeholder="Mật khẩu mới (ít nhất 6 ký tự)" autocomplete="new-password" minlength="6" maxlength="100"
													required aria-label="Mật khẩu mới cho ${u.email}">
												<button class="btn btn-sm btn-primary" type="submit">Lưu mật khẩu</button>
											</form>
										</details>
									</td>
									<td>
										<form method="post" class="user-action-form" action="/admin/users/${u.id}/toggle">
											<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
											<button type="submit" class="btn btn-sm btn-outline-warning">
												${u.blocked ? 'Mở khóa' : (u.active ? 'Khóa' : 'Kích hoạt')}
											</button>
										</form>
									</td>
								</tr>
							</c:forEach>
							<c:if test="${empty usersPage.content}">
								<tr>
									<td colspan="10" class="text-center text-muted py-4">Không tìm thấy tài khoản nào phù hợp.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>

				<div class="card-footer bg-white d-flex flex-column flex-md-row justify-content-between align-items-center py-2">
					<small class="text-muted">
						Hiển thị <b>${usersPage.numberOfElements}</b> / Tổng số <b>${usersPage.totalElements}</b> tài khoản
						(Trang ${usersPage.number + 1}/${usersPage.totalPages == 0 ? 1 : usersPage.totalPages})
					</small>

					<c:if test="${usersPage.totalPages gt 1}">
						<nav class="my-1">
							<ul class="pagination pagination-sm mb-0">
								<li class="page-item ${usersPage.first ? 'disabled' : ''}">
									<c:url var="prevUrl" value="/admin/users">
										<c:param name="page" value="${usersPage.number - 1}" />
										<c:param name="size" value="${pageSize}" />
										<c:if test="${not empty selectedName}"><c:param name="name" value="${selectedName}" /></c:if>
										<c:if test="${not empty selectedId}"><c:param name="id" value="${selectedId}" /></c:if>
										<c:if test="${not empty selectedType}"><c:param name="type" value="${selectedType}" /></c:if>
										<c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}" /></c:if>
										<c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}" /></c:if>
										<c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}" /></c:if>
										<c:if test="${not empty selectedDirection}"><c:param name="direction" value="${selectedDirection}" /></c:if>
									</c:url>
									<a class="page-link" href="${prevUrl}">&laquo; Trước</a>
								</li>
								<c:forEach begin="0" end="${usersPage.totalPages - 1}" var="index">
									<li class="page-item ${usersPage.number eq index ? 'active' : ''}">
										<c:url var="pageUrl" value="/admin/users">
											<c:param name="page" value="${index}" />
											<c:param name="size" value="${pageSize}" />
											<c:if test="${not empty selectedName}"><c:param name="name" value="${selectedName}" /></c:if>
											<c:if test="${not empty selectedId}"><c:param name="id" value="${selectedId}" /></c:if>
											<c:if test="${not empty selectedType}"><c:param name="type" value="${selectedType}" /></c:if>
											<c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}" /></c:if>
											<c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}" /></c:if>
											<c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}" /></c:if>
											<c:if test="${not empty selectedDirection}"><c:param name="direction" value="${selectedDirection}" /></c:if>
										</c:url>
										<a class="page-link" href="${pageUrl}">${index + 1}</a>
									</li>
								</c:forEach>
								<li class="page-item ${usersPage.last ? 'disabled' : ''}">
									<c:url var="nextUrl" value="/admin/users">
										<c:param name="page" value="${usersPage.number + 1}" />
										<c:param name="size" value="${pageSize}" />
										<c:if test="${not empty selectedName}"><c:param name="name" value="${selectedName}" /></c:if>
										<c:if test="${not empty selectedId}"><c:param name="id" value="${selectedId}" /></c:if>
										<c:if test="${not empty selectedType}"><c:param name="type" value="${selectedType}" /></c:if>
										<c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}" /></c:if>
										<c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}" /></c:if>
										<c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}" /></c:if>
										<c:if test="${not empty selectedDirection}"><c:param name="direction" value="${selectedDirection}" /></c:if>
									</c:url>
									<a class="page-link" href="${nextUrl}">Sau &raquo;</a>
								</li>
							</ul>
						</nav>
					</c:if>
				</div>
			</div>
		</main>
	</div>

	<script>
		(function() {
			function updateBranchField(form) {
				const role = form.querySelector('.user-role-select').value;
				const branch = form.querySelector('.user-branch-picker');
				const branchSelect = form.querySelector('.user-branch-select');
				const needsBranch = role === 'ROLE_BRANCH_MANAGER'
						|| role === 'ROLE_STAFF' || role === 'ROLE_SHIPPER';
				if (branch) branch.classList.toggle('d-none', !needsBranch);
				if (branchSelect) {
					branchSelect.disabled = !needsBranch;
					branchSelect.required = needsBranch;
				}
			}
			document.querySelectorAll('.user-permission-form').forEach(
					function(form) {
						updateBranchField(form);
						form.querySelector('.user-role-select')
								.addEventListener('change', function() {
									updateBranchField(form);
								});
					});
		})();
	</script>
</body>
</html>