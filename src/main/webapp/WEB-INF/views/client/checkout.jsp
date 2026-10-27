<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="fragments/header.jsp" />

<div class="container-fluid py-4">

	<!-- BREADCRUMB -->
	<nav aria-label="breadcrumb" class="mb-4">
		<ol class="breadcrumb small">
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/"
				class="text-decoration-none">Trang chủ</a></li>
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/cart"
				class="text-decoration-none">Giỏ hàng</a></li>
			<li class="breadcrumb-item active">Thanh toán đơn hàng</li>
		</ol>
	</nav>

	<h3 class="fw-bold mb-4 text-primary">
		<i class="bi bi-credit-card-2-front me-2"></i>TIẾN HÀNH THANH TOÁN
	</h3>

	<c:if test="${not empty checkoutError}">
		<div class="alert alert-danger" role="alert">
			<c:out value="${checkoutError}" />
		</div>
	</c:if>

	<form action="${pageContext.request.contextPath}/checkout/place-order"
		method="post" id="checkoutForm">

		<input type="hidden" name="${_csrf.parameterName}"
			value="${_csrf.token}">

		<div class="row g-4">

			<!-- CỘT TRÁI: THÔNG TIN GIAO HÀNG & PHƯƠNG THỨC THANH TOÁN -->
			<div class="col-lg-7">

				<!-- 1. SỔ ĐỊA CHỈ & THÔNG TIN NGƯỜI NHẬN -->
				<div class="bg-white p-4 rounded-4 shadow-sm border mb-4">
					<h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
						<i class="bi bi-geo-alt-fill text-danger me-2"></i>1. Địa Chỉ Nhận
						Hàng
					</h5>

					<!-- Nếu user đã có địa chỉ lưu sẵn -->
					<c:if test="${not empty checkoutData.savedAddresses}">
						<div class="mb-3">
							<label class="form-label small fw-bold text-muted">Chọn
								từ sổ địa chỉ của bạn:</label> <select class="form-select rounded-3"
								id="savedAddressSelect" onchange="onSelectSavedAddress(this)">
								<option value="">-- Nhập địa chỉ mới --</option>
								<c:forEach items="${checkoutData.savedAddresses}" var="addr">
									<option value="${addr.id}"
										data-name="${fn:escapeXml(addr.recipientName)}"
										data-phone="${fn:escapeXml(addr.phoneNumber)}"
										data-addr="${fn:escapeXml(addr.fullAddress)}"
										data-province="${fn:escapeXml(addr.province)}">
										<c:out value="${addr.recipientName}" /> -
										<c:out value="${addr.phoneNumber}" /> (
										<c:out value="${addr.fullAddress}" />)
									</option>
								</c:forEach>
							</select>
						</div>
					</c:if>

					<div class="row g-3">
						<div class="col-md-6">
							<label class="form-label small fw-bold">Họ và tên người
								nhận <span class="text-danger">*</span>
							</label> <input type="text" name="recipientName" id="recipientName"
								class="form-control rounded-3"
								value="${fn:escapeXml(orderForm.recipientName)}" maxlength="100"
								required placeholder="Nguyễn Văn A">
						</div>
						<div class="col-md-6">
							<label class="form-label small fw-bold">Số điện thoại <span
								class="text-danger">*</span></label> <input type="tel"
								name="recipientPhone" id="recipientPhone"
								class="form-control rounded-3"
								value="${fn:escapeXml(orderForm.recipientPhone)}" maxlength="10"
								pattern="0[0-9]{9}" inputmode="numeric"
								oninput="this.value = this.value.replace(/[^0-9]/g, '')"
								title="Số điện thoại gồm 10 chữ số, bắt đầu bằng số 0" required
								placeholder="0901234567">
						</div>
						<div class="col-12">
							<label class="form-label small fw-bold">Địa chỉ chi tiết
								(Số nhà, tên đường, phường/xã) <span class="text-danger">*</span>
							</label>
							<textarea name="shippingAddress" id="shippingAddress" rows="2"
								class="form-control rounded-3" required
								placeholder="Số 123 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM"><c:out
									value="${orderForm.shippingAddress}" /></textarea>
						</div>
						<div class="col-12">
							<label class="form-label small fw-bold">Tỉnh / thành phố
								<span class="text-danger">*</span>
							</label> <input type="text" name="province" id="shippingProvince"
								class="form-control rounded-3"
								value="${fn:escapeXml(orderForm.province)}" required
								placeholder="Ví dụ: Thành phố Hồ Chí Minh"> <small
								class="text-muted">Nhập tỉnh/thành để xác định miễn phí
								cùng tỉnh hoặc tính tuyến đường liên tỉnh.</small>
						</div>
						<div class="col-12">
							<label class="form-label small fw-bold">Ghi chú đơn hàng
								(Tùy chọn)</label> <input type="text" name="note"
								class="form-control rounded-3"
								value="${fn:escapeXml(orderForm.note)}"
								placeholder="Ví dụ: Giao giờ hành chính, gọi trước khi đến...">
						</div>
					</div>
				</div>

				<!-- 2. PHƯƠNG THỨC THANH TOÁN (COD / VNPAY / MOMO) -->
				<div class="bg-white p-4 rounded-4 shadow-sm border">
					<h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
						<i class="bi bi-wallet2 text-primary me-2"></i>2. Phương Thức
						Thanh Toán
					</h5>

					<div class="d-flex flex-column gap-3">
						<!-- COD -->
						<label
							class="d-flex align-items-center justify-content-between p-3 border rounded-3 cursor-pointer payment-option ${orderForm.paymentMethod eq 'COD' ? 'active-payment' : ''}">
							<div class="d-flex align-items-center gap-3">

								<input class="form-check-input mt-0" type="radio"
									name="paymentMethod" value="COD"
									${orderForm.paymentMethod eq 'COD' ? 'checked' : ''}>

								<div>
									<b class="text-dark"> Thanh toán khi nhận hàng (COD) </b>

									<div class="text-muted small">Nhận hàng, kiểm tra hàng
										rồi mới thanh toán tiền mặt cho shipper</div>
								</div>

							</div> <i class="bi bi-cash-stack fs-3 text-success"></i>
						</label>

						<!-- VNPAY -->
						<label
							class="d-flex align-items-center justify-content-between p-3 border rounded-3 cursor-pointer payment-option ${orderForm.paymentMethod eq 'VNPAY' ? 'active-payment' : ''}">
							<div class="d-flex align-items-center gap-3">

								<input class="form-check-input mt-0" type="radio"
									name="paymentMethod" value="VNPAY"
									${orderForm.paymentMethod eq 'VNPAY' ? 'checked' : ''}>

								<div>
									<b class="text-dark"> Thanh toán qua Cổng VNPAY (QR / Thẻ
										ATM) </b>

									<div class="text-muted small">Quét mã QR qua ứng dụng
										ngân hàng hoặc thẻ ATM nội địa</div>
								</div>

							</div> <span class="badge bg-primary px-3 py-2 fw-bold"> VNPAY </span>
						</label>


					</div>
				</div>

			</div>

			<!-- CỘT PHẢI: TÓM TẮT ĐƠN HÀNG & MÃ GIẢM GIÁ -->
			<div class="col-lg-5">
				<div class="bg-white p-4 rounded-4 shadow-sm border position-sticky"
					style="top: 20px;">
					<h5 class="fw-bold mb-3 border-bottom pb-2 text-dark">
						<i class="bi bi-bag-check-fill text-success me-2"></i>Đơn Hàng Của
						Bạn (${checkoutData.items.size()} món)
					</h5>

					<!-- Danh sách sản phẩm thanh toán -->
					<div class="d-flex flex-column gap-3 mb-4"
						style="max-height: 250px; overflow-y: auto;">
						<c:forEach items="${checkoutData.items}" var="item">
							<div class="d-flex align-items-center justify-content-between">
								<div class="d-flex align-items-center gap-2">
									<img src="${item.imageUrl}"
										class="rounded-3 border object-fit-contain p-1"
										style="width: 55px; height: 55px;" alt="${item.productName}">
									<div>
										<h6 class="fw-bold mb-0 text-truncate small"
											style="max-width: 200px;" title="${item.productName}">${item.productName}</h6>
										<small class="text-muted">SL: x${item.quantity}</small>
									</div>
								</div>
								<span class="fw-bold text-danger small"> <fmt:formatNumber
										value="${item.subtotal}" type="number" groupingUsed="true" />
									₫
								</span>
							</div>
						</c:forEach>
					</div>

					<!-- KHUNG ÁP DỤNG MÃ GIẢM GIÁ (VOUCHER) -->
					<div class="mb-4 pt-3 border-top">
						<label class="form-label small fw-bold text-dark"> <i
							class="bi bi-ticket-perforated-fill text-warning me-1"></i>Mã
							khuyến mãi / Giảm giá:
						</label>
						<div class="input-group">
							<input type="text" id="voucherCodeInput"
								class="form-control rounded-start-pill text-uppercase"
								placeholder="Nhập mã (VD: DIENMAY50K, SALE10)">
							<button class="btn btn-dark rounded-end-pill px-3 fw-bold"
								type="button" onclick="applyVoucher()">Áp dụng</button>
						</div>
						<div id="voucherMsg" class="small mt-1"></div>
						<input type="hidden" name="voucherCode" id="hiddenVoucherCode"
							value="">
					</div>

					<!-- TÍNH TIỀN -->
					<div class="d-flex flex-column gap-2 border-top pt-3 mb-4">
						<div class="d-flex justify-content-between text-muted small">
							<span>Tạm tính:</span> <span class="fw-bold text-dark"> <fmt:formatNumber
									value="${checkoutData.subtotal}" type="number"
									groupingUsed="true" /> ₫
							</span>
						</div>

						<div class="d-flex justify-content-between text-muted small">
							<span>Phí vận chuyển:</span> <span class="text-success fw-bold"
								id="shippingFeeDisplay">Nhập địa chỉ để tính phí</span>
						</div>
						<div class="small text-muted" id="shippingQuoteMessage"
							aria-live="polite"></div>

						<div class="d-flex justify-content-between text-muted small"
							id="discountRow" style="display: none !important;">
							<span>Giảm giá voucher:</span> <span class="text-danger fw-bold"
								id="discountAmountDisplay">-0 ₫</span>
						</div>

						<div
							class="d-flex justify-content-between align-items-baseline border-top pt-2 mt-2">
							<span class="fw-bold fs-5 text-dark">Tổng thanh toán:</span> <span
								class="fw-bold display-6 fs-3 text-danger"
								id="finalAmountDisplay"> <fmt:formatNumber
									value="${checkoutData.finalAmount}" type="number"
									groupingUsed="true" /> ₫
							</span>
						</div>
					</div>

					<!-- NÚT XÁC NHẬN ĐẶT HÀNG -->
					<button type="submit"
						class="btn btn-danger w-100 rounded-pill py-3 fw-bold fs-5 shadow">
						ĐẶT HÀNG NGAY <i class="bi bi-arrow-right ms-1"></i>
					</button>
					<small class="text-muted text-center d-block mt-2"
						style="font-size: 11px;"> Bằng cách đặt hàng, bạn đồng ý
						với Điều khoản dịch vụ của Điện Máy Shop. </small>
				</div>
			</div>

		</div>
	</form>

