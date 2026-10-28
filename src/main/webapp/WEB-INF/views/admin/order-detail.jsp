<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Chi tiết đơn ${order.orderCode}</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp" />
<jsp:include page="fragments/theme.jsp" />
</head>
<body class="bg-light">
	<div class="d-flex">
		<jsp:include page="fragments/sidebar.jsp" />
		<main class="flex-grow-1 p-4">
			<div
				class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
				<div>
					<a href="${pageContext.request.contextPath}/admin/orders"
						class="text-decoration-none"><i class="bi bi-arrow-left me-1"></i>Quay
						lại danh sách</a>
					<h2 class="fw-bold mt-2 mb-1">Chi tiết đơn ${order.orderCode}</h2>
					<span class="badge text-bg-secondary">${order.status}</span>
				</div>
				<div class="text-secondary">
					Ngày đặt:
					<c:out value="${order.createdAt}" />
				</div>
			</div>

			<div class="row g-3 mb-3">
				<div class="col-lg-6">
					<section class="card h-100 border-0 shadow-sm">
						<div class="card-header bg-white fw-semibold">
							<i class="bi bi-person me-2"></i>Thông tin khách hàng
						</div>
						<div class="card-body">
							<dl class="row mb-0">
								<dt class="col-sm-4">Tài khoản</dt>
								<dd class="col-sm-8">
									<c:choose>
										<c:when test="${empty order.user}">Khách vãng lai</c:when>
										<c:otherwise>
											<c:out value="${order.user.fullName}" /> (<c:out
												value="${order.user.email}" />)</c:otherwise>
									</c:choose>
								</dd>
								<dt class="col-sm-4">Email liên hệ</dt>
								<dd class="col-sm-8">
									<c:out value="${order.recipientEmail}" />
								</dd>
								<dt class="col-sm-4">Người nhận</dt>
								<dd class="col-sm-8">
									<c:out value="${order.recipientName}" />
								</dd>
								<dt class="col-sm-4">Điện thoại</dt>
								<dd class="col-sm-8">
									<c:out value="${order.recipientPhone}" />
								</dd>
								<dt class="col-sm-4">Địa chỉ giao</dt>
								<dd class="col-sm-8">
									<c:out value="${order.shippingAddress}" />
								</dd>
								<dt class="col-sm-4">Chi nhánh</dt>
								<dd class="col-sm-8">
									<c:out value="${order.branch.name}" default="Chưa gán" />
								</dd>
								<dt class="col-sm-4">Ghi chú</dt>
								<dd class="col-sm-8">
									<c:out value="${order.note}" default="Không có" />
								</dd>
							</dl>
						</div>
					</section>
				</div>
				<div class="col-lg-6">
					<section class="card h-100 border-0 shadow-sm">
						<div class="card-header bg-white fw-semibold">
							<i class="bi bi-credit-card me-2"></i>Thanh toán và giao hàng
						</div>
						<div class="card-body">
							<dl class="row mb-0">
								<dt class="col-sm-5">Phương thức</dt>
								<dd class="col-sm-7">
									<c:out value="${order.payment.paymentMethod}" default="Chưa có" />
								</dd>
								<dt class="col-sm-5">Trạng thái thanh toán</dt>
								<dd class="col-sm-7">
									<c:out value="${order.payment.paymentStatus}" default="Chưa có" />
								</dd>
								<dt class="col-sm-5">Thời gian thanh toán</dt>
								<dd class="col-sm-7">
									<c:out value="${order.payment.paymentTime}"
										default="Chưa thanh toán" />
								</dd>
								<dt class="col-sm-5">Mã giao dịch</dt>
								<dd class="col-sm-7">
									<c:out value="${order.payment.transactionNo}" default="—" />
								</dd>
								<dt class="col-sm-5">Shipper</dt>
								<dd class="col-sm-7">
									<c:out value="${order.deliveryAssignment.shipper.fullName}"
										default="Chưa phân công" />
								</dd>
								<dt class="col-sm-5">Trạng thái giao hàng</dt>
								<dd class="col-sm-7">
									<c:out value="${order.deliveryAssignment.status}" default="—" />
								</dd>
								<dt class="col-sm-5">Lý do giao thất bại</dt>
								<dd class="col-sm-7">
									<c:out value="${order.deliveryAssignment.failureReason}"
										default="—" />
								</dd>
							</dl>
						</div>
					</section>
				</div>
			</div>

			<c:if test="${not empty success}">
				<div class="alert alert-success" role="status">
					<i class="bi bi-check-circle-fill me-2"></i>
					<c:out value="${success}" />
				</div>
			</c:if>

			<c:if test="${not empty error}">
				<div class="alert alert-danger" role="alert">
					<i class="bi bi-exclamation-triangle-fill me-2"></i>
					<c:out value="${error}" />
				</div>
			</c:if>

			<section class="card border-0 shadow-sm mb-3">
				<div class="card-header bg-white fw-semibold">
					<i class="bi bi-clipboard-check me-2"></i> Xử lý đơn hàng
				</div>

				<div class="card-body">

					<c:if test="${canConfirm}">
						<p class="text-secondary">Kiểm tra thông tin khách hàng và sản
							phẩm trước khi xác nhận.</p>

						<form method="post"
							action="${pageContext.request.contextPath}/admin/orders/${order.id}/confirm">

							<input type="hidden" name="${_csrf.parameterName}"
								value="${_csrf.token}"> <input type="hidden"
								name="returnTo" value="detail">

							<button type="submit" class="btn btn-success">
								<i class="bi bi-check-circle me-1"></i> Xác nhận đơn hàng
							</button>
						</form>
					</c:if>

					<c:if test="${canAssign}">
						<c:if test="${not empty order.deliveryAssignment}">
							<p class="mb-3">
								Shipper hiện tại: <strong> <c:out
										value="${order.deliveryAssignment.shipper.fullName}" />
								</strong>
							</p>
						</c:if>

						<c:choose>
							<c:when test="${empty shippers}">
								<div class="alert alert-warning mb-0">Chi nhánh chưa có
									shipper hoạt động. Vui lòng kiểm tra tài khoản shipper và chi
									nhánh được gán.</div>
							</c:when>

							<c:otherwise>
								<form method="post"
									action="${pageContext.request.contextPath}/admin/orders/${order.id}/assign">

									<input type="hidden" name="${_csrf.parameterName}"
										value="${_csrf.token}"> <input type="hidden"
										name="returnTo" value="detail"> <label for="shipperId"
										class="form-label"> Shipper phụ trách <span
										class="text-danger">*</span>
									</label>

									<div class="d-flex flex-wrap gap-2">
										<select id="shipperId" name="shipperId" class="form-select"
											style="max-width: 420px" required>

											<option value="">-- Chọn shipper --</option>

											<c:forEach items="${shippers}" var="shipper">
												<option value="${shipper.id}"
													${order.deliveryAssignment.shipper.id eq shipper.id
                                          ? 'selected' : ''}>
													<c:out value="${shipper.fullName}" />
												</option>
											</c:forEach>
										</select>

										<button type="submit" class="btn btn-primary">
											<i class="bi bi-truck me-1"></i> ${empty order.deliveryAssignment
                                  ? 'Phân công shipper' : 'Đổi shipper'}
										</button>
									</div>
								</form>
							</c:otherwise>
						</c:choose>
					</c:if>

					<c:if test="${not canConfirm and not canAssign}">
						<p class="text-secondary mb-0">Không có thao tác xác nhận hoặc
							phân công ở trạng thái hiện tại. Bạn có thể theo dõi kết quả
							trong phần thanh toán và giao hàng.</p>
					</c:if>

				</div>
			</section>

			<section class="card border-0 shadow-sm">
				<div class="card-header bg-white fw-semibold">
					<i class="bi bi-box-seam me-2"></i>Sản phẩm trong đơn
				</div>
				<div class="table-responsive">
					<table class="table table-hover align-middle mb-0">
						<thead class="table-light">
							<tr>
								<th>Sản phẩm</th>
								<th class="text-end">Đơn giá</th>
								<th class="text-center">Số lượng</th>
								<th class="text-end">Thành tiền</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${order.orderItems}" var="item">
								<tr>
									<td><c:out value="${item.product.name}" /></td>
									<td class="text-end"><fmt:formatNumber
											value="${item.price}" type="number" groupingUsed="true" /> ₫</td>
									<td class="text-center"><c:out value="${item.quantity}" /></td>
									<td class="text-end"><fmt:formatNumber
											value="${item.subtotal}" type="number" groupingUsed="true" />
										₫</td>
								</tr>
							</c:forEach>
							<c:if test="${empty order.orderItems}">
								<tr>
									<td colspan="4" class="text-center text-secondary py-4">Đơn
										hàng chưa có sản phẩm.</td>
								</tr>
							</c:if>
						</tbody>
						<tfoot class="table-light">
							<tr>
								<th colspan="3" class="text-end">Tổng tiền sản phẩm</th>
								<td class="text-end"><fmt:formatNumber
										value="${order.totalAmount}" type="number" groupingUsed="true" />
									₫</td>
							</tr>
							<tr>
								<th colspan="3" class="text-end">Phí vận chuyển</th>
								<td class="text-end"><fmt:formatNumber
										value="${order.shippingFee}" type="number" groupingUsed="true" />
									₫</td>
							</tr>
							<tr>
								<th colspan="3" class="text-end">Giảm giá</th>
								<td class="text-end">−<fmt:formatNumber
										value="${order.discountAmount}" type="number"
										groupingUsed="true" /> ₫
								</td>
							</tr>
							<tr>
								<th colspan="3" class="text-end">Khách cần thanh toán</th>
								<th class="text-end text-primary"><fmt:formatNumber
										value="${order.finalAmount}" type="number" groupingUsed="true" />
									₫</th>
							</tr>
						</tfoot>
					</table>
				</div>
			</section>
		</main>
	</div>
</body>
</html>
