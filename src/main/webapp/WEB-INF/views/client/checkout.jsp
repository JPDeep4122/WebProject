<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="fragments/header.jsp" />

<div class="container-fluid py-4">

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

			<div class="col-lg-7">

				<!-- 1. ĐỊA CHỈ NHẬN HÀNG -->
				<div class="bg-white p-4 rounded-4 shadow-sm border mb-4">
					<h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
						<i class="bi bi-geo-alt-fill text-danger me-2"></i>1. Địa Chỉ Nhận Hàng
					</h5>

					<c:if test="${not empty checkoutData.savedAddresses}">
						<div class="mb-3">
							<label class="form-label small fw-bold text-muted">Chọn từ sổ địa chỉ của bạn:</label>
							<select class="form-select rounded-3" id="savedAddressSelect" onchange="onSelectSavedAddress(this)">
								<option value="">-- Nhập địa chỉ mới --</option>
								<c:forEach items="${checkoutData.savedAddresses}" var="addr">
									<option value="${addr.id}"
										data-name="${fn:escapeXml(addr.recipientName)}"
										data-phone="${fn:escapeXml(addr.phoneNumber)}"
										data-detail="${fn:escapeXml(addr.detailAddress)}"
										data-addr="${fn:escapeXml(addr.fullAddress)}"
										data-ward="${fn:escapeXml(addr.ward)}"
										data-province="${fn:escapeXml(addr.province)}">
										<c:out value="${addr.recipientName}" /> - <c:out value="${addr.phoneNumber}" /> (<c:out value="${addr.fullAddress}" />)
									</option>
								</c:forEach>
							</select>
						</div>
					</c:if>

					<div class="row g-3">
						<div class="col-md-6">
							<label class="form-label small fw-bold">Họ và tên người nhận <span class="text-danger">*</span></label>
							<input type="text" name="recipientName" id="recipientName"
								class="form-control rounded-3"
								value="${fn:escapeXml(orderForm.recipientName)}" maxlength="100"
								required placeholder="Nguyễn Văn A">
						</div>
						<div class="col-md-6">
							<label class="form-label small fw-bold">Số điện thoại <span class="text-danger">*</span></label>
							<input type="tel" name="recipientPhone" id="recipientPhone"
								class="form-control rounded-3"
								value="${fn:escapeXml(orderForm.recipientPhone)}" maxlength="10"
								pattern="0[0-9]{9}" inputmode="numeric"
								oninput="this.value = this.value.replace(/[^0-9]/g, '')"
								title="Số điện thoại gồm 10 chữ số, bắt đầu bằng số 0" required
								placeholder="0901234567">
						</div>

						<!-- Địa chỉ cụ thể (Số nhà, tên đường) -->
						<div class="col-12">
							<label class="form-label small fw-bold">Địa chỉ cụ thể (Số nhà, tên đường) <span class="text-danger">*</span></label>
							<input type="text" name="shippingAddress" id="shippingAddress"
								class="form-control rounded-3" required
								value="${fn:escapeXml(orderForm.shippingAddress)}"
								placeholder="Ví dụ: Số 1, đường Võ Văn Ngân">
						</div>

						<!-- Tỉnh / Thành phố Dropdown -->
						<div class="col-md-6">
							<label class="form-label small fw-bold">Tỉnh / thành phố <span class="text-danger">*</span></label>
							<select name="province" id="shippingProvince" class="form-select rounded-3" required onchange="onProvinceSelectChange()">
								<option value="">-- Chọn Tỉnh / Thành phố --</option>
								<option value="Thành phố Hồ Chí Minh" ${orderForm.province eq 'Thành phố Hồ Chí Minh' ? 'selected' : ''}>Thành phố Hồ Chí Minh</option>
								<option value="Hà Nội" ${orderForm.province eq 'Hà Nội' ? 'selected' : ''}>Hà Nội</option>
							</select>
							<small class="text-muted" style="font-size: 0.75rem;">Miễn phí ship khi có chi nhánh cùng tỉnh.</small>
						</div>

						<!-- Phường / Xã Dropdown (Tải tự động qua API) -->
						<div class="col-md-6">
							<label for="shippingWard" class="form-label small fw-bold d-flex justify-content-between align-items-center">
								<span>Phường / xã <span class="text-danger">*</span></span>
								<span id="wardLoadingSpinner" class="spinner-border spinner-border-sm text-primary d-none" role="status"></span>
							</label>
							<select name="ward" id="shippingWard" class="form-select rounded-3" required>
								<option value="">-- Chọn Phường / Xã --</option>
							</select>
						</div>

						<div class="col-12">
							<label class="form-label small fw-bold">Ghi chú đơn hàng (Tùy chọn)</label>
							<input type="text" name="note" class="form-control rounded-3"
								value="${fn:escapeXml(orderForm.note)}"
								placeholder="Ví dụ: Giao giờ hành chính, gọi trước khi đến...">
						</div>
					</div>
				</div>

				<!-- 2. PHƯƠNG THỨC THANH TOÁN -->
				<div class="bg-white p-4 rounded-4 shadow-sm border">
					<h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
						<i class="bi bi-wallet2 text-primary me-2"></i>2. Phương Thức Thanh Toán
					</h5>

					<div class="d-flex flex-column gap-3">
						<label class="d-flex align-items-center justify-content-between p-3 border rounded-3 cursor-pointer payment-option ${orderForm.paymentMethod eq 'COD' ? 'active-payment' : ''}">
							<div class="d-flex align-items-center gap-3">
								<input class="form-check-input mt-0" type="radio"
									name="paymentMethod" value="COD"
									${orderForm.paymentMethod eq 'COD' ? 'checked' : ''}>
								<div>
									<b class="text-dark">Thanh toán khi nhận hàng (COD)</b>
									<div class="text-muted small">Nhận hàng, kiểm tra hàng rồi mới thanh toán tiền mặt cho shipper</div>
								</div>
							</div>
							<i class="bi bi-cash-stack fs-3 text-success"></i>
						</label>

						<label class="d-flex align-items-center justify-content-between p-3 border rounded-3 cursor-pointer payment-option ${orderForm.paymentMethod eq 'VNPAY' ? 'active-payment' : ''}">
							<div class="d-flex align-items-center gap-3">
								<input class="form-check-input mt-0" type="radio"
									name="paymentMethod" value="VNPAY"
									${orderForm.paymentMethod eq 'VNPAY' ? 'checked' : ''}>
								<div>
									<b class="text-dark">Thanh toán qua Cổng VNPAY (QR / Thẻ ATM)</b>
									<div class="text-muted small">Quét mã QR qua ứng dụng ngân hàng hoặc thẻ ATM nội địa</div>
								</div>
							</div>
							<span class="badge bg-primary px-3 py-2 fw-bold">VNPAY</span>
						</label>
					</div>
				</div>

			</div>

			<!-- CỘT BÊN PHẢI: TỔNG QUAN ĐƠN HÀNG & PHÍ SHIP -->
			<div class="col-lg-5">
				<div class="bg-white p-4 rounded-4 shadow-sm border position-sticky" style="top: 20px;">
					<h5 class="fw-bold mb-3 border-bottom pb-2 text-dark">
						<i class="bi bi-bag-check-fill text-success me-2"></i>Đơn Hàng Của Bạn (${checkoutData.items.size()} món)
					</h5>

					<div class="d-flex flex-column gap-3 mb-4" style="max-height: 250px; overflow-y: auto;">
						<c:forEach items="${checkoutData.items}" var="item">
							<div class="d-flex align-items-center justify-content-between">
								<div class="d-flex align-items-center gap-2">
									<img src="${item.imageUrl}"
										class="rounded-3 border object-fit-contain p-1"
										style="width: 55px; height: 55px;" alt="${item.productName}">
									<div>
										<h6 class="fw-bold mb-0 text-truncate small" style="max-width: 200px;" title="${item.productName}">${item.productName}</h6>
										<small class="text-muted">SL: x${item.quantity}</small>
									</div>
								</div>
								<span class="fw-bold text-danger small">
									<fmt:formatNumber value="${item.subtotal}" type="number" groupingUsed="true" /> ₫
								</span>
							</div>
						</c:forEach>
					</div>

					<div class="mb-4 pt-3 border-top">
						<label class="form-label small fw-bold text-dark">
							<i class="bi bi-ticket-perforated-fill text-warning me-1"></i>Mã khuyến mãi / Giảm giá:
						</label>
						<div class="input-group">
							<input type="text" id="voucherCodeInput"
								class="form-control rounded-start-pill text-uppercase"
								placeholder="Nhập mã từ Kho Voucher">
							<button class="btn btn-dark rounded-end-pill px-3 fw-bold"
								type="button" onclick="applyVoucher()">Áp dụng</button>
						</div>
						<div id="voucherMsg" class="small mt-1"></div>
						<input type="hidden" name="voucherCode" id="hiddenVoucherCode" value="">
					</div>

					<div class="d-flex flex-column gap-2 border-top pt-3 mb-4">
						<div class="d-flex justify-content-between text-muted small">
							<span>Tạm tính:</span>
							<span class="fw-bold text-dark">
								<fmt:formatNumber value="${checkoutData.subtotal}" type="number" groupingUsed="true" /> ₫
							</span>
						</div>

						<div class="d-flex justify-content-between text-muted small">
							<span>Phí vận chuyển:</span>
							<span class="text-success fw-bold" id="shippingFeeDisplay">Nhập địa chỉ để tính phí</span>
						</div>
						<div class="small text-muted" id="shippingQuoteMessage" aria-live="polite"></div>

						<div class="d-flex justify-content-between text-muted small" id="discountRow" style="display: none !important;">
							<span>Giảm giá voucher:</span>
							<span class="text-danger fw-bold" id="discountAmountDisplay">-0 ₫</span>
						</div>

						<div class="d-flex justify-content-between align-items-baseline border-top pt-2 mt-2">
							<span class="fw-bold fs-5 text-dark">Tổng thanh toán:</span>
							<span class="fw-bold display-6 fs-3 text-danger" id="finalAmountDisplay">
								<fmt:formatNumber value="${checkoutData.finalAmount}" type="number" groupingUsed="true" /> ₫
							</span>
						</div>
					</div>

					<button type="submit" class="btn btn-danger w-100 rounded-pill py-3 fw-bold fs-5 shadow">
						ĐẶT HÀNG NGAY <i class="bi bi-arrow-right ms-1"></i>
					</button>
					<small class="text-muted text-center d-block mt-2" style="font-size: 11px;">
						Bằng cách đặt hàng, bạn đồng ý với Điều khoản dịch vụ của Điện Máy Shop.
					</small>
				</div>
			</div>

		</div>
	</form>

