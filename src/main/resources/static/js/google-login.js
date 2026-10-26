(function () {
    const section = document.getElementById('googleSignInSection');
    if (!section) return;

    const button = document.getElementById('googleSignInButton');
    const message = document.getElementById('googleSignInMessage');
    const contextPath = section.dataset.contextPath || '';

    let submitting = false;

    function showMessage(text, isError = false) {
        message.textContent = text;
        message.className =
            'small text-center mt-2 mb-0 ' +
            (isError ? 'text-danger' : 'text-muted');
    }

    function getRedirectUrl(user) {
        const roles = Array.isArray(user.roles) ? user.roles : [];
        const defaultPath = roles.includes('ROLE_SHIPPER')
            ? '/shipper/orders'
            : '/';

        let target = contextPath + defaultPath;

        const redirect = new URLSearchParams(location.search)
            .get('redirect');

        if (redirect && redirect.startsWith('/')
                && !redirect.startsWith('//')) {
            try {
                const candidate = new URL(
                    contextPath + redirect,
                    location.origin
                );

                if (candidate.origin === location.origin) {
                    target = candidate.href;
                }
            } catch (error) {
                // Dùng trang mặc định nếu đường dẫn không hợp lệ.
            }
        }

        return target;
    }

    async function handleGoogleCredential(result) {
        if (submitting) return;

        if (!result.credential) {
            showMessage(
                'Chưa nhận được thông tin đăng nhập Google.',
                true
            );
            return;
        }

        submitting = true;
        button.inert = true;
        section.setAttribute('aria-busy', 'true');
        showMessage('Đang xác thực tài khoản Google...');

        try {
            const response = await csrfFetch(
                contextPath + '/api/auth/google',
                {
                    method: 'POST',
                    credentials: 'same-origin',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        credential: result.credential
                    })
                }
            );

            const data = await response.json();

            if (!response.ok || !data.success || !data.data?.token) {
                throw new Error(
                    data.message || 'Đăng nhập Google thất bại.'
                );
            }

            const user = data.data;

            localStorage.setItem('jwtToken', user.token);
            localStorage.setItem('accessToken', user.token);
            localStorage.setItem('currentUser', JSON.stringify(user));

            document.cookie =
                'accessToken=' + encodeURIComponent(user.token) +
                '; path=/; max-age=86400; SameSite=Lax' +
                (location.protocol === 'https:' ? '; Secure' : '');

            showMessage('Đăng nhập thành công! Đang chuyển hướng...');
            location.assign(getRedirectUrl(user));

        } catch (error) {
            const text = error instanceof SyntaxError
                ? 'Máy chủ trả phản hồi không hợp lệ. Hãy tải lại trang.'
                : error.message || 'Không thể kết nối đến máy chủ.';

            showMessage(text, true);
            submitting = false;
            button.inert = false;
            section.removeAttribute('aria-busy');
        }
    }

    window.initTechsevenGoogle = function () {
        const clientId = section.dataset.googleClientId?.trim();

        if (!clientId) {
            showMessage(
                'Đăng nhập Google hiện chưa được cấu hình.',
                true
            );
            return;
        }

        google.accounts.id.initialize({
            client_id: clientId,
            callback: handleGoogleCredential,
            auto_select: false,
            use_fedcm_for_button: true
        });

        google.accounts.id.renderButton(button, {
            type: 'standard',
            theme: 'outline',
            size: 'large',
            shape: 'pill',
            text: 'signin_with',
            locale: 'vi',
            width: Math.max(
                200,
                Math.min(360, Math.floor(button.clientWidth) || 200)
            )
        });
    };

    window.techsevenGoogleLoadFailed = function () {
        showMessage(
            'Không tải được đăng nhập Google. Hãy tải lại trang.',
            true
        );
    };
})();