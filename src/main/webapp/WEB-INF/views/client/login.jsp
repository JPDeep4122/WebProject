<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!-- 1. Nhúng Header chuẩn Điện Máy -->
<jsp:include page="fragments/header.jsp" />

<style>
    .auth-page-wrapper {
        min-height: calc(100vh - 200px);
        background-color: #f4f6f8;
    }
    .auth-card {
        background: #ffffff;
        border-radius: 24px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
        max-width: 480px;
        width: 100%;
        transition: all 0.2s ease-in-out;
    }
    .auth-input-pill {
        border-radius: 50px;
        padding: 12px 18px;
        border: 1px solid #e2e8f0;
        background-color: #ffffff;
        transition: all 0.2s;
    }
    .auth-input-pill:focus {
        border-color: #0b66c3;
        box-shadow: 0 0 0 4px rgba(11, 102, 195, 0.15);
    }
    .btn-auth-main {
        background-color: #2f80ed;
        border: none;
        color: #ffffff;
        font-weight: 700;
        font-size: 1rem;
        padding: 12px;
        border-radius: 50px;
        transition: background-color 0.2s, transform 0.1s;
    }
    .btn-auth-main:hover {
        background-color: #1a6fd8;
        color: #ffffff;
        transform: translateY(-1px);
    }
    .auth-switch-link {
        color: #0b66c3;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
    }
    .auth-switch-link:hover {
        text-decoration: underline;
    }
</style>

