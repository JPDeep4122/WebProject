<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="fragments/header.jsp" />

<style>
@media print {
	.sf-header, .sf-footer, .no-print {
		display: none !important;
	}
	.invoice-card {
		box-shadow: none !important;
		border: 1px solid #000 !important;
	}
}
</style>

<div class="container py-4 py-md-5">
	<div class="row justify-content-center">
		<div class="col-lg-8">

			<div class="bg-white p-4 p-md-5 rounded-4 shadow-sm border invoice-card">
				
				<div class="text-center border-bottom pb-4 mb-4">
					<div class="text-success mb-2">
						<i class="bi bi-check-circle-fill display-3"></i>
					</div>
					<h2 class="fw-bold text-dark mb-1">ĐẶT HÀNG THÀNH CÔNG!</h2>
					<c:choose>
						<c:when test="${order.payment.paymentMethod == 'VNPAY' && order.payment.paymentStatus == 'PENDING'}">
							<p class="text-muted mb-2">Đơn hàng đã được ghi nhận và đang chờ thanh toán qua cổng VNPay.</p>
						</c:when>
						<c:otherwise>
							<p class="text-muted mb-2">Cảm ơn bạn đã mua sắm tại <b>TECHSEVEN</b>. Phiếu xác nhận đơn hàng của bạn dưới đây:</p>
						</c:otherwise>
					</c:choose>
					<span class="badge rounded-pill bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-3 py-2">
						<i class="bi bi-shield-check me-1"></i>Hóa đơn điện tử / Phiếu xác nhận đơn hàng
					</span>
				</div>

				
				<div class="row g-3 mb-4">
					<div class="col-md-6">
						<div class="p-3 bg-light rounded-4 h-100 border">
							<h6 class="fw-bold text-primary text-uppercase small mb-3">
								<i class="bi bi-receipt me-1"></i>Thông tin đơn hàng
							</h6>
							<div class="mb-2">
								<span class="text-muted small d-block">Mã đơn hàng:</span>
								<div class="d-flex align-items-center gap-2 flex-wrap">
									<strong class="text-primary text-break" id="orderCodeText"><c:out value="${order.orderCode}"/></strong>
									<button type="button" class="btn btn-outline-secondary btn-sm py-0 px-2 no-print"
										onclick="navigator.clipboard.writeText(document.getElementById('orderCodeText').innerText); this.innerHTML='<i class=\'bi bi-check2\'></i> Đã chép';"
										title="Sao chép mã đơn">
										<i class="bi bi-copy"></i>
									</button>
								</div>
							</div>
							<div class="mb-2 small">
								<span class="text-muted">Thời gian đặt:</span>
								<strong class="text-dark ms-1">
									${not empty order.createdAt ? fn:substring(fn:replace(order.createdAt, 'T', ' '), 0, 16) : 'Vừa xong'}
								</strong>
							</div>
							<div class="mb-2 small">
								<span class="text-muted">Phương thức thanh toán:</span>
								<span class="badge bg-dark ms-1"><c:out value="${order.payment.paymentMethod}"/></span>
								<c:choose>
									<c:when test="${order.payment.paymentStatus == 'SUCCESS'}">
										<span class="badge bg-success ms-1">Đã thanh toán</span>
									</c:when>
									<c:when test="${order.payment.paymentMethod == 'COD'}">
										<span class="badge bg-secondary ms-1">Thu hộ khi giao</span>
									</c:when>
									<c:otherwise>
										<span class="badge bg-warning text-dark ms-1">Chờ thanh toán</span>
									</c:otherwise>
								</c:choose>
							</div>
							<c:if test="${not empty order.branch}">
								<div class="small">
									<span class="text-muted">Chi nhánh xuất kho:</span>
									<strong class="text-dark ms-1"><c:out value="${order.branch.name}"/></strong>
								</div>
							</c:if>
						</div>
					</div>

					<div class="col-md-6">
						<div class="p-3 bg-light rounded-4 h-100 border">
							<h6 class="fw-bold text-primary text-uppercase small mb-3">
								<i class="bi bi-geo-alt-fill text-danger me-1"></i>Thông tin nhận hàng
							</h6>
							<div class="mb-2 small">
								<span class="text-muted">Người nhận:</span>
								<strong class="text-dark d-block"><c:out value="${order.recipientName}"/></strong>
							</div>
							<div class="mb-2 small">
								<span class="text-muted">Số điện thoại:</span>
								<strong class="text-dark ms-1"><c:out value="${order.recipientPhone}"/></strong>
							</div>
							<div class="mb-2 small">
								<span class="text-muted">Địa chỉ giao hàng:</span>
								<span class="text-dark fw-semibold d-block"><c:out value="${order.shippingAddress}"/></span>
							</div>
							<c:if test="${not empty order.note}">
								<div class="small">
									<span class="text-muted">Ghi chú:</span>
									<span class="fst-italic text-dark ms-1"><c:out value="${order.note}"/></span>
								</div>
							</c:if>
						</div>
					</div>
				</div>

				
				<c:if test="${not empty order.orderItems}">
					<div class="mb-4">
						<h6 class="fw-bold text-dark text-uppercase small mb-2">
							<i class="bi bi-box-seam text-primary me-1"></i>Chi tiết sản phẩm (${fn:length(order.orderItems)} mặt hàng)
						</h6>
						<div class="table-responsive border rounded-4 overflow-hidden">
							<table class="table table-sm align-middle mb-0">
								<thead class="table-light">
									<tr>
										<th class="ps-3 py-2">Sản phẩm</th>
										<th class="text-center py-2">SL</th>
										<th class="text-end py-2">Đơn giá</th>
										<th class="text-end pe-3 py-2">Thành tiền</th>
									</tr>
								</thead>
								<tbody>
									<c:forEach items="${order.orderItems}" var="item">
										<tr>
											<td class="ps-3 py-2">
												<div class="fw-semibold text-dark small"><c:out value="${item.product.name}"/></div>
											</td>
											<td class="text-center py-2 small fw-bold">x${item.quantity}</td>
											<td class="text-end py-2 small text-muted">
												<fmt:formatNumber value="${item.price}" type="number" groupingUsed="true"/> ₫
											</td>
											<td class="text-end pe-3 py-2 small fw-bold text-dark">
												<fmt:formatNumber value="${item.subtotal}" type="number" groupingUsed="true"/> ₫
											</td>
										</tr>
									</c:forEach>
								</tbody>
							</table>
						</div>
					</div>
				</c:if>

				
				<div class="p-4 bg-light rounded-4 mb-4 border">
					<div class="d-flex justify-content-between mb-2 small">
						<span class="text-muted">Tạm tính tiền hàng:</span>
						<span class="fw-semibold text-dark">
							<fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true"/> ₫
						</span>
					</div>
					<div class="d-flex justify-content-between mb-2 small">
						<span class="text-muted">Phí vận chuyển:</span>
						<span class="fw-semibold ${order.shippingFee == 0 ? 'text-success' : 'text-dark'}">
							<c:choose>
								<c:when test="${empty order.shippingFee or order.shippingFee == 0}">Miễn phí (0 ₫)</c:when>
								<c:otherwise><fmt:formatNumber value="${order.shippingFee}" type="number" groupingUsed="true"/> ₫</c:otherwise>
							</c:choose>
						</span>
					</div>
					<c:if test="${not empty order.discountAmount and order.discountAmount > 0}">
						<div class="d-flex justify-content-between mb-2 small">
							<span class="text-muted">Giảm giá Voucher:</span>
							<span class="fw-bold text-danger">
								-<fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true"/> ₫
							</span>
						</div>
					</c:if>
					<div class="d-flex justify-content-between align-items-baseline pt-3 border-top mt-2">
						<div>
							<span class="fw-bold fs-5 text-dark">Tổng thanh toán:</span>
							<small class="text-muted d-block">(Đã bao gồm thuế GTGT / VAT)</small>
						</div>
						<span class="text-danger fs-3 fw-bold">
							<fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/> ₫
						</span>
					</div>
				</div>

				
				<c:if test="${not empty paymentError}">
					<div class="alert alert-warning rounded-3"><c:out value="${paymentError}" /></div>
				</c:if>
				<c:if test="${order.payment.paymentLinkAvailable}">
					<c:url var="continuePaymentUrl" value="/checkout/orders/${order.orderCode}/pay" />
					<form method="post" action="${continuePaymentUrl}" class="mb-3 text-center no-print">
						<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
						<button type="submit" class="btn btn-primary rounded-pill px-4 fw-bold">
							<i class="bi bi-credit-card me-1"></i>Tiếp tục thanh toán VNPay
						</button>
					</form>
				</c:if>

				
				<div class="d-flex flex-wrap gap-2 justify-content-center no-print pt-2">
					<a href="${pageContext.request.contextPath}/products" class="btn btn-outline-secondary rounded-pill px-4 fw-bold">
						<i class="bi bi-arrow-left me-1"></i>Tiếp tục mua sắm
					</a>
					<a href="${pageContext.request.contextPath}/orders/${order.orderCode}" class="btn btn-outline-primary rounded-pill px-4 fw-bold">
						<i class="bi bi-eye me-1"></i>Xem chi tiết đơn hàng
					</a>
					<button type="button" onclick="window.print()" class="btn btn-outline-dark rounded-pill px-3 fw-bold">
						<i class="bi bi-printer me-1"></i>In hóa đơn
					</button>
					<a href="${pageContext.request.contextPath}/" class="btn btn-primary rounded-pill px-4 fw-bold shadow-sm">
						<i class="bi bi-house-door me-1"></i>Trang chủ
					</a>
				</div>

			</div>

		</div>
	</div>
</div>

<jsp:include page="fragments/footer.jsp" />