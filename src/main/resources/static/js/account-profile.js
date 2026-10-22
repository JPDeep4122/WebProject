document.addEventListener('DOMContentLoaded', function () {
    const page = document.getElementById('accountProfilePage');
    if (!page) return;

    // Keep the header in sync with the saved profile, not with an invalid form.
    try {
        const user = JSON.parse(localStorage.getItem('currentUser') || 'null');
        const email = document.getElementById('savedProfileEmail').textContent;
        if (user && user.email === email) {
            user.fullName = document.getElementById('savedProfileName').textContent;
            localStorage.setItem('currentUser', JSON.stringify(user));
            if (typeof checkLoginStatus === 'function') checkLoginStatus();
        }
    } catch (error) {
        // Profile forms also work when browser storage is unavailable.
    }

    const password = document.getElementById('newPassword');
    const confirmation = document.getElementById('confirmPassword');
    function validatePasswords() {
        password.setCustomValidity(new TextEncoder().encode(password.value).length > 72
            ? 'Mật khẩu mới không được vượt quá 72 byte UTF-8.' : '');
        confirmation.setCustomValidity(confirmation.value && confirmation.value !== password.value
            ? 'Xác nhận mật khẩu mới chưa khớp.' : '');
    }
    password.addEventListener('input', validatePasswords);
    confirmation.addEventListener('input', validatePasswords);

    page.querySelectorAll('[data-account-form]').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!form.reportValidity()) {
                event.preventDefault();
                return;
            }
            const button = form.querySelector('button[type="submit"]');
            button.disabled = true;
            button.textContent = 'Đang lưu...';
        });
    });
    page.querySelector('[data-account-error]')?.focus();
});