</div>

<jsp:include page="fragments/footer.jsp" />

<style>
.cursor-pointer {
	cursor: pointer;
}

.active-payment {
	border-color: #0d6efd !important;
	background-color: #f8f9ff;
}
</style>

<script>
  const originalSubtotal = ${checkoutData.subtotal};
  let currentShippingFee = 0;
  let currentDiscount = 0;
  let shippingQuoteTimer;

  function refreshTotal() {
    document.getElementById('finalAmountDisplay').innerText = Math.max(0, originalSubtotal + currentShippingFee - currentDiscount).toLocaleString('vi-VN') + ' ₫';
  }

  // 1. Tự động điền khi chọn địa chỉ lưu sẵn
  function onSelectSavedAddress(selectEl) {
    const selectedOption = selectEl.options[selectEl.selectedIndex];
    if (selectEl.value) {
      document.getElementById('recipientName').value = selectedOption.getAttribute('data-name');
      document.getElementById('recipientPhone').value = selectedOption.getAttribute('data-phone');
      document.getElementById('shippingAddress').value = selectedOption.getAttribute('data-addr');
      document.getElementById('shippingProvince').value = selectedOption.getAttribute('data-province') || '';
      requestShippingQuote();
    }
  }

  function requestShippingQuote() {
    clearTimeout(shippingQuoteTimer);
    shippingQuoteTimer = setTimeout(async () => {
      const address = document.getElementById('shippingAddress').value.trim();
      const province = document.getElementById('shippingProvince').value.trim();
      if (!address || !province) return;
      const feeEl = document.getElementById('shippingFeeDisplay');
      const msgEl = document.getElementById('shippingQuoteMessage');
      feeEl.innerText = 'Đang tính...';
      try {
        const response = await csrfFetch('${pageContext.request.contextPath}/api/checkout/shipping-quote', {
          method: 'POST', headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({shippingAddress: address, province: province})
        });
        const result = await response.json();
        if (!result.success) throw new Error(result.message || 'Không thể tính phí vận chuyển');
        currentShippingFee = Number(result.data.shippingFee || 0);
        feeEl.innerText = currentShippingFee === 0 ? 'Miễn phí (0 ₫)' : currentShippingFee.toLocaleString('vi-VN') + ' ₫';
        feeEl.className = currentShippingFee === 0 ? 'text-success fw-bold' : 'text-danger fw-bold';
        const distance = Number(result.data.distanceKm || 0);
        msgEl.innerText = result.data.sameProvince ? result.message : result.message + ' Khoảng cách: ' + distance.toLocaleString('vi-VN', {maximumFractionDigits: 1}) + ' km; chi nhánh: ' + result.data.branchName + '.';
        refreshTotal();
      } catch (error) {
        feeEl.innerText = 'Chưa tính được';
        msgEl.innerText = error.message;
      }
    }, 500);
  }
  document.getElementById('shippingAddress').addEventListener('change', requestShippingQuote);
  document.getElementById('shippingProvince').addEventListener('change', requestShippingQuote);
  if (document.getElementById('shippingAddress').value.trim()
	        && document.getElementById('shippingProvince').value.trim()) {
	    requestShippingQuote();
	}

  // 2. Hiệu ứng chọn phương thức thanh toán
  document.querySelectorAll('.payment-option input[type="radio"]').forEach(radio => {
    radio.addEventListener('change', function() {
      document.querySelectorAll('.payment-option').forEach(el => el.classList.remove('active-payment'));
      this.closest('.payment-option').classList.add('active-payment');
    });
  });

  // 3. Gọi AJAX áp dụng Voucher
  function applyVoucher() {
    const code = document.getElementById('voucherCodeInput').value.trim();
    const msgEl = document.getElementById('voucherMsg');
    if (!code) {
      msgEl.innerHTML = '<span class="text-danger">Vui lòng nhập mã voucher</span>';
      return;
    }

    csrfFetch('${pageContext.request.contextPath}/api/checkout/apply-voucher?code=' + encodeURIComponent(code) + '&subtotal=' + originalSubtotal, {
      method: 'POST'
    })
    .then(res => res.json())
    .then(res => {
      if (res.success && res.data.valid) {
        msgEl.innerHTML = '<span class="text-success fw-bold"><i class="bi bi-check-circle me-1"></i>' + res.message + '</span>';
        document.getElementById('hiddenVoucherCode').value = res.data.code;
        currentDiscount = Number(res.data.discountAmount || 0);
        
        // Cập nhật số tiền giảm và tổng tiền
        document.getElementById('discountRow').style.setProperty('display', 'flex', 'important');
        document.getElementById('discountAmountDisplay').innerText = '-' + Number(res.data.discountAmount).toLocaleString('vi-VN') + ' ₫';
        refreshTotal();
      } else {
        msgEl.innerHTML = '<span class="text-danger"><i class="bi bi-exclamation-circle me-1"></i>' + (res.message || 'Mã không hợp lệ') + '</span>';
        document.getElementById('hiddenVoucherCode').value = '';
        currentDiscount = 0;
        refreshTotal();
      }
    })
    .catch(err => {
      msgEl.innerHTML = '<span class="text-danger">Lỗi kết nối máy chủ</span>';
    });
  }
</script>
