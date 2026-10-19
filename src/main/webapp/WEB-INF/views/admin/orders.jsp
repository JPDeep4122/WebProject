<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý đơn hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<div class="d-flex">
    <jsp:include page="fragments/sidebar.jsp"/>
    <main class="flex-grow-1 bg-light p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h3 class="mb-1">Quản lý đơn hàng</h3>
                <div class="text-secondary">Theo dõi đơn hàng theo chi nhánh và trạng thái</div>
            </div>
            <span class="badge text-bg-primary fs-6">${ordersPage.totalElements} đơn</span>
        </div>

        <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>

        <div class="card mb-3">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/orders" class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label">Chi nhánh</label>
                        <select class="form-select" name="branchId" ${canChooseBranch ? '' : 'disabled'}>
                            <c:if test="${canChooseBranch}"><option value="">Tất cả chi nhánh</option></c:if>
                            <c:forEach items="${branches}" var="branch">
                                <option value="${branch.id}" ${selectedBranchId eq branch.id ? 'selected' : ''}>${branch.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Trạng thái</label>
                        <select class="form-select" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach items="${statuses}" var="item">
                                <option value="${item}" ${selectedStatus eq item.toString() ? 'selected' : ''}>${item}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Số dòng</label>
                        <select class="form-select" name="size">
                            <option value="10" ${pageSize eq 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${pageSize eq 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${pageSize eq 50 ? 'selected' : ''}>50</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button class="btn btn-primary"><i class="bi bi-funnel"></i> Lọc đơn hàng</button>
                        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin/orders">Đặt lại</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark"><tr><th>Mã đơn</th><th>Khách hàng</th><th>Chi nhánh</th><th>Ngày tạo</th><th class="text-end">Thành tiền</th><th>Trạng thái</th></tr></thead>
                    <tbody>
                    <c:forEach items="${ordersPage.content}" var="order">
                        <tr>
                            <td class="fw-semibold">${order.orderCode}</td>
                            <td>${order.user.fullName}<br><small class="text-secondary">${order.recipientPhone}</small></td>
                            <td><c:out value="${order.branch.name}" default="Chưa gán"/></td>
                            <td>${order.createdAt}</td>
                            <td class="text-end"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/> ₫</td>
                            <td><span class="badge text-bg-secondary">${order.status}</span></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty ordersPage.content}"><tr><td colspan="6" class="text-center text-secondary py-5">Không có đơn hàng phù hợp.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <c:if test="${ordersPage.totalPages gt 1}">
            <nav class="mt-3"><ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${ordersPage.totalPages - 1}" var="index">
                    <li class="page-item ${ordersPage.number eq index ? 'active' : ''}">
                        <c:url var="pageUrl" value="/admin/orders">
                            <c:param name="page" value="${index}"/><c:param name="size" value="${pageSize}"/>
                            <c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}"/></c:if>
                            <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                        </c:url>
                        <a class="page-link" href="${pageUrl}">${index + 1}</a>
                    </li>
                </c:forEach>
            </ul></nav>
        </c:if>
    </main>
</div>
</body>
</html>
