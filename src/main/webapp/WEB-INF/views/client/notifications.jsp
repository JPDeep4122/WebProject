<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<jsp:include page="fragments/header.jsp" />

<main class="container py-4 customer-notifications" data-context="${pageContext.request.contextPath}">
    <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
        <div>
            <h1 class="h3 mb-1">Thông báo</h1>
            <p class="text-muted mb-0">Cập nhật về đơn hàng và voucher của bạn.</p>
        </div>
        <button type="button" class="btn btn-outline-primary" id="markAllNotificationsRead">
            Đánh dấu tất cả đã đọc
        </button>
    </div>
    <div id="notificationPageMessage" class="alert alert-danger d-none" role="alert"></div>
    <div id="notificationList" class="list-group shadow-sm" aria-live="polite">
        <div class="list-group-item text-muted">Đang tải thông báo…</div>
    </div>
</main>

<jsp:include page="fragments/footer.jsp" />
