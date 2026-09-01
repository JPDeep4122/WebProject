<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ — Chuỗi Cửa Hàng Điện Máy</title>
    <!-- Bootstrap 5 CSS & Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Nhúng Header -->
    <jsp:include page="fragments/header.jsp" />

    <!-- Nội dung chính (Body) -->
    <main class="container my-4">
        <!-- Banner khuyến mãi -->
        <div class="p-5 mb-4 bg-primary text-white rounded-3 shadow-sm" style="background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);">
            <div class="container-fluid py-3">
                <span class="badge bg-warning text-dark mb-2">SIÊU SALE ĐIỆN MÁY 2026</span>
                <h1 class="display-6 fw-bold">Mua sắm thả ga — Giảm giá tới 50%</h1>
                <p class="col-md-8 fs-6">Hàng ngàn sản phẩm Tivi, Tủ lạnh, Máy giặt chính hãng từ Samsung, Sony, LG, Panasonic đang có giá cực ưu đãi.</p>
                <a href="#products" class="btn btn-warning btn-lg text-dark fw-bold px-4"><i class="bi bi-fire"></i> Mua ngay</a>
            </div>
        </div>

        <!-- Tiêu đề Sản phẩm nổi bật -->
        <div class="d-flex justify-content-between align-items-center mb-3" id="products">
            <h4 class="fw-bold mb-0 text-dark"><i class="bi bi-star-fill text-warning me-2"></i>Sản phẩm bán chạy nhất</h4>
            <a href="#" class="text-primary text-decoration-none small">Xem tất cả <i class="bi bi-arrow-right"></i></a>
        </div>

        <!-- Lưới sản phẩm mẫu (Grid) -->
        <div class="row row-cols-1 row-cols-md-3 row-cols-lg-4 g-3">
            <!-- Item mẫu 1 -->
            <div class="col">
                <div class="card h-100 shadow-sm border-0">
                    <div class="position-absolute top-0 start-0 m-2"><span class="badge bg-danger">-20%</span></div>
                    <img src="https://placehold.co/400x300/e9ecef/0d6efd?text=Smart+Tivi+4K+55+Inch" class="card-img-top p-3" alt="Tivi">
                    <div class="card-body d-flex flex-column">
                        <small class="text-muted">Samsung</small>
                        <h6 class="card-title fw-bold text-truncate-2">Smart Tivi Crystal UHD 4K 55 inch</h6>
                        <div class="mt-auto">
                            <div class="text-danger fw-bold fs-5">11.490.000 đ</div>
                            <small class="text-muted text-decoration-line-through">14.900.000 đ</small>
                            <div class="d-grid mt-2">
                                <button class="btn btn-outline-primary btn-sm"><i class="bi bi-cart-plus"></i> Thêm vào giỏ</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Item mẫu 2 -->
            <div class="col">
                <div class="card h-100 shadow-sm border-0">
                    <div class="position-absolute top-0 start-0 m-2"><span class="badge bg-danger">-15%</span></div>
                    <img src="https://placehold.co/400x300/e9ecef/0d6efd?text=Tu+Lanh+Inverter+300L" class="card-img-top p-3" alt="Tủ lạnh">
                    <div class="card-body d-flex flex-column">
                        <small class="text-muted">Panasonic</small>
                        <h6 class="card-title fw-bold text-truncate-2">Tủ lạnh Inverter 300L 2 cánh</h6>
                        <div class="mt-auto">
                            <div class="text-danger fw-bold fs-5">8.990.000 đ</div>
                            <small class="text-muted text-decoration-line-through">10.500.000 đ</small>
                            <div class="d-grid mt-2">
                                <button class="btn btn-outline-primary btn-sm"><i class="bi bi-cart-plus"></i> Thêm vào giỏ</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Item mẫu 3 -->
            <div class="col">
                <div class="card h-100 shadow-sm border-0">
                    <img src="https://placehold.co/400x300/e9ecef/0d6efd?text=May+Giat+Cua+Ngang+9kg" class="card-img-top p-3" alt="Máy giặt">
                    <div class="card-body d-flex flex-column">
                        <small class="text-muted">LG</small>
                        <h6 class="card-title fw-bold text-truncate-2">Máy giặt lồng ngang AI DD 9kg</h6>
                        <div class="mt-auto">
                            <div class="text-danger fw-bold fs-5">9.290.000 đ</div>
                            <small class="text-muted text-decoration-line-through">10.990.000 đ</small>
                            <div class="d-grid mt-2">
                                <button class="btn btn-outline-primary btn-sm"><i class="bi bi-cart-plus"></i> Thêm vào giỏ</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Item mẫu 4 -->
            <div class="col">
                <div class="card h-100 shadow-sm border-0">
                    <div class="position-absolute top-0 start-0 m-2"><span class="badge bg-success">Mới</span></div>
                    <img src="https://placehold.co/400x300/e9ecef/0d6efd?text=Dieu+Hoa+Inverter+1.5HP" class="card-img-top p-3" alt="Điều hòa">
                    <div class="card-body d-flex flex-column">
                        <small class="text-muted">Daikin</small>
                        <h6 class="card-title fw-bold text-truncate-2">Điều hòa Inverter 1.5 HP Tiết kiệm điện</h6>
                        <div class="mt-auto">
                            <div class="text-danger fw-bold fs-5">10.790.000 đ</div>
                            <small class="text-muted text-decoration-line-through">12.000.000 đ</small>
                            <div class="d-grid mt-2">
                                <button class="btn btn-outline-primary btn-sm"><i class="bi bi-cart-plus"></i> Thêm vào giỏ</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Nhúng Footer -->
    <jsp:include page="fragments/footer.jsp" />

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>