<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="fragments/header.jsp" />

<style>
.order-tab-link {
	font-weight: 600;
	color: #4b5563;
	border-bottom: 3px solid transparent;
	padding: 12px 18px;
	text-decoration: none;
	transition: all 0.2s;
	white-space: nowrap;
}

.order-tab-link:hover {
	color: #0d6efd;
}

.order-tab-link.active {
	color: #0d6efd;
	border-bottom-color: #0d6efd;
}

.order-card {
	border-radius: 16px;
	border: 1px solid #e5e7eb;
	background: #fff;
	transition: box-shadow 0.2s;
}

.order-card:hover {
	box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
}
</style>

<div class="container py-4">
	<nav aria-label="breadcrumb" class="mb-3">
		<ol class="breadcrumb mb-0 small">
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/"
				class="text-decoration-none text-muted">Trang chủ</a></li>
			<li class="breadcrumb-item active text-primary fw-semibold"
				aria-current="page">Lịch sử đơn hàng</li>
		</ol>
	</nav>

	<div
		class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
		<div>
			<h3 class="fw-bold text-dark mb-1">
				<i class="bi bi-bag-check-fill text-primary me-2"></i>Đơn hàng của
				tôi
			</h3>
			<p class="text-muted small mb-0">Theo dõi trạng thái và lịch sử
				mua sắm của bạn</p>
		</div>
		<a href="${pageContext.request.contextPath}/orders/tracking"
			class="btn btn-outline-secondary btn-sm rounded-pill px-3 fw-semibold">
			<i class="bi bi-search me-1"></i>Tra cứu đơn vãng lai
		</a>
	</div>

	<c:if test="${not empty successMessage}">
		<div
			class="alert alert-success alert-dismissible fade show rounded-4 mb-4 shadow-sm"
			role="alert">
			<i class="bi bi-check-circle-fill me-2"></i>${successMessage}
			<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
		</div>
	</c:if>
	<c:if test="${not empty errorMessage}">
		<div
			class="alert alert-danger alert-dismissible fade show rounded-4 mb-4 shadow-sm"
			role="alert">
			<i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
			<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
		</div>
	</c:if>

	<div
		class="bg-white rounded-4 shadow-sm border mb-4 px-2 overflow-x-auto">
		<div class="d-flex gap-1">
			<a href="${pageContext.request.contextPath}/orders?status=ALL"
				class="order-tab-link ${currentStatus == 'ALL' ? 'active' : ''}">
				Tất cả (${countAll}) </a> <a
				href="${pageContext.request.contextPath}/orders?status=PENDING"
				class="order-tab-link ${currentStatus == 'PENDING' ? 'active' : ''}">
				Chờ xác nhận (${countPending}) </a> <a
				href="${pageContext.request.contextPath}/orders?status=CONFIRMED"
				class="order-tab-link ${currentStatus == 'CONFIRMED' ? 'active' : ''}">
				Đã xác nhận (${countConfirmed}) </a> <a
				href="${pageContext.request.contextPath}/orders?status=SHIPPING"
				class="order-tab-link ${currentStatus == 'SHIPPING' ? 'active' : ''}">
				Đang giao (${countShipping}) </a> <a
				href="${pageContext.request.contextPath}/orders?status=DELIVERED"
				class="order-tab-link ${currentStatus == 'DELIVERED' ? 'active' : ''}">
				Đã giao (${countDelivered}) </a> <a
				href="${pageContext.request.contextPath}/orders?status=CANCELLED"
				class="order-tab-link ${currentStatus == 'CANCELLED' ? 'active' : ''}">
				Đã hủy (${countCancelled}) </a>
		</div>
	</div>

	<c:choose>
		<c:when test="${empty orders}">
			<div class="bg-white p-5 rounded-4 text-center border shadow-sm my-4">
				<div class="text-muted mb-3">
					<i class="bi bi-bag-x display-1 text-secondary opacity-50"></i>
				</div>
				<h5 class="fw-bold text-dark mb-2">Chưa có đơn hàng nào</h5>
				<p class="text-muted small mb-4">Bạn chưa có đơn hàng nào trong
					trạng thái này.</p>
				<a href="${pageContext.request.contextPath}/products"
					class="btn btn-primary rounded-pill px-4 fw-bold shadow-sm"> <i
					class="bi bi-arrow-right-circle me-1"></i>Khám phá sản phẩm ngay
				</a>
			</div>
		</c:when>

		<c:otherwise>
			<c:forEach var="order" items="${orders}">
				<div class="order-card p-4 mb-4 shadow-sm">
					<div
						class="d-flex flex-wrap justify-content-between align-items-center border-bottom pb-3 mb-3 gap-2">
						<div class="d-flex align-items-center gap-3">
							<span class="fw-bold text-primary fs-5">#${order.orderCode}</span>
							<span class="text-muted small border-start ps-3"> <i
								class="bi bi-calendar3 me-1"></i> ${order.createdAt != null ? order.createdAt.toString().replace('T', ' ').substring(0, 16) : ''}
							</span>
						</div>
						<div>
							<c:choose>
								<c:when test="${order.status == 'PENDING'}">
									<span
										class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle rounded-pill px-3 py-2 fw-semibold">
										<i class="bi bi-clock-history me-1"></i>Chờ xác nhận
									</span>
								</c:when>
								<c:when test="${order.status == 'CONFIRMED'}">
									<span
										class="badge bg-info-subtle text-info-emphasis border border-info-subtle rounded-pill px-3 py-2 fw-semibold">
										<i class="bi bi-check2-circle me-1"></i>Đã xác nhận
									</span>
								</c:when>
								<c:when test="${order.status == 'PROCESSING'}">
									<span
										class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-2 fw-semibold">
										<i class="bi bi-box-seam me-1"></i>Đang chuẩn bị hàng
									</span>
								</c:when>
								<c:when test="${order.status == 'SHIPPING'}">
									<span
										class="badge bg-primary text-white rounded-pill px-3 py-2 fw-semibold">
										<i class="bi bi-truck me-1"></i>Đang giao hàng
									</span>
								</c:when>
								<c:when test="${order.status == 'DELIVERED'}">
									<span
										class="badge bg-success-subtle text-success-emphasis border border-success-subtle rounded-pill px-3 py-2 fw-semibold">
										<i class="bi bi-patch-check-fill me-1"></i>Giao hàng thành
										công
									</span>
								</c:when>
								<c:when test="${order.status == 'CANCELLED'}">
									<span
										class="badge bg-danger-subtle text-danger-emphasis border border-danger-subtle rounded-pill px-3 py-2 fw-semibold">
										<i class="bi bi-x-circle me-1"></i>Đã hủy
									</span>
								</c:when>
								<c:otherwise>
									<span class="badge bg-secondary rounded-pill px-3 py-2">${order.status}</span>
								</c:otherwise>
							</c:choose>
						</div>
					</div>

					<div class="mb-3">
						<c:forEach var="item" items="${order.orderItems}">
							<div
								class="d-flex align-items-center justify-content-between py-2 border-bottom border-light gap-3">
								<div class="d-flex align-items-center gap-3">
									<c:choose>
										<c:when test="${not empty item.product.mainImageUrl}">
											<img src="${item.product.mainImageUrl}"
												class="rounded-3 border object-fit-cover"
												style="width: 65px; height: 65px;"
												alt="${item.product.name}">
										</c:when>
										<c:otherwise>
											<div
												class="rounded-3 border bg-light d-flex align-items-center justify-content-center text-muted"
												style="width: 65px; height: 65px;">
												<i class="bi bi-image fs-4"></i>
											</div>
										</c:otherwise>
									</c:choose>
									<div>
										<a
											href="${pageContext.request.contextPath}/products/${item.product.slug}"
											class="fw-bold text-dark text-decoration-none">
											${item.product.name} </a>
										<div class="text-muted small mt-1">
											Số lượng: <b class="text-dark">x${item.quantity}</b> <span
												class="mx-2">•</span> Đơn giá:
											<fmt:formatNumber value="${item.price}" type="number"
												groupingUsed="true" />
											₫
										</div>
									</div>
								</div>
								<div class="text-end fw-bold text-dark">
									<fmt:formatNumber value="${item.subtotal}" type="number"
										groupingUsed="true" />
									₫
								</div>
							</div>
						</c:forEach>
					</div>

					<div
						class="d-flex flex-wrap justify-content-between align-items-center pt-2 gap-3">
						<div class="small">
							<span class="text-muted me-1">Hình thức thanh toán:</span> <span
								class="badge bg-light text-dark border me-2"> <c:choose>
									<c:when test="${order.payment.paymentMethod == 'VNPAY'}">
										<i class="bi bi-qr-code text-primary me-1"></i>VNPAY
                                    </c:when>
									<c:otherwise>
										<i class="bi bi-cash-stack text-success me-1"></i>COD
                                    </c:otherwise>
								</c:choose>
							</span>
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

						<div class="d-flex align-items-center gap-3">
							<div>
								<span class="text-muted small me-1">Thành tiền:</span> <span
									class="fs-5 fw-bold text-danger"> <fmt:formatNumber
										value="${order.finalAmount}" type="number" groupingUsed="true" />
									₫
								</span>
							</div>

							<a
								href="${pageContext.request.contextPath}/orders/${order.orderCode}"
								class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold">
								<i class="bi bi-eye me-1"></i>Chi tiết
							</a>
							
							<c:if test="${order.status == 'DELIVERED'}">
								<a
									href="${pageContext.request.contextPath}/orders/${order.orderCode}"
									class="btn btn-warning btn-sm rounded-pill px-3 fw-bold text-dark shadow-sm">
									<i class="bi bi-star-fill me-1"></i>Đánh giá
								</a>
							</c:if>

							<a
								href="${pageContext.request.contextPath}/orders/${order.orderCode}"
								class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold">
								<i class="bi bi-eye me-1"></i>Chi tiết
							</a>

							<form
								action="${pageContext.request.contextPath}/orders/${order.orderCode}/reorder"
								method="post" class="d-inline">
								<button type="submit"
									class="btn btn-primary btn-sm rounded-pill px-3 fw-bold shadow-sm">
									<i class="bi bi-arrow-repeat me-1"></i>Mua lại
								</button>
							</form>
						</div>
					</div>
				</div>
			</c:forEach>
		</c:otherwise>
	</c:choose>
</div>

<jsp:include page="fragments/footer.jsp" />