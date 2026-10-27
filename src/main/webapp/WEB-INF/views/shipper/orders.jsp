<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đơn giao của tôi — TECHSEVEN</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="/WEB-INF/views/admin/fragments/theme.jsp"/>
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark sf-staff-navbar sticky-top py-2">
        <div class="container-fluid px-4">
            <div class="d-flex align-items-center gap-3">
                <a class="navbar-brand d-flex align-items-center gap-2 m-0" href="${pageContext.request.contextPath}/shipper/orders">
                    <img class="sf-brand-logo" src="${pageContext.request.contextPath}/images/brand/techseven-logo.svg" alt="TECHSEVEN">
                </a>
                <span class="badge rounded-pill text-dark fw-bold px-3 py-2 d-none d-md-inline-block" style="background-color: #ffe000;">
                    <i class="bi bi-truck me-1"></i>PHÂN HỆ GIAO HÀNG
                </span>
            </div>
            <div class="d-flex align-items-center gap-2 gap-md-3 text-white">
                <a class="btn btn-warning btn-sm fw-bold rounded-pill px-3" href="${pageContext.request.contextPath}/shipper/statistics">
                    <i class="bi bi-bar-chart-fill me-1"></i>Thống kê
                </a>
                <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="${pageContext.request.contextPath}/account/profile">
                    <i class="bi bi-person-circle me-1"></i><span class="d-none d-sm-inline"><c:out value="${shipper.fullName}"/></span>
                </a>
                <div class="text-end d-none d-lg-block lh-sm">
                    <small class="text-white-50 d-block">Chi nhánh trực thuộc</small>
                    <span class="fw-semibold small text-warning"><c:out value="${shipper.branch.name}" default="Chưa gán chi nhánh"/></span>
                </div>
                <a class="btn btn-light btn-sm text-danger fw-bold rounded-pill px-3" href="${pageContext.request.contextPath}/logout">
                    <i class="bi bi-box-arrow-right me-1"></i>Đăng xuất
                </a>
            </div>
        </div>
    </nav>

    <main class="container-fluid px-4 py-4" style="max-width: 1440px;">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <h2 class="fw-bold mb-1 text-dark"><i class="bi bi-box-seam text-primary me-2"></i>Đơn được phân công</h2>
                <div class="text-secondary">Danh sách đơn hàng bạn phụ trách vận chuyển và thu hộ</div>
            </div>
            <span class="badge rounded-pill text-bg-primary fs-6 px-3 py-2 shadow-sm">
                Tổng: ${assignmentsPage.totalElements} đơn
            </span>
        </div>

        <c:if test="${not empty success}"><div class="alert alert-success rounded-3 shadow-sm"><i class="bi bi-check-circle-fill me-2"></i><c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger rounded-3 shadow-sm"><i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${error}"/></div></c:if>

        <div class="card border-0 rounded-4 shadow-sm mb-4">
            <div class="card-body p-3 p-md-4">
                <form method="get" action="${pageContext.request.contextPath}/shipper/orders"
                      class="row g-3 align-items-end">
                    <div class="col-md-5 col-lg-4">
                        <label class="form-label fw-semibold">Trạng thái giao hàng</label>
                        <select class="form-select rounded-3" name="status">
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
                        <select class="form-select rounded-3" name="size">
                            <option value="10" ${pageSize eq 10 ? 'selected' : ''}>10 dòng</option>
                            <option value="20" ${pageSize eq 20 ? 'selected' : ''}>20 dòng</option>
                            <option value="50" ${pageSize eq 50 ? 'selected' : ''}>50 dòng</option>
                        </select>
                    </div>
                    <div class="col-md-4 d-flex gap-2">
                        <button class="btn btn-primary rounded-3 px-4 fw-medium"><i class="bi bi-funnel me-1"></i>Lọc đơn</button>
                        <a class="btn btn-outline-secondary rounded-3 px-3" href="${pageContext.request.contextPath}/shipper/orders">Đặt lại</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 rounded-4 shadow-sm overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="sf-table-head">
                        <tr>
                            <th class="ps-3">Mã đơn</th>
                            <th>Người nhận</th>
                            <th>Địa chỉ giao</th>
                            <th>Điểm lấy hàng</th>
                            <th class="text-end">Thu hộ</th>
                            <th>Phân công</th>
                            <th>Trạng thái</th>
                            <th class="pe-3">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${assignmentsPage.content}" var="assignment">
                            <c:set var="order" value="${assignment.order}"/>
                            <tr>
                                <td class="ps-3">
                                    <div class="fw-bold text-primary"><c:out value="${order.orderCode}"/></div>
                                    <small class="text-secondary">Đơn: <c:out value="${order.status}"/></small>
                                </td>
                                <td>
                                    <div class="fw-semibold"><c:out value="${order.recipientName}"/></div>
                                    <a class="text-decoration-none small fw-medium" href="tel:${order.recipientPhone}">
                                        <i class="bi bi-telephone-fill me-1"></i><c:out value="${order.recipientPhone}"/>
                                    </a>
                                </td>
                                <td style="min-width: 260px"><c:out value="${order.shippingAddress}"/></td>
                                <td style="min-width: 200px">
                                    <div class="fw-semibold"><c:out value="${order.branch.name}"/></div>
                                    <small class="text-secondary"><c:out value="${order.branch.address}"/></small>
                                </td>
                                <td class="text-end text-nowrap">
                                    <div class="fw-bold text-danger"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/> ₫</div>
                                    <small class="text-secondary">
                                        <c:out value="${order.payment.paymentMethod}" default="Chưa có thanh toán"/>
                                    </small>
                                </td>
                                <td class="text-nowrap small text-secondary">${assignment.assignedAt}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${assignment.status eq 'ASSIGNED'}"><span class="badge rounded-pill text-bg-secondary">Chờ nhận đơn</span></c:when>
                                        <c:when test="${assignment.status eq 'PICKED_UP'}"><span class="badge rounded-pill text-bg-info">Đã lấy hàng</span></c:when>
                                        <c:when test="${assignment.status eq 'DELIVERING'}"><span class="badge rounded-pill text-bg-primary">Đang giao</span></c:when>
                                        <c:when test="${assignment.status eq 'DELIVERED_SUCCESS'}"><span class="badge rounded-pill text-bg-success">Giao thành công</span></c:when>
                                        <c:when test="${assignment.status eq 'DELIVERED_FAILED'}"><span class="badge rounded-pill text-bg-danger">Giao thất bại</span></c:when>
                                        <c:otherwise><span class="badge rounded-pill text-bg-warning">Đã từ chối</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="pe-3" style="min-width: 220px">
                                    <c:if test="${assignment.status eq 'ASSIGNED' or assignment.status eq 'PICKED_UP'}">
                                        <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/status">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="status" value="DELIVERING">
                                            <button class="btn btn-sm btn-primary rounded-3 w-100 fw-medium"
                                                    onclick="return confirm('Bắt đầu giao đơn này?');">
                                                <i class="bi bi-truck me-1"></i>Bắt đầu giao
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${assignment.status eq 'DELIVERING'}">
                                        <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/status" class="mb-2">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="status" value="DELIVERED_SUCCESS">
                                            <button class="btn btn-sm btn-success rounded-3 w-100 fw-medium"
                                                    onclick="return confirm('Xác nhận đã giao hàng thành công?');">
                                                <i class="bi bi-check-circle me-1"></i>Giao thành công
                                            </button>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/status">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="status" value="DELIVERED_FAILED">
                                            <input class="form-control form-control-sm rounded-3 mb-2" name="failureReason"
                                                   maxlength="1000" placeholder="Lý do giao thất bại" required>
                                            <button class="btn btn-sm btn-outline-danger rounded-3 w-100"
                                                    onclick="return confirm('Xác nhận giao hàng thất bại?');">
                                                <i class="bi bi-x-circle me-1"></i>Giao thất bại
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${assignment.status eq 'DELIVERED_FAILED'}">
                                        <div class="small text-danger mb-2"><c:out value="${assignment.failureReason}"/></div>
                                        <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/status">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="status" value="DELIVERING">
                                            <button class="btn btn-sm btn-outline-primary rounded-3 w-100">
                                                <i class="bi bi-arrow-repeat me-1"></i>Giao lại
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${assignment.status eq 'DELIVERED_SUCCESS'}">
                                        <span class="text-success small fw-semibold"><i class="bi bi-check2-all me-1"></i>Đã hoàn tất</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty assignmentsPage.content}">
                            <tr><td colspan="8" class="text-center py-5 text-secondary">
                                <i class="bi bi-inbox fs-1 d-block mb-2 text-muted"></i>
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