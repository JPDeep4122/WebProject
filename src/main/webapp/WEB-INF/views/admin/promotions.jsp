<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý Khuyến mãi &amp; Voucher — TECHSEVEN</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>

    <style>
        .promo-page-header {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
        }

        .promo-kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .promo-kpi-card {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 18px 20px;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            background: #ffffff;
            box-shadow: 0 2px 10px rgba(15, 23, 42, 0.03);
        }

        .promo-kpi-icon {
            display: grid;
            place-items: center;
            flex-shrink: 0;
            width: 48px;
            height: 48px;
            border-radius: 12px;
            font-size: 22px;
        }

        .voucher-form-group {
            padding: 16px 18px;
            border: 1px solid #e5eaf2;
            border-radius: 12px;
            background: #f8fafc;
        }

        .voucher-form-group__title {
            margin-bottom: 12px;
            color: #0f172a;
            font-size: 14px;
            font-weight: 700;
        }

        /* Hộp chọn danh mục dạng Chip / Pill cuộn gọn */
        .voucher-cat-box {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            max-height: 155px;
            overflow-y: auto;
            padding: 12px;
            border: 1px solid #dbe3ef;
            border-radius: 10px;
            background: #ffffff;
        }

        .voucher-cat-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin: 0;
            padding: 5px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 999px;
            background: #f8fafc;
            color: #334155;
            font-size: 12.5px;
            font-weight: 500;
            cursor: pointer;
            user-select: none;
            transition: all 140ms ease;
        }

        .voucher-cat-chip:hover {
            border-color: #0046be;
            color: #0046be;
        }

        .voucher-cat-chip input {
            margin: 0;
            accent-color: #0046be;
        }

        .voucher-cat-chip:has(input:checked) {
            border-color: #0046be;
            background: #eff6ff;
            color: #0046be;
            font-weight: 700;
        }

        /* Bảng quản lý Voucher chuẩn Responsive Table */
        .voucher-table-wrapper {
            overflow: auto;
            max-inline-size: 100%;
            max-block-size: 72vh;
            container-type: inline-size;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            background: #ffffff;
            box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
        }

        .voucher-table {
            width: 100%;
            margin-bottom: 0;
            border-collapse: separate;
            border-spacing: 0;
        }

        .voucher-table thead {
            position: sticky;
            inset-block-start: 0;
            z-index: 2;
            background: #f1f5f9;
        }

        .voucher-table thead th {
            padding: 14px 16px;
            border-bottom: 1px solid #e2e8f0;
            color: #475569;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
        }

        .voucher-table tbody td,
        .voucher-table tbody th {
            padding: 16px;
            border-bottom: 1px solid #eef2f6;
            vertical-align: middle;
        }

        .voucher-row:hover > td,
        .voucher-row:hover > th {
            background-color: #f8fafc;
        }

        /* Huy hiệu Mã Voucher kiểu Ticket */
        .voucher-code-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border: 1.5px dashed #0046be;
            border-radius: 8px;
            background: #eff6ff;
            color: #0046be;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 14px;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        .voucher-copy-btn {
            border: 0;
            background: transparent;
            color: #64748b;
            padding: 0 2px;
            font-size: 13px;
            cursor: pointer;
        }

        .voucher-copy-btn:hover {
            color: #0046be;
        }

        .voucher-usage-bar {
            width: 130px;
            height: 7px;
            border-radius: 999px;
            background: #e2e8f0;
            overflow: hidden;
        }

        .voucher-usage-bar__fill {
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, #0046be, #3b82f6);
        }

        .voucher-edit-drawer {
            background: #f8fafc;
        }
    </style>
</head>

