<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thống kê giao hàng — TECHSEVEN</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="/WEB-INF/views/admin/fragments/theme.jsp"/>
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark sf-staff-navbar sticky-top py-2">
        <div class="container-fluid px-4">
            <div class="d-flex align-items-center gap-3">
                <a class="navbar-brand d-flex align-items-center gap-2 m-0" href="${pageContext.request.contextPath}/shipper/orders">
                    <img class="sf-brand-logo" src="${pageContext.request.contextPath}/images/brand/techseven-logo.svg" alt="TECHSEVEN">
                </a>
                <span class="badge rounded-pill text-dark fw-bold px-3 py-2 d-none d-md-inline-block" style="background-color: #ffe000;">
                    <i class="bi bi-truck me-1"></i>PHÂN HỆ GIAO HÀNG
                </span>
            </div>
            <div class="d-flex align-items-center gap-2 gap-md-3 text-white">
                <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="${pageContext.request.contextPath}/shipper/orders">
                    <i class="bi bi-list-check me-1"></i>Đơn giao
                </a>
                <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="${pageContext.request.contextPath}/account/profile">
                    <i class="bi bi-person-circle me-1"></i><span class="d-none d-sm-inline"><c:out value="${shipper.fullName}"/></span>
                </a>
                <div class="text-end d-none d-lg-block lh-sm">
                    <small class="text-white-50 d-block">Chi nhánh trực thuộc</small>
                    <span class="fw-semibold small text-warning"><c:out value="${shipper.branch.name}" default="Chưa gán chi nhánh"/></span>
                </div>
                <a class="btn btn-light btn-sm text-danger fw-bold rounded-pill px-3" href="${pageContext.request.contextPath}/logout">
                    <i class="bi bi-box-arrow-right me-1"></i>Đăng xuất
                </a>
            </div>
        </div>
    </nav>

    <main class="container py-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <h2 class="fw-bold mb-1 text-dark"><i class="bi bi-bar-chart-line-fill text-primary me-2"></i>Thống kê đơn đã giao</h2>
                <div class="text-secondary"><c:out value="${report.periodLabel}"/></div>
            </div>
            <div class="btn-group shadow-sm" role="group" aria-label="Khoảng thống kê">
                <a class="btn ${report.period eq 'DAY' ? 'btn-primary' : 'btn-outline-primary'}"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=DAY&date=${report.anchor}">Ngày</a>
                <a class="btn ${report.period eq 'WEEK' ? 'btn-primary' : 'btn-outline-primary'}"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=WEEK&date=${report.anchor}">Tuần</a>
                <a class="btn ${report.period eq 'MONTH' ? 'btn-primary' : 'btn-outline-primary'}"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=MONTH&date=${report.anchor}">Tháng</a>
            </div>
        </div>

        <div class="card border-0 rounded-4 shadow-sm mb-4">
            <div class="card-body d-flex flex-wrap justify-content-between align-items-end gap-3">
                <a class="btn btn-outline-secondary rounded-3"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=${report.period}&date=${report.previousAnchor}">
                    <i class="bi bi-chevron-left"></i> Kỳ trước
                </a>
                <form method="get" action="${pageContext.request.contextPath}/shipper/statistics" class="d-flex gap-2 align-items-end">
                    <input type="hidden" name="period" value="${report.period}">
                    <div>
                        <label class="form-label fw-semibold mb-1">Chọn ngày tham chiếu</label>
                        <input class="form-control rounded-3" type="date" name="date" value="${report.anchor}">
                    </div>
                    <button class="btn btn-primary rounded-3 px-3"><i class="bi bi-search me-1"></i>Xem</button>
                </form>
                <a class="btn btn-outline-secondary rounded-3"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=${report.period}&date=${report.nextAnchor}">
                    Kỳ sau <i class="bi bi-chevron-right"></i>
                </a>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card border-0 rounded-4 shadow-sm h-100"><div class="card-body p-4">
                    <div class="text-secondary mb-2 fw-medium"><i class="bi bi-check-circle-fill text-success me-1"></i> Đơn giao thành công</div>
                    <div class="display-6 fw-bold text-dark">${report.deliveredOrders}</div>
                </div></div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 rounded-4 shadow-sm h-100"><div class="card-body p-4">
                    <div class="text-secondary mb-2 fw-medium"><i class="bi bi-cash-stack text-primary me-1"></i> Giá trị đơn đã giao</div>
                    <div class="h3 fw-bold text-primary mb-0"><fmt:formatNumber value="${report.deliveredValue}" type="number" groupingUsed="true"/> ₫</div>
                </div></div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 rounded-4 shadow-sm h-100"><div class="card-body p-4">
                    <div class="text-secondary mb-2 fw-medium"><i class="bi bi-calculator-fill text-warning me-1"></i> Giá trị trung bình</div>
                    <div class="h3 fw-bold text-dark mb-0"><fmt:formatNumber value="${report.averageOrderValue}" type="number" groupingUsed="true"/> ₫</div>
                </div></div>
            </div>
        </div>

        <div class="card border-0 rounded-4 shadow-sm overflow-hidden">
            <div class="card-header bg-white py-3"><h5 class="fw-bold mb-0">Chi tiết theo ngày</h5></div>
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead class="sf-table-head"><tr><th class="ps-3">Ngày</th><th style="width:45%">Số đơn</th><th class="text-end pe-3">Giá trị đơn</th></tr></thead>
                    <tbody>
                        <c:forEach items="${report.points}" var="point">
                            <tr>
                                <td class="fw-semibold ps-3"><c:out value="${point.label}"/></td>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="progress flex-grow-1" style="height: 10px">
                                            <div class="progress-bar bg-success" style="width: ${point.percentage}%"></div>
                                        </div>
                                        <span class="badge rounded-pill text-bg-success">${point.orderCount} đơn</span>
                                    </div>
                                </td>
                                <td class="text-end fw-semibold pe-3"><fmt:formatNumber value="${point.orderValue}" type="number" groupingUsed="true"/> ₫</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <c:if test="${report.deliveredOrders eq 0}">
                <div class="card-footer bg-white text-center text-secondary py-4">
                    <i class="bi bi-inbox fs-2 d-block mb-2 text-muted"></i>Chưa có đơn giao thành công trong kỳ này.
                </div>
            </c:if>
        </div>
    </main>
</body>
</html>