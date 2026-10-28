<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hóa đơn</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body class="bg-light">
<div class="d-flex">
    <jsp:include page="fragments/sidebar.jsp" />
    <main class="flex-grow-1 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1">Hóa đơn</h2>
                <div class="text-secondary">Đơn đã đặt, loại trừ đơn đã hủy. Chọn chi tiết để xem hóa đơn đầy đủ.</div>
            </div>
            <span class="badge text-bg-primary fs-6">${invoicesPage.totalElements} hóa đơn</span>
        </div>
        <form method="get" action="${pageContext.request.contextPath}/admin/invoices"
              class="card card-body border-0 shadow-sm mb-3">
            <label for="invoice-search" class="form-label fw-semibold">Tìm hóa đơn</label>
            <div class="input-group mb-3">
                <input id="invoice-search" class="form-control" type="search" name="q"
                       value="${fn:escapeXml(searchQuery)}"
                       placeholder="Nhập mã hóa đơn hoặc mã khách hàng (ID tài khoản)">
                <button class="btn btn-primary" type="submit"><i class="bi bi-search me-1"></i>Tìm</button>
                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin/invoices">Xóa lọc</a>
            </div>
            <div class="row g-3 align-items-end">
                <div class="col-md-5 col-lg-4">
                    <label for="invoice-status" class="form-label mb-1">Trạng thái đơn hàng</label>
                    <select id="invoice-status" class="form-select" name="status">
                        <option value="">Tất cả trạng thái</option>
                        <c:forEach items="${statuses}" var="invoiceStatus">
                            <option value="${invoiceStatus.name()}" ${selectedStatus eq invoiceStatus.name() ? 'selected' : ''}>
                                <c:out value="${invoiceStatus}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-5 col-lg-4">
                    <label for="invoice-branch" class="form-label mb-1">Chi nhánh</label>
                    <select id="invoice-branch" class="form-select" name="branchId">
                        <option value="">Tất cả chi nhánh</option>
                        <c:forEach items="${branches}" var="branch">
                            <option value="${branch.id}" ${selectedBranchId eq branch.id ? 'selected' : ''}>
                                <c:out value="${branch.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2 col-lg-4">
                    <button class="btn btn-outline-primary w-100" type="submit"><i class="bi bi-funnel me-1"></i>Lọc hóa đơn</button>
                </div>
            </div>
            <small class="text-secondary mt-2">Mã khách hàng là ID tài khoản trong hệ thống.</small>
        </form>
        <section class="card border-0 shadow-sm">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light"><tr><th>Mã đơn</th><th>Khách hàng</th><th>Chi nhánh</th><th>Ngày đặt</th><th class="text-end">Tổng tiền</th><th>Trạng thái đơn</th><th>Thanh toán</th><th></th></tr></thead>
                    <tbody>
                    <c:forEach items="${invoicesPage.content}" var="order">
                        <tr>
                            <td class="fw-semibold"><c:out value="${order.orderCode}"/></td>
                            <td><c:out value="${order.recipientName}"/><br><small class="text-secondary"><c:out value="${order.recipientPhone}"/></small></td>
                            <td><c:out value="${order.branch.name}" default="Chưa gán"/></td>
                            <td><c:out value="${order.createdAt}"/></td>
                            <td class="text-end fw-semibold"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/> ₫</td>
                            <td><c:out value="${order.status}"/></td>
                            <td><c:out value="${order.payment.paymentStatus}" default="Chưa có"/></td>
                            <td><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/admin/orders/${order.id}"><i class="bi bi-eye me-1"></i>Chi tiết</a></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty invoicesPage.content}"><tr><td colspan="8" class="text-center text-secondary py-5">Chưa có hóa đơn.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </section>
        <c:if test="${invoicesPage.totalPages gt 1}">
            <nav class="mt-3" aria-label="Phân trang hóa đơn"><ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${invoicesPage.totalPages - 1}" var="index">
                    <li class="page-item ${invoicesPage.number eq index ? 'active' : ''}">
                        <c:url var="invoicePageUrl" value="/admin/invoices">
                            <c:param name="page" value="${index}"/>
                            <c:if test="${not empty searchQuery}"><c:param name="q" value="${searchQuery}"/></c:if>
                            <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                            <c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}"/></c:if>
                        </c:url>
                        <a class="page-link" href="${pageContext.request.contextPath}${invoicePageUrl}">${index + 1}</a>
                    </li>
                </c:forEach>
            </ul></nav>
        </c:if>
    </main>
</div>
</body>
</html>