<!-- 2. KHU VỰC CHÍNH CỦA TRANG XÁC THỰC -->
<div class="auth-page-wrapper py-5 d-flex align-items-center">
    <div class="container">
        <div class="row align-items-center justify-content-center g-5">
            
            <div class="col-lg-5 col-md-6 d-none d-md-flex justify-content-center">
                <div class="text-center">
                    <img src="https://cdni.iconscout.com/illustration/premium/thumb/online-shopping-app-illustration-download-in-svg-png-gif-file-formats--discount-voucher-credit-card-pack-e-commerce-illustrations-3783954.png" 
                         alt="Đăng nhập Điện Máy" class="img-fluid" style="max-height: 380px;">
                    <div class="mt-3 text-muted small">Mua sắm tiện lợi • Tích điểm thành viên • Bảo hành điện tử</div>
                </div>
            </div>

            <div class="col-lg-5 col-md-6 d-flex justify-content-center">
                <div class="auth-card p-4 p-sm-5">
                    
                    <!-- Hộp thông báo lỗi/thành công độc lập trên trang này -->
                    <div id="pageAuthAlert" class="alert d-none py-2 small rounded-3" role="alert"></div>

                    <!-- 1. Form đăng nhập -->
                    <div id="viewLogin">
                        <h3 class="fw-bold text-center mb-4 text-dark">Đăng nhập</h3>
                        <form id="formLogin">
                            <div class="mb-3">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                                        <i class="bi bi-envelope"></i>
                                    </span>
                                    <input type="email" class="form-control auth-input-pill border-start-0 rounded-end-pill ps-2" 
                                           id="pageLoginEmail" placeholder="Nhập email tài khoản" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                                        <i class="bi bi-shield-lock"></i>
                                    </span>
                                    <input type="password" class="form-control auth-input-pill border-start-0 rounded-end-pill ps-2" 
                                           id="pageLoginPassword" placeholder="Nhập mật khẩu" required>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-auth-main w-100 mt-2 shadow-sm">TIẾP TỤC</button>
                            <p class="text-muted text-center small mt-3 mb-0" style="font-size: 0.78rem; line-height: 1.4;">
                                Nhấn <b>"Tiếp tục"</b> đồng nghĩa với việc bạn cho phép hệ thống xác thực tài khoản và chấp thuận các điều khoản mua hàng.
                            </p>
                            <hr class="my-4 text-muted">
                            <div class="d-flex justify-content-between align-items-center small">
                                <span class="auth-switch-link" onclick="switchView('register')">Chưa có tài khoản? Đăng ký</span>
                                <span class="auth-switch-link text-muted" onclick="switchView('forgot')">Quên mật khẩu?</span>
                            </div>
                        </form>
                    </div>

                    <!-- 2. Form đăng ký -->
                    <div id="viewRegister" class="d-none">
                        <h3 class="fw-bold text-center mb-4 text-dark">Tạo tài khoản</h3>
                        <form id="formRegister">
                            <div class="mb-2">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                                        <i class="bi bi-person"></i>
                                    </span>
                                    <input type="text" class="form-control auth-input-pill border-start-0 rounded-end-pill ps-2" 
                                           id="pageRegFullName" placeholder="Họ và tên của bạn" required>
                                </div>
                            </div>
                            <div class="mb-2">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                                        <i class="bi bi-telephone"></i>
                                    </span>
                                    <input type="tel" class="form-control auth-input-pill border-start-0 rounded-end-pill ps-2" 
                                           id="pageRegPhone" placeholder="Số điện thoại" required>
                                </div>
                            </div>
                            <div class="mb-2">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                                        <i class="bi bi-envelope"></i>
                                    </span>
                                    <input type="email" class="form-control auth-input-pill border-start-0 rounded-end-pill ps-2" 
                                           id="pageRegEmail" placeholder="Địa chỉ Email" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                                        <i class="bi bi-lock"></i>
                                    </span>
                                    <input type="password" class="form-control auth-input-pill border-start-0 rounded-end-pill ps-2" 
                                           id="pageRegPassword" placeholder="Mật khẩu (từ 6 ký tự)" minlength="6" required>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-auth-main w-100 mt-2 shadow-sm">ĐĂNG KÝ TÀI KHOẢN</button>
                            <hr class="my-4 text-muted">
                            <div class="text-center small">
                                <span>Đã có tài khoản? </span>
                                <span class="auth-switch-link" onclick="switchView('login')">Đăng nhập ngay</span>
                            </div>
                        </form>
                    </div>

                    <!-- 3. Form xác thực OTP - kích hoạt -->
                    <div id="viewOtp" class="d-none text-center">
                        <i class="bi bi-shield-lock-fill text-warning fs-1"></i>
                        <h4 class="fw-bold mt-2 text-dark">Nhập mã OTP</h4>
                        <p class="text-muted small">Mã 6 số đã được gửi tới email: <br><b id="pageOtpTargetEmail" class="text-primary"></b></p>
                        <form id="formOtp">
                            <div class="mb-3">
                                <input type="text" class="form-control form-control-lg text-center fw-bold fs-3 rounded-pill letter-spacing-2" 
                                       id="pageOtpCodeInput" maxlength="6" placeholder="000000" required>
                            </div>
                            <button type="submit" class="btn btn-auth-main w-100 shadow-sm">KÍCH HOẠT & TIẾP TỤC</button>
                            <div class="mt-3 small">
                                <span class="auth-switch-link text-muted" onclick="resendOtp()">Gửi lại mã OTP</span>
                                <span class="mx-2">•</span>
                                <span class="auth-switch-link" onclick="switchView('login')">Quay lại Đăng nhập</span>
                            </div>
                        </form>
                    </div>

                    <!-- 4. Form quên mật khẩu -->
                    <div id="viewForgot" class="d-none">
                        <h3 class="fw-bold text-center mb-2 text-dark">Khôi phục mật khẩu</h3>
                        <p class="text-muted text-center small mb-4">Nhập email đăng ký của bạn để nhận mã xác nhận</p>
                        <form id="formForgot">
                            <div class="mb-3">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                                        <i class="bi bi-envelope"></i>
                                    </span>
                                    <input type="email" class="form-control auth-input-pill border-start-0 rounded-end-pill ps-2" 
                                           id="pageForgotEmail" placeholder="Nhập email của bạn" required>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-auth-main w-100 mt-2 shadow-sm">GỬI MÃ XÁC NHẬN</button>
                            <hr class="my-4 text-muted">
                            <div class="text-center small">
                                <span class="auth-switch-link" onclick="switchView('login')">Quay lại Đăng nhập</span>
                            </div>
                        </form>
                    </div>

                    <!-- 5. Form đặt lại mật khẩu -->
                    <div id="viewReset" class="d-none">
                        <h3 class="fw-bold text-center mb-2 text-dark">Đặt lại mật khẩu</h3>
                        <p class="text-muted text-center small mb-4">Nhập mã OTP từ email và tạo mật khẩu mới</p>
                        <form id="formReset">
                            <div class="mb-3">
                                <input type="text" class="form-control auth-input-pill text-center fw-bold" 
                                       id="pageResetOtpCode" placeholder="Nhập mã OTP 6 số" maxlength="6" required>
                            </div>
                            <div class="mb-3">
                                <input type="password" class="form-control auth-input-pill" 
                                       id="pageResetNewPassword" placeholder="Mật khẩu mới (từ 6 ký tự)" minlength="6" required>
                            </div>
                            <button type="submit" class="btn btn-auth-main w-100 mt-2 shadow-sm">LƯU MẬT KHẨU MỚI</button>
                            <hr class="my-4 text-muted">
                            <div class="text-center small">
                                <span class="auth-switch-link" onclick="switchView('login')">Quay lại Đăng nhập</span>
                            </div>
                        </form>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

