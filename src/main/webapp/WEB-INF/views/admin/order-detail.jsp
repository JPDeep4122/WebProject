<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
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
	<c:set var="principalText">${pageContext.request.userPrincipal}</c:set>
	<c:set var="canConfirmCodHandover"
		value="${pageContext.request.isUserInRole('ADMIN') or pageContext.request.isUserInRole('BRANCH_MANAGER')}" />
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
								<dt class="col-sm-4">Chi nhánh đặt</dt>
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
									<span class="badge ${order.payment.paymentStatus eq 'SUCCESS' ? 'text-bg-success' : (order.payment.paymentStatus eq 'REFUNDED' ? 'text-bg-info' : 'text-bg-warning text-dark')}">
										<c:out value="${order.payment.paymentStatus}" default="Chưa có" />
									</span>
								</dd>
								<dt class="col-sm-5">Tiền thu khi nhận hàng</dt>
								<dd class="col-sm-7">
									<c:choose>
										<c:when test="${order.prepaidVnPay}">
											<strong class="text-success">0 ₫</strong>
											<small class="text-success d-block">(Đơn trả trước qua VNPay — Shipper không thu tiền)</small>
										</c:when>
										<c:otherwise>
											<strong class="text-danger"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true" /> ₫</strong>
											<small class="text-secondary d-block">(Thu tiền mặt COD khi giao hàng)</small>
										</c:otherwise>
									</c:choose>
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
								<c:if test="${order.payment.paymentMethod eq 'COD' and not empty order.deliveryAssignment}">
									<dt class="col-sm-5">Đối soát tiền COD</dt>
									<dd class="col-sm-7">
										<c:choose>
											<c:when test="${order.deliveryAssignment.codHandoverStatus eq 'HANDED_OVER'}">
												<span class="badge text-bg-success">Đã nộp về chi nhánh</span>
												<small class="text-secondary d-block">Người nhận quỹ: <c:out value="${order.deliveryAssignment.codReceivedBy.fullName}"/></small>
											</c:when>
											<c:when test="${order.deliveryAssignment.codHandoverStatus eq 'PENDING_HANDOVER'}">
												<span class="badge text-bg-warning">Shipper đang giữ tiền COD (<fmt:formatNumber value="${order.deliveryAssignment.collectedAmount}" type="number" groupingUsed="true"/> ₫)</span>
												<c:if test="${canConfirmCodHandover}">
													<form method="post" action="${pageContext.request.contextPath}/admin/orders/${order.id}/confirm-cod-handover" class="mt-2">
														<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
														<button type="submit" class="btn btn-sm btn-success" onclick="return confirm('Xác nhận chi nhánh đã nhận đủ tiền mặt COD từ Shipper?');">
															<i class="bi bi-cash-coin me-1"></i> Xác nhận đã nhận tiền COD từ Shipper
														</button>
													</form>
												</c:if>
											</c:when>
											<c:otherwise><span class="text-muted">Chưa thu</span></c:otherwise>
										</c:choose>
									</dd>
								</c:if>
								<c:if test="${order.status eq 'CANCELLED'}">
									<dt class="col-sm-5">Lý do giao thất bại</dt>
									<dd class="col-sm-7">
										<c:out value="${order.deliveryAssignment.failureReason}"
											default="—" />
									</dd>
								</c:if>
							</dl>
							<c:if test="${not empty proofViewUrl}">
								<hr class="my-3">
								<div class="fw-semibold mb-2"><i class="bi bi-camera me-2"></i>Ảnh minh chứng giao hàng</div>
								<a href="<c:out value='${proofViewUrl}'/>" target="_blank" rel="noopener noreferrer">
									<img src="<c:out value='${proofViewUrl}'/>" alt="Ảnh minh chứng giao hàng"
										class="img-fluid rounded-3 border" style="max-height: 320px">
								</a>
							</c:if>
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

			<!-- KHUNG XỬ LÝ HOÀN TIỀN CHO ĐƠN TRẢ TRƯỚC VNPAY BỊ HỦY -->
			<c:if test="${order.refundRequired or order.refundCompleted}">
				<section class="card border-0 shadow-sm mb-3 ${order.refundRequired ? 'border-start border-warning border-4' : 'border-start border-success border-4'}">
					<div class="card-header bg-white fw-semibold">
						<i class="bi bi-cash-stack me-2 text-primary"></i>Hoàn tiền đơn trả trước VNPay đã hủy (Hỗ trợ hoàn tại chi nhánh đặt hoặc chi nhánh gần nhất)
					</div>
					<div class="card-body">
						<c:choose>
							<c:when test="${order.refundRequired}">
								<div class="alert alert-warning mb-3">
									<strong><i class="bi bi-exclamation-circle me-1"></i>Đơn hàng đã thanh toán VNPay (<fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true" /> ₫) nhưng đã bị hủy.</strong>
									<div class="small mt-1">
										Khách hàng có thể nhận lại tiền mặt trực tiếp tại quầy chi nhánh gần nhất hoặc nhân viên chi nhánh chuyển khoản ngân hàng trả hộ cho khách.
									</div>
								</div>
								<c:if test="${canConfirmCodHandover}">
								<form method="post" action="${pageContext.request.contextPath}/admin/orders/${order.id}/refund-cancelled"
									onsubmit="return confirm('Xác nhận đã chi trả đủ số tiền hoàn cho khách hàng?');" class="row g-3">
									<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
									<div class="col-md-4">
										<label class="form-label fw-semibold">Hình thức hoàn tiền</label>
										<select name="refundMethod" class="form-select" required>
											<option value="CASH_AT_BRANCH">Chi tiền mặt tại quầy chi nhánh</option>
											<option value="BANK_TRANSFER">Nhân viên chi nhánh chuyển khoản trả hộ</option>
										</select>
									</div>
									<div class="col-md-5">
										<label class="form-label fw-semibold">Ghi chú đối soát (CCCD/SĐT người nhận hoặc Mã GD chuyển khoản)</label>
										<input type="text" name="refundNote" class="form-control" maxlength="500"
											placeholder="VD: Đã chi tiền mặt tại quầy cho khách Nguyễn Văn A (SĐT 0912...)" required>
									</div>
									<div class="col-md-3 d-flex align-items-end">
										<button type="submit" class="btn btn-success w-100 fw-semibold">
											<i class="bi bi-check2-circle me-1"></i>Xác nhận đã hoàn tiền
										</button>
									</div>
								</form>
								</c:if>
								<c:if test="${not canConfirmCodHandover}">
									<div class="text-secondary">Quản lý chi nhánh/Admin xác nhận hoàn tiền cho khách hàng.</div>
								</c:if>
							</c:when>
							<c:otherwise>
								<div class="alert alert-success mb-0">
									<div class="fw-bold mb-1">
										<i class="bi bi-check-circle-fill me-1"></i>ĐÃ HOÀN TIỀN THÀNH CÔNG:
										<fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true" /> ₫
									</div>
									<div class="small">
										<strong>Hình thức hoàn:</strong>
										${order.payment.refundMethod eq 'BANK_TRANSFER' ? 'Nhân viên chi nhánh chuyển khoản ngân hàng trả hộ' : 'Chi tiền mặt trực tiếp tại quầy chi nhánh'}
										<br>
										<strong>Chi nhánh chi trả:</strong> <c:out value="${order.payment.refundBranch.name}" default="—" />
										• <strong>Nhân viên thực hiện:</strong> <c:out value="${order.payment.refundedBy.fullName}" default="—" />
										• <strong>Thời gian:</strong> <c:out value="${order.payment.refundedAt}" default="—" />
										<br>
										<strong>Ghi chú đối soát:</strong> <c:out value="${order.payment.refundNote}" default="—" />
									</div>
								</div>
							</c:otherwise>
						</c:choose>
					</div>
				</section>
			</c:if>

			<section class="card border-0 shadow-sm mb-3">
				<div class="card-header bg-white fw-semibold">
					<i class="bi bi-clipboard-check me-2"></i> Xử lý đơn hàng
				</div>

				<div class="card-body">

					<c:if test="${order.awaitingPayment}">
						<div class="alert alert-warning mb-3">
							Đơn hàng đang chờ khách hoàn tất thanh toán trên cổng VNPay.
						</div>
					</c:if>

					<c:if test="${canConfirm}">
						<p class="text-secondary">Kiểm tra thông tin khách hàng và sản
							phẩm trước khi xác nhận.</p>

						<div class="d-flex flex-wrap gap-2">
							<form method="post"
								action="${pageContext.request.contextPath}/admin/orders/${order.id}/confirm">
								<input type="hidden" name="${_csrf.parameterName}"
									value="${_csrf.token}"> <input type="hidden"
									name="returnTo" value="detail">
								<button type="submit" class="btn btn-success">
									<i class="bi bi-check-circle me-1"></i> Xác nhận đơn hàng
								</button>
							</form>

							<form method="post"
								action="${pageContext.request.contextPath}/admin/orders/${order.id}/cancel"
								onsubmit="return confirm('Hủy đơn hàng này và hoàn lại tồn kho?');">
								<input type="hidden" name="${_csrf.parameterName}"
									value="${_csrf.token}"> <input type="hidden"
									name="returnTo" value="detail">
								<button type="submit" class="btn btn-outline-danger">
									<i class="bi bi-x-circle me-1"></i> Hủy đơn hàng
								</button>
							</form>
						</div>
					</c:if>

					<c:if test="${order.status eq 'CONFIRMED'}">
						<div class="d-flex flex-wrap gap-2 mb-3">
							<form method="post"
								action="${pageContext.request.contextPath}/admin/orders/${order.id}/start-picking">
								<input type="hidden" name="${_csrf.parameterName}"
									value="${_csrf.token}">
								<button type="submit" class="btn btn-primary">
									<i class="bi bi-box-seam me-1"></i> Bắt đầu lấy và chuẩn bị hàng
								</button>
							</form>
							<form method="post"
								action="${pageContext.request.contextPath}/admin/orders/${order.id}/cancel"
								onsubmit="return confirm('Hủy đơn hàng này và hoàn lại tồn kho?');">
								<input type="hidden" name="${_csrf.parameterName}"
									value="${_csrf.token}"> <input type="hidden"
									name="returnTo" value="detail">
								<button type="submit" class="btn btn-outline-danger">
									<i class="bi bi-x-circle me-1"></i> Hủy đơn hàng
								</button>
							</form>
						</div>
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

					<c:if test="${not canConfirm and not canAssign and order.status ne 'CONFIRMED'}">
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
								<th colspan="3" class="text-end">Tổng giá trị đơn hàng</th>
								<th class="text-end text-primary"><fmt:formatNumber
										value="${order.finalAmount}" type="number" groupingUsed="true" />
									₫</th>
							</tr>
							<tr>
								<th colspan="3" class="text-end">Số tiền cần thu khi nhận hàng</th>
								<th class="text-end ${order.prepaidVnPay ? 'text-success' : 'text-danger'}">
									<c:choose>
										<c:when test="${order.prepaidVnPay}">0 ₫ (Đã thanh toán trả trước qua VNPay)</c:when>
										<c:otherwise><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true" /> ₫ (Thu hộ COD)</c:otherwise>
									</c:choose>
								</th>
							</tr>
						</tfoot>
					</table>
				</div>
			</section>
		</main>
	</div>
</body>
</html>
