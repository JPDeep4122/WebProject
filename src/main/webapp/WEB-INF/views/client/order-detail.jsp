<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="fragments/header.jsp" />

<style>
.order-stepper {
	display: flex;
	justify-content: space-between;
	position: relative;
	margin: 20px 0 30px;
}

.order-stepper::before {
	content: '';
	position: absolute;
	top: 24px;
	left: 10%;
	right: 10%;
	height: 4px;
	background: #e5e7eb;
	z-index: 1;
}

.stepper-item {
	position: relative;
	z-index: 2;
	text-align: center;
	flex: 1;
}

.stepper-icon {
	width: 48px;
	height: 48px;
	border-radius: 50%;
	background: #f3f4f6;
	color: #9ca3af;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	font-size: 1.25rem;
	border: 4px solid #fff;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
	transition: all 0.3s;
}

.stepper-item.completed .stepper-icon {
	background: #198754;
	color: #fff;
}

.stepper-item.active .stepper-icon {
	background: #0d6efd;
	color: #fff;
	box-shadow: 0 0 0 4px rgba(13, 110, 253, 0.25);
}

.stepper-title {
	font-size: 0.85rem;
	font-weight: 600;
	margin-top: 8px;
	color: #4b5563;
}

.stepper-item.active .stepper-title {
	color: #0d6efd;
}

.stepper-item.completed .stepper-title {
	color: #198754;
}
</style>

