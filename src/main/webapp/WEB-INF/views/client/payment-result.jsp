<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="fragments/header.jsp" />

<div class="container py-5">
	<div class="row justify-content-center">
		<div class="col-lg-7 text-center">

			<div class="bg-white p-5 rounded-4 shadow-sm border">
				
				<c:choose>
					<c:when test="${isSuccess}">
						<div class="text-success mb-3">
							<i class="bi bi-patch-check-fill display-1"></i>
						</div>
						<h2 class="fw-bold text-success mb-2">THANH TOÁN THÀNH CÔNG!</h2>
						<p class="text-muted mb-4">Giao dịch của bạn qua <b>Cổng VNPAY</b> đã được xác nhận thành công.</p>

						<div class="p-4 bg-light rounded-4 text-start mb-4 border">
							<div class="d-flex justify-content-between mb-2">
								<span class="text-muted">Mã đơn hàng:</span>
								<b class="text-primary fs-5">${order.orderCode}</b>
							</div>
							<div class="d-flex justify-content-between mb-2">
								<span class="text-muted">Mã giao dịch VNPAY:</span>
								<b class="text-dark">${transactionNo}</b>
							</div>
							<div class="d-flex justify-content-between mb-2">
								<span class="text-muted">Ngân hàng thanh toán:</span>
								<span class="badge bg-primary">${bankCode} (${cardType})</span>
							</div>
							<div class="d-flex justify-content-between mb-2">
								<span class="text-muted">Người nhận:</span>
								<b class="text-dark">${order.recipientName} - ${order.recipientPhone}</b>
							</div>
							<div class="d-flex justify-content-between mb-2">
								<span class="text-muted">Địa chỉ nhận hàng:</span>
								<span class="text-dark fw-semibold text-end" style="max-width: 350px;">${order.shippingAddress}</span>
							</div>
							<div class="d-flex justify-content-between pt-2 border-top mt-2">
								<span class="fw-bold fs-5 text-dark">Số tiền đã thanh toán:</span>
								<span class="text-success fs-4 fw-bold">
									<fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/> ₫
								</span>
							</div>
						</div>
					</c:when>

					<c:otherwise>
						<div class="text-danger mb-3">
							<i class="bi bi-x-circle-fill display-1"></i>
						</div>
						<h2 class="fw-bold text-danger mb-2">THANH TOÁN KHÔNG THÀNH CÔNG</h2>
						<p class="text-muted mb-4">Giao dịch bị hủy hoặc xảy ra lỗi trong quá trình xử lý trên cổng VNPAY (Mã lỗi: ${responseCode}).</p>

						<div class="alert alert-warning text-start rounded-3 mb-4">
							Đơn hàng <b>${order.orderCode}</b> của bạn vẫn được lưu lại ở trạng thái <i>Chờ thanh toán</i>. Bạn có thể thanh toán lại hoặc chọn phương thức thanh toán khác.
						</div>
					</c:otherwise>
				</c:choose>

				<div class="d-flex gap-3 justify-content-center">
					<a href="${pageContext.request.contextPath}/products" class="btn btn-outline-secondary rounded-pill px-4 fw-bold">
						<i class="bi bi-arrow-left me-1"></i>Tiếp tục mua sắm
					</a>
					<a href="${pageContext.request.contextPath}/" class="btn btn-primary rounded-pill px-4 fw-bold shadow">
						Trang chủ
					</a>
				</div>

			</div>

		</div>
	</div>
</div>

<jsp:include page="fragments/footer.jsp" />