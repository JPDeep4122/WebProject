<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="fragments/header.jsp" />

<style>
.voucher-page {
    background: #f1f5f9;
    min-height: 75vh;
    padding: 28px 0 56px;
}

/* HERO BANNER KHO VOUCHER */
.voucher-page .voucher-banner {
    position: relative;
    overflow: hidden;
    background: linear-gradient(125deg, #003da6 0%, #0046be 55%, #0284c7 100%);
    color: #fff;
    border-radius: 22px;
    padding: 36px 40px;
    box-shadow: 0 14px 34px rgba(0, 70, 190, 0.18);
}

.voucher-page .voucher-banner::after {
    content: "";
    position: absolute;
    right: -60px;
    top: -60px;
    width: 260px;
    height: 260px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(255, 224, 0, 0.28) 0%, transparent 70%);
    pointer-events: none;
}

.voucher-page .voucher-banner-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #ffe000;
    color: #0f172a;
    font-size: 0.78rem;
    font-weight: 800;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    padding: 6px 14px;
    border-radius: 999px;
    margin-bottom: 14px;
}

.voucher-page .voucher-banner h1 {
    font-size: clamp(1.6rem, 2.8vw, 2.2rem);
    font-weight: 800;
    letter-spacing: -0.02em;
    margin-bottom: 8px;
}

.voucher-page .voucher-banner p {
    color: #dbeafe;
    max-width: 640px;
    font-size: 0.96rem;
}

/* TABS BỘ LỌC LOẠI VOUCHER */
.voucher-page .voucher-tabs {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin: 26px 0 16px;
}

.voucher-page .voucher-tab {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    border: 1px solid #cbd5e1;
    border-radius: 999px;
    padding: 10px 18px;
    background: #ffffff;
    color: #334155;
    font-size: 0.9rem;
    font-weight: 700;
    white-space: nowrap;
    transition: all 0.18s ease;
}

.voucher-page .voucher-tab:hover {
    border-color: #0046be;
    color: #0046be;
    background: #eff6ff;
}

.voucher-page .voucher-tab.active {
    background: #0046be;
    border-color: #0046be;
    color: #ffffff;
    box-shadow: 0 6px 16px rgba(0, 70, 190, 0.22);
}

/* LƯỚI THẺ VOUCHER */
.voucher-page .voucher-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
}

.voucher-page .voucher-card-item {
    min-width: 0;
    container-type: inline-size;
}

.voucher-page .voucher-card-item[hidden] {
    display: none !important;
}

/* THẺ VÉ VOUCHER CHUẨN SHOPEE MALL x BEST BUY */
.voucher-page .voucher-ticket {
    --stub: 148px;
    display: flex;
    position: relative;
    min-height: 210px;
    height: 100%;
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 4px 14px rgba(15, 23, 42, 0.05);
    transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.voucher-page .voucher-ticket:hover {
    transform: translateY(-3px);
    border-color: #93c5fd;
    box-shadow: 0 12px 28px rgba(0, 70, 190, 0.12);
}

/* 2 Khuyết tròn trên/dưới ngay đường cắt vé */
.voucher-page .voucher-ticket::before,
.voucher-page .voucher-ticket::after {
    content: "";
    position: absolute;
    left: calc(var(--stub) - 11px);
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: #f1f5f9;
    border: 1px solid #e2e8f0;
    z-index: 3;
}

.voucher-page .voucher-ticket::before {
    top: -12px;
}

.voucher-page .voucher-ticket::after {
    bottom: -12px;
}

/* CUỐNG VÉ BÊN TRÁI (GRAPHIC STUB) */
.voucher-page .voucher-left {
    position: relative;
    flex: 0 0 var(--stub);
    width: var(--stub);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 18px 12px;
    color: #ffffff;
    text-align: center;
    gap: 8px;
    border-right: 2px dashed rgba(255, 255, 255, 0.45);
    overflow: hidden;
}

/* Họa tiết răng cưa dọc mép trái của cuống vé */
.voucher-page .voucher-left::before {
    content: "";
    position: absolute;
    left: -6px;
    top: 12px;
    bottom: 12px;
    width: 12px;
    background-image: radial-gradient(circle, #f1f5f9 4px, transparent 5px);
    background-size: 12px 18px;
    background-repeat: repeat-y;
    z-index: 2;
}

/* Vòng sáng trang trí nền cuống vé */
.voucher-page .voucher-left::after {
    content: "";
    position: absolute;
    width: 130px;
    height: 130px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.22) 0%, transparent 70%);
    top: -25px;
    right: -25px;
    pointer-events: none;
}

