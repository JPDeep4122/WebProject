<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="fragments/header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="bg-white p-5 rounded-4 shadow-sm border text-center">
                <div class="text-primary mb-3">
                    <i class="bi bi-search display-3"></i>
                </div>
                <h4 class="fw-bold text-dark mb-2">Tra cứu đơn hàng</h4>
                <p class="text-muted small mb-4">
                    Nhập mã đơn hàng và số điện thoại đặt hàng để kiểm tra tiến trình giao hàng.
                </p>

                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger rounded-3 text-start small mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/orders/tracking" method="post" class="text-start">
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">Mã đơn hàng</label>
                        <input type="text" name="orderCode" value="${orderCode}" class="form-control rounded-3 py-2" 
                               placeholder="Ví dụ: ORD202609206588" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label text-muted small fw-bold">Số điện thoại nhận hàng</label>
                        <input type="tel" name="phone" value="${phone}" class="form-control rounded-3 py-2" 
                               placeholder="Ví dụ: 0912345678" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-pill fw-bold shadow-sm">
                        <i class="bi bi-search me-1"></i>TRA CỨU TIẾN TRÌNH ĐƠN HÀNG
                    </button>
                </form>

                <div class="mt-4 pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/orders" class="text-decoration-none small text-muted">
                        <i class="bi bi-arrow-left me-1"></i>Về danh sách đơn hàng của tôi
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="fragments/footer.jsp" />