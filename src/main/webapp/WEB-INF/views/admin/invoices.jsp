<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
                        <a class="page-link" href="${pageContext.request.contextPath}/admin/invoices?page=${index}">${index + 1}</a>
                    </li>
                </c:forEach>
            </ul></nav>
        </c:if>
    </main>
</div>
</body>
</html>
