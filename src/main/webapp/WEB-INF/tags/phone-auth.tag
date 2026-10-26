<%@ tag body-content="empty" pageEncoding="UTF-8" %>
<%@ attribute name="mode" required="true" type="java.lang.String" %>

<section class="mt-3"
         data-phone-auth
         data-mode="${mode}"
         data-context-path="${pageContext.request.contextPath}">

    <button type="button"
            class="btn btn-outline-primary w-100 rounded-pill py-2"
            data-phone-toggle
            aria-expanded="false"
            aria-controls="phone-panel-${mode}"
            disabled>
        <i class="bi bi-telephone me-2" aria-hidden="true"></i>
        ${mode eq 'link'
            ? 'Xác minh số điện thoại'
            : 'Đăng nhập bằng số điện thoại'}
    </button>

    <div id="phone-panel-${mode}"
         class="border rounded-4 p-3 mt-3 d-none"
         data-phone-panel>

        <form data-phone-send-form>
            <label class="form-label"
                   for="phone-input-${mode}">
                Số điện thoại
            </label>

            <input id="phone-input-${mode}"
                   class="form-control rounded-pill mb-3"
                   type="tel"
                   autocomplete="tel"
                   placeholder="Nhập số điện thoại"
                   maxlength="20"
                   data-phone-input
                   required>

            <div class="mb-3" data-phone-captcha></div>

            <button class="btn btn-primary w-100 rounded-pill"
                    type="submit"
                    data-phone-send>
                Gửi mã OTP
            </button>
        </form>

        <form class="d-none" data-phone-code-form>
            <p class="small text-muted">
                Nhập mã xác thực cho
                <strong data-phone-target></strong>
            </p>

            <label class="form-label"
                   for="phone-code-${mode}">
                Mã OTP
            </label>

            <input id="phone-code-${mode}"
                   class="form-control rounded-pill text-center mb-3"
                   type="text"
                   inputmode="numeric"
                   autocomplete="one-time-code"
                   pattern="[0-9]{6}"
                   maxlength="6"
                   placeholder="Nhập mã 6 chữ số"
                   data-phone-code
                   required>

            <button class="btn btn-primary w-100 rounded-pill"
                    type="submit"
                    data-phone-confirm>
                ${mode eq 'link'
                    ? 'Xác nhận liên kết'
                    : 'Xác nhận đăng nhập'}
            </button>

            <button class="btn btn-link w-100 mt-2"
                    type="button"
                    data-phone-change>
                Đổi số / Gửi lại mã
            </button>
        </form>
    </div>

    <p class="small mt-2 mb-0"
       data-phone-message
       role="status"
       aria-live="polite"></p>
</section>