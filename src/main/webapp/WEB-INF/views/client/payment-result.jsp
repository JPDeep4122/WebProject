<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="fragments/header.jsp"/>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-9 col-xl-8">

            <div class="bg-white p-4 p-md-5 rounded-4 shadow-sm border">

                <!-- Môi trường kiểm thử -->
                <c:if test="${isSandbox}">
                    <div class="alert alert-warning text-center mb-4"
                         role="status">
                        <i class="bi bi-flask me-1"></i>
                        <strong>Môi trường Sandbox.</strong>
                        Đây là giao dịch thử nghiệm,
                        không phát sinh thanh toán thực tế.
                    </div>
                </c:if>

                <!-- Kết quả thanh toán -->
                <div class="text-center mb-4">
                    <c:choose>

                        <c:when test="${isSuccess}">
                            <div class="text-success mb-3">
                                <i class="bi bi-patch-check-fill display-1"></i>
                            </div>

                            <h2 class="fw-bold text-success">
                                THANH TOÁN THÀNH CÔNG!
                            </h2>

                            <p class="text-muted mb-3">
                                Giao dịch qua cổng VNPay
                                đã được hệ thống xác minh thành công.
                            </p>
                        </c:when>

                        <c:when test="${isRefunded}">
                            <div class="text-info mb-3">
                                <i class="bi bi-arrow-counterclockwise display-1"></i>
                            </div>

                            <h2 class="fw-bold text-info">
                                ĐÃ GHI NHẬN TRẠNG THÁI HOÀN TIỀN
                            </h2>

                            <p class="text-muted">
                                Xem chi tiết đơn hàng để theo dõi
                                thông tin và chứng từ hoàn tiền.
                            </p>
                        </c:when>

                        <c:when test="${isPending}">
                            <div class="text-primary mb-3">
                                <i class="bi bi-hourglass-split display-1"></i>
                            </div>

                            <h2 class="fw-bold text-primary">
                                ĐANG XÁC MINH THANH TOÁN
                            </h2>

                            <p class="text-muted">
                                Hệ thống đang chờ kết quả từ VNPay.
                                Vui lòng kiểm tra lại trạng thái sau.
                            </p>
                        </c:when>

                        <c:otherwise>
                            <div class="text-danger mb-3">
                                <i class="bi bi-x-circle-fill display-1"></i>
                            </div>

                            <h2 class="fw-bold text-danger">
                                THANH TOÁN CHƯA THÀNH CÔNG
                            </h2>

                            <p class="text-muted">
                                Đơn hàng và danh sách sản phẩm vẫn được lưu.
                                Hãy mở chi tiết đơn để tiếp tục xử lý.
                            </p>
                        </c:otherwise>

                    </c:choose>
                </div>

                <!-- Tiến độ xử lý đơn -->
                <div class="alert alert-info rounded-3 mb-4">
                    <i class="bi bi-info-circle me-1"></i>
                    <c:out value="${orderNextStep}"/>
                </div>

                <c:if test="${fullyPrepaid}">
                    <div class="alert alert-success rounded-3 mb-4">
                        <i class="bi bi-check-circle me-1"></i>
                        Đơn hàng đã được thanh toán đủ.
                        Bạn không cần thanh toán thêm khi nhận hàng.
                    </div>
                </c:if>

                <!-- Thông tin giao dịch và nhận hàng -->
                <div class="p-3 p-md-4 bg-light rounded-4 border mb-4">
                    <dl class="row gy-3 mb-0">

                        <dt class="col-md-5 text-muted fw-normal">
                            Mã đơn hàng
                        </dt>
                        <dd class="col-md-7 text-md-end fw-bold text-primary mb-0">
                            <c:out value="${order.orderCode}"/>
                        </dd>

                        <c:if test="${not empty transactionNo}">
                            <dt class="col-md-5 text-muted fw-normal">
                                Mã giao dịch VNPay
                            </dt>
                            <dd class="col-md-7 text-md-end fw-semibold mb-0">
                                <c:out value="${transactionNo}"/>
                            </dd>
                        </c:if>

                        <c:if test="${isSuccess or isRefunded}">
                            <dt class="col-md-5 text-muted fw-normal">
                                Thời gian thanh toán
                            </dt>
                            <dd class="col-md-7 text-md-end fw-semibold mb-0">
                                <c:out value="${paymentTimeText}"/>
                                <small class="text-muted d-block">
                                    Giờ Việt Nam (GMT+7)
                                </small>
                            </dd>
                        </c:if>

                        <c:if test="${not empty bankCode}">
                            <dt class="col-md-5 text-muted fw-normal">
                                Ngân hàng thanh toán
                            </dt>
                            <dd class="col-md-7 text-md-end mb-0">
                                <span class="badge bg-primary">
                                    <c:out value="${bankCode}"/>
                                    <c:if test="${not empty cardType}">
                                        (<c:out value="${cardType}"/>)
                                    </c:if>
                                </span>
                            </dd>
                        </c:if>

                        <dt class="col-md-5 text-muted fw-normal">
                            Người nhận
                        </dt>
                        <dd class="col-md-7 text-md-end fw-semibold mb-0">
                            <c:out value="${order.recipientName}"/>
                        </dd>

                        <dt class="col-md-5 text-muted fw-normal">
                            Số điện thoại
                        </dt>
                        <dd class="col-md-7 text-md-end fw-semibold mb-0">
                            <c:out value="${order.recipientPhone}"/>
                        </dd>

                        <dt class="col-md-5 text-muted fw-normal">
                            Địa chỉ nhận hàng
                        </dt>
                        <dd class="col-md-7 text-md-end fw-semibold text-break mb-0">
                            <c:out value="${order.shippingAddress}"/>
                        </dd>

                        <dt class="col-md-5 text-muted fw-normal">
                            Chi nhánh xử lý
                        </dt>
                        <dd class="col-md-7 text-md-end fw-semibold mb-0">
                            <c:choose>
                                <c:when test="${not empty order.branch}">
                                    <c:out value="${order.branch.name}"/>
                                </c:when>
                                <c:otherwise>
                                    Đang xác định
                                </c:otherwise>
                            </c:choose>
                        </dd>

                        <c:if test="${not empty order.branch.phone}">
                            <dt class="col-md-5 text-muted fw-normal">
                                Liên hệ chi nhánh
                            </dt>
                            <dd class="col-md-7 text-md-end fw-semibold mb-0">
                                <i class="bi bi-telephone me-1"></i>
                                <c:out value="${order.branch.phone}"/>
                            </dd>
                        </c:if>

                    </dl>

                    <div class="d-flex flex-wrap justify-content-between
                                align-items-center gap-2 border-top pt-3 mt-3">
                        <span class="fw-bold fs-5">
                            <c:choose>
                                <c:when test="${isSuccess}">
                                    Số tiền đã thanh toán
                                </c:when>
                                <c:when test="${isRefunded}">
                                    Số tiền giao dịch gốc
                                </c:when>
                                <c:otherwise>
                                    Giá trị thanh toán
                                </c:otherwise>
                            </c:choose>
                        </span>

                        <span class="fw-bold fs-4 ${isSuccess ? 'text-success' : 'text-dark'}">
                            <fmt:formatNumber
                                value="${order.payment.amount}"
                                type="number"
                                maxFractionDigits="0"
                                groupingUsed="true"/>
                            ₫
                        </span>
                    </div>
                </div>

                <!-- Các thao tác -->
                <div class="d-flex flex-wrap gap-3 justify-content-center">

                    <a href="${pageContext.request.contextPath}/orders/${order.orderCode}"
                       class="btn btn-primary rounded-pill px-4 fw-bold">
                        <i class="bi bi-receipt me-1"></i>
                        Xem chi tiết đơn hàng
                    </a>

                    <a href="${pageContext.request.contextPath}/products"
                       class="btn btn-outline-primary rounded-pill px-4">
                        <i class="bi bi-bag me-1"></i>
                        Tiếp tục mua sắm
                    </a>

                    <c:if test="${order.payment.paymentLinkAvailable}">
                        <form method="post"
                              action="${pageContext.request.contextPath}/checkout/orders/${order.orderCode}/pay">

                            <input type="hidden"
                                   name="${_csrf.parameterName}"
                                   value="${_csrf.token}">

                            <button type="submit"
                                    class="btn btn-outline-primary rounded-pill px-4">
                                Tiếp tục thanh toán VNPay
                            </button>
                        </form>
                    </c:if>

                    <c:if test="${isPending}">
                        <button type="button"
                                onclick="window.location.reload()"
                                class="btn btn-outline-secondary rounded-pill px-4">
                            <i class="bi bi-arrow-clockwise me-1"></i>
                            Tải lại trạng thái
                        </button>
                    </c:if>

                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="fragments/footer.jsp"/>