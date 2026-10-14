<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="d-flex flex-column flex-shrink-0 p-3 text-white bg-dark" style="width: 260px; min-height: 100vh;">
    <a href="/admin" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none">
        <i class="bi bi-shield-lock-fill fs-4 text-warning me-2"></i>
        <span class="fs-5 fw-bold">QUẢN LÝ CỬA HÀNG</span>
    </a>
    <hr>
    <ul class="nav nav-pills flex-column mb-auto">
        <li class="nav-item">
            <a href="/admin" class="nav-link active text-white"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
        </li>
        <li>
            <a href="/admin/products" class="nav-link text-white-50"><i class="bi bi-box-seam me-2"></i> Quản lý Sản phẩm</a>
        </li>
        <li>
            <a href="/admin/categories" class="nav-link text-white-50"><i class="bi bi-tags me-2"></i> Quản lý Danh mục</a>
        </li>
        <li>
            <a href="/admin/orders" class="nav-link text-white-50"><i class="bi bi-receipt me-2"></i> Quản lý Đơn hàng</a>
        </li>
        <li>
            <a href="/admin/inventory" class="nav-link text-white-50"><i class="bi bi-boxes me-2"></i> Tồn kho chi nhánh</a>
        </li>
        <li>
            <a href="/admin/branches" class="nav-link text-white-50"><i class="bi bi-shop me-2"></i> Quản lý Chi nhánh</a>
        </li>
        <li>
            <a href="/admin/promotions" class="nav-link text-white-50"><i class="bi bi-percent me-2"></i> Khuyến mãi & Mã giảm</a>
        </li>
        <li>
            <a href="/admin/users" class="nav-link text-white-50"><i class="bi bi-people me-2"></i> Quản lý Người dùng</a>
        </li>
        <li>
            <a href="/admin/audit-logs" class="nav-link text-white-50"><i class="bi bi-journal-text me-2"></i> Nhật ký Audit Log</a>
        </li>
    </ul>
    <hr>
    <div class="dropdown">
        <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" data-bs-toggle="dropdown">
            <i class="bi bi-person-circle fs-4 me-2"></i>
            <strong>Admin / Manager</strong>
        </a>
        <ul class="dropdown-menu dropdown-menu-dark text-small shadow">
            <li><a class="dropdown-item" href="/"><i class="bi bi-box-arrow-up-right me-1"></i> Xem trang Khách</a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item text-danger" href="/logout"><i class="bi bi-box-arrow-right me-1"></i> Đăng xuất</a></li>
        </ul>
    </div>
</div>
