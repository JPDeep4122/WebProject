<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Quản trị Chuỗi Điện Máy</title>
    <!-- Bootstrap 5 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body>
    <div class="d-flex">
        <!-- Nhúng Sidebar Admin -->
        <jsp:include page="fragments/sidebar.jsp" />

        <!-- Khu vực nội dung Admin chính -->
        <div class="flex-grow-1 bg-light p-4">
            <!-- Header trên cùng -->
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                <div>
                    <h3 class="fw-bold mb-0">Tổng quan hệ thống</h3>
                    <small class="text-muted">Phạm vi: Toàn chuỗi chi nhánh</small>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-outline-primary btn-sm"><i class="bi bi-download"></i> Xuất báo cáo</button>
                    <a href="/" class="btn btn-primary btn-sm"><i class="bi bi-house"></i> Về trang bán hàng</a>
                </div>
            </div>

            <!-- 4 Thẻ Card Thống kê mẫu -->
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm border-start border-primary border-4 p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <small class="text-muted fw-bold">DOANH THU THÁNG</small>
                                <h4 class="fw-bold text-primary mt-1">450.800.000 đ</h4>
                            </div>
                            <div class="fs-2 text-primary"><i class="bi bi-currency-dollar"></i></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm border-start border-success border-4 p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <small class="text-muted fw-bold">ĐƠN HÀNG MỚI</small>
                                <h4 class="fw-bold text-success mt-1">128 Đơn</h4>
                            </div>
                            <div class="fs-2 text-success"><i class="bi bi-cart-check"></i></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm border-start border-warning border-4 p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <small class="text-muted fw-bold">SẢN PHẨM TỒN KHO</small>
                                <h4 class="fw-bold text-warning mt-1">1.450 SP</h4>
                            </div>
                            <div class="fs-2 text-warning"><i class="bi bi-box"></i></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm border-start border-info border-4 p-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <small class="text-muted fw-bold">KHÁCH HÀNG MỚI</small>
                                <h4 class="fw-bold text-info mt-1">340 User</h4>
                            </div>
                            <div class="fs-2 text-info"><i class="bi bi-person-plus"></i></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bảng đơn hàng gần đây -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white fw-bold py-3">
                    <i class="bi bi-clock-history me-1"></i> Đơn hàng cần xử lý gần đây
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Chi nhánh nhận</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><strong>#DH-10023</strong></td>
                                    <td>Nguyễn Văn A (0912345678)</td>
                                    <td>Chi nhánh Quận 1</td>
                                    <td class="text-danger fw-bold">11.490.000 đ</td>
                                    <td><span class="badge bg-warning text-dark">Chờ xác nhận</span></td>
                                    <td><button class="btn btn-sm btn-outline-primary">Chi tiết</button></td>
                                </tr>
                                <tr>
                                    <td><strong>#DH-10022</strong></td>
                                    <td>Trần Thị B (0987654321)</td>
                                    <td>Chi nhánh Thủ Đức</td>
                                    <td class="text-danger fw-bold">8.990.000 đ</td>
                                    <td><span class="badge bg-info">Đang giao hàng</span></td>
                                    <td><button class="btn btn-sm btn-outline-primary">Chi tiết</button></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>