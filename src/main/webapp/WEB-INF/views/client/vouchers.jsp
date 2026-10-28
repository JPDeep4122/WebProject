<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>


<jsp:include page="fragments/header.jsp" />

<style>
.voucher-page-bg {
	background-color: #f4f6f8;
	min-height: calc(100vh - 250px);
}

.voucher-banner {
	background: linear-gradient(135deg, #0b66c3 0%, #003e82 100%);
	color: #ffffff;
	border-radius: 20px;
	padding: 35px 30px;
}

.voucher-ticket {
	display: flex;
	background: #ffffff;
	border-radius: 16px;
	box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
	position: relative;
	border: 1px solid #e2e8f0;
	overflow: hidden;
	transition: all 0.25s ease;
	height: 100%;
}

.voucher-ticket:hover {
	transform: translateY(-4px);
	box-shadow: 0 10px 24px rgba(11, 102, 195, 0.12);
	border-color: #93c5fd;
}

.voucher-ticket::before, .voucher-ticket::after {
	content: '';
	position: absolute;
	width: 20px;
	height: 20px;
	background-color: #f4f6f8;
	border-radius: 50%;
	left: 110px;
	z-index: 2;
	border: 1px solid #e2e8f0;
}

.voucher-ticket::before {
	top: -11px;
}

.voucher-ticket::after {
	bottom: -11px;
}

/* Cột trái của vé */
.voucher-left {
	width: 120px;
	min-width: 120px;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 16px 8px;
	color: #ffffff;
	text-align: center;
}

.bg-voucher-blue {
	background: linear-gradient(135deg, #0b66c3, #0284c7);
}

.bg-voucher-orange {
	background: linear-gradient(135deg, #ea580c, #f97316);
}

.bg-voucher-green {
	background: linear-gradient(135deg, #16a34a, #22c55e);
}

.bg-voucher-purple {
	background: linear-gradient(135deg, #9333ea, #a855f7);
}

/* Cột phải của vé */
.voucher-right {
	padding: 16px 18px 16px 24px;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	flex-grow: 1;
}

.voucher-code-badge {
	background-color: #f1f5f9;
	color: #0b66c3;
	font-weight: 700;
	letter-spacing: 0.5px;
	padding: 4px 10px;
	border-radius: 6px;
	border: 1px dashed #0b66c3;
	font-size: 0.85rem;
}

.btn-copy-code {
	border-radius: 50px;
	font-size: 0.82rem;
	font-weight: 600;
	padding: 6px 16px;
}
</style>


<div class="voucher-page-bg py-4">
	<div class="container">

		
		<div
			class="voucher-banner mb-4 shadow-sm position-relative overflow-hidden">
			<div class="row align-items-center">
				<div class="col-md-8">
					<span
						class="badge bg-warning text-dark px-3 py-1 rounded-pill fw-bold mb-2">
						<i class="bi bi-gift-fill me-1"></i> TRUNG TÂM KHUYẾN MÃI
					</span>
					<h2 class="fw-bold mb-2">Kho Voucher & Mã Giảm Giá Độc Quyền</h2>
					<p class="mb-0 text-white-50">Thu thập mã giảm giá để mua sắm
						điện máy chính hãng với giá tốt nhất mỗi ngày!</p>
				</div>
				<div class="col-md-4 text-md-end d-none d-md-block">
					<i
						class="bi bi-ticket-perforated-fill display-1 text-white-50 opacity-50"></i>
				</div>
			</div>
		</div>

		
		<div
			class="d-flex align-items-center justify-content-between mb-4 overflow-x-auto text-nowrap pb-2">
			<ul class="nav nav-pills gap-2" id="voucherFilterTabs">
				<li class="nav-item">
					<button class="nav-link active rounded-pill px-4 fw-bold"
						onclick="filterVouchers('all', this)">Tất cả mã</button>
				</li>
				<li class="nav-item">
					<button type="button"
        class="nav-link rounded-pill px-4 fw-bold"
        onclick="filterVouchers('ship', this)">
    Ưu đãi phí vận chuyển
</button>
				</li>
				<li class="nav-item">
					<button class="nav-link rounded-pill px-4 fw-bold"
						onclick="filterVouchers('order', this)">Giảm giá đơn hàng</button>
				</li>
				<li class="nav-item">
					<button class="nav-link rounded-pill px-4 fw-bold"
						onclick="filterVouchers('payment', this)">Thanh toán
						VNPAY</button>
				</li>
			</ul>
			<span class="text-muted small d-none d-lg-inline"><i
				class="bi bi-info-circle me-1"></i>Mỗi đơn hàng chỉ áp dụng tối đa 1
				mã</span>
		</div>

		
		<c:if test="${empty vouchers}">
			<div class="col-12">
				<div class="alert alert-info">Hiện chưa có voucher khả dụng.</div>
			</div>
		</c:if>

		<c:forEach items="${vouchers}" var="p">
			<div class="col-lg-6 voucher-card-item"
				data-type="${p.requiredPaymentMethod == 'VNPAY'
             ? 'payment'
             : (p.discountType == 'SHIPPING' ? 'ship' : 'order')}">

				<div class="voucher-ticket">
					<div class="voucher-left bg-voucher-blue">
						<i class="bi bi-ticket-perforated fs-2"></i> <strong class="mt-2">
							<c:choose>
								<c:when test="${p.discountType == 'PERCENT'}">
                            GIẢM ${p.discountPercent}%
                        </c:when>
								<c:when test="${p.discountType == 'FIXED'}">
                            GIẢM
                            <fmt:formatNumber
										value="${p.discountAmount}" />đ
                        </c:when>
								<c:otherwise>GIẢM PHÍ SHIP</c:otherwise>
							</c:choose>
						</strong>
					</div>

					<div class="voucher-right">
						<h6 class="fw-bold">
							<c:out value="${p.name}" />
						</h6>

						<div class="small text-muted mb-2">
							<div>
								Tiền sản phẩm đủ điều kiện từ
								<fmt:formatNumber value="${p.minOrderAmount}" />
								đ.
							</div>

							<c:if test="${not empty p.maxDiscountAmount}">
								<div>
									Giảm tối đa
									<fmt:formatNumber value="${p.maxDiscountAmount}" />
									đ.
								</div>
							</c:if>

							<c:if test="${p.discountType == 'SHIPPING'}">
								<div>Giảm theo phí vận chuyển thực tế.</div>
							</c:if>

							<c:if test="${not empty p.requiredPaymentMethod}">
								<div>Thanh toán: ${p.requiredPaymentMethod}.</div>
							</c:if>

							<c:if test="${p.newCustomerOnly}">
								<div>Chỉ áp dụng cho khách mới.</div>
							</c:if>

							<c:if test="${not empty p.perUserLimit}">
								<div>Tối đa ${p.perUserLimit} lượt mỗi khách.</div>
							</c:if>

							<c:choose>
								<c:when test="${empty p.categories}">
									<div>Áp dụng mọi danh mục.</div>
								</c:when>
								<c:otherwise>
									<div>
										Danh mục:
										<c:forEach items="${p.categories}" var="cat">
											<span class="badge bg-light text-dark"> <c:out
													value="${cat.name}" />
											</span>
										</c:forEach>
									</div>
								</c:otherwise>
							</c:choose>

							<c:if test="${not empty p.endsAt}">
								<div>Hết hạn: ${p.endsAt} — giờ Việt Nam.</div>
							</c:if>
						</div>

						<div class="d-flex justify-content-between align-items-center">
							<code>
								<c:out value="${p.code}" />
							</code>

							<button type="button"
        class="btn btn-outline-primary"
        data-code="<c:out value='${p.code}'/>"
        onclick="copyCode(this.dataset.code, this)">
    Sao chép mã
</button>
						</div>
					</div>
				</div>
			</div>
		</c:forEach>

		
		<div class="card border-0 rounded-4 shadow-sm p-4 mt-5 bg-white">
			<h5 class="fw-bold mb-3 text-dark">
				<i class="bi bi-lightbulb-fill text-warning me-2"></i>Hướng dẫn 3
				bước sử dụng mã giảm giá
			</h5>
			<div class="row g-3 text-center">
				<div class="col-md-4">
					<div class="p-3 rounded-3 bg-light h-100">
						<span class="badge bg-primary rounded-circle mb-2 fs-6">1</span>
						<h6 class="fw-bold">Sao chép mã</h6>
						<p class="text-muted small mb-0">Chọn mã ưu đãi phù hợp ở
							trang này và nhấn nút "Sao chép mã".</p>
					</div>
				</div>
				<div class="col-md-4">
					<div class="p-3 rounded-3 bg-light h-100">
						<span class="badge bg-primary rounded-circle mb-2 fs-6">2</span>
						<h6 class="fw-bold">Chọn mua sản phẩm</h6>
						<p class="text-muted small mb-0">Thêm sản phẩm điện máy bạn
							yêu thích vào giỏ hàng và tiến hành Đặt hàng.</p>
					</div>
				</div>
				<div class="col-md-4">
					<div class="p-3 rounded-3 bg-light h-100">
						<span class="badge bg-primary rounded-circle mb-2 fs-6">3</span>
						<h6 class="fw-bold">Áp dụng & Nhận giảm giá</h6>
						<p class="text-muted small mb-0">Tại màn hình Thanh toán
							(Checkout), dán mã vào ô "Mã giảm giá" và bấm Áp dụng.</p>
					</div>
				</div>
			</div>
		</div>

	</div>
</div>

<script>
    
    function copyCode(code, btnElement) {
        const btn = btnElement || (window.event ? window.event.currentTarget : null);
        
        navigator.clipboard.writeText(code).then(() => {
            if (btn) {
                const originalHtml = btn.innerHTML;
                const originalClasses = btn.className;
                btn.className = "btn btn-success btn-copy-code text-white";
                btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Sao chép thành công';
                btn.disabled = true; 
                setTimeout(() => {
                    btn.className = originalClasses;
                    btn.innerHTML = originalHtml;
                    btn.disabled = false;
                }, 1000);
            }
        });
    }
    
    function filterVouchers(type, btnElement) {
        
        document.querySelectorAll('#voucherFilterTabs .nav-link').forEach(btn => btn.classList.remove('active'));
        btnElement.classList.add('active');

        
        const items = document.querySelectorAll('.voucher-card-item');
        items.forEach(item => {
            if (type === 'all' || item.getAttribute('data-type') === type) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }
</script>

<jsp:include page="fragments/footer.jsp" />