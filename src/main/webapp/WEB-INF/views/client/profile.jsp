<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="fragments/header.jsp" />

<main class="storefront-container py-4" id="accountProfilePage">
    <nav aria-label="Điều hướng">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li class="breadcrumb-item active" aria-current="page">Hồ sơ của tôi</li>
        </ol>
    </nav>

    <div class="mb-4">
        <h1 class="h3 fw-bold mb-2">Hồ sơ của tôi</h1>
        <p class="text-muted mb-0">Quản lý thông tin cá nhân và mật khẩu tài khoản TECHSEVEN.</p>
    </div>

    <div class="row g-4 align-items-start">
        <section class="col-lg-6" aria-labelledby="profileHeading">
            <div class="bg-white border rounded-4 p-3 p-md-4">
                <h2 class="h5 fw-bold mb-4" id="profileHeading">
                    <i class="bi bi-person-circle me-2 text-primary" aria-hidden="true"></i>Thông tin cá nhân
                </h2>
                <c:if test="${not empty profileSuccess}">
                    <div class="alert alert-success" role="status"><c:out value="${profileSuccess}" /></div>
                </c:if>
                <c:if test="${not empty profileError}">
                    <div class="alert alert-danger" role="alert" tabindex="-1" data-account-error><c:out value="${profileError}" /></div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/account/profile" data-account-form>
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <div class="mb-3">
                        <label for="accountEmail" class="form-label fw-bold">Email</label>
                        <input id="accountEmail" class="form-control" type="email" readonly
                               value="${fn:escapeXml(accountProfile.email)}" aria-describedby="emailHelp">
                        <div class="form-text" id="emailHelp">Email đăng nhập không thay đổi tại đây.</div>
                    </div>
                    <div class="mb-3">
                        <label for="accountFullName" class="form-label fw-bold">Họ và tên <span class="text-danger">*</span></label>
                        <input id="accountFullName" class="form-control" name="fullName" type="text" required
                               maxlength="100" autocomplete="name" value="${fn:escapeXml(profileForm.fullName)}">
                    </div>
                    <div class="mb-4">
                        <label for="accountPhone" class="form-label fw-bold">Số điện thoại</label>
                        <input id="accountPhone" class="form-control" name="phoneNumber" type="tel"
                               maxlength="20" autocomplete="tel" aria-describedby="phoneHelp"
                               value="${fn:escapeXml(profileForm.phoneNumber)}">
                        <div class="form-text" id="phoneHelp">Nhập 9–15 chữ số, có thể bắt đầu bằng dấu +.</div>
                    </div>
                    <button class="btn btn-primary px-4" type="submit">Lưu thông tin</button>
                </form>
            </div>
        </section>

        <section class="col-lg-6" id="change-password" aria-labelledby="passwordHeading">
            <div class="bg-white border rounded-4 p-3 p-md-4">
                <h2 class="h5 fw-bold mb-4" id="passwordHeading">
                    <i class="bi bi-shield-lock me-2 text-primary" aria-hidden="true"></i>Đổi mật khẩu
                </h2>
                <c:if test="${not empty passwordSuccess}">
                    <div class="alert alert-success" role="status"><c:out value="${passwordSuccess}" /></div>
                </c:if>
                <c:if test="${not empty passwordError}">
                    <div class="alert alert-danger" role="alert" tabindex="-1" data-account-error><c:out value="${passwordError}" /></div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/account/password" data-account-form>
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <div class="mb-3">
                        <label for="currentPassword" class="form-label fw-bold">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                        <input id="currentPassword" class="form-control" name="currentPassword" type="password"
                               required maxlength="72" autocomplete="current-password">
                    </div>
                    <div class="mb-3">
                        <label for="newPassword" class="form-label fw-bold">Mật khẩu mới <span class="text-danger">*</span></label>
                        <input id="newPassword" class="form-control" name="newPassword" type="password"
                               required minlength="8" maxlength="72" autocomplete="new-password" aria-describedby="passwordHelp">
                        <div class="form-text" id="passwordHelp">Ít nhất 8 ký tự và không quá 72 byte UTF-8. Nên kết hợp chữ, số và ký tự đặc biệt.</div>
                    </div>
                    <div class="mb-4">
                        <label for="confirmPassword" class="form-label fw-bold">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                        <input id="confirmPassword" class="form-control" name="confirmPassword" type="password"
                               required minlength="8" maxlength="72" autocomplete="new-password">
                    </div>
                    <button class="btn btn-primary px-4" type="submit">Đổi mật khẩu</button>
                </form>
            </div>
        </section>
    </div>

    <span id="savedProfileEmail" hidden><c:out value="${accountProfile.email}" /></span>
    <span id="savedProfileName" hidden><c:out value="${accountProfile.fullName}" /></span>
</main>

<script src="${pageContext.request.contextPath}/js/account-profile.js" defer></script>
<jsp:include page="fragments/footer.jsp" />
