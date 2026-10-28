<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết đơn giao #${order.orderCode} — TECHSEVEN</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="/WEB-INF/views/admin/fragments/theme.jsp"/>
</head>
<body class="bg-light">
    <nav class="navbar navbar-dark sf-staff-navbar sticky-top py-2">
        <div class="container-fluid px-4">
            <a class="navbar-brand d-flex align-items-center gap-2 m-0" href="${pageContext.request.contextPath}/shipper/orders">
                <img class="sf-brand-logo" src="${pageContext.request.contextPath}/images/brand/techseven-logo.svg" alt="TECHSEVEN">
            </a>
            <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="${pageContext.request.contextPath}/shipper/orders">
                <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách đơn
            </a>
        </div>
    </nav>

    <main class="container py-4" style="max-width: 1040px;">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    Đơn hàng <span class="text-primary">#<c:out value="${order.orderCode}"/></span>
                </h3>
                <div class="text-secondary">
                    Phân công: #${assignment.id} • Trạng thái: 
                    <span class="badge rounded-pill ${assignment.status eq 'DELIVERED_SUCCESS' ? 'text-bg-success' : (assignment.status eq 'DELIVERED_FAILED' ? 'text-bg-danger' : 'text-bg-primary')} px-3">
                        <c:out value="${assignment.status.label}"/>
                    </span>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/shipper/orders" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                <i class="bi bi-chevron-left me-1"></i>Về danh sách
            </a>
        </div>

        <!-- 1. TIẾN TRÌNH CÁC MỐC THỜI GIAN -->
        <div class="card border-0 rounded-4 shadow-sm p-4 mb-4">
            <h5 class="fw-bold text-dark mb-3"><i class="bi bi-calendar2-check me-2 text-primary"></i>Tiến trình bàn giao đơn hàng</h5>
            <div class="row g-3 text-center">
                <div class="col-6 col-md-3">
                    <div class="p-3 rounded-3 bg-light border">
                        <small class="text-muted d-block mb-1">1. Phân công</small>
                        <strong class="text-dark"><c:out value="${assignment.assignedAtVn}" default="—"/></strong>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="p-3 rounded-3 bg-light border">
                        <small class="text-muted d-block mb-1">2. Lấy hàng</small>
                        <strong class="text-dark"><c:out value="${assignment.pickedUpAtVn}" default="Chưa lấy"/></strong>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="p-3 rounded-3 bg-light border">
                        <small class="text-muted d-block mb-1">3. Bắt đầu giao</small>
                        <strong class="text-primary"><c:out value="${assignment.deliveryStartedAtVn}" default="Chưa đi"/></strong>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="p-3 rounded-3 ${assignment.status eq 'DELIVERED_SUCCESS' ? 'bg-success-subtle border-success' : (assignment.status eq 'DELIVERED_FAILED' ? 'bg-danger-subtle border-danger' : 'bg-light border')} border">
                        <small class="text-muted d-block mb-1">4. Kết quả</small>
                        <strong class="${assignment.status eq 'DELIVERED_SUCCESS' ? 'text-success' : (assignment.status eq 'DELIVERED_FAILED' ? 'text-danger' : 'text-dark')}">
                            <c:out value="${assignment.completedAtVn}" default="Đang xử lý"/>
                        </strong>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <!-- 2. ĐỊA CHỈ & LIÊN HỆ -->
            <div class="col-md-6">
                <div class="card border-0 rounded-4 shadow-sm p-4 h-100">
                    <h5 class="fw-bold text-primary mb-3"><i class="bi bi-geo-alt me-2"></i>Điểm lấy &amp; Giao hàng</h5>
                    <div class="mb-3 p-3 bg-light rounded-3">
                        <small class="text-secondary d-block fw-semibold mb-1">Điểm lấy hàng (Kho chi nhánh):</small>
                        <div class="fw-bold text-dark"><c:out value="${order.branch.name}"/></div>
                        <div class="small text-secondary"><c:out value="${order.branch.address}"/></div>
                    </div>

                    <div class="p-3 bg-light rounded-3">
                        <small class="text-secondary d-block fw-semibold mb-1">Địa chỉ giao tới khách:</small>
                        <div class="fw-bold fs-6 text-dark mb-1"><c:out value="${order.recipientName}"/></div>
                        <div class="mb-2 text-dark"><c:out value="${order.shippingAddress}"/></div>
                        <a href="tel:${order.recipientPhone}" class="btn btn-sm btn-success rounded-pill px-3">
                            <i class="bi bi-telephone-outbound-fill me-1"></i>Gọi ngay: <c:out value="${order.recipientPhone}"/>
                        </a>
                    </div>
                </div>
            </div>

            <!-- 3. THANH TOÁN & THU HỘ -->
            <div class="col-md-6">
                <div class="card border-0 rounded-4 shadow-sm p-4 h-100">
                    <h5 class="fw-bold text-primary mb-3"><i class="bi bi-credit-card me-2"></i>Thanh toán &amp; Thu hộ</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary">Phương thức:</span>
                        <strong><c:out value="${order.payment.paymentMethod}"/> (<c:out value="${order.payment.paymentStatus}"/>)</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary">Tổng giá trị đơn:</span>
                        <strong class="fs-5 text-danger"><fmt:formatNumber value="${order.finalAmount}" type="number"/> ₫</strong>
                    </div>

                    <hr>
                    <c:choose>
                        <c:when test="${order.payment.paymentMethod eq 'VNPAY' and order.payment.paymentStatus eq 'SUCCESS'}">
                            <div class="alert alert-success py-2 px-3 rounded-3 mb-0 small fw-semibold">
                                <i class="bi bi-check-circle-fill me-1"></i>Đã thanh toán VNPay — Thu hộ: 0 ₫ (Không thu thêm tiền)
                            </div>
                        </c:when>
                        <c:when test="${order.payment.paymentMethod eq 'COD'}">
                            <div class="p-3 rounded-3 bg-warning-subtle border border-warning">
                                <div class="d-flex justify-content-between">
                                    <span class="fw-bold text-dark">Số tiền cần thu hộ (COD):</span>
                                    <span class="fs-5 fw-bold text-danger"><fmt:formatNumber value="${order.finalAmount}" type="number"/> ₫</span>
                                </div>
                                <c:if test="${not empty assignment.collectedAmount}">
                                    <div class="d-flex justify-content-between mt-2 pt-2 border-top border-warning">
                                        <span class="text-success fw-bold">Số tiền đã thu thực tế:</span>
                                        <span class="text-success fw-bold fs-5"><fmt:formatNumber value="${assignment.collectedAmount}" type="number"/> ₫</span>
                                    </div>
                                </c:if>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-warning py-2 px-3 rounded-3 mb-0 small">
                                Trạng thái thanh toán: <c:out value="${order.payment.paymentStatus}"/>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- 4. DANH SÁCH SẢN PHẨM CẦN BÀN GIAO -->
        <div class="card border-0 rounded-4 shadow-sm p-4 mb-4">
            <h5 class="fw-bold text-dark mb-3"><i class="bi bi-box-seam me-2 text-primary"></i>Danh sách sản phẩm cần bàn giao</h5>
            <div class="table-responsive">
                <table class="table table-bordered align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>STT</th>
                            <th>Tên sản phẩm</th>
                            <th class="text-center">Số lượng</th>
                            <th class="text-end">Đơn giá</th>
                            <th class="text-end">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${order.orderItems}" var="item" varStatus="loop">
                            <tr>
                                <td class="text-center fw-bold">${loop.index + 1}</td>
                                <td>
                                    <div class="fw-semibold text-dark"><c:out value="${item.product.name}"/></div>
                                    <small class="text-secondary">SKU: <c:out value="${item.product.sku}"/></small>
                                </td>
                                <td class="text-center fw-bold fs-6 text-primary">${item.quantity}</td>
                                <td class="text-end"><fmt:formatNumber value="${item.price}" type="number"/> ₫</td>
                                <td class="text-end fw-semibold"><fmt:formatNumber value="${item.price * item.quantity}" type="number"/> ₫</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 5. KẾT QUẢ BÀN GIAO & ẢNH MINH CHỨNG (KHI HOÀN TẤT) -->
        <c:if test="${assignment.status eq 'DELIVERED_SUCCESS'}">
            <div class="card border-0 rounded-4 shadow-sm p-4 mb-4">
                <h5 class="fw-bold text-success mb-3"><i class="bi bi-shield-check me-2"></i>Biên bản bàn giao thành công</h5>
                <div class="row g-4 align-items-center">
                    <div class="col-md-7">
                        <div class="mb-2"><span class="text-secondary">Người thực tế nhận:</span> <strong class="fs-6 text-dark"><c:out value="${assignment.receivedBy}"/></strong></div>
                        <div class="mb-2"><span class="text-secondary">Cách thu tiền:</span> <strong><c:out value="${not empty assignment.collectionMethod ? assignment.collectionMethod.label : 'N/A'}"/></strong></div>
                        <div class="mb-2"><span class="text-secondary">Thời điểm hoàn tất:</span> <strong><c:out value="${assignment.completedAtVn}"/></strong></div>
                        <div class="mb-2"><span class="text-secondary">Ghi chú bàn giao:</span> <c:out value="${assignment.completionNote}" default="(Không có ghi chú)"/></div>
                    </div>
                    <div class="col-md-5 text-center">
                        <c:if test="${not empty proofSignedUrl}">
                            <small class="text-secondary d-block fw-semibold mb-2">Ảnh minh chứng bàn giao:</small>
                            <a href="${proofSignedUrl}" target="_blank" class="d-inline-block border rounded-3 p-2 bg-light shadow-sm">
                                <img src="${proofSignedUrl}" alt="Ảnh minh chứng" class="img-fluid rounded-2" style="max-height: 200px;">
                                <div class="small text-primary mt-1"><i class="bi bi-box-arrow-up-right me-1"></i>Xem ảnh gốc</div>
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- 6. LỊCH SỬ TỪNG LẦN GIAO (DELIVERY_ATTEMPTS) -->
        <div class="card border-0 rounded-4 shadow-sm p-4">
            <h5 class="fw-bold text-dark mb-3"><i class="bi bi-clock-history me-2 text-primary"></i>Lịch sử các lượt giao (delivery_attempts)</h5>
            <div class="table-responsive">
                <table class="table table-bordered align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="text-center">Lượt #</th>
                            <th>Bắt đầu</th>
                            <th>Kết thúc</th>
                            <th>Trạng thái</th>
                            <th>Chi tiết kết quả / Lý do</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${attempts}" var="att">
                            <tr>
                                <td class="fw-bold text-center">${att.attemptNo}</td>
                                <td>${att.startedAtVn}</td>
                                <td><c:out value="${att.completedAtVn}" default="Đang giao..."/></td>
                                <td>
                                    <span class="badge ${att.status eq 'DELIVERED_SUCCESS' ? 'text-bg-success' : (att.status eq 'DELIVERED_FAILED' ? 'text-bg-danger' : 'text-bg-primary')}">
                                        <c:out value="${att.status.label}"/>
                                    </span>
                                </td>
                                <td>
                                    <c:if test="${not empty att.failureCode}">
                                        <div class="text-danger fw-semibold">[<c:out value="${att.failureCode.label}"/>]</div>
                                        <div class="small text-secondary"><c:out value="${att.failureDetails}"/></div>
                                    </c:if>
                                    <c:if test="${not empty att.receivedBy}">
                                        <div class="text-success fw-semibold">Người nhận: <c:out value="${att.receivedBy}"/></div>
                                        <div class="small text-secondary"><c:out value="${att.collectionMethod.label}"/> • Thu: <fmt:formatNumber value="${att.collectedAmount}" type="number"/> ₫</div>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>