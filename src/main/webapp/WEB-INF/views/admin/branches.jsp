<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý chi nhánh</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
</head>
<body>
<div class="d-flex">
    <jsp:include page="fragments/sidebar.jsp"/>
    <main class="flex-grow-1 bg-light p-4">
        <h3 class="mb-4">Quản lý chi nhánh</h3>

        <c:if test="${not empty success}"><div class="alert alert-success">${success}</div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>

        <div class="card mb-4">
            <div class="card-header">Thêm chi nhánh</div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/admin/branches" class="row g-2">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <div class="col-lg-3"><input class="form-control" name="name" placeholder="Tên chi nhánh" maxlength="150" required></div>
                    <div class="col-lg-4"><input class="form-control" name="address" placeholder="Địa chỉ" maxlength="255" required></div>
                    <div class="col-md-4 col-lg-2"><input class="form-control" name="province" placeholder="Tỉnh / thành phố" maxlength="100"></div>
                    <div class="col-md-4 col-lg-2"><input class="form-control" name="phone" placeholder="Số điện thoại" maxlength="20"></div>
                    <div class="col-md-4 col-lg-1 d-grid"><button class="btn btn-primary">Thêm</button></div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="table table-striped align-middle mb-0">
                    <thead><tr><th>ID</th><th>Tên chi nhánh</th><th>Địa chỉ</th><th>Tỉnh / thành phố</th><th>Điện thoại</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
                    <tbody>
                    <c:forEach items="${branches}" var="branch">
                        <tr>
                            <td>${branch.id}
                                <form id="update-${branch.id}" method="post" action="${pageContext.request.contextPath}/admin/branches/${branch.id}/update">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                </form>
                            </td>
                            <td><input form="update-${branch.id}" class="form-control form-control-sm" name="name" value="${branch.name}" maxlength="150" required></td>
                            <td><input form="update-${branch.id}" class="form-control form-control-sm" name="address" value="${branch.address}" maxlength="255" required></td>
                            <td><input form="update-${branch.id}" class="form-control form-control-sm" name="province" value="${branch.province}" maxlength="100"></td>
                            <td><input form="update-${branch.id}" class="form-control form-control-sm" name="phone" value="${branch.phone}" maxlength="20"></td>
                            <td><select form="update-${branch.id}" class="form-select form-select-sm" name="active">
                                <option value="true" ${branch.active ? 'selected' : ''}>Đang hoạt động</option>
                                <option value="false" ${!branch.active ? 'selected' : ''}>Đã tạm ngưng</option>
                            </select></td>
                            <td><button form="update-${branch.id}" class="btn btn-sm btn-outline-primary">Lưu</button></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty branches}"><tr><td colspan="7" class="text-center text-muted py-4">Chưa có chi nhánh nào.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="alert alert-info mt-3 mb-0"><i class="bi bi-info-circle me-1"></i>Tạm ngưng chi nhánh sẽ giữ lại dữ liệu đơn hàng và tồn kho hiện có.</div>
    </main>
</div>
</body>
</html>