<div class="container py-4">
	<nav aria-label="breadcrumb" class="mb-3">
		<ol class="breadcrumb mb-0 small">
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/"
				class="text-decoration-none text-muted">Trang chủ</a></li>
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/orders"
				class="text-decoration-none text-muted">Lịch sử đơn hàng</a></li>
			<li class="breadcrumb-item active text-primary fw-semibold"
				aria-current="page">#${order.orderCode}</li>
		</ol>
	</nav>

	<div
		class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
		<div class="d-flex align-items-center gap-3">
			<a href="${pageContext.request.contextPath}/orders"
				class="btn btn-outline-secondary btn-sm rounded-circle p-2"
				style="width: 36px; height: 36px;"> <i class="bi bi-arrow-left"></i>
			</a>
			<div>
				<h4 class="fw-bold text-dark mb-0">Đơn hàng #${order.orderCode}</h4>
				<small class="text-muted"> Đặt lúc: ${order.createdAt != null ? order.createdAt.toString().replace('T', ' ').substring(0, 16) : ''}
				</small>
			</div>
		</div>

		<div class="d-flex gap-2">
			<form
				action="${pageContext.request.contextPath}/orders/${order.orderCode}/reorder"
				method="post" class="d-inline">
				<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
				<button type="submit"
					class="btn btn-primary btn-sm rounded-pill px-3 fw-bold shadow-sm">
					<i class="bi bi-arrow-repeat me-1"></i>Mua lại đơn này
				</button>
			</form>
			<c:if test="${order.status == 'PENDING'}">
				<button type="button"
					class="btn btn-outline-danger btn-sm rounded-pill px-3 fw-bold"
					data-bs-toggle="modal" data-bs-target="#cancelOrderModal">
					<i class="bi bi-x-circle me-1"></i>Hủy đơn hàng
				</button>
			</c:if>
		</div>
	</div>

	<c:if test="${not empty successMessage}">
		<div
			class="alert alert-success alert-dismissible fade show rounded-4 mb-4"
			role="alert">
			<i class="bi bi-check-circle-fill me-2"></i>${successMessage}
			<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
		</div>
	</c:if>
	<c:if test="${not empty errorMessage}">
		<div
			class="alert alert-danger alert-dismissible fade show rounded-4 mb-4"
			role="alert">
			<i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
			<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
		</div>
	</c:if>

	<div class="bg-white rounded-4 shadow-sm border p-4 mb-4">
		<c:choose>
			<c:when test="${order.status == 'CANCELLED'}">
				<div
					class="alert alert-danger rounded-4 p-3 mb-0 d-flex align-items-center gap-3">
					<i class="bi bi-x-circle-fill fs-1 text-danger"></i>
					<div>
						<h6 class="fw-bold mb-1 text-danger">ĐƠN HÀNG ĐÃ BỊ HỦY</h6>
						<div class="small text-muted">${not empty order.note ? order.note : 'Đơn hàng đã được hủy theo yêu cầu của bạn.'}
						</div>
					</div>
				</div>
			</c:when>

			<c:otherwise>
				<div class="order-stepper">
					<div class="stepper-item completed">
						<div class="stepper-icon">
							<i class="bi bi-bag-check"></i>
						</div>
						<div class="stepper-title">Đặt hàng thành công</div>
					</div>

					<div
						class="stepper-item ${order.status == 'CONFIRMED' || order.status == 'PROCESSING' || order.status == 'SHIPPING' || order.status == 'DELIVERED' ? 'completed' : (order.status == 'PENDING' ? 'active' : '')}">
						<div class="stepper-icon">
							<i class="bi bi-card-checklist"></i>
						</div>
						<div class="stepper-title">Đã xác nhận đơn</div>
					</div>

					<div
						class="stepper-item ${order.status == 'DELIVERED' ? 'completed' : (order.status == 'SHIPPING' ? 'active' : '')}">
						<div class="stepper-icon">
							<i class="bi bi-truck"></i>
						</div>
						<div class="stepper-title">Đang giao hàng</div>
					</div>

					<div
						class="stepper-item ${order.status == 'DELIVERED' ? 'completed' : ''}">
						<div class="stepper-icon">
							<i class="bi bi-box2-heart"></i>
						</div>
						<div class="stepper-title">Giao thành công</div>
					</div>
				</div>
			</c:otherwise>
		</c:choose>
	</div>

	<div class="row g-4">
		<div class="col-lg-8">
			<div class="bg-white rounded-4 shadow-sm border p-4 mb-4">
				<h5 class="fw-bold text-dark border-bottom pb-3 mb-3">
					<i class="bi bi-box-seam me-2 text-primary"></i>Danh sách sản phẩm
					(${order.orderItems.size()})
				</h5>

				<div class="table-responsive">
					<table class="table align-middle mb-0">
						<thead class="table-light small text-muted text-uppercase">
							<tr>
								<th scope="col" style="min-width: 250px;">Sản phẩm</th>
								<th scope="col" class="text-center">Đơn giá</th>
								<th scope="col" class="text-center">Số lượng</th>
								<th scope="col" class="text-end">Thành tiền</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="item" items="${order.orderItems}">
								<tr>
									<td>
										<div class="d-flex align-items-center gap-3">
											<c:choose>
												<c:when test="${not empty item.product.mainImageUrl}">
													<img src="${item.product.mainImageUrl}"
														class="rounded-3 border object-fit-cover"
														style="width: 60px; height: 60px;"
														alt="${item.product.name}">
												</c:when>
												<c:otherwise>
													<div
														class="rounded-3 border bg-light d-flex align-items-center justify-content-center text-muted"
														style="width: 60px; height: 60px;">
														<i class="bi bi-image fs-4"></i>
													</div>
												</c:otherwise>
											</c:choose>
											<div>
												<a
													href="${pageContext.request.contextPath}/products/${item.product.slug}"
													class="fw-bold text-dark text-decoration-none">
													${item.product.name} </a>
												<div class="text-muted small">Mã SP:
													${item.product.sku}</div>
												<c:if test="${order.status == 'DELIVERED'}">
													<div class="mt-2">
														<a
															href="${pageContext.request.contextPath}/products/${item.product.slug}#reviewsSection"
															class="btn btn-outline-warning btn-sm rounded-pill px-3 py-1 fw-bold text-dark"
															style="font-size: 0.78rem;"> <i
															class="bi bi-star-fill text-warning me-1"></i>Viết đánh
															giá cho sản phẩm này
														</a>
													</div>
												</c:if>
											</div>
										</div>
									</td>
									<td class="text-center"><fmt:formatNumber
											value="${item.price}" type="number" groupingUsed="true" /> ₫
									</td>
									<td class="text-center fw-bold">x${item.quantity}</td>
									<td class="text-end fw-bold text-dark"><fmt:formatNumber
											value="${item.subtotal}" type="number" groupingUsed="true" />
										₫</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>

				<div class="border-top pt-3 mt-3">
					<div class="d-flex justify-content-between py-1">
						<span class="text-muted">Tổng tiền hàng:</span> <span
							class="fw-semibold text-dark"><fmt:formatNumber
								value="${order.totalAmount}" type="number" groupingUsed="true" />
							₫</span>
					</div>
					<div class="d-flex justify-content-between py-1">
						<span class="text-muted">Phí vận chuyển:</span> <span
							class="fw-semibold text-dark"><fmt:formatNumber
								value="${order.shippingFee}" type="number" groupingUsed="true" />
							₫</span>
					</div>
					<c:if test="${order.discountAmount > 0}">
						<div class="d-flex justify-content-between py-1 text-success">
							<span>Giảm giá (Voucher):</span> <span class="fw-bold">-<fmt:formatNumber
									value="${order.discountAmount}" type="number"
									groupingUsed="true" /> ₫
							</span>
						</div>
					</c:if>
					<div class="d-flex justify-content-between pt-2 border-top mt-2">
						<span class="fw-bold fs-5 text-dark">Tổng thanh toán:</span> <span
							class="fw-bold fs-4 text-danger"> <fmt:formatNumber
								value="${order.finalAmount}" type="number" groupingUsed="true" />
							₫
						</span>
					</div>
				</div>
			</div>
		</div>

		<div class="col-lg-4">
			<div class="bg-white rounded-4 shadow-sm border p-4 mb-4">
				<h6 class="fw-bold text-dark border-bottom pb-2 mb-3">
					<i class="bi bi-geo-alt-fill text-danger me-2"></i>Địa chỉ nhận
					hàng
				</h6>
				<div class="mb-2">
					<b class="text-dark">${order.recipientName}</b> <span
						class="text-muted ms-2">• ${order.recipientPhone}</span>
				</div>
				<div class="text-muted small mb-2">${order.shippingAddress}</div>
				<c:if test="${not empty order.note}">
					<div class="p-2 bg-light rounded-3 small text-muted border">
						<i class="bi bi-chat-left-text me-1"></i>Ghi chú: ${order.note}
					</div>
				</c:if>
			</div>

			<!-- Card Thanh toán -->
			<div class="bg-white rounded-4 shadow-sm border p-4 mb-4">
				<h6 class="fw-bold text-dark border-bottom pb-2 mb-3">
					<i class="bi bi-credit-card-2-front-fill text-primary me-2"></i>Thông
					tin thanh toán
				</h6>
				<div class="d-flex justify-content-between mb-2 small">
					<span class="text-muted">Phương thức:</span> <b class="text-dark">${order.payment.paymentMethod}</b>
				</div>
				<div class="d-flex justify-content-between mb-2 small">
					<span class="text-muted">Trạng thái:</span>
					<c:choose>
						<c:when test="${order.payment.paymentStatus == 'SUCCESS'}">
							<span
								class="badge bg-success-subtle text-success border border-success-subtle">
								<i class="bi bi-check-circle me-1"></i>Đã thanh toán
							</span>
						</c:when>
						<c:otherwise>
							<span class="badge bg-secondary-subtle text-secondary border">
								<i class="bi bi-clock me-1"></i>Chưa thanh toán
							</span>
						</c:otherwise>
					</c:choose>
				</div>
				<c:if test="${not empty order.payment.transactionNo}">
					<div class="d-flex justify-content-between mb-2 small">
						<span class="text-muted">Mã GD VNPAY:</span> <span
							class="text-dark font-monospace">${order.payment.transactionNo}</span>
					</div>
				</c:if>
				<c:if test="${not empty order.payment.paymentTime}">
					<div class="d-flex justify-content-between small">
						<span class="text-muted">Thời gian TT:</span> <span
							class="text-dark">${order.payment.paymentTime.toString().replace('T', ' ').substring(0, 16)}</span>
					</div>
				</c:if>
			</div>
		</div>
	</div>
