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

    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet">

    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
        rel="stylesheet">

    <jsp:include page="/WEB-INF/views/shared/security.jsp" />
    <jsp:include page="fragments/theme.jsp" />
    <style>
        .dashboard-chart-grid {
            display: grid;
            grid-template-columns: repeat(7, minmax(0, 1fr));
            align-items: end;
            gap: clamp(.5rem, 2vw, 1.25rem);
            min-height: 15rem;
            padding: 1rem .5rem 0;
            border-bottom: 1px solid var(--bs-border-color);
            background: repeating-linear-gradient(to top, transparent 0, transparent 3.65rem, rgba(108,117,125,.12) 3.7rem, transparent 3.75rem);
        }
        .dashboard-chart-column { display:flex; flex-direction:column; justify-content:flex-end; align-items:center; min-width:0; }
        .dashboard-chart-bar-area { display:flex; align-items:flex-end; justify-content:center; width:100%; height:9rem; }
        .dashboard-chart-bar { width:min(100%, 2.8rem); min-height:3px; border-radius:.45rem .45rem 0 0; background:linear-gradient(180deg,#4f9bff,#0755c9); transition:height .25s ease; }
        .dashboard-chart-label { font-size:.75rem; white-space:nowrap; }
        .dashboard-chart-date { color:var(--bs-secondary-color); font-size:.7rem; }
        .dashboard-status-row { display:grid; grid-template-columns:minmax(7rem, 1fr) minmax(5rem, 2fr) auto; gap:.75rem; align-items:center; margin-bottom:1rem; }
        .dashboard-status-track { height:.65rem; overflow:hidden; border-radius:999px; background:#e9ecef; }
        .dashboard-status-fill { height:100%; border-radius:inherit; }
        @media (max-width: 575.98px) {
            .dashboard-chart-grid { gap:.3rem; }
            .dashboard-chart-label { font-size:.65rem; }
            .dashboard-status-row { grid-template-columns:minmax(6.5rem, 1fr) minmax(3rem, 1fr) auto; gap:.5rem; font-size:.85rem; }
        }
    </style>
</head>

<body>
    <div class="d-flex">
        <jsp:include page="fragments/sidebar.jsp" />

        <div class="flex-grow-1 bg-light p-4">

            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 pb-3 mb-4 border-bottom">
                <div>
                    <h3 class="fw-bold mb-0">Tổng quan hệ thống</h3>
                    <small class="text-muted">
                        Phạm vi:
                        <c:out value="${currentBranchName}" />
                    </small>
                </div>

                <div class="d-flex flex-wrap gap-2">
                    <c:if test="${canViewRevenue}">
                        <button type="button"
                                class="btn btn-outline-primary btn-sm">
                            <i class="bi bi-download me-1"></i>
                            Xuất báo cáo
                        </button>
                    </c:if>

                    <a href="${pageContext.request.contextPath}/"
                       class="btn btn-primary btn-sm">
                        <i class="bi bi-house me-1"></i>
                        Về trang bán hàng
                    </a>
                </div>
            </div>

            <c:choose>
                <c:when test="${canViewRevenue}">

                    <section class="mb-4" aria-labelledby="dashboard-summary-title">
                        <div class="d-flex justify-content-between align-items-end flex-wrap gap-2 mb-3">
                            <div>
                                <h5 id="dashboard-summary-title" class="fw-bold mb-1">Tổng quan hoạt động</h5>
                                <div class="small text-muted">Số đơn được giới hạn theo phạm vi chi nhánh ở trên.</div>
                            </div>
                        </div>
                        <div class="row g-3">
                        <div class="col-12 col-sm-6 col-xl-4">
                            <div class="card border-0 shadow-sm border-start border-primary border-4 p-3 h-100">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <small class="text-muted fw-bold">
                                            KHÁCH HÀNG ĐÃ MUA
                                        </small>

                                        <h4 class="fw-bold text-primary mt-1 mb-0">
                                            <fmt:formatNumber
                                                value="${customerCount}"
                                                type="number"
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

                        <div class="col-12 col-sm-6 col-xl-4">
                            <div class="card border-0 shadow-sm border-start border-success border-4 p-3 h-100">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <small class="text-muted fw-bold">
                                            TỔNG DOANH THU
                                        </small>

                                        <h4 class="fw-bold text-success mt-1 mb-0">
                                            <fmt:formatNumber
                                                value="${totalRevenue}"
                                                type="number"
                                                maxFractionDigits="0"
                                                groupingUsed="true" />
                                            đ
                                        </h4>
                                    </div>

                                    <div class="fs-2 text-success">
                                        <i class="bi bi-currency-dollar"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-xl-4">
                            <a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=PENDING">
                            <div class="card border-0 shadow-sm border-start border-warning border-4 p-3 h-100">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div><small class="text-muted fw-bold">CHỜ XÁC NHẬN</small>
                                        <h4 class="fw-bold text-warning mt-1 mb-0"><fmt:formatNumber value="${pendingOrderCount}" maxFractionDigits="0" /> đơn</h4></div>
                                    <i class="bi bi-hourglass-split fs-2 text-warning"></i>
                                </div>
                            </div>
                            </a>
                        </div>
                        <div class="col-12 col-sm-6 col-xl-4">
                            <a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=PROCESSING">
                            <div class="card border-0 shadow-sm border-start border-info border-4 p-3 h-100">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div><small class="text-muted fw-bold">ĐANG CHUẨN BỊ</small>
                                        <h4 class="fw-bold text-info mt-1 mb-0"><fmt:formatNumber value="${processingOrderCount}" maxFractionDigits="0" /> đơn</h4></div>
                                    <i class="bi bi-box-seam fs-2 text-info"></i>
                                </div>
                            </div>
                            </a>
                        </div>
                        <div class="col-12 col-sm-6 col-xl-4">
                            <a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=SHIPPING">
                            <div class="card border-0 shadow-sm border-start border-secondary border-4 p-3 h-100">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div><small class="text-muted fw-bold">ĐANG GIAO</small>
                                        <h4 class="fw-bold text-secondary mt-1 mb-0"><fmt:formatNumber value="${shippingOrderCount}" maxFractionDigits="0" /> đơn</h4></div>
                                    <i class="bi bi-truck fs-2 text-secondary"></i>
                                </div>
                            </div>
                            </a>
                        </div>
                        <div class="col-12 col-sm-6 col-xl-4">
                            <a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=DELIVERED">
                            <div class="card border-0 shadow-sm border-start border-success border-4 p-3 h-100">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div><small class="text-muted fw-bold">ĐÃ GIAO</small>
                                        <h4 class="fw-bold text-success mt-1 mb-0"><fmt:formatNumber value="${deliveredOrderCount}" maxFractionDigits="0" /> đơn</h4></div>
                                    <i class="bi bi-check-circle fs-2 text-success"></i>
                                </div>
                            </div>
                            </a>
                        </div>
                        </div>
                    </section>

                    <section class="row g-3 mb-4" aria-label="Biểu đồ thống kê">
                        <div class="col-12 col-xl-7">
                            <div class="card border-0 shadow-sm h-100">
                                <div class="card-header bg-white fw-bold py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <span><i class="bi bi-bar-chart-line me-1 text-primary"></i>Doanh thu 7 ngày gần nhất</span>
                                    <small class="text-muted fw-normal">Đơn thanh toán thành công · đ</small>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${empty revenueTrend}">
                                            <div class="text-center text-secondary py-5">Chưa có dữ liệu doanh thu.</div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="dashboard-chart-grid" role="img" aria-label="Biểu đồ cột doanh thu theo ngày trong 7 ngày gần nhất">
                                                <c:forEach items="${revenueTrend}" var="day">
                                                    <div class="dashboard-chart-column" title="${day.dateLabel}">
                                                        <span class="small text-primary text-center text-nowrap mb-1">
                                                            <fmt:formatNumber value="${day.revenue}" maxFractionDigits="0" groupingUsed="true" />
                                                        </span>
                                                        <div class="dashboard-chart-bar-area" aria-hidden="true"><div class="dashboard-chart-bar" style="height:${day.barPercent}%;"></div></div>
                                                        <span class="dashboard-chart-label fw-semibold mt-2"><c:out value="${day.dayLabel}" /></span>
                                                        <span class="dashboard-chart-date"><c:out value="${day.dateLabel}" /></span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-xl-5">
                            <div class="card border-0 shadow-sm h-100">
                                <div class="card-header bg-white fw-bold py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <span><i class="bi bi-pie-chart me-1 text-primary"></i>Cơ cấu trạng thái đơn hàng</span>
                                    <small class="text-muted fw-normal"><fmt:formatNumber value="${statusChartTotal}" maxFractionDigits="0" /> đơn</small>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${statusChartTotal == 0}">
                                            <div class="text-center text-secondary py-5">Chưa có đơn hàng trong phạm vi này.</div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${orderStatusChart}" var="slice">
                                                <div class="dashboard-status-row">
                                                    <span class="text-truncate" title="${slice.label}"><c:out value="${slice.label}" /></span>
                                                    <div class="dashboard-status-track" role="progressbar" aria-label="${slice.label}" aria-valuenow="${slice.percent}" aria-valuemin="0" aria-valuemax="100">
                                                        <div class="dashboard-status-fill" style="width:${slice.percent}%;background-color:${slice.color};"></div>
                                                    </div>
                                                    <strong class="text-nowrap"><fmt:formatNumber value="${slice.count}" maxFractionDigits="0" /></strong>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </section>

                    <div class="card border-0 shadow-sm mb-4">
                        <div class="card-header bg-white fw-bold py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <span>
                            <i class="bi bi-shop me-1"></i>
                            Doanh thu theo chi nhánh
                            </span>
                            <small class="text-muted fw-normal">Tỷ trọng trên doanh thu của phạm vi đang xem</small>
                        </div>

                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty branches}">
                                    <p class="text-muted mb-0">
                                        Chưa có chi nhánh.
                                    </p>
                                </c:when>

                                <c:otherwise>
                                    <div class="row g-3">
                                        <c:forEach var="branch" items="${branches}">
                                            <div class="col-md-6 col-xl-4">
                                                <div class="border rounded p-3 h-100">
                                                    <div class="d-flex justify-content-between align-items-start gap-2">
                                                        <div class="text-muted small text-break"><c:out value="${branch.name}" /></div>
                                                        <strong class="text-primary text-nowrap">
                                                        <fmt:formatNumber
                                                            value="${branch.revenue}"
                                                            type="number"
                                                            maxFractionDigits="0"
                                                            groupingUsed="true" />
                                                        đ</strong>
                                                    </div>
                                                    <div class="progress mt-3" role="progressbar" aria-label="Tỷ trọng doanh thu chi nhánh" aria-valuenow="${branch.sharePercent}" aria-valuemin="0" aria-valuemax="100" style="height: .5rem">
                                                        <div class="progress-bar" style="width: ${branch.sharePercent}%"></div>
                                                    </div>
                                                    <div class="small text-muted mt-2"><fmt:formatNumber value="${branch.sharePercent}" maxFractionDigits="0" />% doanh thu</div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="alert alert-info small" role="note">
                        <i class="bi bi-info-circle me-1"></i>
                        Số liệu được truy vấn trực tiếp từ hệ thống và cập nhật
                        khi tải lại trang. Doanh thu chỉ tính đơn đã thanh toán
                        thành công; đơn đã hủy không được tính.
                    </div>

                    <div class="card border-0 shadow-sm mb-4">
                        <div class="card-header bg-white fw-bold py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <span>
                                <i class="bi bi-check2-circle me-1 text-success"></i>
                                Đơn hàng thanh toán thành công gần đây
                            </span>

                            <a class="btn btn-sm btn-outline-primary"
                               href="${pageContext.request.contextPath}/admin/invoices">
                                Xem tất cả hóa đơn
                            </a>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Mã đơn</th>
                                        <th>Khách hàng</th>
                                        <th>Chi nhánh</th>
                                        <th>Ngày đặt</th>
                                        <th class="text-end">Tổng tiền</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:forEach items="${successfulOrders}" var="order">
                                        <tr>
                                            <td>
                                                <strong>
                                                    <c:out value="${order.orderCode}" />
                                                </strong>
                                            </td>

                                            <td>
                                                <c:out value="${order.recipientName}" />
                                                <br>
                                                <small class="text-secondary">
                                                    <c:out value="${order.recipientPhone}" />
                                                </small>
                                            </td>

                                            <td>
                                                <c:out
                                                    value="${order.branch.name}"
                                                    default="Chưa gán" />
                                            </td>

                                            <td>
                                                <c:out value="${order.createdAt}" />
                                            </td>

                                            <td class="text-end fw-bold">
                                                <fmt:formatNumber
                                                    value="${order.finalAmount}"
                                                    type="number"
                                                    maxFractionDigits="0"
                                                    groupingUsed="true" />
                                                đ
                                            </td>

                                            <td>
                                                <a class="btn btn-sm btn-outline-primary"
                                                   href="${pageContext.request.contextPath}/admin/orders/${order.id}">
                                                    <i class="bi bi-eye me-1"></i>
                                                    Chi tiết hóa đơn
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>

                                    <c:if test="${empty successfulOrders}">
                                        <tr>
                                            <td colspan="6"
                                                class="text-center text-secondary py-4">
                                                Chưa có đơn hàng thanh toán thành công.
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </c:when>

                <c:otherwise>
                    <div class="card border-0 shadow-sm p-4">
                        <h5 class="fw-bold text-primary mb-2">
                            <i class="bi bi-person-workspace me-2"></i>
                            Không gian làm việc Nhân viên Chi nhánh
                        </h5>

                        <p class="text-secondary mb-3">
                            Bạn đang làm việc tại
                            <strong>
                                <c:out value="${currentBranchName}" />
                            </strong>.
                            Dữ liệu doanh thu và báo cáo tài chính chỉ dành cho
                            Quản lý chi nhánh và Admin tổng.
                        </p>

                        <div class="d-flex flex-wrap gap-2">
                            <a href="${pageContext.request.contextPath}/admin/orders"
                               class="btn btn-primary">
                                <i class="bi bi-receipt me-1"></i>
                                Xử lý đơn hàng chi nhánh
                            </a>

                            <a href="${pageContext.request.contextPath}/admin/inventory"
                               class="btn btn-outline-primary">
                                <i class="bi bi-boxes me-1"></i>
                                Tồn kho &amp; Tra cứu liên chi nhánh
                            </a>

                            <a href="${pageContext.request.contextPath}/admin/returns"
                               class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-counterclockwise me-1"></i>
                                Tiếp nhận trả hàng
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </div>

    <c:if test="${not empty orderRealtimeDestination}">
        <div id="orderRealtime"
             data-context-path="${pageContext.request.contextPath}"
             data-destination="${orderRealtimeDestination}"
             data-poll-url="${pageContext.request.contextPath}${orderStatusPollUrl}">
        </div>

        <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
        <script src="${pageContext.request.contextPath}/js/order-realtime.js"></script>
    </c:if>
</body>
</html>
