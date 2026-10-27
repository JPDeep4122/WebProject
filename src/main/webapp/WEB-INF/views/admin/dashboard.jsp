<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard — Quản trị Chuỗi Điện Máy</title>
<!-- Bootstrap 5 & Icons -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp" />
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
	<div class="d-flex">
		<!-- Nhúng Sidebar Admin -->
		<jsp:include page="fragments/sidebar.jsp" />

		<!-- Khu vực nội dung Admin chính -->
		<div class="flex-grow-1 bg-light p-4">
			<!-- Header trên cùng -->
			<div
				class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
				<div>
					<h3 class="fw-bold mb-0">Tổng quan hệ thống</h3>
					<small class="text-muted">Phạm vi: Toàn chuỗi chi nhánh</small>
				</div>
				<div class="d-flex gap-2">
					<button class="btn btn-outline-primary btn-sm">
						<i class="bi bi-download"></i> Xuất báo cáo
					</button>
					<a href="/" class="btn btn-primary btn-sm"><i
						class="bi bi-house"></i> Về trang bán hàng</a>
				</div>
			</div>

			<div class="row g-3 mb-4">
				<div class="col-md-6">
					<div
						class="card border-0 shadow-sm border-start border-primary border-4 p-3 h-100">
						<div class="d-flex justify-content-between align-items-center">
							<div>
								<small class="text-muted fw-bold">TỔNG SỐ KHÁCH HÀNG</small>
								<h4 class="fw-bold text-primary mt-1 mb-0">
									<fmt:formatNumber value="${customerCount}" type="number"
										maxFractionDigits="0" />
									khách hàng
								</h4>
							</div>
							<div class="fs-2 text-primary">
								<i class="bi bi-people"></i>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-6">
					<div
						class="card border-0 shadow-sm border-start border-success border-4 p-3 h-100">
						<div class="d-flex justify-content-between align-items-center">
							<div>
								<small class="text-muted fw-bold">TỔNG DOANH THU</small>
								<h4 class="fw-bold text-success mt-1 mb-0">
									<fmt:formatNumber value="${totalRevenue}" type="number"
										maxFractionDigits="0" groupingUsed="true" />
									đ
								</h4>
							</div>
							<div class="fs-2 text-success">
								<i class="bi bi-currency-dollar"></i>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="card border-0 shadow-sm mb-4">
				<div class="card-header bg-white fw-bold py-3">
					<i class="bi bi-shop me-1"></i> Doanh thu theo chi nhánh
				</div>
				<div class="card-body">
					<c:choose>
						<c:when test="${empty branches}">
							<p class="text-muted mb-0">Chưa có chi nhánh.</p>
						</c:when>
						<c:otherwise>
							<div class="row g-3">
								<c:forEach var="branch" items="${branches}">
									<div class="col-md-6 col-xl-4">
										<div class="border rounded p-3 h-100">
											<div class="text-muted small">${branch.name}</div>
											<div class="fs-5 fw-bold text-primary mt-1">
												<fmt:formatNumber value="${branch.revenue}" type="number"
													maxFractionDigits="0" groupingUsed="true" />
												đ
											</div>
										</div>
									</div>
								</c:forEach>
							</div>
						</c:otherwise>
					</c:choose>
				</div>
			</div>

			<div class="alert alert-info small" role="note">
				<i class="bi bi-info-circle me-1"></i> Số liệu được truy vấn trực
				tiếp từ hệ thống và cập nhật khi tải lại trang. Doanh thu chỉ tính
				đơn đã thanh toán thành công; đơn đã hủy không được tính.
			</div>

			<div class="card border-0 shadow-sm mb-4">
				<div class="card-header bg-white fw-bold py-3 d-flex justify-content-between align-items-center">
					<span><i class="bi bi-check2-circle me-1 text-success"></i> Đơn hàng thanh toán thành công gần đây</span>
					<a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/admin/invoices">Xem tất cả hóa đơn</a>
				</div>
				<div class="table-responsive">
					<table class="table table-hover align-middle mb-0">
						<thead class="table-light"><tr><th>Mã đơn</th><th>Khách hàng</th><th>Chi nhánh</th><th>Ngày đặt</th><th class="text-end">Tổng tiền</th><th>Thao tác</th></tr></thead>
						<tbody>
							<c:forEach items="${successfulOrders}" var="order">
								<tr>
									<td><strong><c:out value="${order.orderCode}" /></strong></td>
									<td><c:out value="${order.recipientName}" /><br><small class="text-secondary"><c:out value="${order.recipientPhone}" /></small></td>
									<td><c:out value="${order.branch.name}" default="Chưa gán" /></td>
									<td><c:out value="${order.createdAt}" /></td>
									<td class="text-end fw-bold"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true" /> đ</td>
									<td><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/admin/orders/${order.id}"><i class="bi bi-eye me-1"></i>Chi tiết hóa đơn</a></td>
								</tr>
							</c:forEach>
							<c:if test="${empty successfulOrders}"><tr><td colspan="6" class="text-center text-secondary py-4">Chưa có đơn hàng thanh toán thành công.</td></tr></c:if>
						</tbody>
					</table>
				</div>
			</div>

		</div>
	</div>

</body>
</html>
