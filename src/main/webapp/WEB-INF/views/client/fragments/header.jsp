<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- Topbar thông tin -->
<div class="bg-primary text-white py-1 small">
    <div class="container d-flex justify-content-between align-items-center">
        <div><i class="bi bi-telephone-fill me-1"></i> Hotline: 1800.1061 (Miễn phí)</div>
        <div>
            <a href="#" class="text-white text-decoration-none me-3"><i class="bi bi-geo-alt-fill me-1"></i> Hệ thống 50+ chi nhánh</a>
            <a href="#" class="text-white text-decoration-none"><i class="bi bi-person-fill me-1"></i> Đăng nhập / Đăng ký</a>
        </div>
    </div>
</div>

<!-- Header chính: Logo + Tìm kiếm + Giỏ hàng -->
<header class="bg-white border-bottom sticky-top shadow-sm py-2">
    <div class="container d-flex align-items-center justify-content-between gap-3">
        <!-- Logo -->
        <a class="navbar-brand fw-bold text-primary fs-3 d-flex align-items-center" href="/">
            <i class="bi bi-lightning-charge-fill me-1"></i> ĐIỆN MÁY SHOP
        </a>

        <!-- Thanh tìm kiếm dùng chung -->
        <form class="flex-grow-1 mx-lg-5" action="/search" method="get">
            <div class="input-group">
                <input type="text" name="keyword" class="form-control" placeholder="Bạn cần tìm điện thoại, tủ lạnh, tivi, máy giặt...?" required>
                <button class="btn btn-primary px-4" type="submit">
                    <i class="bi bi-search"></i> Tìm kiếm
                </button>
            </div>
        </form>

        <!-- Nút Tra cứu đơn & Giỏ hàng -->
        <div class="d-flex align-items-center gap-3">
            <a href="/orders/history" class="btn btn-outline-secondary btn-sm d-none d-md-inline-block">
                <i class="bi bi-truck me-1"></i> Tra cứu đơn
            </a>
            <a href="/cart" class="btn btn-primary position-relative">
                <i class="bi bi-cart3 fs-5"></i>
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                    0
                </span>
            </a>
        </div>
    </div>

    <!-- Menu Danh mục nhanh -->
    <nav class="container mt-2 d-none d-md-block">
        <ul class="nav nav-pills gap-2 small">
            <li class="nav-item"><a class="nav-link active py-1" href="/"><i class="bi bi-house-door"></i> Trang chủ</a></li>
            <li class="nav-item"><a class="nav-link text-dark py-1" href="/category/tivi"><i class="bi bi-tv"></i> Tivi</a></li>
            <li class="nav-item"><a class="nav-link text-dark py-1" href="/category/tu-lanh"><i class="bi bi-snow"></i> Tủ lạnh</a></li>
            <li class="nav-item"><a class="nav-link text-dark py-1" href="/category/may-giat"><i class="bi bi-water"></i> Máy giặt</a></li>
            <li class="nav-item"><a class="nav-link text-dark py-1" href="/category/dieu-hoa"><i class="bi bi-wind"></i> Điều hòa</a></li>
            <li class="nav-item"><a class="nav-link text-dark py-1" href="/category/gia-dung"><i class="bi bi-plug"></i> Gia dụng</a></li>
        </ul>
    </nav>
</header>