.voucher-page .voucher-stub-brand {
    font-size: 0.63rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 3px 8px;
    border-radius: 999px;
    background: rgba(0, 0, 0, 0.18);
    color: #ffffff;
}

/* Huy hiệu Icon trung tâm cuống vé */
.voucher-page .voucher-emblem {
    position: relative;
    width: 54px;
    height: 54px;
    border-radius: 16px;
    display: grid;
    place-items: center;
    background: rgba(255, 255, 255, 0.18);
    border: 1.5px solid rgba(255, 255, 255, 0.4);
    box-shadow: 0 6px 14px rgba(0, 0, 0, 0.12), inset 0 1px 1px rgba(255, 255, 255, 0.4);
    backdrop-filter: blur(4px);
}

.voucher-page .voucher-emblem > i {
    font-size: 1.65rem;
    color: #ffffff;
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.15));
}

.voucher-page .voucher-left strong {
    font-size: 1.05rem;
    font-weight: 800;
    letter-spacing: -0.01em;
    line-height: 1.25;
    overflow-wrap: anywhere;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
}

.voucher-page .voucher-stub-tag {
    font-size: 0.68rem;
    font-weight: 700;
    letter-spacing: 0.04em;
    padding: 2px 9px;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.92);
}

/* 3 Tông màu cuống vé đặc trưng như Shopee / Best Buy */
.voucher-page .voucher-shipping {
    background: linear-gradient(155deg, #008b68 0%, #0d9488 55%, #14b8a6 100%);
}
.voucher-page .voucher-shipping .voucher-stub-tag {
    color: #0f766e;
}

.voucher-page .voucher-percent {
    background: linear-gradient(155deg, #003da6 0%, #0055d4 55%, #2563eb 100%);
}
.voucher-page .voucher-percent .voucher-stub-tag {
    color: #0046be;
}

.voucher-page .voucher-fixed {
    background: linear-gradient(155deg, #ea580c 0%, #f97316 55%, #fb923c 100%);
}
.voucher-page .voucher-fixed .voucher-stub-tag {
    color: #c2410c;
}

/* PHẦN NỘI DUNG VÉ BÊN PHẢI */
.voucher-page .voucher-right {
    min-width: 0;
    flex: 1;
    padding: 18px 20px;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.voucher-page .voucher-top-tags {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px;
}

.voucher-page .voucher-pill {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    font-size: 0.72rem;
    font-weight: 700;
    padding: 3px 9px;
    border-radius: 6px;
}

.voucher-page .voucher-pill-mall {
    background: #fee2e2;
    color: #dc2626;
}

.voucher-page .voucher-pill-vnpay {
    background: #dbeafe;
    color: #1d4ed8;
}

.voucher-page .voucher-pill-cod {
    background: #fef3c7;
    color: #b45309;
}

.voucher-page .voucher-pill-new {
    background: #dcfce7;
    color: #15803d;
}

.voucher-page .voucher-title {
    font-size: 1.02rem;
    line-height: 1.4;
    font-weight: 750;
    color: #0f172a;
    margin: 4px 0 0;
}

/* Danh sách điều kiện dạng chip + dòng ngắn gọn */
.voucher-page .voucher-conditions {
    color: #475569;
    font-size: 0.82rem;
    line-height: 1.55;
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.voucher-page .voucher-cond-row {
    display: flex;
    align-items: baseline;
    gap: 6px;
}

.voucher-page .voucher-cond-row i {
    color: #0046be;
    font-size: 0.78rem;
    flex-shrink: 0;
}

/* CHÂN VÉ: HỘP MÃ COUPON & NÚT SAO CHÉP */
.voucher-page .voucher-footer {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-top: auto;
    padding-top: 12px;
    border-top: 1px dashed #cbd5e1;
}

.voucher-page .voucher-meta-left {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.voucher-page .voucher-code-box {
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

.voucher-page .voucher-code-label {
    font-size: 0.72rem;
    color: #64748b;
    font-weight: 600;
}

.voucher-page .voucher-code {
    color: #0046be;
    background: #eff6ff;
    border: 1px dashed #60a5fa;
    border-radius: 6px;
    padding: 3px 9px;
    font-size: 0.82rem;
    font-weight: 800;
    letter-spacing: 0.03em;
}

.voucher-page .voucher-expiry {
    font-size: 0.75rem;
    color: #64748b;
}

.voucher-page .voucher-copy {
    font-size: 0.82rem;
    font-weight: 700;
    padding: 7px 16px;
    border-radius: 999px;
    background: #0046be;
    border-color: #0046be;
    color: #ffffff;
    box-shadow: 0 4px 10px rgba(0, 70, 190, 0.18);
    transition: all 0.15s ease;
}

.voucher-page .voucher-copy:hover {
    background: #003da6;
    border-color: #003da6;
    color: #ffffff;
}

.voucher-page .voucher-guide {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 18px;
    padding: 24px;
    margin-top: 32px;
}

@container (max-width: 440px) {
    .voucher-page .voucher-ticket {
        --stub: 112px;
    }
    .voucher-page .voucher-right {
        padding: 14px;
    }
    .voucher-page .voucher-left strong {
        font-size: 0.92rem;
    }
}

@media (max-width: 900px) {
    .voucher-page .voucher-grid {
        grid-template-columns: minmax(0, 1fr);
    }
}
</style>

<main class="voucher-page">
<div class="container">
    <!-- HERO BANNER -->
    <div class="voucher-banner d-flex align-items-center justify-content-between gap-4">
        <div>
            <span class="voucher-banner-badge">
                <i class="bi bi-lightning-charge-fill"></i> TECHSEVEN REWARDS &amp; COUPONS
            </span>
            <h1>Săn Mã Giảm Giá &amp; Ưu Đãi Độc Quyền</h1>
            <p class="mb-0">Lưu mã miễn phí vận chuyển, voucher giảm phần trăm và ưu đãi thanh toán VNPay áp dụng trực tiếp tại bước thanh toán.</p>
        </div>
        <i class="bi bi-ticket-perforated-fill display-1 d-none d-md-block opacity-25" aria-hidden="true"></i>
    </div>

    <!-- FILTER TABS -->
    <div class="voucher-tabs" id="voucherFilterTabs" aria-label="Loại voucher">
        <button type="button" class="voucher-tab active" data-filter="all" aria-pressed="true">
            <i class="bi bi-grid-fill"></i> Tất cả ưu đãi
        </button>
        <button type="button" class="voucher-tab" data-filter="SHIPPING" aria-pressed="false">
            <i class="bi bi-truck"></i> Miễn phí vận chuyển
        </button>
        <button type="button" class="voucher-tab" data-filter="PERCENT" aria-pressed="false">
            <i class="bi bi-percent"></i> Giảm theo %
        </button>
        <button type="button" class="voucher-tab" data-filter="FIXED" aria-pressed="false">
            <i class="bi bi-cash-stack"></i> Giảm trực tiếp
        </button>
        <button type="button" class="voucher-tab" data-filter="VNPAY" aria-pressed="false">
            <i class="bi bi-qr-code-scan"></i> Ưu đãi VNPay
        </button>
    </div>

    <div class="d-flex flex-wrap justify-content-between gap-2 text-muted small mb-3">
        <span id="voucherVisibleCount" class="fw-semibold text-dark" role="status"></span>
        <span><i class="bi bi-shield-check text-primary me-1"></i>Áp dụng ngay tại trang Giỏ hàng &amp; Thanh toán</span>
    </div>

    <!-- DANH SÁCH THẺ VOUCHER -->
    <div class="voucher-grid" id="voucherGrid">
    <c:forEach items="${vouchers}" var="p">
        <c:set var="shipping" value="${p.discountType == 'SHIPPING'}" />
        <c:set var="percent" value="${p.discountType == 'PERCENT'}" />
        <article class="voucher-card-item" data-type="${p.discountType}" data-payment="${p.requiredPaymentMethod}">
            <div class="voucher-ticket">
                <!-- CUỐNG VÉ ĐỒ HỌA BÊN TRÁI -->
                <div class="voucher-left ${shipping ? 'voucher-shipping' : (percent ? 'voucher-percent' : 'voucher-fixed')}">
                    <span class="voucher-stub-brand">
                        ${shipping ? 'FREESHIP XTRA' : 'TECHSEVEN'}
                    </span>
                    <div class="voucher-emblem" aria-hidden="true">
                        <i class="bi ${shipping ? 'bi-truck-front-fill' : (percent ? 'bi-patch-percent-fill' : 'bi-gift-fill')}"></i>
                    </div>
                    <strong><c:out value="${p.benefitLabel}" /></strong>
                    <span class="voucher-stub-tag">
                        ${shipping ? 'PHÍ GIAO HÀNG' : (percent ? 'ƯU ĐÃI %' : 'GIẢM TIỀN MẶT')}
                    </span>
                </div>

                <!-- THÂN VÉ BÊN PHẢI -->
                <div class="voucher-right">
                    <div>
                        <div class="voucher-top-tags">
                            <span class="voucher-pill voucher-pill-mall">
                                <i class="bi bi-patch-check-fill"></i> Chính hãng
                            </span>
                            <c:if test="${not empty p.requiredPaymentMethod}">
                                <span class="voucher-pill ${p.requiredPaymentMethod == 'VNPAY' ? 'voucher-pill-vnpay' : 'voucher-pill-cod'}">
                                    <i class="bi ${p.requiredPaymentMethod == 'VNPAY' ? 'bi-qr-code-scan' : 'bi-cash-coin'}"></i>
                                    Chỉ ${p.requiredPaymentMethod == 'VNPAY' ? 'VNPay' : 'COD'}
                                </span>
                            </c:if>
                            <c:if test="${p.newCustomerOnly}">
                                <span class="voucher-pill voucher-pill-new">
                                    <i class="bi bi-stars"></i> Khách mới
                                </span>
                            </c:if>
                        </div>
                        <h2 class="voucher-title"><c:out value="${p.displayName}" /></h2>
                    </div>

                    <div class="voucher-conditions">
                        <div class="voucher-cond-row">
                            <i class="bi bi-bag-check-fill"></i>
                            <span>
                                <c:choose>
                                    <c:when test="${p.minOrderAmount gt 0}">
                                        Đơn tối thiểu <strong><c:out value="${p.minOrderAmountDisplay}" /></strong>
                                    </c:when>
                                    <c:otherwise>Áp dụng cho mọi giá trị đơn hàng (Từ 0₫)</c:otherwise>
                                </c:choose>
                                <c:if test="${not empty p.maxDiscountAmount}">
                                    • Giảm tối đa <strong><c:out value="${p.maxDiscountAmountDisplay}" /></strong>
                                </c:if>
                            </span>
                        </div>

                        <div class="voucher-cond-row">
                            <i class="bi bi-grid-fill"></i>
                            <span>
                                <c:choose>
                                    <c:when test="${empty p.categories}">Áp dụng cho tất cả ngành hàng</c:when>
                                    <c:otherwise>
                                        Ngành hàng:
                                        <c:forEach items="${p.categories}" var="cat" varStatus="status">
                                            <c:if test="${not status.first}">, </c:if>
                                            <c:out value="${fn:replace(cat.name, '[TV08] ', '')}" />
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <c:if test="${not empty p.perUserLimit}">
                            <div class="voucher-cond-row">
                                <i class="bi bi-person-check-fill"></i>
                                <span>Tối đa ${p.perUserLimit} lượt sử dụng / khách hàng</span>
                            </div>
                        </c:if>
                    </div>

                    <!-- CHÂN VÉ: MÃ CODE + HSD (ĐÃ BỎ CHỮ GIỜ VN) + NÚT COPY -->
                    <div class="voucher-footer">
                        <div class="voucher-meta-left">
                            <div class="voucher-code-box">
                                <span class="voucher-code-label">Mã:</span>
                                <code class="voucher-code"><c:out value="${p.code}" /></code>
                            </div>
                            <div class="voucher-expiry">
                                <i class="bi bi-clock me-1"></i>
                                <c:choose>
                                    <c:when test="${not empty p.endsAt}">
                                        HSD: <c:out value="${p.endsAtDisplay}" />
                                    </c:when>
                                    <c:otherwise>Không giới hạn thời gian</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <button type="button" class="btn voucher-copy" data-copy-code="<c:out value='${p.code}'/>">
                            <i class="bi bi-copy me-1"></i>Sao chép mã
                        </button>
                    </div>
                </div>
            </div>
        </article>
    </c:forEach>
    </div>

    <p id="voucherEmptyState" class="alert alert-info mt-3" hidden>Chưa có voucher khả dụng thuộc nhóm này.</p>
    <p id="voucherCopyStatus" class="small text-muted mt-3" role="status" aria-live="polite"></p>

    <div class="voucher-guide">
        <h2 class="h5 fw-bold mb-3"><i class="bi bi-lightbulb-fill text-warning me-2"></i>Hướng dẫn áp dụng mã giảm giá</h2>
        <div class="row g-3">
            <div class="col-md-4"><strong>1. Lưu mã ưu đãi</strong><p class="small text-muted mb-0 mt-1">Nhấn "Sao chép mã" trên voucher phù hợp với đơn hàng của bạn.</p></div>
            <div class="col-md-4"><strong>2. Mua sắm sản phẩm</strong><p class="small text-muted mb-0 mt-1">Thêm sản phẩm điện máy yêu thích vào giỏ hàng hoặc nhấn Mua ngay.</p></div>
            <div class="col-md-4"><strong>3. Dán mã khi thanh toán</strong><p class="small text-muted mb-0 mt-1">Nhập hoặc chọn mã tại trang Thanh toán để được trừ tiền trực tiếp.</p></div>
        </div>
    </div>
</div>
</main>
<script src="${pageContext.request.contextPath}/js/vouchers.js"></script>
<jsp:include page="fragments/footer.jsp" />