<!-- 3. JS xử lý chuyển đổi form và gọi API -->
<script>
    const CONTEXT_PATH = "${pageContext.request.contextPath}";
    let currentPendingEmail = "";

    // Hàm hiển thị thông báo trực tiếp trên trang này
    function showAlert(type, msg) {
        const alertBox = document.getElementById('pageAuthAlert');
        if (alertBox) {
            alertBox.className = "alert alert-" + type + " py-2 small rounded-3";
            alertBox.innerText = msg;
            alertBox.classList.remove('d-none');
        }
    }

    function hideAlert() {
        const alertBox = document.getElementById('pageAuthAlert');
        if (alertBox) {
            alertBox.classList.add('d-none');
        }
    }

    // Hàm chuyển đổi qua lại giữa các Form
    function switchView(viewName) {
        hideAlert();
        document.getElementById('viewLogin').classList.add('d-none');
        document.getElementById('viewRegister').classList.add('d-none');
        document.getElementById('viewOtp').classList.add('d-none');
        document.getElementById('viewForgot').classList.add('d-none');
        document.getElementById('viewReset').classList.add('d-none');

        if (viewName === 'login') document.getElementById('viewLogin').classList.remove('d-none');
        if (viewName === 'register') document.getElementById('viewRegister').classList.remove('d-none');
        if (viewName === 'otp') document.getElementById('viewOtp').classList.remove('d-none');
        if (viewName === 'forgot') document.getElementById('viewForgot').classList.remove('d-none');
        if (viewName === 'reset') document.getElementById('viewReset').classList.remove('d-none');
    }

    // 1. XỬ LÝ ĐĂNG NHẬP
    document.getElementById('formLogin').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
        const email = document.getElementById('pageLoginEmail').value.trim();
        const password = document.getElementById('pageLoginPassword').value.trim();
        const btn = this.querySelector('button[type="submit"]');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang đăng nhập...';

        try {
            const res = await fetch(CONTEXT_PATH + '/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });
            const data = await res.json();

            if (data.success) {
                localStorage.setItem('jwtToken', data.data.token);
                localStorage.setItem('accessToken', data.data.token);
                localStorage.setItem('currentUser', JSON.stringify(data.data));
                document.cookie = "accessToken=" + data.data.token + "; path=/; max-age=86400";

                showAlert('success', 'Đăng nhập thành công! Đang chuyển hướng...');
                const urlParams = new URLSearchParams(window.location.search);
                const redirectUrl = urlParams.get('redirect');
                setTimeout(() => {
                    window.location.href = redirectUrl ? CONTEXT_PATH + redirectUrl : CONTEXT_PATH + '/';
                }, 700);
            } else {
                showAlert('danger', data.message || 'Email hoặc mật khẩu không chính xác!');
                btn.disabled = false;
                btn.innerText = 'TIẾP TỤC';
            }
        } catch (err) {
            showAlert('danger', 'Lỗi kết nối máy chủ!');
            btn.disabled = false;
            btn.innerText = 'TIẾP TỤC';
        }
    });

    // 2. XỬ LÝ ĐĂNG KÝ
    document.getElementById('formRegister').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
        const fullname = document.getElementById('pageRegFullName').value.trim();
        const phoneNumber = document.getElementById('pageRegPhone').value.trim();
        const email = document.getElementById('pageRegEmail').value.trim();
        const password = document.getElementById('pageRegPassword').value.trim();
        const btn = this.querySelector('button[type="submit"]');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang tạo tài khoản & gửi OTP...';

        try {
            const res = await fetch(CONTEXT_PATH + '/api/auth/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ fullname, phoneNumber, email, password })
            });
            const data = await res.json();

            if (data.success) {
                currentPendingEmail = email;
                document.getElementById('pageOtpTargetEmail').innerText = email;
                showAlert('success', 'Đăng ký thành công! Vui lòng nhập mã OTP đã gửi tới email của bạn.');
                switchView('otp');
            } else {
                showAlert('danger', data.message || 'Không thể đăng ký tài khoản!');
                btn.disabled = false;
                btn.innerText = 'ĐĂNG KÝ TÀI KHOẢN';
            }
        } catch (err) {
            showAlert('danger', 'Lỗi kết nối máy chủ!');
            btn.disabled = false;
            btn.innerText = 'ĐĂNG KÝ TÀI KHOẢN';
        }
    });

    // 3. XỬ LÝ XÁC THỰC OTP
    document.getElementById('formOtp').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
        const otpCode = document.getElementById('pageOtpCodeInput').value.trim();
        const btn = this.querySelector('button[type="submit"]');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang kích hoạt...';

        try {
            const res = await fetch(CONTEXT_PATH + '/api/auth/verify-otp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: currentPendingEmail, otpCode })
            });
            const data = await res.json();

            if (data.success) {
                showAlert('success', 'Kích hoạt thành công! Đang chuyển về màn hình Đăng nhập...');
                setTimeout(() => { 
                    switchView('login');
                    document.getElementById('pageLoginEmail').value = currentPendingEmail;
                }, 1200);
            } else {
                showAlert('danger', data.message || 'Mã OTP không chính xác hoặc đã hết hạn!');
                btn.disabled = false;
                btn.innerText = 'KÍCH HOẠT & TIẾP TỤC';
            }
        } catch (err) {
            showAlert('danger', 'Lỗi kết nối máy chủ!');
            btn.disabled = false;
            btn.innerText = 'KÍCH HOẠT & TIẾP TỤC';
        }
    });

    // 4. XỬ LÝ GỬI LẠI OTP
    async function resendOtp() {
        if (!currentPendingEmail) return;
        try {
            const res = await fetch(CONTEXT_PATH + '/api/auth/resend-otp?email=' + encodeURIComponent(currentPendingEmail), { method: 'POST' });
            const data = await res.json();
            showAlert(data.success ? 'info' : 'danger', data.message);
        } catch (e) {
            showAlert('danger', 'Không thể gửi lại mã OTP!');
        }
    }

    // 5. XỬ LÝ YÊU CẦU QUÊN MẬT KHẨU
    document.getElementById('formForgot').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
        const email = document.getElementById('pageForgotEmail').value.trim();
        const btn = this.querySelector('button[type="submit"]');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang gửi mã...';

        try {
            const res = await fetch(CONTEXT_PATH + '/api/auth/forgot-password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email })
            });
            const data = await res.json();

            if (data.success) {
                currentPendingEmail = email;
                showAlert('success', 'Đã gửi mã OTP đặt lại mật khẩu về email của bạn!');
                switchView('reset');
            } else {
                showAlert('danger', data.message);
                btn.disabled = false;
                btn.innerText = 'GỬI MÃ XÁC NHẬN';
            }
        } catch (err) {
            showAlert('danger', 'Lỗi kết nối máy chủ!');
            btn.disabled = false;
            btn.innerText = 'GỬI MÃ XÁC NHẬN';
        }
    });

    // 6. XỬ LÝ ĐẶT LẠI MẬT KHẨU MỚI
    document.getElementById('formReset').addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlert();
        const otpCode = document.getElementById('pageResetOtpCode').value.trim();
        const newPassword = document.getElementById('pageResetNewPassword').value.trim();
        const btn = this.querySelector('button[type="submit"]');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang lưu mật khẩu...';

        try {
            const res = await fetch(CONTEXT_PATH + '/api/auth/reset-password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: currentPendingEmail, otpCode, newPassword })
            });
            const data = await res.json();

            if (data.success) {
                showAlert('success', 'Đặt lại mật khẩu thành công! Hãy đăng nhập với mật khẩu mới.');
                setTimeout(() => { switchView('login'); }, 1500);
            } else {
                showAlert('danger', data.message);
                btn.disabled = false;
                btn.innerText = 'LƯU MẬT KHẨU MỚI';
            }
        } catch (err) {
            showAlert('danger', 'Lỗi kết nối máy chủ!');
            btn.disabled = false;
            btn.innerText = 'LƯU MẬT KHẨU MỚI';
        }
    });
</script>

<!-- 4. Nhúng Footer -->
<jsp:include page="fragments/footer.jsp" />