<body>
<div class="d-flex">

    <jsp:include page="fragments/sidebar.jsp"/>

    <main class="flex-grow-1 bg-light p-4">

        <!-- ĐẾM SỐ LƯỢNG VOUCHER ĐANG BẬT / TẮT -->
        <c:set var="activeCount" value="0" />
        <c:set var="inactiveCount" value="0" />
        <c:forEach items="${promotions}" var="item">
            <c:choose>
                <c:when test="${item.active}">
                    <c:set var="activeCount" value="${activeCount + 1}" />
                </c:when>
                <c:otherwise>
                    <c:set var="inactiveCount" value="${inactiveCount + 1}" />
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <!-- HEADER TRANG -->
        <div class="promo-page-header">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    <i class="bi bi-ticket-perforated-fill text-primary me-2"></i>Quản lý Khuyến mãi &amp; Voucher
                </h3>
                <p class="text-muted small mb-0">Thiết lập mã giảm giá, điều kiện đơn hàng, giới hạn lượt dùng và phạm vi ngành hàng</p>
            </div>

            <div class="d-flex flex-wrap gap-2">
                <!-- Nút dọn đơn VNPay hết hạn -->
                <form method="post" action="${pageContext.request.contextPath}/admin/promotions/expire-unpaid" class="m-0">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" class="btn btn-white border shadow-sm fw-semibold"
                            title="Hủy tối đa 50 đơn chờ xác nhận đã hết hạn link VNPay và hoàn lại lượt voucher">
                        <i class="bi bi-clock-history text-warning me-1"></i> Dọn đơn VNPay quá hạn
                    </button>
                </form>

                <!-- Nút bật/tắt khung Tạo Voucher mới -->
                <button class="btn btn-primary fw-bold shadow-sm px-3" type="button"
                        data-bs-toggle="collapse" data-bs-target="#createVoucherCollapse"
                        aria-expanded="false" aria-controls="createVoucherCollapse">
                    <i class="bi bi-plus-lg me-1"></i> Tạo Voucher mới
                </button>
            </div>
        </div>

        <!-- THÔNG BÁO FLASH MESSAGE -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm d-flex align-items-center gap-2" role="alert">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <div><c:out value="${success}"/></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm d-flex align-items-center gap-2" role="alert">
                <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                <div><c:out value="${error}"/></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
            </div>
        </c:if>

        <!-- 4 THẺ KPI TỔNG QUAN -->
        <div class="promo-kpi-grid">
            <div class="promo-kpi-card">
                <div class="promo-kpi-icon bg-primary-subtle text-primary">
                    <i class="bi bi-ticket-detailed-fill"></i>
                </div>
                <div>
                    <div class="text-muted small fw-semibold">Tổng số Voucher</div>
                    <div class="fs-4 fw-bold text-dark">${fn:length(promotions)}</div>
                </div>
            </div>

            <div class="promo-kpi-card">
                <div class="promo-kpi-icon bg-success-subtle text-success">
                    <i class="bi bi-check-circle-fill"></i>
                </div>
                <div>
                    <div class="text-muted small fw-semibold">Đang hoạt động</div>
                    <div class="fs-4 fw-bold text-success">${activeCount}</div>
                </div>
            </div>

            <div class="promo-kpi-card">
                <div class="promo-kpi-icon bg-secondary-subtle text-secondary">
                    <i class="bi bi-pause-circle-fill"></i>
                </div>
                <div>
                    <div class="text-muted small fw-semibold">Đã tạm dừng / Tắt</div>
                    <div class="fs-4 fw-bold text-secondary">${inactiveCount}</div>
                </div>
            </div>

            <div class="promo-kpi-card">
                <div class="promo-kpi-icon bg-warning-subtle text-warning-emphasis">
                    <i class="bi bi-shield-check"></i>
                </div>
                <div>
                    <div class="text-muted small fw-semibold">Bảo vệ hoàn lượt</div>
                    <div class="small fw-semibold text-dark">Tự động hoàn khi hủy đơn chờ</div>
                </div>
            </div>
        </div>

        <!-- KHUNG TẠO VOUCHER MỚI (COLLAPSIBLE PANEL GỌN ĐẸP) -->
        <div class="collapse ${not empty error ? 'show' : ''} mb-4" id="createVoucherCollapse">
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="card-header bg-primary text-white py-3 px-4 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi bi-plus-circle me-2"></i>Thiết lập Voucher khuyến mãi mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white"
                            data-bs-toggle="collapse" data-bs-target="#createVoucherCollapse" aria-label="Đóng"></button>
                </div>

                <div class="card-body p-4">
                    <form method="post" action="${pageContext.request.contextPath}/admin/promotions" novalidate>
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                        <c:set var="formPromotion" value="${newPromotion}" scope="request"/>
                        <jsp:include page="fragments/promotion-fields.jsp">
                            <jsp:param name="editMode" value="false"/>
                        </jsp:include>

                        <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                            <button type="button" class="btn btn-light border px-4"
                                    data-bs-toggle="collapse" data-bs-target="#createVoucherCollapse">
                                Đóng lại
                            </button>
                            <button type="submit" class="btn btn-primary fw-bold px-4">
                                <i class="bi bi-check2-circle me-1"></i> Lưu &amp; Phát hành Voucher
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- THANH CÔNG CỤ LỌC & TÌM KIẾM DANH SÁCH VOUCHER -->
        <div class="card border-0 shadow-sm rounded-4 mb-3">
            <div class="card-body py-3 px-4">
                <div class="row g-3 align-items-center">
                    <div class="col-lg-5">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted">
                                <i class="bi bi-search"></i>
                            </span>
                            <input type="search" id="voucherSearchInput" class="form-control border-start-0"
                                   placeholder="Tìm kiếm theo mã voucher hoặc tên chương trình..."
                                   oninput="filterVoucherRows()">
                        </div>
                    </div>

                    <div class="col-sm-6 col-lg-3">
                        <select id="voucherTypeFilter" class="form-select" onchange="filterVoucherRows()">
                            <option value="ALL">Tất cả loại giảm giá</option>
                            <option value="PERCENT">% Giảm theo phần trăm</option>
                            <option value="FIXED">₫ Giảm số tiền cố định</option>
                            <option value="SHIPPING">🚚 Giảm phí vận chuyển</option>
                        </select>
                    </div>

                    <div class="col-sm-6 col-lg-3">
                        <select id="voucherStatusFilter" class="form-select" onchange="filterVoucherRows()">
                            <option value="ALL">Tất cả trạng thái</option>
                            <option value="ACTIVE">Đang hoạt động</option>
                            <option value="INACTIVE">Đã tắt</option>
                        </select>
                    </div>

                    <div class="col-lg-1 text-end">
                        <span class="badge bg-light text-secondary border px-2 py-2" id="voucherVisibleCount">
                            ${fn:length(promotions)} mã
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG DANH SÁCH VOUCHER CHUYÊN NGHIỆP -->
        <c:choose>
            <c:when test="${empty promotions}">
                <div class="card border-0 shadow-sm rounded-4 text-center py-5">
                    <div class="card-body">
                        <i class="bi bi-ticket-perforated display-4 text-muted"></i>
                        <h5 class="fw-bold mt-3">Chưa có mã khuyến mãi nào</h5>
                        <p class="text-muted small mb-3">Hãy nhấn nút "Tạo Voucher mới" ở góc trên để phát hành chương trình ưu đãi đầu tiên.</p>
                        <button class="btn btn-primary fw-bold" type="button"
                                data-bs-toggle="collapse" data-bs-target="#createVoucherCollapse">
                            <i class="bi bi-plus-lg me-1"></i> Tạo Voucher ngay
                        </button>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <div tabindex="0" role="region" aria-label="Danh sách mã giảm giá" class="voucher-table-wrapper">
                    <table class="voucher-table">
                        <thead>
                            <tr>
                                <th>Mã &amp; Chương trình</th>
                                <th>Loại &amp; Mức giảm</th>
                                <th>Điều kiện áp dụng</th>
                                <th>Đã áp dụng / giới hạn</th>
                                <th>Thời gian hiệu lực</th>
                                <th>Trạng thái</th>
                                <th class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${promotions}" var="p">
                                <tr class="voucher-row"
                                    data-code="<c:out value='${p.code}'/>"
                                    data-name="<c:out value='${p.name}'/>"
                                    data-type="${p.discountType}"
                                    data-status="${p.active ? 'ACTIVE' : 'INACTIVE'}">

                                    <!-- 1. Mã & Tên -->
                                    <th>
                                        <div class="d-flex align-items-center gap-2 mb-1">
                                            <span class="voucher-code-pill">
                                                <c:out value="${p.code}"/>
                                            </span>
                                            <button type="button" class="voucher-copy-btn"
                                                    onclick="copyVoucherCode('<c:out value="${p.code}"/>', this)"
                                                    title="Sao chép mã">
                                                <i class="bi bi-copy"></i>
                                            </button>
                                        </div>
                                        <div class="fw-semibold text-dark small">
                                            <c:out value="${p.name}"/>
                                        </div>
                                        <c:if test="${p.newCustomerOnly}">
                                            <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle mt-1" style="font-size: 11px;">
                                                <i class="bi bi-stars me-1"></i>Khách hàng mới
                                            </span>
                                        </c:if>
                                    </th>

                                    <!-- 2. Loại & Mức giảm -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.discountType == 'PERCENT'}">
                                                <span class="badge bg-primary-subtle text-primary mb-1">% Phần trăm</span>
                                                <div class="fw-bold text-danger fs-6">
                                                    Giảm <fmt:formatNumber value="${p.discountPercent}" maxFractionDigits="2"/>%
                                                </div>
                                            </c:when>
                                            <c:when test="${p.discountType == 'FIXED'}">
                                                <span class="badge bg-warning-subtle text-warning-emphasis mb-1">₫ Tiền mặt</span>
                                                <div class="fw-bold text-danger fs-6">
                                                    Giảm <fmt:formatNumber value="${p.discountAmount}" type="number" groupingUsed="true"/> ₫
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-success-subtle text-success mb-1">🚚 Freeship</span>
                                                <div class="fw-bold text-success">
                                                    Miễn phí vận chuyển
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <c:if test="${not empty p.maxDiscountAmount}">
                                            <div class="text-muted" style="font-size: 12px;">
                                                Tối đa: <strong><fmt:formatNumber value="${p.maxDiscountAmount}" type="number" groupingUsed="true"/> ₫</strong>
                                            </div>
                                        </c:if>
                                    </td>

                                    <!-- 3. Điều kiện áp dụng -->
                                    <td>
                                        <div class="small text-dark">
                                            Đơn tối thiểu:
                                            <strong><fmt:formatNumber value="${p.minOrderAmount}" type="number" groupingUsed="true"/> ₫</strong>
                                        </div>
                                        <div class="small text-muted mt-1">
                                            Thanh toán:
                                            <span class="fw-semibold text-dark">
                                                <c:choose>
                                                    <c:when test="${empty p.requiredPaymentMethod}">Tất cả</c:when>
                                                    <c:otherwise>${p.requiredPaymentMethod}</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="small text-muted">
                                            Ngành hàng:
                                            <span class="fw-semibold text-primary">
                                                <c:choose>
                                                    <c:when test="${empty p.categories}">Toàn bộ sản phẩm</c:when>
                                                    <c:otherwise>${fn:length(p.categories)} danh mục</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </td>

                                    <!-- 4. Lượt sử dụng -->
                                    <td>
                                        <div class="d-flex justify-content-between align-items-center small mb-1" style="width: 130px;">
                                            <span class="fw-bold text-dark">${p.usedCount}</span>
                                            <span class="text-muted">/ ${empty p.maxUses ? '∞' : p.maxUses}</span>
                                        </div>
                                        <div class="voucher-usage-bar">
                                            <c:set var="usagePct" value="${not empty p.maxUses and p.maxUses gt 0 ? (p.usedCount * 100 / p.maxUses) : 15}" />
                                            <div class="voucher-usage-bar__fill" style="width: ${usagePct > 100 ? 100 : usagePct}%;"></div>
                                        </div>
                                        <div class="text-muted mt-1" style="font-size: 11.5px;">
                                            Mỗi khách: <strong>${empty p.perUserLimit ? 'Không giới hạn' : p.perUserLimit.toString().concat(' lượt')}</strong>
                                        </div>
                                        <div class="text-muted" style="font-size: 11px;">Đếm theo đơn dùng mã, không phải số tài khoản lưu mã.</div>
                                    </td>

                                    <!-- 5. Thời gian hiệu lực -->
                                    <td>
                                        <div class="small">
                                            <span class="text-muted">Từ:</span>
                                            <span class="fw-semibold text-dark">${empty p.startsAt ? 'Ngay lập tức' : fn:replace(p.startsAt, 'T', ' ')}</span>
                                        </div>
                                        <div class="small mt-1">
                                            <span class="text-muted">Đến:</span>
                                            <span class="fw-semibold text-dark">${empty p.endsAt ? 'Không thời hạn' : fn:replace(p.endsAt, 'T', ' ')}</span>
                                        </div>
                                    </td>

                                    <!-- 6. Trạng thái -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.active}">
                                                <span class="badge rounded-pill bg-success-subtle text-success border border-success-subtle px-3 py-2">
                                                    <i class="bi bi-dot"></i> Đang bật
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge rounded-pill bg-secondary-subtle text-secondary border border-secondary-subtle px-3 py-2">
                                                    Đã tắt
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- 7. Thao tác -->
                                    <td class="text-end">
                                        <div class="d-inline-flex align-items-center gap-2">
                                            <button class="btn btn-sm btn-outline-primary fw-semibold"
                                                    type="button"
                                                    data-bs-toggle="collapse"
                                                    data-bs-target="#editRow-${p.id}"
                                                    aria-expanded="false">
                                                <i class="bi bi-sliders me-1"></i> Sửa
                                            </button>

                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/admin/promotions/${p.id}/toggle"
                                                  class="m-0">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <button type="submit"
                                                        class="btn btn-sm ${p.active ? 'btn-outline-warning' : 'btn-outline-success'} fw-semibold">
                                                    <i class="bi ${p.active ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
                                                    ${p.active ? 'Tắt' : 'Bật'}
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>

                                <!-- DÒNG MỞ RỘNG CHỈNH SỬA CHI TIẾT VOUCHER -->
                                <tr class="collapse voucher-edit-drawer" id="editRow-${p.id}">
                                    <td colspan="7" class="p-4 border-bottom">
                                        <div class="card border shadow-sm rounded-4">
                                            <div class="card-header bg-white py-3 px-4 d-flex justify-content-between align-items-center">
                                                <h6 class="mb-0 fw-bold text-primary">
                                                    <i class="bi bi-pencil-square me-2"></i>Chỉnh sửa cấu hình Voucher:
                                                    <code><c:out value="${p.code}"/></code>
                                                </h6>
                                                <button type="button" class="btn-close"
                                                        data-bs-toggle="collapse"
                                                        data-bs-target="#editRow-${p.id}"
                                                        aria-label="Đóng"></button>
                                            </div>
                                            <div class="card-body p-4">
                                                <form method="post" novalidate
                                                      action="${pageContext.request.contextPath}/admin/promotions/${p.id}/update">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                                                    <c:set var="formPromotion" value="${p}" scope="request"/>
                                                    <jsp:include page="fragments/promotion-fields.jsp">
                                                        <jsp:param name="editMode" value="true"/>
                                                    </jsp:include>

                                                    <div class="d-flex justify-content-end gap-2 mt-3 pt-3 border-top">
                                                        <button type="button" class="btn btn-light border px-3"
                                                                data-bs-toggle="collapse"
                                                                data-bs-target="#editRow-${p.id}">
                                                            Hủy
                                                        </button>
                                                        <button type="submit" class="btn btn-primary fw-bold px-4">
                                                            <i class="bi bi-save me-1"></i> Lưu thay đổi
                                                        </button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function syncVoucherTypeFields(selectEl) {
        const formWrap = selectEl.closest('[data-voucher-form]');
        if (!formWrap) return;

        const type = selectEl.value;
        const percentBox = formWrap.querySelector('[data-field-role="percent"]');
        const fixedBox = formWrap.querySelector('[data-field-role="fixed"]');
        const shippingBox = formWrap.querySelector('[data-field-role="shipping-info"]');

        if (percentBox) {
            percentBox.classList.toggle('d-none', type !== 'PERCENT');
            const input = percentBox.querySelector('input');
            if (input) {
                input.disabled = (type !== 'PERCENT');
                input.required = (type === 'PERCENT');
<<<<<<< HEAD
                input.setCustomValidity('');
=======
>>>>>>> ef7ad95adc9b078a7c50a2ecde237f892e6bdd99
            }
        }
        if (fixedBox) {
            fixedBox.classList.toggle('d-none', type !== 'FIXED');
            const input = fixedBox.querySelector('input');
            if (input) {
                input.disabled = (type !== 'FIXED');
                input.required = (type === 'FIXED');
<<<<<<< HEAD
                input.setCustomValidity('');
=======
>>>>>>> ef7ad95adc9b078a7c50a2ecde237f892e6bdd99
            }
        }
        if (shippingBox) {
            shippingBox.classList.toggle('d-none', type !== 'SHIPPING');
        }
    }

    function voucherValidationMessage(input) {
        const name = input.name;
        if (input.validity.valueMissing) {
            return ({
                name: 'Vui lòng nhập tên chương trình voucher.',
                code: 'Vui lòng nhập mã voucher.',
                discountAmount: 'Vui lòng nhập số tiền giảm.',
                discountPercent: 'Vui lòng nhập phần trăm giảm.',
                minOrderAmount: 'Vui lòng nhập giá trị đơn hàng tối thiểu.'
            })[name] || 'Vui lòng điền trường này.';
        }
        if (input.validity.patternMismatch) return 'Mã voucher gồm 2–50 ký tự: chữ, số, dấu gạch ngang hoặc gạch dưới.';
        if (input.validity.rangeUnderflow) {
            if (name === 'maxUses') return 'Tổng số lượt phải từ 1 trở lên; để trống nếu không giới hạn.';
            if (name === 'perUserLimit') return 'Lượt dùng mỗi khách phải từ 1 trở lên; để trống nếu không giới hạn.';
            if (name === 'discountPercent') return 'Phần trăm giảm phải lớn hơn 0.';
            if (name === 'minOrderAmount') return 'Giá trị đơn hàng tối thiểu không được âm.';
            return 'Giá trị phải lớn hơn 0.';
        }
        if (input.validity.rangeOverflow) return 'Phần trăm giảm không được vượt quá 100%.';
        if (input.validity.stepMismatch) return 'Vui lòng nhập số nguyên hợp lệ.';
        if (input.type === 'datetime-local' && input.validity.badInput) return 'Thời gian không hợp lệ. Vui lòng chọn lại ngày giờ.';
        return 'Giá trị không hợp lệ. Vui lòng kiểm tra lại.';
    }

    function validateVoucherDates(formWrap) {
        const form = formWrap.closest('form');
        const startsAt = form?.querySelector('[name="startsAt"]');
        const endsAt = form?.querySelector('[name="endsAt"]');
        if (!startsAt || !endsAt) return;
        endsAt.setCustomValidity('');
        if (startsAt.value && endsAt.value && endsAt.value <= startsAt.value) {
            endsAt.setCustomValidity('Thời gian kết thúc phải sau thời gian bắt đầu.');
        }
    }

    function bindVoucherValidation(formWrap) {
        const form = formWrap.closest('form');
        if (!form || form.dataset.validationBound === 'true') return;
        form.dataset.validationBound = 'true';
        form.addEventListener('input', event => {
            event.target.setCustomValidity('');
            validateVoucherDates(formWrap);
        });
        form.addEventListener('change', event => {
            event.target.setCustomValidity('');
            validateVoucherDates(formWrap);
        });
        form.addEventListener('submit', event => {
            validateVoucherDates(formWrap);
            const invalidInput = Array.from(form.querySelectorAll('input, select, textarea'))
                .find(input => input.willValidate && !input.validity.valid);
            if (invalidInput) {
                if (!invalidInput.validationMessage || invalidInput.validity.customError === false) {
                    invalidInput.setCustomValidity(voucherValidationMessage(invalidInput));
                }
                event.preventDefault();
                invalidInput.reportValidity();
            }
        });
    }

    function updateCategoryCounter(formWrap) {
        if (!formWrap) return;
        const checkedCount = formWrap.querySelectorAll('input[name="categoryIds"]:checked').length;
        const badge = formWrap.querySelector('[data-cat-counter]');
        if (!badge) return;

        if (checkedCount === 0) {
            badge.textContent = 'Không chọn = Áp dụng tất cả ngành hàng';
            badge.className = 'badge bg-primary-subtle text-primary ms-2 fw-semibold';
        } else {
            badge.textContent = 'Đang giới hạn: ' + checkedCount + ' danh mục';
            badge.className = 'badge bg-warning-subtle text-warning-emphasis ms-2 fw-semibold';
        }
    }

    function filterCategoryChips(searchInput) {
        const formWrap = searchInput.closest('[data-voucher-form]');
        const q = searchInput.value.trim().toLowerCase();
        formWrap.querySelectorAll('.voucher-cat-chip').forEach(chip => {
            const name = (chip.getAttribute('data-cat-name') || '').toLowerCase();
            chip.classList.toggle('d-none', q !== '' && !name.includes(q));
        });
    }

    function setAllCategoryChips(btn, checked) {
        const formWrap = btn.closest('[data-voucher-form]');
        formWrap.querySelectorAll('.voucher-cat-chip:not(.d-none) input[name="categoryIds"]').forEach(cb => {
            cb.checked = checked;
        });
        updateCategoryCounter(formWrap);
    }

    function filterVoucherRows() {
        const q = (document.getElementById('voucherSearchInput')?.value || '').trim().toLowerCase();
        const typeFilter = document.getElementById('voucherTypeFilter')?.value || 'ALL';
        const statusFilter = document.getElementById('voucherStatusFilter')?.value || 'ALL';

        let visible = 0;
        document.querySelectorAll('.voucher-row').forEach(row => {
            const code = (row.getAttribute('data-code') || '').toLowerCase();
            const name = (row.getAttribute('data-name') || '').toLowerCase();
            const type = row.getAttribute('data-type');
            const status = row.getAttribute('data-status');

            const matchText = !q || code.includes(q) || name.includes(q);
            const matchType = (typeFilter === 'ALL' || type === typeFilter);
            const matchStatus = (statusFilter === 'ALL' || status === statusFilter);

            const show = matchText && matchType && matchStatus;
            row.classList.toggle('d-none', !show);
            if (show) visible++;
        });

        const countBadge = document.getElementById('voucherVisibleCount');
        if (countBadge) countBadge.textContent = visible + ' mã';
    }

    function copyVoucherCode(code, btn) {
        navigator.clipboard.writeText(code).then(() => {
            const icon = btn.querySelector('i');
            icon.className = 'bi bi-check2 text-success fw-bold';
            setTimeout(() => { icon.className = 'bi bi-copy'; }, 1500);
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('[data-voucher-form]').forEach(formWrap => {
            const select = formWrap.querySelector('select[name="discountType"]');
            if (select) syncVoucherTypeFields(select);
            updateCategoryCounter(formWrap);
            bindVoucherValidation(formWrap);
        });
    });
</script>
<script src="${pageContext.request.contextPath}/js/promotion-form.js"></script>
</body>
</html>
