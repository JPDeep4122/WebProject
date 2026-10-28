<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đơn giao của tôi — TECHSEVEN</title>
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
                <a class="btn btn-warning btn-sm fw-bold rounded-pill px-3" href="${pageContext.request.contextPath}/shipper/statistics">
                    <i class="bi bi-bar-chart-fill me-1"></i>Thống kê
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

    <main class="container-fluid px-4 py-4" style="max-width: 1440px;">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div>
                <h2 class="fw-bold mb-1 text-dark"><i class="bi bi-box-seam text-primary me-2"></i>Đơn được phân công</h2>
                <div class="text-secondary">Danh sách đơn hàng bạn phụ trách vận chuyển, thu hộ và cập nhật tiến độ</div>
            </div>
            <span class="badge rounded-pill text-bg-primary fs-6 px-3 py-2 shadow-sm">
                Tổng: ${assignmentsPage.totalElements} đơn
            </span>
        </div>

        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show rounded-4 shadow-sm mb-4" role="alert">
                <i class="bi bi-check-circle-fill fs-5 me-2 align-middle"></i>
                <span class="align-middle fw-medium"><c:out value="${success}"/></span>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show rounded-4 shadow-sm mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill fs-5 me-2 align-middle"></i>
                <span class="align-middle fw-medium"><c:out value="${error}"/></span>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
            </div>
        </c:if>

        <div class="card border-0 rounded-4 shadow-sm mb-4">
            <div class="card-body p-3 p-md-4">
                <form method="get" action="${pageContext.request.contextPath}/shipper/orders" class="row g-3 align-items-end">
                    <div class="col-md-5 col-lg-4">
                        <label class="form-label fw-semibold">Trạng thái giao hàng</label>
                        <select class="form-select rounded-3" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach items="${statuses}" var="item">
                                <option value="${item}" ${selectedStatus eq item.toString() ? 'selected' : ''}>
                                    <c:out value="${item.label}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3 col-lg-2">
                        <label class="form-label fw-semibold">Số dòng</label>
                        <select class="form-select rounded-3" name="size">
                            <option value="10" ${pageSize eq 10 ? 'selected' : ''}>10 dòng</option>
                            <option value="20" ${pageSize eq 20 ? 'selected' : ''}>20 dòng</option>
                            <option value="50" ${pageSize eq 50 ? 'selected' : ''}>50 dòng</option>
                        </select>
                    </div>
                    <div class="col-md-4 d-flex gap-2">
                        <button class="btn btn-primary rounded-3 px-4 fw-medium"><i class="bi bi-funnel me-1"></i>Lọc đơn</button>
                        <a class="btn btn-outline-secondary rounded-3 px-3" href="${pageContext.request.contextPath}/shipper/orders">Đặt lại</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 rounded-4 shadow-sm overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="sf-table-head">
                        <tr>
                            <th class="ps-3">Mã đơn</th>
                            <th>Khách nhận</th>
                            <th>Địa chỉ giao</th>
                            <th class="text-end">Tiền cần thu</th>
                            <th>Tiến độ thời gian</th>
                            <th>Trạng thái</th>
                            <th class="pe-3 text-center" style="min-width: 250px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${assignmentsPage.content}" var="assignment">
                            <c:set var="order" value="${assignment.order}"/>
                            <c:set var="paymentMethodName" value="${not empty order.payment ? order.payment.paymentMethod.toString() : ''}"/>
                            <c:set var="paymentStatusName" value="${not empty order.payment ? order.payment.paymentStatus.toString() : ''}"/>
                            <c:set var="isCod" value="${paymentMethodName eq 'COD'}"/>
                            <c:set var="isVnPayPaid" value="${paymentMethodName eq 'VNPAY' and paymentStatusName eq 'SUCCESS'}"/>
                            <c:set var="isCodPending" value="${isCod and paymentStatusName eq 'PENDING'}"/>
                            <tr>
                                <td class="ps-3">
                                    <a href="${pageContext.request.contextPath}/shipper/orders/${assignment.id}" class="fw-bold text-primary text-decoration-none">
                                        <c:out value="${order.orderCode}"/>
                                    </a>
                                </td>
                                <td>
                                    <div class="fw-semibold"><c:out value="${order.recipientName}"/></div>
                                    <a class="text-decoration-none small fw-medium" href="tel:${order.recipientPhone}">
                                        <i class="bi bi-telephone-fill text-success me-1"></i><c:out value="${order.recipientPhone}"/>
                                    </a>
                                </td>
                                <td style="max-width: 260px;">
                                    <div class="small"><c:out value="${order.shippingAddress}"/></div>
                                    <small class="text-secondary d-block mt-1">Lấy tại: <strong><c:out value="${order.branch.name}"/></strong></small>
                                </td>

                                <td class="text-end text-nowrap">
                                    <c:choose>
                                        <c:when test="${isVnPayPaid}">
                                            <div class="fw-bold text-success">0 ₫</div>
                                            <span class="badge text-bg-success-subtle text-success border border-success-subtle">VNPay đã trả</span>
                                        </c:when>
                                        <c:when test="${isCodPending}">
                                            <div class="fw-bold text-danger fs-6"><fmt:formatNumber value="${order.finalAmount}" type="number"/> ₫</div>
                                            <span class="badge text-bg-warning text-dark">Thu hộ COD</span>
                                        </c:when>
                                        <c:when test="${isCod and paymentStatusName eq 'SUCCESS'}">
                                            <div class="fw-bold text-success">0 ₫</div>
                                            <small class="text-secondary d-block">Đã thu COD: <fmt:formatNumber value="${not empty assignment.collectedAmount ? assignment.collectedAmount : order.finalAmount}" type="number"/> ₫</small>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="fw-bold text-secondary">0 ₫</div>
                                            <small class="text-secondary"><c:out value="${paymentStatusName}" default="N/A"/></small>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="small text-secondary" style="min-width: 190px;">
                                    <div>Phân công: <strong>${assignment.assignedAtVn}</strong></div>
                                    <c:if test="${not empty assignment.pickedUpAtVn}"><div>Lấy hàng: <strong>${assignment.pickedUpAtVn}</strong></div></c:if>
                                    <c:if test="${not empty assignment.deliveryStartedAtVn}"><div class="text-primary">Bắt đầu giao: <strong>${assignment.deliveryStartedAtVn}</strong></div></c:if>
                                    <c:if test="${not empty assignment.completedAtVn}"><div class="text-dark">Kết thúc: <strong>${assignment.completedAtVn}</strong></div></c:if>
                                </td>

                                <td>
                                    <span class="badge rounded-pill ${assignment.status eq 'DELIVERED_SUCCESS' ? 'text-bg-success' : (assignment.status eq 'DELIVERED_FAILED' ? 'text-bg-danger' : (assignment.status eq 'DELIVERING' ? 'text-bg-primary' : (assignment.status eq 'PICKED_UP' ? 'text-bg-info text-white' : 'text-bg-secondary')))} px-3 py-2">
                                        <c:out value="${assignment.status.label}"/>
                                    </span>
                                </td>

                                <!-- KHU VỰC NÚT BẤM CHUẨN HÓA THEO TỪNG TRẠNG THÁI -->
                                <td class="pe-3 text-center">
                                    <div class="d-flex flex-column gap-2">
                                        <!-- 1. Trạng thái: Chờ nhận hàng (ASSIGNED) -->
                                        <c:if test="${assignment.status eq 'ASSIGNED'}">
                                            <button type="button" class="btn btn-sm btn-info text-white rounded-3 fw-medium w-100 shadow-sm"
                                                    data-bs-toggle="modal" data-bs-target="#pickupModal_${assignment.id}">
                                                <i class="bi bi-box-seam me-1"></i>Xác nhận đã lấy hàng
                                            </button>
                                            <a href="${pageContext.request.contextPath}/shipper/orders/${assignment.id}" class="btn btn-sm btn-outline-secondary rounded-3 w-100">
                                                <i class="bi bi-info-circle me-1"></i>Chi tiết
                                            </a>
                                        </c:if>

                                        <!-- 2. Trạng thái: Đã lấy hàng (PICKED_UP) -->
                                        <c:if test="${assignment.status eq 'PICKED_UP'}">
                                            <button type="button" class="btn btn-sm btn-primary rounded-3 fw-medium w-100 shadow-sm"
                                                    data-bs-toggle="modal" data-bs-target="#startDeliveryModal_${assignment.id}">
                                                <i class="bi bi-truck me-1"></i>Bắt đầu giao
                                            </button>
                                            <a href="${pageContext.request.contextPath}/shipper/orders/${assignment.id}" class="btn btn-sm btn-outline-secondary rounded-3 w-100">
                                                <i class="bi bi-info-circle me-1"></i>Chi tiết
                                            </a>
                                        </c:if>

                                        <!-- 3. Trạng thái: Đang giao (DELIVERING) -->
                                        <c:if test="${assignment.status eq 'DELIVERING'}">
                                            <button type="button" class="btn btn-sm btn-success rounded-3 fw-semibold w-100 shadow-sm"
                                                    data-bs-toggle="modal" data-bs-target="#completeModal_${assignment.id}">
                                                <i class="bi bi-check-circle me-1"></i>Giao thành công
                                            </button>
                                            <button type="button" class="btn btn-sm btn-outline-danger rounded-3 fw-semibold w-100"
                                                    data-bs-toggle="modal" data-bs-target="#failModal_${assignment.id}">
                                                <i class="bi bi-x-circle me-1"></i>Giao thất bại
                                            </button>
                                            <a href="${pageContext.request.contextPath}/shipper/orders/${assignment.id}" class="btn btn-sm btn-outline-secondary rounded-3 w-100">
                                                <i class="bi bi-info-circle me-1"></i>Chi tiết
                                            </a>
                                        </c:if>

                                        <!-- 4. Trạng thái: Giao thất bại (DELIVERED_FAILED) -->
                                        <c:if test="${assignment.status eq 'DELIVERED_FAILED'}">
                                            <a href="${pageContext.request.contextPath}/shipper/orders/${assignment.id}" class="btn btn-sm btn-outline-secondary rounded-3 w-100">
                                                <i class="bi bi-info-circle me-1"></i>Chi tiết
                                            </a>
                                            <c:choose>
                                                <c:when test="${not empty assignment.failureCode and assignment.failureCode.requiresStaffReview}">
                                                    <span class="badge text-bg-warning text-dark text-wrap p-2 w-100">
                                                        <i class="bi bi-shield-exclamation me-1"></i>Chờ chi nhánh kiểm tra
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button" class="btn btn-sm btn-outline-primary rounded-3 w-100 fw-medium"
                                                            data-bs-toggle="modal" data-bs-target="#startDeliveryModal_${assignment.id}">
                                                        <i class="bi bi-arrow-repeat me-1"></i>Giao lại
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>

                                        <!-- 5. Trạng thái: Giao thành công (DELIVERED_SUCCESS) -->
                                        <c:if test="${assignment.status eq 'DELIVERED_SUCCESS'}">
                                            <a href="${pageContext.request.contextPath}/shipper/orders/${assignment.id}" class="btn btn-sm btn-outline-success rounded-3 w-100 fw-medium">
                                                <i class="bi bi-check2-all me-1"></i>Xem kết quả giao
                                            </a>
                                        </c:if>
                                    </div>

                                    <!-- MODAL XÁC NHẬN LẤY HÀNG (Thay cho window.confirm) -->
                                    <div class="modal fade" id="pickupModal_${assignment.id}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content rounded-4 border-0 shadow">
                                                <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/pickup" class="shipper-action-form">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <div class="modal-header bg-info text-white rounded-top-4">
                                                        <h5 class="modal-title fw-bold"><i class="bi bi-box-seam me-2"></i>Xác nhận lấy kiện hàng</h5>
                                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body text-start p-4">
                                                        <p class="mb-2">Bạn xác nhận đã nhận kiện hàng cho đơn <strong><c:out value="${order.orderCode}"/></strong> từ chi nhánh <strong><c:out value="${order.branch.name}"/></strong>?</p>
                                                        <div class="small text-secondary"><i class="bi bi-geo-alt me-1"></i>Địa chỉ kho: <c:out value="${order.branch.address}"/></div>
                                                    </div>
                                                    <div class="modal-footer bg-light rounded-bottom-4">
                                                        <button type="button" class="btn btn-outline-secondary rounded-3" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-info text-white rounded-3 fw-medium px-4">Xác nhận đã lấy hàng</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- MODAL BẮT ĐẦU GIAO (Thay cho window.confirm) -->
                                    <div class="modal fade" id="startDeliveryModal_${assignment.id}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content rounded-4 border-0 shadow">
                                                <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/start-delivery" class="shipper-action-form">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <div class="modal-header bg-primary text-white rounded-top-4">
                                                        <h5 class="modal-title fw-bold"><i class="bi bi-truck me-2"></i>Bắt đầu đi giao hàng</h5>
                                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body text-start p-4">
                                                        <p class="mb-2">Bắt đầu tiến trình giao đơn <strong><c:out value="${order.orderCode}"/></strong> tới khách hàng?</p>
                                                        <div class="p-3 bg-light rounded-3 small">
                                                            <div>Khách nhận: <strong><c:out value="${order.recipientName}"/></strong> (<c:out value="${order.recipientPhone}"/>)</div>
                                                            <div>Địa chỉ: <c:out value="${order.shippingAddress}"/></div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer bg-light rounded-bottom-4">
                                                        <button type="button" class="btn btn-outline-secondary rounded-3" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-primary rounded-3 fw-medium px-4">Bắt đầu đi giao</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- MODAL GIAO THÀNH CÔNG -->
                                    <div class="modal fade" id="completeModal_${assignment.id}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content rounded-4 border-0 shadow">
                                                <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/success" enctype="multipart/form-data" class="shipper-action-form">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <div class="modal-header bg-success text-white rounded-top-4">
                                                        <h5 class="modal-title fw-bold"><i class="bi bi-box2-heart me-2"></i>Xác nhận Giao hàng thành công</h5>
                                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body p-4 text-start">
                                                        <div class="p-3 rounded-3 bg-light border mb-3 small">
                                                            <div class="d-flex justify-content-between mb-1">
                                                                <span class="text-secondary">Mã đơn:</span>
                                                                <strong class="text-primary"><c:out value="${order.orderCode}"/></strong>
                                                            </div>
                                                            <div class="d-flex justify-content-between mb-1">
                                                                <span class="text-secondary">Người nhận dự kiến:</span>
                                                                <strong><c:out value="${order.recipientName}"/></strong>
                                                            </div>
                                                            <div><span class="text-secondary">Địa chỉ:</span> <c:out value="${order.shippingAddress}"/></div>
                                                        </div>

                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Người thực tế nhận hàng <span class="text-danger">*</span></label>
                                                            <input type="text" name="receivedBy" class="form-control" maxlength="100" value="<c:out value='${order.recipientName}'/>" required>
                                                        </div>

                                                        <c:choose>
                                                            <c:when test="${isCod}">
                                                                <div class="p-3 rounded-3 border border-warning bg-warning-subtle mb-3">
                                                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                                                        <span class="fw-bold text-dark">Số tiền COD cần thu:</span>
                                                                        <span class="fs-5 fw-bold text-danger"><fmt:formatNumber value="${order.finalAmount}" type="number"/> ₫</span>
                                                                    </div>
                                                                    <input type="hidden" name="collectionMethod" value="CASH">
                                                                    <input type="hidden" name="collectedAmount" value="${order.finalAmount}">
                                                                    <div class="form-check mt-2">
                                                                        <input class="form-check-input" type="checkbox" id="codCheck_${assignment.id}" name="codConfirmed" value="true" required>
                                                                        <label class="form-check-label fw-semibold small" for="codCheck_${assignment.id}">
                                                                            Xác nhận đã nhận đủ tiền mặt từ khách hàng <span class="text-danger">*</span>
                                                                        </label>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="alert alert-success py-2 px-3 rounded-3 mb-3 small fw-semibold">
                                                                    <i class="bi bi-shield-check me-1"></i>Đã thanh toán VNPay — Thu hộ: 0 ₫
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Ảnh minh chứng bàn giao <span class="text-danger">*</span></label>
                                                            <input type="file" name="proof" class="form-control" accept="image/jpeg,image/png" capture="environment" required>
                                                            <div class="form-text">Chụp kiện hàng đã bàn giao. Định dạng JPG/PNG, tối đa 5 MB.</div>
                                                        </div>

                                                        <div class="mb-2">
                                                            <label class="form-label fw-semibold">Ghi chú <span class="text-secondary fw-normal small">(Tùy chọn)</span></label>
                                                            <textarea name="completionNote" class="form-control" rows="2" maxlength="500" placeholder="Ghi chú thêm..."></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer bg-light rounded-bottom-4">
                                                        <button type="button" class="btn btn-outline-secondary rounded-3" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-success rounded-3 fw-semibold px-4">Xác nhận hoàn tất</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- MODAL GIAO THẤT BẠI -->
                                    <div class="modal fade" id="failModal_${assignment.id}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content rounded-4 border-0 shadow">
                                                <form method="post" action="${pageContext.request.contextPath}/shipper/orders/${assignment.id}/failure" enctype="multipart/form-data" class="shipper-action-form">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <div class="modal-header bg-danger text-white rounded-top-4">
                                                        <h5 class="modal-title fw-bold"><i class="bi bi-exclamation-octagon me-2"></i>Báo cáo Giao hàng thất bại</h5>
                                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body p-4 text-start">
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Lý do thất bại <span class="text-danger">*</span></label>
                                                            <select name="failureCode" class="form-select" required>
                                                                <option value="">-- Chọn lý do thất bại --</option>
                                                                <c:forEach items="${failureCodes}" var="fc">
                                                                    <c:if test="${not (paymentMethodName eq 'VNPAY' and fc eq 'INSUFFICIENT_COD_PAYMENT')}">
                                                                        <option value="${fc}"><c:out value="${fc.label}"/></option>
                                                                    </c:if>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Chi tiết lý do <span class="text-danger">*</span></label>
                                                            <textarea name="failureReason" class="form-control" rows="3" minlength="10" maxlength="1000" placeholder="Ví dụ: Đã gọi khách lúc 14:10 và 14:20 nhưng không liên lạc được." required></textarea>
                                                            <div class="form-text">Bắt buộc nhập từ 10 đến 1.000 ký tự.</div>
                                                        </div>
                                                        <div class="mb-2">
                                                            <label class="form-label fw-semibold">Ảnh minh chứng <span class="text-secondary fw-normal small">(Tùy chọn)</span></label>
                                                            <input type="file" name="proof" class="form-control" accept="image/jpeg,image/png" capture="environment">
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer bg-light rounded-bottom-4">
                                                        <button type="button" class="btn btn-outline-secondary rounded-3" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-danger rounded-3 fw-semibold px-4">Xác nhận thất bại</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty assignmentsPage.content}">
                            <tr><td colspan="7" class="text-center py-5 text-secondary">
                                <i class="bi bi-inbox fs-1 d-block mb-2 text-muted"></i>
                                Không có đơn giao phù hợp.
                            </td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <c:if test="${assignmentsPage.totalPages gt 1}">
            <nav class="mt-4" aria-label="Phân trang đơn giao">
                <ul class="pagination justify-content-center">
                    <c:forEach begin="0" end="${assignmentsPage.totalPages - 1}" var="index">
                        <c:url var="pageUrl" value="/shipper/orders">
                            <c:param name="page" value="${index}"/>
                            <c:param name="size" value="${pageSize}"/>
                            <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                        </c:url>
                        <li class="page-item ${assignmentsPage.number eq index ? 'active' : ''}">
                            <a class="page-link" href="${pageUrl}">${index + 1}</a>
                        </li>
                    </c:forEach>
                </ul>
            </nav>
        </c:if>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.querySelectorAll('.shipper-action-form').forEach(form => {
            form.addEventListener('submit', function (e) {
                const btn = form.querySelector('button[type="submit"]');
                if (btn && !btn.disabled) {
                    btn.disabled = true;
                    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang lưu kết quả...';
                }
            });
        });
    </script>
</body>
</html>