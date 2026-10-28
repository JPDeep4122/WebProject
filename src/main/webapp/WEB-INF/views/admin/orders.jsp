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
<jsp:include page="/WEB-INF/views/shared/security.jsp" />
<jsp:include page="fragments/theme.jsp" />
</head>
<body>
	<div class="d-flex">
		<jsp:include page="fragments/sidebar.jsp" />
		<main class="flex-grow-1 bg-light p-4">
			<div class="d-flex justify-content-between align-items-center mb-3">
				<div>
					<h3 class="mb-1">Quản lý đơn hàng</h3>
					<div class="text-secondary">Theo dõi đơn hàng, xác nhận đơn trả trước và hỗ trợ hoàn tiền tại chi nhánh</div>
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
						<div class="col-md-3">
							<label class="form-label">Mã đơn (Hỗ trợ hoàn tiền hộ)</label>
							<input type="text" class="form-control" name="keyword"
								value="<c:out value='${keyword}'/>"
								placeholder="Nhập mã đơn (VD: 20261029-...)">
						</div>
						<div class="col-md-3">
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
						<div class="col-md-2">
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
						<div class="col-md-2">
							<button class="btn btn-primary">
								<i class="bi bi-funnel"></i> Lọc
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
					<table
						class="table table-hover align-middle mb-0 admin-orders-table">
						<thead>
							<tr>
								<th>Mã đơn</th>
								<th>Khách hàng</th>
								<th>Chi nhánh</th>
								<th>Ngày tạo</th>
								<th class="text-end">Thành tiền / Thu khi giao</th>
								<th>Giao hàng</th>
								<th class="text-center">Trạng thái &amp; Xử lý</th>
								<th class="text-center">Chi tiết</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${ordersPage.content}" var="order">
								<tr>
									<td class="fw-semibold order-code-cell">${order.orderCode}</td>
									<td><c:out value="${order.recipientName}" /><br>
									<small class="text-secondary"><c:out
												value="${order.recipientPhone}" /></small></td>
									<td><c:out value="${order.branch.name}" default="Chưa gán" /></td>
									<td class="order-date-cell">${order.createdAt}</td>
									<td class="text-end">
										<div class="fw-bold"><fmt:formatNumber
												value="${order.finalAmount}" type="number"
												groupingUsed="true" /> ₫</div>
										<c:choose>
											<c:when test="${order.refundCompleted}">
												<span class="badge text-bg-info">VNPay • Đã hoàn tiền</span>
											</c:when>
											<c:when test="${order.refundRequired}">
												<span class="badge text-bg-danger">VNPay • Chờ hoàn tiền</span>
											</c:when>
											<c:when test="${order.prepaidVnPay}">
												<span class="badge text-bg-success">Đã TT VNPay • Khi giao: 0 ₫</span>
											</c:when>
											<c:when test="${not empty order.payment and order.payment.paymentMethod eq 'VNPAY'}">
												<span class="badge text-bg-warning text-dark">VNPay (Chưa TT)</span>
											</c:when>
											<c:otherwise>
												<span class="badge text-bg-secondary">COD • Thu khi giao</span>
											</c:otherwise>
										</c:choose>
									</td>
									<td style="min-width: 230px"><c:choose>
											<c:when test="${not empty order.deliveryAssignment}">
												<div class="fw-semibold">
													<c:out value="${order.deliveryAssignment.shipper.fullName}" />
												</div>
												<small class="text-secondary"><c:out
														value="${order.deliveryAssignment.status}" /></small>
											</c:when>
											<c:otherwise>
												<span class="text-secondary">Chưa phân công</span>
											</c:otherwise>
										</c:choose> <c:if test="${order.status eq 'PROCESSING'}">
											<form method="post"
												action="${pageContext.request.contextPath}/admin/orders/${order.id}/assign"
												class="mt-2">
												<input type="hidden" name="${_csrf.parameterName}"
													value="${_csrf.token}">
												<div class="input-group input-group-sm">
													<select class="form-select" name="shipperId" required>
														<option value="">Chọn shipper</option>
														<c:forEach items="${shippers}" var="shipper">
															<c:if
																test="${not empty shipper.branch and shipper.branch.id eq order.branch.id}">
																<option value="${shipper.id}"
																	${not empty order.deliveryAssignment and order.deliveryAssignment.shipper.id eq shipper.id ? 'selected' : ''}>
																	<c:out value="${shipper.fullName}" />
																</option>
															</c:if>
														</c:forEach>
													</select>
													<button class="btn btn-outline-primary">${empty order.deliveryAssignment ? 'Phân công' : 'Đổi'}</button>
												</div>
											</form>
										</c:if></td>
									<td class="order-status-cell text-center">
										<span class="badge ${order.status eq 'DELIVERED' ? 'text-bg-success' : (order.status eq 'CANCELLED' ? 'text-bg-danger' : (order.status eq 'PENDING' ? 'text-bg-warning text-dark' : 'text-bg-primary'))}">${order.status}</span>

										<c:if test="${order.awaitingPayment}">
											<div class="small text-warning-emphasis mt-2">Chờ khách
												thanh toán VNPay.</div>
											<form method="post"
												action="${pageContext.request.contextPath}/admin/orders/${order.id}/cancel"
												class="mt-1"
												onsubmit="return confirm('Hủy đơn chưa thanh toán này và nhả tồn kho giữ chỗ?');">
												<input type="hidden" name="${_csrf.parameterName}"
													value="${_csrf.token}">
												<button class="btn btn-sm btn-outline-danger">Hủy đơn</button>
											</form>
										</c:if>

										<c:if test="${order.readyForConfirmation}">
											<div class="d-flex justify-content-center gap-1 mt-2">
												<form method="post"
													action="${pageContext.request.contextPath}/admin/orders/${order.id}/confirm">
													<input type="hidden" name="${_csrf.parameterName}"
														value="${_csrf.token}">
													<button class="btn btn-sm btn-success">
														<i class="bi bi-check-lg"></i> Xác nhận đơn
													</button>
												</form>
												<form method="post"
													action="${pageContext.request.contextPath}/admin/orders/${order.id}/cancel"
													onsubmit="return confirm('Hủy đơn hàng này và hoàn lại tồn kho?');">
													<input type="hidden" name="${_csrf.parameterName}"
														value="${_csrf.token}">
													<button class="btn btn-sm btn-outline-danger">Hủy đơn</button>
												</form>
											</div>
										</c:if>

										<c:if test="${order.status eq 'CONFIRMED'}">
											<form method="post"
												action="${pageContext.request.contextPath}/admin/orders/${order.id}/start-picking"
												class="mt-2">
												<input type="hidden" name="${_csrf.parameterName}"
													value="${_csrf.token}">
												<button class="btn btn-sm btn-primary">Bắt đầu lấy
													hàng</button>
											</form>
										</c:if>
										<c:if
											test="${order.status eq 'PROCESSING' and not empty order.deliveryAssignment}">
											<div class="small text-primary mt-2">Đã phân công.
												Shipper bắt đầu giao trên tài khoản của mình.</div>
										</c:if>
										<c:if
											test="${order.status eq 'PROCESSING' and empty order.deliveryAssignment}">
											<div class="small text-warning mt-2">Phân công shipper
												trước khi giao</div>
										</c:if>
										<c:if test="${order.status eq 'SHIPPING'}">
											<div class="small text-primary mt-2">Shipper đang giao;
												chờ shipper cập nhật kết quả.</div>
										</c:if>
										<c:if
											test="${order.status eq 'CONFIRMED' or order.status eq 'PROCESSING'}">
											<form method="post"
												action="${pageContext.request.contextPath}/admin/orders/${order.id}/cancel"
												class="mt-2"
												onsubmit="return confirm('Hủy đơn và hoàn lại toàn bộ tồn kho?');">
												<input type="hidden" name="${_csrf.parameterName}"
													value="${_csrf.token}">
												<button class="btn btn-sm btn-outline-danger">Hủy
													đơn</button>
											</form>
										</c:if>
										<c:if test="${order.refundRequired}">
											<div class="mt-2">
												<a class="btn btn-sm btn-warning fw-semibold"
													href="${pageContext.request.contextPath}/admin/orders/${order.id}">
													<i class="bi bi-cash-stack me-1"></i>Hoàn tiền khách
												</a>
											</div>
										</c:if>
										<c:if test="${order.refundCompleted}">
											<div class="small text-success fw-semibold mt-2">
												<i class="bi bi-check-circle-fill me-1"></i>Đã hoàn tiền tại
												<c:out value="${order.payment.refundBranch.name}" default="chi nhánh"/>
											</div>
										</c:if>
										<c:if test="${order.status eq 'RETURN_REQUESTED'}">
											<a class="btn btn-sm btn-outline-warning mt-2"
												href="${pageContext.request.contextPath}/admin/returns">
												Xem yêu cầu trả hàng </a>
										</c:if>
									</td>
									<td class="order-detail-cell text-center"><a
										class="btn btn-sm btn-outline-primary"
										href="${pageContext.request.contextPath}/admin/orders/${order.id}"><i
											class="bi bi-eye me-1"></i>Chi tiết</a></td>
								</tr>
							</c:forEach>
							<c:if test="${empty ordersPage.content}">
								<tr>
									<td colspan="8" class="text-center text-secondary py-5">Không
										có đơn hàng phù hợp.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>
			</div>

			<c:if test="${ordersPage.totalPages gt 1}">
				<nav class="mt-3">
					<ul class="pagination justify-content-center">
						<c:forEach begin="0" end="${ordersPage.totalPages - 1}"
							var="index">
							<li
								class="page-item ${ordersPage.number eq index ? 'active' : ''}">
								<c:url var="pageUrl" value="/admin/orders">
									<c:param name="page" value="${index}" />
									<c:param name="size" value="${pageSize}" />
									<c:if test="${not empty selectedBranchId}">
										<c:param name="branchId" value="${selectedBranchId}" />
									</c:if>
									<c:if test="${not empty selectedStatus}">
										<c:param name="status" value="${selectedStatus}" />
									</c:if>
									<c:if test="${not empty keyword}">
										<c:param name="keyword" value="${keyword}" />
									</c:if>
								</c:url> <a class="page-link" href="${pageUrl}">${index + 1}</a>
							</li>
						</c:forEach>
					</ul>
				</nav>
			</c:if>
		</main>
	</div>
	<c:if test="${not empty orderRealtimeDestination}">
		<c:url var="orderStatusPollUrl" value="/admin/orders/status-snapshot">
			<c:if test="${not empty selectedBranchId}">
				<c:param name="branchId" value="${selectedBranchId}" />
			</c:if>
		</c:url>
		<div id="orderRealtime"
			data-context-path="${pageContext.request.contextPath}"
			data-destination="${orderRealtimeDestination}"
			data-poll-url="${orderStatusPollUrl}"></div>
		<script
			src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
		<script
			src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
		<script src="${pageContext.request.contextPath}/js/order-realtime.js"></script>
	</c:if>
</body>
</html>