<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="adminCurrentPath" value="${requestScope['jakarta.servlet.forward.request_uri']}" />
<c:if test="${empty adminCurrentPath}">
    <c:set var="adminCurrentPath" value="${pageContext.request.requestURI}" />
</c:if>
<c:set var="adminCurrentPath" value="${fn:substringAfter(adminCurrentPath, pageContext.request.contextPath)}" />
<aside class="admin-sidebar">
    <a href="${pageContext.request.contextPath}/admin" class="admin-brand">
        <img src="${pageContext.request.contextPath}/images/brand/techseven-logo.svg" alt="TECHSEVEN">
        <small>KHU VỰC QUẢN TRỊ</small>
    </a>
    <hr>
    <ul class="nav nav-pills flex-column mb-auto">
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin" class="nav-link ${adminCurrentPath eq '/admin' ? 'active text-white' : 'text-white-50'}" ${adminCurrentPath eq '/admin' ? 'aria-current="page"' : ''}><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/products" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/products') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/products') ? 'aria-current="page"' : ''}><i class="bi bi-box-seam me-2"></i> Quản lý Sản phẩm</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/categories" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/categories') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/categories') ? 'aria-current="page"' : ''}><i class="bi bi-tags me-2"></i> Quản lý Danh mục</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/orders" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/orders') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/orders') ? 'aria-current="page"' : ''}><i class="bi bi-receipt me-2"></i> Quản lý Đơn hàng</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/invoices" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/invoices') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/invoices') ? 'aria-current="page"' : ''}><i class="bi bi-receipt-cutoff me-2"></i> Hóa đơn</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/inventory" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/inventory') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/inventory') ? 'aria-current="page"' : ''}><i class="bi bi-boxes me-2"></i> Tồn kho chi nhánh</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/returns" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/returns') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/returns') ? 'aria-current="page"' : ''}><i class="bi bi-arrow-counterclockwise me-2"></i> Yêu cầu trả hàng</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/branches" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/branches') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/branches') ? 'aria-current="page"' : ''}><i class="bi bi-shop me-2"></i> Quản lý Chi nhánh</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/promotions" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/promotions') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/promotions') ? 'aria-current="page"' : ''}><i class="bi bi-percent me-2"></i> Khuyến mãi & Mã giảm</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/users') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/users') ? 'aria-current="page"' : ''}><i class="bi bi-people me-2"></i> Quản lý Người dùng</a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/audit-logs" class="nav-link ${fn:startsWith(adminCurrentPath, '/admin/audit-logs') ? 'active text-white' : 'text-white-50'}" ${fn:startsWith(adminCurrentPath, '/admin/audit-logs') ? 'aria-current="page"' : ''}><i class="bi bi-journal-text me-2"></i> Nhật ký Audit Log</a>
        </li>
    </ul>
    <hr>
    <div class="admin-account dropdown">
        <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" data-bs-toggle="dropdown">
            <span class="admin-account-icon"><i class="bi bi-person-fill-gear"></i></span>
            <span><strong>Quản trị viên</strong><small>Quản lý hệ thống</small></span>
        </a>
        <ul class="dropdown-menu dropdown-menu-dark text-small shadow">
            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/"><i class="bi bi-box-arrow-up-right me-1"></i> Xem trang bán hàng</a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-1"></i> Đăng xuất</a></li>
        </ul>
    </div>
</aside>