</div>

<!-- MODAL XÁC NHẬN HỦY ĐƠN HÀNG -->
<div class="modal fade" id="cancelOrderModal" tabindex="-1"
	aria-hidden="true">
	<div class="modal-dialog modal-dialog-centered">
		<div class="modal-content rounded-4 border-0 shadow">
			<form
				action="${pageContext.request.contextPath}/orders/${order.orderCode}/cancel"
				method="post">
				<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
				<div class="modal-header border-bottom-0 pb-0">
					<h5 class="modal-title fw-bold text-danger">
						<i class="bi bi-exclamation-triangle me-2"></i>Xác nhận hủy đơn
						hàng
					</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body p-4">
					<p class="text-muted small">
						Bạn có chắc chắn muốn hủy đơn hàng <b>#${order.orderCode}</b>? Sau
						khi hủy, bạn không thể khôi phục lại đơn hàng này.
					</p>
					<label class="form-label small fw-bold text-dark">Vui lòng
						chọn lý do hủy:</label>
					<div class="form-check mb-2">
						<input class="form-check-input" type="radio" name="cancelReason"
							id="reason1" value="Tôi muốn thay đổi địa chỉ nhận hàng" checked>
						<label class="form-check-label small" for="reason1">Tôi
							muốn thay đổi địa chỉ nhận hàng</label>
					</div>
					<div class="form-check mb-2">
						<input class="form-check-input" type="radio" name="cancelReason"
							id="reason2" value="Tôi muốn đổi phương thức thanh toán">
						<label class="form-check-label small" for="reason2">Tôi
							muốn đổi phương thức thanh toán</label>
					</div>
					<div class="form-check mb-2">
						<input class="form-check-input" type="radio" name="cancelReason"
							id="reason3" value="Tôi tìm thấy giá tốt hơn ở nơi khác">
						<label class="form-check-label small" for="reason3">Tôi
							tìm thấy giá tốt hơn ở nơi khác</label>
					</div>
					<div class="form-check mb-2">
						<input class="form-check-input" type="radio" name="cancelReason"
							id="reason4" value="Tôi không có nhu cầu mua nữa"> <label
							class="form-check-label small" for="reason4">Tôi không có
							nhu cầu mua nữa</label>
					</div>
				</div>
				<div class="modal-footer border-top-0 pt-0 px-4 pb-4">
					<button type="button" class="btn btn-light rounded-pill px-4"
						data-bs-dismiss="modal">Đóng</button>
					<button type="submit"
						class="btn btn-danger rounded-pill px-4 fw-bold">Xác nhận
						hủy đơn</button>
				</div>
			</form>
		</div>
	</div>
</div>

<jsp:include page="fragments/footer.jsp" />