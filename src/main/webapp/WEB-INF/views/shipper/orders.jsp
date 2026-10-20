<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đơn giao của tôi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark bg-dark shadow-sm">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/shipper/orders">
                <i class="bi bi-truck me-2 text-warning"></i>Điện Máy UTE - Giao hàng
            </a>
            <div class="d-flex align-items-center gap-3 text-white">
                <div class="text-end d-none d-sm-block">
                    <div class="fw-semibold"><c:out value="${shipper.fullName}"/></div>
                    <small class="text-white-50"><c:out value="${shipper.branch.name}" default="Chưa gán chi nhánh"/></small>
                </div>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">
                    <i class="bi bi-box-arrow-right"></i> Đăng xuất
                </a>
            </div>
        </div>
    </nav>

    <main class="container-fluid px-4 py-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <h2 class="mb-1">Đơn được phân công</h2>
                <div class="text-secondary">Danh sách đơn hàng bạn phụ trách giao</div>
            </div>
            <span class="badge rounded-pill text-bg-primary fs-6 px-3 py-2">
                ${assignmentsPage.totalElements} đơn
            </span>
        </div>

        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/shipper/orders"
                      class="row g-3 align-items-end">
                    <div class="col-md-5 col-lg-4">
                        <label class="form-label fw-semibold">Trạng thái giao hàng</label>
                        <select class="form-select" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach items="${statuses}" var="item">
                                <option value="${item}" ${selectedStatus eq item.toString() ? 'selected' : ''}>
                                    <c:choose>
                                        <c:when test="${item eq 'ASSIGNED'}">Chờ nhận đơn</c:when>
                                        <c:when test="${item eq 'PICKED_UP'}">Đã lấy hàng</c:when>
                                        <c:when test="${item eq 'DELIVERING'}">Đang giao</c:when>
                                        <c:when test="${item eq 'DELIVERED_SUCCESS'}">Giao thành công</c:when>
                                        <c:when test="${item eq 'DELIVERED_FAILED'}">Giao thất bại</c:when>
                                        <c:otherwise>Đã từ chối</c:otherwise>
                                    </c:choose>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3 col-lg-2">
                        <label class="form-label fw-semibold">Số dòng</label>
                        <select class="form-select" name="size">
                            <option value="10" ${pageSize eq 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${pageSize eq 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${pageSize eq 50 ? 'selected' : ''}>50</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <button class="btn btn-primary"><i class="bi bi-funnel"></i> Lọc đơn</button>
                        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/shipper/orders">Đặt lại</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>Mã đơn</th>
                            <th>Người nhận</th>
                            <th>Địa chỉ giao</th>
                            <th>Điểm lấy hàng</th>
                            <th class="text-end">Thu hộ</th>
                            <th>Phân công</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${assignmentsPage.content}" var="assignment">
                            <c:set var="order" value="${assignment.order}"/>
                            <tr>
                                <td>
                                    <div class="fw-bold"><c:out value="${order.orderCode}"/></div>
                                    <small class="text-secondary">Đơn: <c:out value="${order.status}"/></small>
                                </td>
                                <td>
                                    <div class="fw-semibold"><c:out value="${order.recipientName}"/></div>
                                    <a class="text-decoration-none" href="tel:${order.recipientPhone}">
                                        <i class="bi bi-telephone"></i> <c:out value="${order.recipientPhone}"/>
                                    </a>
                                </td>
                                <td style="min-width: 260px"><c:out value="${order.shippingAddress}"/></td>
                                <td style="min-width: 200px">
                                    <div class="fw-semibold"><c:out value="${order.branch.name}"/></div>
                                    <small class="text-secondary"><c:out value="${order.branch.address}"/></small>
                                </td>
                                <td class="text-end text-nowrap">
                                    <div class="fw-bold"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/> ₫</div>
                                    <small class="text-secondary">
                                        <c:out value="${order.payment.paymentMethod}" default="Chưa có thanh toán"/>
                                    </small>
                                </td>
                                <td class="text-nowrap">${assignment.assignedAt}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${assignment.status eq 'ASSIGNED'}"><span class="badge text-bg-secondary">Chờ nhận đơn</span></c:when>
                                        <c:when test="${assignment.status eq 'PICKED_UP'}"><span class="badge text-bg-info">Đã lấy hàng</span></c:when>
                                        <c:when test="${assignment.status eq 'DELIVERING'}"><span class="badge text-bg-primary">Đang giao</span></c:when>
                                        <c:when test="${assignment.status eq 'DELIVERED_SUCCESS'}"><span class="badge text-bg-success">Giao thành công</span></c:when>
                                        <c:when test="${assignment.status eq 'DELIVERED_FAILED'}"><span class="badge text-bg-danger">Giao thất bại</span></c:when>
                                        <c:otherwise><span class="badge text-bg-warning">Đã từ chối</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty assignmentsPage.content}">
                            <tr><td colspan="7" class="text-center py-5 text-secondary">
                                <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                                Không có đơn giao phù hợp.
                            </td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <c:if test="${assignmentsPage.totalPages gt 1}">
            <nav class="mt-4" aria-label="Phân trang đơn giao">
                <ul class="pagination justify-content-center">
                    <c:forEach begin="0" end="${assignmentsPage.totalPages - 1}" var="index">
                        <c:url var="pageUrl" value="/shipper/orders">
                            <c:param name="page" value="${index}"/>
                            <c:param name="size" value="${pageSize}"/>
                            <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                        </c:url>
                        <li class="page-item ${assignmentsPage.number eq index ? 'active' : ''}">
                            <a class="page-link" href="${pageUrl}">${index + 1}</a>
                        </li>
                    </c:forEach>
                </ul>
            </nav>
        </c:if>
    </main>
</body>
</html>
