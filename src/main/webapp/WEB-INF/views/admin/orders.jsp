<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Quản lý đơn hàng</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
	<div class="d-flex">
		<jsp:include page="fragments/sidebar.jsp" />
		<main class="flex-grow-1 bg-light p-4">
			<div class="d-flex justify-content-between align-items-center mb-3">
				<div>
					<h3 class="mb-1">Quản lý đơn hàng</h3>
					<div class="text-secondary">Theo dõi đơn hàng theo chi nhánh
						và trạng thái</div>
				</div>
				<span class="badge text-bg-primary fs-6">${ordersPage.totalElements}
					đơn</span>
			</div>

			<c:if test="${not empty success}">
				<div class="alert alert-success">
					<c:out value="${success}" />
				</div>
			</c:if>
			<c:if test="${not empty error}">
				<div class="alert alert-danger">
					<c:out value="${error}" />
				</div>
			</c:if>

			<div class="card mb-3">
				<div class="card-body">
					<form method="get"
						action="${pageContext.request.contextPath}/admin/orders"
						class="row g-3 align-items-end">
						<div class="col-md-4">
							<label class="form-label">Chi nhánh</label> <select
								class="form-select" name="branchId"
								${canChooseBranch ? '' : 'disabled'}>
								<c:if test="${canChooseBranch}">
									<option value="">Tất cả chi nhánh</option>
								</c:if>
								<c:forEach items="${branches}" var="branch">
									<option value="${branch.id}"
										${selectedBranchId eq branch.id ? 'selected' : ''}>${branch.name}</option>
								</c:forEach>
							</select>
						</div>
						<div class="col-md-3">
							<label class="form-label">Trạng thái</label> <select
								class="form-select" name="status">
								<option value="">Tất cả trạng thái</option>
								<c:forEach items="${statuses}" var="item">
									<option value="${item}"
										${selectedStatus eq item.toString() ? 'selected' : ''}>${item}</option>
								</c:forEach>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label">Số dòng</label> <select
								class="form-select" name="size">
								<option value="10" ${pageSize eq 10 ? 'selected' : ''}>10</option>
								<option value="20" ${pageSize eq 20 ? 'selected' : ''}>20</option>
								<option value="50" ${pageSize eq 50 ? 'selected' : ''}>50</option>
							</select>
						</div>
						<div class="col-md-3">
							<button class="btn btn-primary">
								<i class="bi bi-funnel"></i> Lọc đơn hàng
							</button>
							<a class="btn btn-outline-secondary"
								href="${pageContext.request.contextPath}/admin/orders">Đặt
								lại</a>
						</div>
					</form>
				</div>
			</div>

        <div class="card border-0 shadow-sm">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark"><tr><th>Mã đơn</th><th>Khách hàng</th><th>Chi nhánh</th><th>Ngày tạo</th><th class="text-end">Thành tiền</th><th>Giao hàng</th><th>Trạng thái</th><th>Chi tiết</th></tr></thead>
                    <tbody>
                    <c:forEach items="${ordersPage.content}" var="order">
                        <tr>
                            <td class="fw-semibold">${order.orderCode}</td>
                            <td><c:out value="${order.recipientName}"/><br><small class="text-secondary"><c:out value="${order.recipientPhone}"/></small></td>
                            <td><c:out value="${order.branch.name}" default="Chưa gán"/></td>
                            <td>${order.createdAt}</td>
                            <td class="text-end"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/> ₫</td>
                            <td style="min-width: 230px">
                                <c:choose>
                                    <c:when test="${not empty order.deliveryAssignment}">
                                        <div class="fw-semibold"><c:out value="${order.deliveryAssignment.shipper.fullName}"/></div>
                                        <small class="text-secondary"><c:out value="${order.deliveryAssignment.status}"/></small>
                                    </c:when>
                                    <c:otherwise><span class="text-secondary">Chưa phân công</span></c:otherwise>
                                </c:choose>
                                <c:if test="${order.status eq 'PROCESSING'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders/${order.id}/assign" class="mt-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <div class="input-group input-group-sm">
                                            <select class="form-select" name="shipperId" required>
                                                <option value="">Chọn shipper</option>
                                                <c:forEach items="${shippers}" var="shipper">
                                                    <c:if test="${not empty shipper.branch and shipper.branch.id eq order.branch.id}">
                                                        <option value="${shipper.id}" ${not empty order.deliveryAssignment and order.deliveryAssignment.shipper.id eq shipper.id ? 'selected' : ''}>
                                                            <c:out value="${shipper.fullName}"/>
                                                        </option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                            <button class="btn btn-outline-primary">${empty order.deliveryAssignment ? 'Phân công' : 'Đổi'}</button>
                                        </div>
                                    </form>
                                </c:if>
                            </td>
                            <td><span class="badge text-bg-secondary">${order.status}</span>
                                <c:if test="${order.status eq 'PENDING'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders/${order.id}/confirm" class="mt-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="btn btn-sm btn-success">Duyệt &amp; xác nhận đơn</button>
                                    </form>
                                </c:if>
                                <c:if test="${order.status eq 'CONFIRMED'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders/${order.id}/start-picking" class="mt-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="btn btn-sm btn-primary">Bắt đầu lấy hàng</button>
                                    </form>
                                </c:if>
                                <c:if test="${order.status eq 'PROCESSING' and not empty order.deliveryAssignment}">
                                    <div class="small text-primary mt-2">Đã phân công. Shipper bắt đầu giao trên tài khoản của mình.</div>
                                </c:if>
                                <c:if test="${order.status eq 'PROCESSING' and empty order.deliveryAssignment}">
                                    <div class="small text-warning mt-2">Phân công shipper trước khi giao</div>
                                </c:if>
                                <c:if test="${order.status eq 'SHIPPING'}">
                                    <div class="small text-primary mt-2">Shipper đang giao; chờ shipper cập nhật kết quả.</div>
                                </c:if>
                                <c:if test="${order.status eq 'CONFIRMED' or order.status eq 'PROCESSING'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders/${order.id}/cancel" class="mt-2"
                                          onsubmit="return confirm('Hủy đơn và hoàn lại toàn bộ tồn kho?');">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="btn btn-sm btn-outline-danger">Hủy đơn</button>
                                    </form>
                                </c:if>
                                <c:if test="${order.status eq 'RETURN_REQUESTED'}">
                                    <a class="btn btn-sm btn-outline-warning mt-2" href="${pageContext.request.contextPath}/admin/returns">
                                        Xem yêu cầu trả hàng
                                    </a>
                                </c:if>
                            </td>
                            <td><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/admin/orders/${order.id}"><i class="bi bi-eye me-1"></i>Chi tiết</a></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty ordersPage.content}"><tr><td colspan="8" class="text-center text-secondary py-5">Không có đơn hàng phù hợp.</td></tr></c:if>
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
<c:if test="${not empty orderRealtimeDestination}">
    <c:url var="orderStatusPollUrl" value="/admin/orders/status-snapshot">
        <c:if test="${not empty selectedBranchId}">
            <c:param name="branchId" value="${selectedBranchId}"/>
        </c:if>
    </c:url>
    <div id="orderRealtime"
         data-context-path="${pageContext.request.contextPath}"
         data-destination="${orderRealtimeDestination}"
         data-poll-url="${orderStatusPollUrl}"></div>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/order-realtime.js"></script>
</c:if>
</body>
</html>
