<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!-- 1. Nhúng Header chuẩn Điện Máy -->
<jsp:include page="fragments/header.jsp" />

<style>
    .voucher-page-bg {
        background-color: #f4f6f8;
        min-height: calc(100vh - 250px);
    }
    .voucher-banner {
        background: linear-gradient(135deg, #0b66c3 0%, #003e82 100%);
        color: #ffffff;
        border-radius: 20px;
        padding: 35px 30px;
    }

    /* THIẾT KẾ THẺ VÉ VOUCHER CẮT RĂNG CƯA ĐẶC TRƯNG */
    .voucher-ticket {
        display: flex;
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        position: relative;
        border: 1px solid #e2e8f0;
        overflow: hidden;
        transition: all 0.25s ease;
        height: 100%;
    }
    .voucher-ticket:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 24px rgba(11, 102, 195, 0.12);
        border-color: #93c5fd;
    }

    /* Vết cắt tròn 2 bên tạo hình chiếc vé thật */
    .voucher-ticket::before, .voucher-ticket::after {
        content: '';
        position: absolute;
        width: 20px;
        height: 20px;
        background-color: #f4f6f8; /* trùng màu nền trang */
        border-radius: 50%;
        left: 110px;
        z-index: 2;
        border: 1px solid #e2e8f0;
    }
    .voucher-ticket::before { top: -11px; }
    .voucher-ticket::after { bottom: -11px; }

    /* Cột trái của vé */
    .voucher-left {
        width: 120px;
        min-width: 120px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 16px 8px;
        color: #ffffff;
        text-align: center;
    }
    .bg-voucher-blue { background: linear-gradient(135deg, #0b66c3, #0284c7); }
    .bg-voucher-orange { background: linear-gradient(135deg, #ea580c, #f97316); }
    .bg-voucher-green { background: linear-gradient(135deg, #16a34a, #22c55e); }
    .bg-voucher-purple { background: linear-gradient(135deg, #9333ea, #a855f7); }

    /* Cột phải của vé */
    .voucher-right {
        padding: 16px 18px 16px 24px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        flex-grow: 1;
    }
    .voucher-code-badge {
        background-color: #f1f5f9;
        color: #0b66c3;
        font-weight: 700;
        letter-spacing: 0.5px;
        padding: 4px 10px;
        border-radius: 6px;
        border: 1px dashed #0b66c3;
        font-size: 0.85rem;
    }
    .btn-copy-code {
        border-radius: 50px;
        font-size: 0.82rem;
        font-weight: 600;
        padding: 6px 16px;
    }
</style>

<!-- 2. NỘI DUNG CHÍNH: KHO VOUCHER                 -->
<div class="voucher-page-bg py-4">
    <div class="container">

        <!-- A. BANNER ĐẦU TRANG -->
        <div class="voucher-banner mb-4 shadow-sm position-relative overflow-hidden">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <span class="badge bg-warning text-dark px-3 py-1 rounded-pill fw-bold mb-2">
                        <i class="bi bi-gift-fill me-1"></i> TRUNG TÂM KHUYẾN MÃI
                    </span>
                    <h2 class="fw-bold mb-2">Kho Voucher & Mã Giảm Giá Độc Quyền</h2>
                    <p class="mb-0 text-white-50">Thu thập mã giảm giá để mua sắm điện máy chính hãng với giá tốt nhất mỗi ngày!</p>
                </div>
                <div class="col-md-4 text-md-end d-none d-md-block">
                    <i class="bi bi-ticket-perforated-fill display-1 text-white-50 opacity-50"></i>
                </div>
            </div>
        </div>

        <!-- B. BỘ LỌC DANH MỤC VOUCHER (NAV PILLS) -->
        <div class="d-flex align-items-center justify-content-between mb-4 overflow-x-auto text-nowrap pb-2">
            <ul class="nav nav-pills gap-2" id="voucherFilterTabs">
                <li class="nav-item">
                    <button class="nav-link active rounded-pill px-4 fw-bold" onclick="filterVouchers('all', this)">Tất cả mã</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link rounded-pill px-4 fw-bold" onclick="filterVouchers('ship', this)">Miễn phí vận chuyển</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link rounded-pill px-4 fw-bold" onclick="filterVouchers('order', this)">Giảm giá đơn hàng</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link rounded-pill px-4 fw-bold" onclick="filterVouchers('payment', this)">Thanh toán VNPAY</button>
                </li>
            </ul>
            <span class="text-muted small d-none d-lg-inline"><i class="bi bi-info-circle me-1"></i>Mỗi đơn hàng chỉ áp dụng tối đa 1 mã</span>
        </div>

        <!-- C. DANH SÁCH THẺ VOUCHER (GRID) -->
        <div class="row g-4" id="voucherGrid">

            <!-- VOUCHER 1: GIAM50K (Khớp chuẩn với logic CheckoutServiceImpl của Backend) -->
            <div class="col-lg-6 voucher-card-item" data-type="order">
                <div class="voucher-ticket">
                    <div class="voucher-left bg-voucher-orange">
                        <i class="bi bi-tag-fill fs-2 mb-1"></i>
                        <span class="fw-bold fs-5">GIẢM 50K</span>
                        <small class="text-white-50" style="font-size: 0.65rem;">ĐIỆN MÁY</small>
                    </div>
                    <div class="voucher-right">
                        <div>
                            <div class="d-flex justify-content-between align-items-start mb-1">
                                <h6 class="fw-bold mb-0 text-dark">Giảm trực tiếp 50.000đ</h6>
                                <span class="badge bg-danger-subtle text-danger small">Số lượng có hạn</span>
                            </div>
                            <p class="text-muted small mb-2">Áp dụng cho mọi đơn hàng điện máy từ <b>2.000.000đ</b>.</p>
                        </div>
                        <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                            <span class="voucher-code-badge">GIAM50K</span>
                            <button class="btn btn-outline-primary btn-copy-code" onclick="copyCode('GIAM50K')">
                                <i class="bi bi-copy me-1"></i> Sao chép mã
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- VOUCHER 2: FREESHIP -->
            <div class="col-lg-6 voucher-card-item" data-type="ship">
                <div class="voucher-ticket">
                    <div class="voucher-left bg-voucher-green">
                        <i class="bi bi-truck fs-2 mb-1"></i>
                        <span class="fw-bold fs-5">FREE SHIP</span>
                        <small class="text-white-50" style="font-size: 0.65rem;">VẬN CHUYỂN</small>
                    </div>
                    <div class="voucher-right">
                        <div>
                            <div class="d-flex justify-content-between align-items-start mb-1">
                                <h6 class="fw-bold mb-0 text-dark">Miễn phí giao hàng toàn quốc</h6>
                                <span class="badge bg-success-subtle text-success small">Toàn hệ thống</span>
                            </div>
                            <p class="text-muted small mb-2">Giao nhanh trong 2 giờ tại các khu vực có chi nhánh siêu thị.</p>
                        </div>
                        <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                            <span class="voucher-code-badge">FREESHIP</span>
                            <button class="btn btn-outline-success btn-copy-code" onclick="copyCode('FREESHIP')">
                                <i class="bi bi-copy me-1"></i> Sao chép mã
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- VOUCHER 3: VNPAY -->
            <div class="col-lg-6 voucher-card-item" data-type="payment">
                <div class="voucher-ticket">
                    <div class="voucher-left bg-voucher-blue">
                        <i class="bi bi-qr-code-scan fs-2 mb-1"></i>
                        <span class="fw-bold fs-5">GIẢM 100K</span>
                        <small class="text-white-50" style="font-size: 0.65rem;">VNPAY QR</small>
                    </div>
                    <div class="voucher-right">
                        <div>
                            <div class="d-flex justify-content-between align-items-start mb-1">
                                <h6 class="fw-bold mb-0 text-dark">Ưu đãi thanh toán qua VNPAY</h6>
                                <span class="badge bg-primary-subtle text-primary small">Cổng VNPAY</span>
                            </div>
                            <p class="text-muted small mb-2">Giảm ngay 100.000đ khi thanh toán đơn hàng qua cổng Sandbox VNPAY.</p>
                        </div>
                        <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                            <span class="voucher-code-badge">VNPAY100</span>
                            <button class="btn btn-outline-primary btn-copy-code" onclick="copyCode('VNPAY100')">
                                <i class="bi bi-copy me-1"></i> Sao chép mã
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- VOUCHER 4: SIÊU SALE GIA DỤNG -->
            <div class="col-lg-6 voucher-card-item" data-type="order">
                <div class="voucher-ticket">
                    <div class="voucher-left bg-voucher-purple">
                        <i class="bi bi-stars fs-2 mb-1"></i>
                        <span class="fw-bold fs-5">GIẢM 10%</span>
                        <small class="text-white-50" style="font-size: 0.65rem;">GIA DỤNG</small>
                    </div>
                    <div class="voucher-right">
                        <div>
                            <div class="d-flex justify-content-between align-items-start mb-1">
                                <h6 class="fw-bold mb-0 text-dark">Ưu đãi Nồi cơm, Bếp từ, Lò vi sóng</h6>
                                <span class="badge bg-warning-subtle text-dark small">Khách mới</span>
                            </div>
                            <p class="text-muted small mb-2">Giảm tối đa 200.000đ cho đơn hàng thiết bị gia dụng nhà bếp.</p>
                        </div>
                        <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                            <span class="voucher-code-badge">GIADUNG10</span>
                            <button class="btn btn-outline-primary btn-copy-code" onclick="copyCode('GIADUNG10')">
                                <i class="bi bi-copy me-1"></i> Sao chép mã
                            </button>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <!-- D. HƯỚNG DẪN DÙNG VOUCHER -->
        <div class="card border-0 rounded-4 shadow-sm p-4 mt-5 bg-white">
            <h5 class="fw-bold mb-3 text-dark"><i class="bi bi-lightbulb-fill text-warning me-2"></i>Hướng dẫn 3 bước sử dụng mã giảm giá</h5>
            <div class="row g-3 text-center">
                <div class="col-md-4">
                    <div class="p-3 rounded-3 bg-light h-100">
                        <span class="badge bg-primary rounded-circle mb-2 fs-6">1</span>
                        <h6 class="fw-bold">Sao chép mã</h6>
                        <p class="text-muted small mb-0">Chọn mã ưu đãi phù hợp ở trang này và nhấn nút "Sao chép mã".</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="p-3 rounded-3 bg-light h-100">
                        <span class="badge bg-primary rounded-circle mb-2 fs-6">2</span>
                        <h6 class="fw-bold">Chọn mua sản phẩm</h6>
                        <p class="text-muted small mb-0">Thêm sản phẩm điện máy bạn yêu thích vào giỏ hàng và tiến hành Đặt hàng.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="p-3 rounded-3 bg-light h-100">
                        <span class="badge bg-primary rounded-circle mb-2 fs-6">3</span>
                        <h6 class="fw-bold">Áp dụng & Nhận giảm giá</h6>
                        <p class="text-muted small mb-0">Tại màn hình Thanh toán (Checkout), dán mã vào ô "Mã giảm giá" và bấm Áp dụng.</p>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
    // 1. Sao chép mã vào Clipboard kèm thông báo Toast
    function copyCode(code, btnElement) {
        const btn = btnElement || (window.event ? window.event.currentTarget : null);
        
        navigator.clipboard.writeText(code).then(() => {
            if (btn) {
                const originalHtml = btn.innerHTML;
                const originalClasses = btn.className;
                btn.className = "btn btn-success btn-copy-code text-white";
                btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Sao chép thành công';
                btn.disabled = true; 
                setTimeout(() => {
                    btn.className = originalClasses;
                    btn.innerHTML = originalHtml;
                    btn.disabled = false;
                }, 1000);
            }
        });
    }
    // 2. Lọc Voucher theo Tab
    function filterVouchers(type, btnElement) {
        // Đổi active tab
        document.querySelectorAll('#voucherFilterTabs .nav-link').forEach(btn => btn.classList.remove('active'));
        btnElement.classList.add('active');

        // Lọc hiển thị các thẻ
        const items = document.querySelectorAll('.voucher-card-item');
        items.forEach(item => {
            if (type === 'all' || item.getAttribute('data-type') === type) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }
</script>

<jsp:include page="fragments/footer.jsp" />