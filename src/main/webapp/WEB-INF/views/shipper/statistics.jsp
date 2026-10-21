<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thống kê giao hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark bg-dark shadow-sm">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/shipper/orders">
                <i class="bi bi-truck me-2 text-warning"></i>Điện Máy UTE - Giao hàng
            </a>
            <div class="d-flex align-items-center gap-3 text-white">
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/shipper/orders">
                    <i class="bi bi-list-check"></i> Đơn giao
                </a>
                <div class="text-end d-none d-sm-block">
                    <div class="fw-semibold"><c:out value="${shipper.fullName}"/></div>
                    <small class="text-white-50"><c:out value="${shipper.branch.name}" default="Chưa gán chi nhánh"/></small>
                </div>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">
                    <i class="bi bi-box-arrow-right"></i> Đăng xuất
                </a>
            </div>
        </div>
    </nav>

    <main class="container py-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <h2 class="mb-1">Thống kê đơn đã giao</h2>
                <div class="text-secondary"><c:out value="${report.periodLabel}"/></div>
            </div>
            <div class="btn-group" role="group" aria-label="Khoảng thống kê">
                <a class="btn ${report.period eq 'DAY' ? 'btn-primary' : 'btn-outline-primary'}"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=DAY&date=${report.anchor}">Ngày</a>
                <a class="btn ${report.period eq 'WEEK' ? 'btn-primary' : 'btn-outline-primary'}"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=WEEK&date=${report.anchor}">Tuần</a>
                <a class="btn ${report.period eq 'MONTH' ? 'btn-primary' : 'btn-outline-primary'}"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=MONTH&date=${report.anchor}">Tháng</a>
            </div>
        </div>

        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body d-flex flex-wrap justify-content-between align-items-end gap-3">
                <a class="btn btn-outline-secondary"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=${report.period}&date=${report.previousAnchor}">
                    <i class="bi bi-chevron-left"></i> Kỳ trước
                </a>
                <form method="get" action="${pageContext.request.contextPath}/shipper/statistics" class="d-flex gap-2 align-items-end">
                    <input type="hidden" name="period" value="${report.period}">
                    <div>
                        <label class="form-label fw-semibold mb-1">Chọn ngày tham chiếu</label>
                        <input class="form-control" type="date" name="date" value="${report.anchor}">
                    </div>
                    <button class="btn btn-primary"><i class="bi bi-search"></i> Xem</button>
                </form>
                <a class="btn btn-outline-secondary"
                   href="${pageContext.request.contextPath}/shipper/statistics?period=${report.period}&date=${report.nextAnchor}">
                    Kỳ sau <i class="bi bi-chevron-right"></i>
                </a>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100"><div class="card-body">
                    <div class="text-secondary mb-2"><i class="bi bi-check-circle text-success"></i> Đơn giao thành công</div>
                    <div class="display-6 fw-bold">${report.deliveredOrders}</div>
                </div></div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100"><div class="card-body">
                    <div class="text-secondary mb-2"><i class="bi bi-cash-stack text-primary"></i> Giá trị đơn đã giao</div>
                    <div class="h3 fw-bold mb-0"><fmt:formatNumber value="${report.deliveredValue}" type="number" groupingUsed="true"/> ₫</div>
                </div></div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100"><div class="card-body">
                    <div class="text-secondary mb-2"><i class="bi bi-calculator text-warning"></i> Giá trị trung bình</div>
                    <div class="h3 fw-bold mb-0"><fmt:formatNumber value="${report.averageOrderValue}" type="number" groupingUsed="true"/> ₫</div>
                </div></div>
            </div>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white py-3"><h5 class="mb-0">Chi tiết theo ngày</h5></div>
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead class="table-light"><tr><th>Ngày</th><th style="width:45%">Số đơn</th><th class="text-end">Giá trị đơn</th></tr></thead>
                    <tbody>
                        <c:forEach items="${report.points}" var="point">
                            <tr>
                                <td class="fw-semibold"><c:out value="${point.label}"/></td>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="progress flex-grow-1" style="height: 10px">
                                            <div class="progress-bar bg-success" style="width: ${point.percentage}%"></div>
                                        </div>
                                        <span class="badge text-bg-success">${point.orderCount} đơn</span>
                                    </div>
                                </td>
                                <td class="text-end fw-semibold"><fmt:formatNumber value="${point.orderValue}" type="number" groupingUsed="true"/> ₫</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <c:if test="${report.deliveredOrders eq 0}">
                <div class="card-footer bg-white text-center text-secondary py-4">
                    <i class="bi bi-inbox fs-2 d-block mb-2"></i>Chưa có đơn giao thành công trong kỳ này.
                </div>
            </c:if>
        </div>
    </main>
</body>
</html>
