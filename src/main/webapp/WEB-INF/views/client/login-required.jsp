<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="fragments/header.jsp" />
<main class="container py-5">
    <div class="bg-white border rounded-4 shadow-sm p-4 p-md-5 text-center mx-auto" style="max-width: 640px;">
        <i class="bi bi-person-lock text-primary display-4" aria-hidden="true"></i>
        <h1 class="h3 fw-bold mt-3"><c:out value="${loginRequiredTitle}" /></h1>
        <p class="text-muted my-3">Bạn có thể xem sản phẩm và thêm vào giỏ hàng khi chưa đăng nhập.
            Vui lòng đăng nhập để mua hàng, xem đơn hàng hoặc quản lý hồ sơ.</p>
        <a class="btn btn-primary rounded-pill px-4 py-2" href="<c:out value='${loginUrl}'/>">
            <i class="bi bi-box-arrow-in-right me-1" aria-hidden="true"></i>Đăng nhập để tiếp tục
        </a>
        <div class="d-flex justify-content-center gap-3 flex-wrap mt-4">
            <a href="${pageContext.request.contextPath}/cart">Xem giỏ hàng</a>
            <a href="${pageContext.request.contextPath}/products">Tiếp tục xem sản phẩm</a>
        </div>
    </div>
</main>
<jsp:include page="fragments/footer.jsp" />
