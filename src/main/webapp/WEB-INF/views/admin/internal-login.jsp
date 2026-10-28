<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cổng Đăng Nhập Nội Bộ — TECHSEVEN</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="/WEB-INF/views/admin/fragments/theme.jsp"/>
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #001f54 0%, #0046be 55%, #002b75 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .internal-card {
            max-width: 920px;
            width: 100%;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 24px 60px rgba(0, 15, 45, 0.45);
            background: #ffffff;
        }
        .internal-banner {
            background: linear-gradient(180deg, #00358f 0%, #002260 100%);
            color: #ffffff;
            padding: 40px 36px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .role-pill {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.18);
            border-radius: 12px;
            padding: 10px 14px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>

<div class="internal-card">
    <div class="row g-0">
        <!-- CỘT TRÁI: THÔNG TIN NỘI BỘ CÔNG TY -->
        <div class="col-lg-5 internal-banner">
            <div>
                <a href="${pageContext.request.contextPath}/" class="d-inline-block mb-3">
                    <img src="${pageContext.request.contextPath}/images/brand/techseven-logo.svg"
                         alt="TECHSEVEN" style="width: 210px; height: auto;">
                </a>
                <div class="badge rounded-pill text-dark fw-bold px-3 py-2 mb-3" style="background-color: #ffe000;">
                    <i class="bi bi-building-lock me-1"></i>INTERNAL WORKSPACE
                </div>
                <h4 class="fw-bold mb-2">Hệ Thống Quản Trị & Vận Hành Nội Bộ</h4>
                <p class="small text-white-50 mb-4">
                    Cổng xác thực dành riêng cho nhân sự thuộc chuỗi hệ thống Điện Máy TECHSEVEN.
                </p>

                <div class="role-pill">
                    <div class="fw-bold small text-warning"><i class="bi bi-shield-lock-fill me-2"></i>Quản trị viên (ADMIN)</div>
                    <small class="text-white-50">Điều hành toàn chuỗi, chi nhánh, nhân sự & khuyến mãi</small>
                </div>
                <div class="role-pill">
                    <div class="fw-bold small text-info"><i class="bi bi-person-badge-fill me-2"></i>Nhân viên chi nhánh (STAFF)</div>
                    <small class="text-white-50">Xác nhận đơn hàng, xuất kho, phân công giao & đổi trả</small>
                </div>
                <div class="role-pill mb-0">
                    <div class="fw-bold small text-light"><i class="bi bi-truck me-2"></i>Nhân viên giao hàng (SHIPPER)</div>
                    <small class="text-white-50">Nhận đơn vận chuyển, cập nhật giao hàng & thu hộ COD</small>
                </div>
            </div>

            <div class="mt-4 pt-3 border-top border-light border-opacity-25 small text-white-50">
                <i class="bi bi-info-circle me-1"></i>Khách mua hàng vui lòng sử dụng
                <a href="${pageContext.request.contextPath}/login" class="text-warning fw-bold text-decoration-none">Cổng Khách Hàng</a>.
            </div>
        </div>

        <!-- CỘT PHẢI: FORM ĐĂNG NHẬP NHÂN SỰ -->
        <div class="col-lg-7 p-4 p-md-5 d-flex flex-column justify-content-center bg-white">
            <div class="mb-4">
                <h3 class="fw-bold text-dark mb-1">Đăng nhập Nhân sự</h3>
                <p class="text-secondary small mb-0">Sử dụng tài khoản Email công ty được cấp để truy cập phân hệ làm việc.</p>
            </div>

            <c:if test="${not empty param.logout}">
                <div class="alert alert-success rounded-3 small py-2 mb-3">
                    <i class="bi bi-check-circle-fill me-2"></i>Đã đăng xuất khỏi phiên làm việc nội bộ thành công.
                </div>
            </c:if>

            <div id="internalAlert" class="alert d-none rounded-3 small py-2 mb-3" role="alert"></div>

            <form id="internalLoginForm">
                <div class="mb-3">
                    <label for="staffEmail" class="form-label fw-bold small text-dark">Email nhân sự <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="bi bi-person-workspace text-primary"></i></span>
                        <input type="email" id="staffEmail" class="form-control py-2"
                               placeholder="vd: admin@dienmay.com / staff@dienmay.com" required autocomplete="username">
                    </div>
                </div>

                <div class="mb-4">
                    <label for="staffPassword" class="form-label fw-bold small text-dark">Mật khẩu <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="bi bi-key-fill text-primary"></i></span>
                        <input type="password" id="staffPassword" class="form-control py-2"
                               placeholder="Nhập mật khẩu nội bộ" required autocomplete="current-password">
                        <button class="btn btn-outline-secondary" type="button" onclick="toggleStaffPwd()">
                            <i class="bi bi-eye" id="staffPwdIcon"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" id="btnInternalSubmit" class="btn btn-primary w-100 py-2 fw-bold rounded-3 shadow-sm">
                    <i class="bi bi-box-arrow-in-right me-1"></i>ĐĂNG NHẬP HỆ THỐNG NỘI BỘ
                </button>
            </form>

            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top small">
                <a href="${pageContext.request.contextPath}/" class="text-decoration-none text-secondary">
                    <i class="bi bi-arrow-left me-1"></i>Về trang chủ bán hàng
                </a>
                <a href="${pageContext.request.contextPath}/login" class="text-decoration-none fw-semibold text-primary">
                    <i class="bi bi-bag-heart me-1"></i>Đăng nhập Khách hàng
                </a>
            </div>
        </div>
    </div>
</div>

<script>
    const CONTEXT_PATH = "${pageContext.request.contextPath}";

    // Nếu vừa bấm Đăng xuất thì xóa sạch token trong LocalStorage
    if (new URLSearchParams(window.location.search).has('logout')) {
        localStorage.removeItem('jwtToken');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('currentUser');
    }

    function toggleStaffPwd() {
        const input = document.getElementById('staffPassword');
        const icon = document.getElementById('staffPwdIcon');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'bi bi-eye';
        }
    }

    function showInternalAlert(type, msg) {
        const el = document.getElementById('internalAlert');
        el.className = 'alert alert-' + type + ' rounded-3 small py-2 mb-3';
        el.textContent = msg;
    }

    document.getElementById('internalLoginForm').addEventListener('submit', async function (e) {
        e.preventDefault();
        const btn = document.getElementById('btnInternalSubmit');
        const email = document.getElementById('staffEmail').value.trim();
        const password = document.getElementById('staffPassword').value;

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang xác thực quyền nhân sự...';

        try {
            const res = await csrfFetch(CONTEXT_PATH + '/api/auth/login', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({email, password})
            });
            const data = await res.json();

            if (data.success && data.data) {
                const roles = Array.isArray(data.data.roles) ? data.data.roles : [];
                const isInternal = roles.includes('ROLE_ADMIN') || roles.includes('ROLE_STAFF') || roles.includes('ROLE_SHIPPER');

                if (!isInternal) {
                    showInternalAlert('danger', 'Tài khoản này là tài khoản Khách hàng! Vui lòng đăng nhập tại Cổng Khách Hàng.');
                    btn.disabled = false;
                    btn.innerHTML = '<i class="bi bi-box-arrow-in-right me-1"></i>ĐĂNG NHẬP HỆ THỐNG NỘI BỘ';
                    return;
                }

                // Lưu thông tin đăng nhập nội bộ
                localStorage.setItem('jwtToken', data.data.token);
                localStorage.setItem('accessToken', data.data.token);
                localStorage.setItem('currentUser', JSON.stringify(data.data));

                document.cookie = 'accessToken=' + encodeURIComponent(data.data.token)
                    + '; path=/; max-age=86400; SameSite=Lax'
                    + (location.protocol === 'https:' ? '; Secure' : '');

                // Điều hướng chuẩn theo đúng chức vụ trong công ty
                let targetUrl = CONTEXT_PATH + '/admin';
                let roleName = 'Quản trị viên';
                if (roles.includes('ROLE_ADMIN')) {
                    targetUrl = CONTEXT_PATH + '/admin';
                    roleName = 'Quản trị viên (Admin)';
                } else if (roles.includes('ROLE_STAFF')) {
                    targetUrl = CONTEXT_PATH + '/admin/orders';
                    roleName = 'Nhân viên chi nhánh (Staff)';
                } else if (roles.includes('ROLE_SHIPPER')) {
                    targetUrl = CONTEXT_PATH + '/shipper/orders';
                    roleName = 'Nhân viên giao hàng (Shipper)';
                }

                showInternalAlert('success', 'Xác thực thành công vai trò: ' + roleName + '. Đang chuyển vào phân hệ làm việc...');
                setTimeout(() => {
                    window.location.assign(targetUrl);
                }, 600);
            } else {
                showInternalAlert('danger', data.message || 'Email hoặc mật khẩu không chính xác!');
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-box-arrow-in-right me-1"></i>ĐĂNG NHẬP HỆ THỐNG NỘI BỘ';
            }
        } catch (err) {
            showInternalAlert('danger', 'Lỗi kết nối máy chủ! Vui lòng tải lại trang và thử lại.');
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-box-arrow-in-right me-1"></i>ĐĂNG NHẬP HỆ THỐNG NỘI BỘ';
        }
    });
</script>
</body>
</html>