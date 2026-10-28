<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="fragments/header.jsp" />
<style>
.voucher-page{background:#f4f6f8;min-height:70vh;padding:28px 0 44px}
.voucher-page .voucher-banner{background:linear-gradient(135deg,#0b66c3,#003e82);color:#fff;border-radius:20px;padding:32px;box-shadow:0 6px 20px #003e8214}
.voucher-page .voucher-banner h1{font-size:clamp(1.5rem,3vw,2rem);font-weight:750}
.voucher-page .voucher-banner p{color:#d5e8ff;max-width:660px}
.voucher-page .voucher-tabs{display:flex;flex-wrap:wrap;gap:8px;margin:24px 0 12px}
.voucher-page .voucher-tab{border:1px solid transparent;border-radius:999px;padding:10px 17px;background:transparent;color:#0b66c3;font-weight:650;white-space:nowrap}
.voucher-page .voucher-tab:hover{background:#e3efff}
.voucher-page .voucher-tab.active{background:#0d6efd;color:#fff}
.voucher-page .voucher-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}
.voucher-page .voucher-card-item{min-width:0}
.voucher-page .voucher-card-item[hidden]{display:none!important}
.voucher-page .voucher-ticket{--stub:126px;display:flex;position:relative;min-height:240px;height:100%;background:#fff;border:1px solid #e2e8f0;border-radius:17px;overflow:hidden;box-shadow:0 4px 16px #0f172a08;transition:transform .2s,box-shadow .2s}
.voucher-page .voucher-ticket:hover{transform:translateY(-3px);box-shadow:0 10px 24px #0b66c31c}
.voucher-page .voucher-ticket:before,.voucher-page .voucher-ticket:after{content:"";position:absolute;left:calc(var(--stub) - 10px);width:20px;height:20px;border-radius:50%;background:#f4f6f8;border:1px solid #e2e8f0;z-index:1}
.voucher-page .voucher-ticket:before{top:-11px}.voucher-page .voucher-ticket:after{bottom:-11px}
.voucher-page .voucher-left{flex:0 0 var(--stub);width:var(--stub);display:flex;flex-direction:column;justify-content:center;align-items:center;padding:22px 10px;color:#fff;text-align:center;gap:12px}
.voucher-page .voucher-left>i{font-size:2.2rem}.voucher-page .voucher-left strong{font-size:1.06rem;overflow-wrap:anywhere;line-height:1.5}.voucher-page .voucher-left small{font-size:.7rem;opacity:.9}
.voucher-page .voucher-shipping{background:linear-gradient(145deg,#087f5b,#22a06b)}
.voucher-page .voucher-percent{background:linear-gradient(145deg,#0b66c3,#0284c7)}
.voucher-page .voucher-fixed{background:linear-gradient(145deg,#c2410c,#f97316)}
.voucher-page .voucher-right{min-width:0;flex:1;padding:20px;display:flex;flex-direction:column;gap:12px}
.voucher-page .voucher-title{font-size:1rem;line-height:1.5;font-weight:700;margin:0}
.voucher-page .voucher-conditions{color:#64748b;font-size:.84rem;line-height:1.65;display:grid;gap:4px}
.voucher-page .voucher-footer{display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:10px;margin-top:auto;padding-top:12px;border-top:1px dashed #e2e8f0}
.voucher-page .voucher-code{color:#0b66c3;background:#eff6ff;border:1px dashed #93c5fd;border-radius:7px;padding:5px 9px;font-weight:750;overflow-wrap:anywhere}
.voucher-page .voucher-copy{font-size:.82rem;border-radius:999px}
.voucher-page .voucher-guide{background:#fff;border:1px solid #e2e8f0;border-radius:18px;padding:24px;margin-top:32px}
@media(max-width:850px){.voucher-page .voucher-grid{grid-template-columns:minmax(0,1fr)}}
@media(max-width:480px){.voucher-page .voucher-banner{padding:24px}.voucher-page .voucher-ticket{--stub:96px}.voucher-page .voucher-right{padding:16px 13px}.voucher-page .voucher-left strong{font-size:.9rem}.voucher-page .voucher-tab{font-size:.85rem;padding:9px 12px}}
</style>
<main class="voucher-page">
<div class="container">
    <div class="voucher-banner d-flex align-items-center justify-content-between gap-3">
        <div>
            <span class="badge bg-warning text-dark rounded-pill mb-3 px-3 py-2"><i class="bi bi-gift-fill me-1"></i> TRUNG TÂM KHUYẾN MÃI</span>
            <h1>Kho Voucher &amp; Mã Giảm Giá Độc Quyền</h1>
            <p class="mb-0">Chọn ưu đãi phí vận chuyển, giảm phần trăm hoặc giảm trực tiếp để mua sắm tại TECHSEVEN.</p>
        </div>
        <i class="bi bi-ticket-perforated-fill display-1 d-none d-md-block opacity-50" aria-hidden="true"></i>
    </div>
    <div class="voucher-tabs" id="voucherFilterTabs" aria-label="Loại voucher">
        <button type="button" class="voucher-tab active" data-filter="all" aria-pressed="true"><i class="bi bi-grid me-1"></i>Tất cả mã</button>
        <button type="button" class="voucher-tab" data-filter="SHIPPING" aria-pressed="false"><i class="bi bi-truck me-1"></i>Phí vận chuyển</button>
        <button type="button" class="voucher-tab" data-filter="PERCENT" aria-pressed="false"><i class="bi bi-percent me-1"></i>Giảm phần trăm</button>
        <button type="button" class="voucher-tab" data-filter="FIXED" aria-pressed="false"><i class="bi bi-cash-coin me-1"></i>Giảm tiền trực tiếp</button>
        <button type="button" class="voucher-tab" data-filter="VNPAY" aria-pressed="false"><i class="bi bi-qr-code-scan me-1"></i>Thanh toán VNPay</button>
    </div>
    <div class="d-flex flex-wrap justify-content-between gap-2 text-muted small mb-3">
        <span id="voucherVisibleCount" role="status"></span>
        <span><i class="bi bi-info-circle me-1"></i>Mỗi đơn hàng áp dụng tối đa 1 mã</span>
    </div>
    <div class="voucher-grid" id="voucherGrid">
    <c:forEach items="${vouchers}" var="p">
        <c:set var="shipping" value="${p.discountType == 'SHIPPING'}" />
        <c:set var="percent" value="${p.discountType == 'PERCENT'}" />
        <article class="voucher-card-item" data-type="${p.discountType}" data-payment="${p.requiredPaymentMethod}">
            <div class="voucher-ticket">
                <div class="voucher-left ${shipping ? 'voucher-shipping' : (percent ? 'voucher-percent' : 'voucher-fixed')}">
                    <i class="bi ${shipping ? 'bi-truck' : (percent ? 'bi-percent' : 'bi-cash-coin')}" aria-hidden="true"></i>
                    <strong><c:out value="${p.benefitLabel}" /></strong>
                    <small>${shipping ? 'VẬN CHUYỂN' : (percent ? 'PHẦN TRĂM' : 'GIẢM TRỰC TIẾP')}</small>
                </div>
                <div class="voucher-right">
                    <div>
                        <h2 class="voucher-title"><c:out value="${p.name}" /></h2>
                        <c:if test="${not empty p.requiredPaymentMethod}">
                            <span class="badge bg-primary-subtle text-primary mt-2"><i class="bi ${p.requiredPaymentMethod == 'VNPAY' ? 'bi-qr-code-scan' : 'bi-cash'} me-1"></i>Chỉ thanh toán ${p.requiredPaymentMethod == 'VNPAY' ? 'VNPay' : 'COD'}</span>
                        </c:if>
                    </div>
                    <div class="voucher-conditions">
                        <c:choose>
                            <c:when test="${p.minOrderAmount gt 0}"><div>Từ <strong><c:out value="${p.minOrderAmountDisplay}" /></strong> tiền sản phẩm đủ điều kiện.</div></c:when>
                            <c:otherwise><div>Không yêu cầu giá trị đơn tối thiểu.</div></c:otherwise>
                        </c:choose>
                        <c:if test="${not empty p.maxDiscountAmount}"><div>Giảm tối đa <strong><c:out value="${p.maxDiscountAmountDisplay}" /></strong>.</div></c:if>
                        <c:if test="${shipping}"><div>Áp dụng trên phí vận chuyển thực tế.</div></c:if>
                        <c:if test="${p.newCustomerOnly}"><div><i class="bi bi-person-plus me-1"></i>Dành cho khách chưa có đơn mua hàng.</div></c:if>
                        <c:if test="${not empty p.perUserLimit}"><div>Tối đa ${p.perUserLimit} lượt mỗi khách.</div></c:if>
                        <c:choose>
                            <c:when test="${empty p.categories}"><div>Áp dụng mọi danh mục.</div></c:when>
                            <c:otherwise><div>Danh mục: <c:forEach items="${p.categories}" var="cat" varStatus="status"><c:if test="${not status.first}">, </c:if><c:out value="${cat.name}" /></c:forEach></div></c:otherwise>
                        </c:choose>
                        <div><i class="bi bi-clock me-1"></i><c:choose><c:when test="${not empty p.endsAt}">Hết hạn: <c:out value="${p.endsAtDisplay}" /> (giờ VN)</c:when><c:otherwise>Không giới hạn thời gian</c:otherwise></c:choose></div>
                    </div>
                    <div class="voucher-footer">
                        <code class="voucher-code"><c:out value="${p.code}" /></code>
                        <button type="button" class="btn btn-outline-primary voucher-copy" data-copy-code="<c:out value='${p.code}'/>"><i class="bi bi-copy me-1"></i>Sao chép mã</button>
                    </div>
                </div>
            </div>
        </article>
    </c:forEach>
    </div>
    <p id="voucherEmptyState" class="alert alert-info mt-3" hidden>Chưa có voucher khả dụng thuộc nhóm này.</p>
    <p id="voucherCopyStatus" class="small text-muted mt-3" role="status" aria-live="polite"></p>
    <div class="voucher-guide">
        <h2 class="h5 fw-bold mb-3"><i class="bi bi-lightbulb-fill text-warning me-2"></i>Ba bước sử dụng voucher</h2>
        <div class="row g-3">
            <div class="col-md-4"><strong>1. Chọn ưu đãi</strong><p class="small text-muted mb-0 mt-2">Đọc điều kiện và sao chép mã phù hợp.</p></div>
            <div class="col-md-4"><strong>2. Chọn sản phẩm</strong><p class="small text-muted mb-0 mt-2">Thêm vào giỏ hoặc chọn Mua ngay để đến thanh toán.</p></div>
            <div class="col-md-4"><strong>3. Áp dụng mã</strong><p class="small text-muted mb-0 mt-2">Nhập mã tại thanh toán để kiểm tra ưu đãi cho đơn của bạn.</p></div>
        </div>
    </div>
</div>
</main>
<script src="${pageContext.request.contextPath}/js/vouchers.js"></script>
<jsp:include page="fragments/footer.jsp" />
