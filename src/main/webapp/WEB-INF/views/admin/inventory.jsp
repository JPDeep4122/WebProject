<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tồn kho chi nhánh</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
<div class="d-flex">
    <jsp:include page="fragments/sidebar.jsp"/>
    <main class="flex-grow-1 bg-light p-4" style="min-width:0">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="mb-1">Tồn kho chi nhánh</h3>
                <div class="text-secondary">Xem số lượng thực tế, giữ chỗ và điều chỉnh thủ công</div>
            </div>
            <span class="badge text-bg-primary fs-6">${inventoryPage.totalElements} sản phẩm</span>
        </div>

        <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
        <c:if test="${not empty warning}"><div class="alert alert-warning"><c:out value="${warning}"/></div></c:if>

        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/inventory" class="row g-3 align-items-end">
                    <c:if test="${canChooseBranch}">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Chi nhánh</label>
                            <select class="form-select" name="branchId">
                                <option value="">Tất cả chi nhánh</option>
                                <c:forEach items="${branches}" var="branch">
                                    <option value="${branch.id}" ${selectedBranchId eq branch.id ? 'selected' : ''}>
                                        <c:out value="${branch.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Sản phẩm</label>
                        <input class="form-control" name="keyword" value="<c:out value='${keyword}'/>"
                               placeholder="Tên hoặc mã SKU">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Số dòng</label>
                        <select class="form-select" name="size">
                            <option value="10" ${pageSize eq 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${pageSize eq 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${pageSize eq 50 ? 'selected' : ''}>50</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button class="btn btn-primary"><i class="bi bi-search"></i> Lọc</button>
                        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin/inventory">Đặt lại</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 shadow-sm mb-4">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                    <tr><th>Sản phẩm</th><th>Chi nhánh</th><th class="text-center">Thực tế</th>
                        <th class="text-center">Giữ chỗ</th><th class="text-center">Có thể bán</th><th style="min-width:330px">Điều chỉnh</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${inventoryPage.content}" var="inventory">
                        <tr>
                            <td style="min-width:260px">
                                <div class="d-flex align-items-center gap-3">
                                    <c:if test="${not empty inventory.product.mainImageUrl}">
                                        <img src="${inventory.product.mainImageUrl}" alt="" width="52" height="52" class="rounded object-fit-cover">
                                    </c:if>
                                    <div><div class="fw-semibold"><c:out value="${inventory.product.name}"/></div>
                                        <small class="text-secondary">SKU: <c:out value="${inventory.product.sku}"/></small></div>
                                </div>
                            </td>
                            <td><div class="fw-semibold"><c:out value="${inventory.branch.name}"/></div>
                                <small class="text-secondary"><c:out value="${inventory.branch.address}"/></small></td>
                            <td class="text-center fs-5 fw-bold">${inventory.stockQuantity}</td>
                            <td class="text-center"><span class="badge text-bg-warning">${inventory.reservedQuantity}</span></td>
                            <td class="text-center"><span class="badge ${inventory.availableQuantity le 2 ? 'text-bg-danger' : 'text-bg-success'}">${inventory.availableQuantity}</span></td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/admin/inventory/${inventory.id}/adjust"
                                      class="row g-2" onsubmit="return confirm('Xác nhận điều chỉnh tồn kho sản phẩm này?');">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <input type="hidden" name="branchId" value="${selectedBranchId}">
                                    <div class="col-4"><input class="form-control form-control-sm" type="number" name="newStock"
                                         min="${inventory.reservedQuantity}" value="${inventory.stockQuantity}" required aria-label="Tồn kho mới"></div>
                                    <div class="col-8"><input class="form-control form-control-sm" name="reason" maxlength="500"
                                         placeholder="Lý do điều chỉnh" required></div>
                                    <div class="col-12"><button class="btn btn-sm btn-outline-primary w-100">
                                        <i class="bi bi-pencil-square"></i> Cập nhật tồn kho
                                    </button></div>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty inventoryPage.content}">
                        <tr><td colspan="6" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Không có dữ liệu tồn kho phù hợp.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <c:if test="${inventoryPage.totalPages gt 1}">
            <nav class="mb-4"><ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${inventoryPage.totalPages - 1}" var="index">
                    <c:url var="pageUrl" value="/admin/inventory">
                        <c:param name="page" value="${index}"/><c:param name="size" value="${pageSize}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}"/></c:if>
                    </c:url>
                    <li class="page-item ${inventoryPage.number eq index ? 'active' : ''}"><a class="page-link" href="${pageUrl}">${index + 1}</a></li>
                </c:forEach>
            </ul></nav>
        </c:if>

        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white py-3"><h5 class="mb-0"><i class="bi bi-clock-history"></i> 20 lần điều chỉnh gần nhất</h5></div>
            <div class="table-responsive"><table class="table table-sm align-middle mb-0">
                <thead class="table-light"><tr><th>Thời gian</th><th>Sản phẩm</th><th>Chi nhánh</th><th>Thay đổi</th><th>Người sửa</th><th>Lý do</th></tr></thead>
                <tbody>
                <c:forEach items="${adjustments}" var="item">
                    <tr><td class="text-nowrap">${item.createdAt}</td><td><c:out value="${item.product.name}"/></td>
                        <td><c:out value="${item.branch.name}"/></td>
                        <td><span class="fw-semibold">${item.previousStock}</span> <i class="bi bi-arrow-right"></i> <span class="fw-bold text-primary">${item.newStock}</span></td>
                        <td><c:out value="${item.adjustedBy.fullName}"/></td><td><c:out value="${item.reason}"/></td></tr>
                </c:forEach>
                <c:if test="${empty adjustments}"><tr><td colspan="6" class="text-center text-secondary py-4">Chưa có lịch sử điều chỉnh thủ công.</td></tr></c:if>
                </tbody>
            </table></div>
        </div>
    </main>
</div>
</body>
</html>