</div>

<jsp:include page="fragments/footer.jsp" />

<style>
.cursor-pointer { cursor: pointer; }
.active-payment {
	border-color: #0d6efd !important;
	background-color: #f8f9ff;
}
</style>

<script>
(() => {
    const contextPath = '${pageContext.request.contextPath}';

    const codeInput = document.getElementById('voucherCodeInput');
    const hiddenCode = document.getElementById('hiddenVoucherCode');
    const addressInput = document.getElementById('shippingAddress');
    const provinceInput = document.getElementById('shippingProvince');
    const wardInput = document.getElementById('shippingWard');
    const spinner = document.getElementById('wardLoadingSpinner');

    const voucherMsg = document.getElementById('voucherMsg');
    const shippingMsg = document.getElementById('shippingQuoteMessage');
    const feeDisplay = document.getElementById('shippingFeeDisplay');
    const discountDisplay = document.getElementById('discountAmountDisplay');
    const discountRow = document.getElementById('discountRow');
    const finalDisplay = document.getElementById('finalAmountDisplay');

    const form = hiddenCode.closest('form');
    const submitButton = form.querySelector('button[type="submit"]');

    let timer;
    let version = 0;
    let validSnapshot = null;

    const PROVINCE_CODES = {
        "Thành phố Hồ Chí Minh": 79,
        "Hà Nội": 1
    };

    const wardCache = {};

    const fallbackWards = {
        "Thành phố Hồ Chí Minh": [
            "Phường Bến Nghé (Quận 1)", "Phường Bến Thành (Quận 1)", "Phường Đa Kao (Quận 1)", "Phường Tân Định (Quận 1)",
            "Phường Võ Thị Sáu (Quận 3)", "Phường 1 (Quận 3)", "Phường 2 (Quận 3)", "Phường 12 (Quận 10)", "Phường 14 (Quận 10)",
            "Phường 1 (Quận Bình Thạnh)", "Phường 2 (Quận Bình Thạnh)", "Phường 15 (Quận Bình Thạnh)", "Phường 25 (Quận Bình Thạnh)",
            "Phường Linh Chiểu (TP. Thủ Đức)", "Phường Hiệp Phú (TP. Thủ Đức)", "Phường Thảo Điền (TP. Thủ Đức)", "Phường An Phú (TP. Thủ Đức)",
            "Phường Tân Phú (Quận 7)", "Phường Tân Hưng (Quận 7)", "Phường 1 (Quận Gò Vấp)", "Phường 5 (Quận Gò Vấp)"
        ],
        "Hà Nội": [
            "Phường Tràng Tiền (Quận Hoàn Kiếm)", "Phường Hàng Bạc (Quận Hoàn Kiếm)", "Phường Hàng Đào (Quận Hoàn Kiếm)", "Phường Đồng Xuân (Quận Hoàn Kiếm)",
            "Phường Điện Biên (Quận Ba Đình)", "Phường Kim Mã (Quận Ba Đình)", "Phường Cống Vị (Quận Ba Đình)",
            "Phường Dịch Vọng (Quận Cầu Giấy)", "Phường Dịch Vọng Hậu (Quận Cầu Giấy)", "Phường Trung Hòa (Quận Cầu Giấy)",
            "Phường Bách Khoa (Quận Hai Bà Trưng)", "Phường Đồng Tâm (Quận Hai Bà Trưng)",
            "Phường Khương Mai (Quận Thanh Xuân)", "Phường Nhân Chính (Quận Thanh Xuân)",
            "Phường Mỹ Đình 1 (Quận Nam Từ Liêm)", "Phường Mỹ Đình 2 (Quận Nam Từ Liêm)",
            "Phường Láng Thượng (Quận Đống Đa)", "Phường Ô Chợ Dừa (Quận Đống Đa)"
        ]
    };

    async function loadWardsFromApi(provinceName, selectedWard) {
        if (!provinceName) {
            wardInput.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';
            return;
        }

        if (spinner) spinner.classList.remove('d-none');
        wardInput.innerHTML = '<option value="">-- Đang tải danh sách phường/xã... --</option>';

        let wards = wardCache[provinceName];

        if (!wards) {
            const code = PROVINCE_CODES[provinceName];
            if (code) {
                try {
                    const res = await fetch('https://provinces.open-api.vn/api/p/' + code + '?depth=3');
                    if (res.ok) {
                        const data = await res.json();
                        const list = [];
                        if (data.districts) {
                            data.districts.forEach(d => {
                                if (d.wards) {
                                    d.wards.forEach(w => {
                                        list.push(w.name + ' (' + d.name + ')');
                                    });
                                }
                            });
                        }
                        list.sort((a, b) => a.localeCompare(b, 'vi'));
                        wards = list;
                        wardCache[provinceName] = wards;
                    }
                } catch (e) {
                    console.warn('API ngoài không phản hồi, chuyển sang dữ liệu dự phòng:', e);
                }
            }
        }

        if (!wards || wards.length === 0) {
            wards = fallbackWards[provinceName] || [];
        }

        if (spinner) spinner.classList.add('d-none');
        wardInput.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';

        wards.forEach(w => {
            const opt = document.createElement('option');
            opt.value = w;
            opt.textContent = w;
            if (selectedWard && selectedWard === w) {
                opt.selected = true;
            }
            wardInput.appendChild(opt);
        });
    }

    window.onProvinceSelectChange = async () => {
        await loadWardsFromApi(provinceInput.value, '');
        scheduleQuote();
    };

    const money = value => Number(value || 0).toLocaleString('vi-VN') + ' ₫';

    function payload() {
        return {
            code: codeInput.value.trim().toUpperCase(),
            shippingAddress: [
                addressInput.value.trim(),
                wardInput.value.trim()
            ].filter(Boolean).join(', '),
            province: provinceInput.value.trim(),
            paymentMethod: form.querySelector('input[name="paymentMethod"]:checked')?.value || ''
        };
    }

    function resetPrice() {
        hiddenCode.value = '';
        validSnapshot = null;
        discountDisplay.textContent = '-0 ₫';
        discountRow.style.setProperty('display', 'none', 'important');
        feeDisplay.textContent = 'Chưa xác nhận';
        finalDisplay.textContent = 'Đang cập nhật';
        voucherMsg.textContent = '';
        shippingMsg.textContent = '';
        submitButton.disabled = true;
    }

    async function calculate(requestVersion) {
        const request = payload();

        if (!addressInput.value.trim() || !wardInput.value.trim() || !request.province) {
            if (requestVersion !== version) return;
            feeDisplay.textContent = 'Nhập địa chỉ để tính phí';
            finalDisplay.textContent = 'Chưa xác định';
            return;
        }

        const snapshot = JSON.stringify(request);
        feeDisplay.textContent = 'Đang tính...';

        try {
            const response = await csrfFetch(
                contextPath + '/api/checkout/apply-voucher',
                {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: snapshot
                }
            );

            const result = await response.json();
            if (requestVersion !== version) return;

            if (!response.ok || !result.success || !result.data?.valid) {
                throw new Error(result.message || 'Chưa áp dụng được voucher.');
            }

            const data = result.data;
            const discount = Number(data.discountAmount || 0);

            hiddenCode.value = data.code || '';
            feeDisplay.textContent = money(data.shippingFee);
            finalDisplay.textContent = money(data.newFinalAmount);

            discountDisplay.textContent = '-' + money(discount);
            discountRow.style.setProperty('display', discount > 0 ? 'flex' : 'none', 'important');

            voucherMsg.className = 'small mt-1 text-success';
            voucherMsg.textContent = request.code ? result.message : '';

            validSnapshot = snapshot;
            submitButton.disabled = false;

        } catch (error) {
            if (requestVersion !== version) return;
            resetPrice();
            voucherMsg.className = 'small mt-1 text-danger';
            voucherMsg.textContent = error.message || 'Không kết nối được máy chủ.';
            finalDisplay.textContent = 'Chưa xác định';
        }
    }

    function scheduleQuote(delay = 400) {
        clearTimeout(timer);
        const requestVersion = ++version;
        resetPrice();
        timer = setTimeout(() => calculate(requestVersion), delay);
    }

    window.applyVoucher = () => scheduleQuote(0);

    window.onSelectSavedAddress = async select => {
        const option = select.options[select.selectedIndex];
        if (!select.value) return;

        document.getElementById('recipientName').value = option.dataset.name || '';
        document.getElementById('recipientPhone').value = option.dataset.phone || '';
        addressInput.value = option.dataset.detail || option.dataset.addr || '';

        const prov = option.dataset.province || '';
        provinceInput.value = prov;

        const savedWard = option.dataset.ward || '';
        await loadWardsFromApi(prov, savedWard);

        scheduleQuote();
    };

    addressInput.addEventListener('input', () => scheduleQuote());
    wardInput.addEventListener('change', () => scheduleQuote());
    provinceInput.addEventListener('change', () => scheduleQuote());
    codeInput.addEventListener('input', () => scheduleQuote());

    form.querySelectorAll('input[name="paymentMethod"]').forEach(radio => {
        radio.addEventListener('change', () => {
            form.querySelectorAll('.payment-option').forEach(option => option.classList.remove('active-payment'));
            radio.closest('.payment-option')?.classList.add('active-payment');
            scheduleQuote();
        });
    });

    form.addEventListener('submit', event => {
        if (!validSnapshot || validSnapshot !== JSON.stringify(payload())) {
            event.preventDefault();
            scheduleQuote(0);
        }
    });

    document.addEventListener('DOMContentLoaded', async () => {
        const initialProvince = provinceInput.value;
        const initialWard = "${fn:escapeXml(orderForm.ward)}";
        if (initialProvince) {
            await loadWardsFromApi(initialProvince, initialWard);
        }
        scheduleQuote(0);
    });
})();
</script>