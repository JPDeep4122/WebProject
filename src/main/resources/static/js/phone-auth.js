import { initializeApp } from
    'https://www.gstatic.com/firebasejs/13.1.0/firebase-app.js';

import {
    getAuth,
    RecaptchaVerifier,
    signInWithPhoneNumber,
    setPersistence,
    inMemoryPersistence,
    signOut
} from 'https://www.gstatic.com/firebasejs/13.1.0/firebase-auth.js';

const firebaseConfig = {
    apiKey: 'AIzaSyD5DTnqcOr5L0Oz3TfW3ZN_yMV_k7iXdFU',
    authDomain: 'techseven-auth-dev.firebaseapp.com',
    projectId: 'techseven-auth-dev',
    appId: '1:567821530704:web:6dc89c1fab1837b72f8355'
};

const roots = document.querySelectorAll('[data-phone-auth]');

function showMessage(root, text, error = false) {
    const message = root.querySelector('[data-phone-message]');
    message.textContent = text;
    message.className =
        'small mt-2 mb-0 ' +
        (error ? 'text-danger' : 'text-muted');
}

function normalizePhone(value) {
    let phone = value.replace(/[\s().-]/g, '');

    if (/^0\d{9}$/.test(phone)) {
        phone = '+84' + phone.slice(1);
    } else if (/^84\d{9}$/.test(phone)) {
        phone = '+' + phone;
    }

    if (!/^\+[1-9]\d{7,14}$/.test(phone)) {
        throw new Error('Số điện thoại không đúng định dạng.');
    }

    return phone;
}

function errorMessage(error) {
    const messages = {
        'auth/invalid-phone-number': 'Số điện thoại không hợp lệ.',
        'auth/invalid-verification-code': 'Mã OTP không chính xác.',
        'auth/code-expired': 'Mã đã hết hạn. Vui lòng gửi lại mã.',
        'auth/too-many-requests': 'Bạn thao tác quá nhiều. Hãy thử lại sau.',
        'auth/quota-exceeded': 'Dịch vụ SMS đã đạt giới hạn gửi.',
        'auth/captcha-check-failed': 'Vui lòng xác thực reCAPTCHA lại.',
        'auth/billing-not-enabled':
            'SMS hiện chưa khả dụng. Hãy dùng email hoặc Google.'
    };

    return messages[error.code]
        || error.message
        || 'Không thể xác thực số điện thoại.';
}

function completeLogin(user, contextPath) {
    localStorage.setItem('jwtToken', user.token);
    localStorage.setItem('accessToken', user.token);
    localStorage.setItem('currentUser', JSON.stringify(user));

    document.cookie =
        'accessToken=' + encodeURIComponent(user.token) +
        '; path=/; max-age=86400; SameSite=Lax' +
        (location.protocol === 'https:' ? '; Secure' : '');

    const roles = Array.isArray(user.roles) ? user.roles : [];
    let target = contextPath +
        (roles.includes('ROLE_SHIPPER') ? '/shipper/orders' : '/');

    const redirect = new URLSearchParams(location.search)
        .get('redirect');

    if (redirect?.startsWith('/') && !redirect.startsWith('//')) {
        try {
            const candidate = new URL(contextPath + redirect, location.origin);
            if (candidate.origin === location.origin) {
                target = candidate.href;
            }
        } catch (error) {
            // Dùng trang mặc định.
        }
    }

    location.assign(target);
}

function setup(root, auth, localTest) {
    const find = name => root.querySelector('[data-' + name + ']');
    const linking = root.dataset.mode === 'link';
    const contextPath = root.dataset.contextPath || '';

    const toggle = find('phone-toggle');
    const panel = find('phone-panel');
    const sendForm = find('phone-send-form');
    const codeForm = find('phone-code-form');
    const phoneInput = find('phone-input');
    const codeInput = find('phone-code');
    const captchaContainer = find('phone-captcha');
    const sendButton = find('phone-send');
    const confirmButton = find('phone-confirm');
    const changeButton = find('phone-change');
    const originalLabel = toggle.textContent.trim();

    let confirmation = null;
    let verifier = null;
    let verifiedToken = null;
    let busy = false;

    function setBusy(value) {
        busy = value;
        [
            toggle, sendButton, confirmButton,
            changeButton, phoneInput, codeInput
        ].forEach(element => element.disabled = value);
    }

    function setOpen(open) {
        panel.classList.toggle('d-none', !open);
        toggle.setAttribute('aria-expanded', String(open));

        if (!linking) {
            document.getElementById('formLogin')
                ?.classList.toggle('d-none', open);

            document.getElementById('googleSignInSection')
                ?.classList.toggle('d-none', open);

            toggle.textContent = open
                ? 'Quay lại đăng nhập email'
                : originalLabel;
        }
    }

    function clearCaptcha() {
        verifier?.clear();
        verifier = null;
        captchaContainer.replaceChildren();
    }

    toggle.disabled = false;

    toggle.addEventListener('click', function () {
        const open = panel.classList.contains('d-none');
        setOpen(open);

        if (open) {
            if (codeForm.classList.contains('d-none')) {
                phoneInput.focus();
            } else {
                codeInput.focus();
            }
        }
    });

    sendForm.addEventListener('submit', async function (event) {
        event.preventDefault();
        if (busy) return;

        try {
            const phone = normalizePhone(phoneInput.value);
            setBusy(true);
            verifiedToken = null;
            showMessage(root, 'Đang yêu cầu mã xác thực...');

            if (!verifier) {
                verifier = new RecaptchaVerifier(
                    auth, captchaContainer, { size: 'normal' }
                );
            }

            await verifier.render();

            confirmation = await signInWithPhoneNumber(
                auth, phone, verifier
            );

            find('phone-target').textContent = phone;
            sendForm.classList.add('d-none');
            codeForm.classList.remove('d-none');
            codeInput.value = '';
            codeInput.readOnly = false;

            showMessage(root, localTest
                ? 'Nhập mã kiểm thử đã đặt trong Firebase.'
                : 'Nhập mã OTP bạn nhận được qua SMS.');

        } catch (error) {
            clearCaptcha();
            showMessage(root, errorMessage(error), true);
        } finally {
            setBusy(false);
            if (!codeForm.classList.contains('d-none')) {
                codeInput.focus();
            }
        }
    });

    codeForm.addEventListener('submit', async function (event) {
        event.preventDefault();
        if (busy) return;

        let leaving = false;

        try {
            if (!confirmation && !verifiedToken) {
                throw new Error('Vui lòng gửi mã OTP trước.');
            }

            setBusy(true);
            showMessage(root, 'Đang xác thực...');

            if (!verifiedToken) {
                const result = await confirmation.confirm(
                    codeInput.value.trim()
                );

                verifiedToken = await result.user.getIdToken();
                codeInput.readOnly = true;
                await signOut(auth);
            }

            const endpoint = linking
                ? '/api/account/phone/link'
                : '/api/auth/phone/login';

            const response = await csrfFetch(contextPath + endpoint, {
                method: 'POST',
                credentials: 'same-origin',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ idToken: verifiedToken })
            });

            let data;
            try {
                data = await response.json();
            } catch (error) {
                throw new Error(
                    'Không đọc được phản hồi máy chủ. Hãy tải lại trang.'
                );
            }

            if (!response.ok || !data.success) {
                throw new Error(data.message || 'Xác thực thất bại.');
            }

            if (linking) {
                showMessage(root,
                    'Đã liên kết ' + data.data +
                    '. Bạn có thể đăng nhập bằng số này.');

                confirmation = null;
                verifiedToken = null;
                codeInput.readOnly = false;
                sendForm.classList.remove('d-none');
                codeForm.classList.add('d-none');
                clearCaptcha();
                setOpen(false);
            } else {
                if (!data.data?.token) {
                    throw new Error('Máy chủ chưa trả thông tin đăng nhập.');
                }

                leaving = true;
                completeLogin(data.data, contextPath);
            }

        } catch (error) {
            showMessage(root, errorMessage(error), true);
        } finally {
            if (!leaving) setBusy(false);
        }
    });

    changeButton.addEventListener('click', function () {
        confirmation = null;
        verifiedToken = null;
        codeInput.value = '';
        codeInput.readOnly = false;
        sendForm.classList.remove('d-none');
        codeForm.classList.add('d-none');
        clearCaptcha();
        showMessage(root, '');
        phoneInput.focus();
    });

    if (localTest) {
        showMessage(root,
            'Chế độ thử: dùng số và mã kiểm thử đã khai báo trong Firebase.');
    }
}

try {
    const app = initializeApp(firebaseConfig, 'techseven-phone-ui');
    const auth = getAuth(app);

    auth.languageCode = 'vi';
    await setPersistence(auth, inMemoryPersistence);

    const localTest =
        firebaseConfig.projectId === 'techseven-auth-dev'
        && ['localhost', '127.0.0.1'].includes(location.hostname);

    if (localTest) {
        auth.settings.appVerificationDisabledForTesting = true;
    }

    roots.forEach(root => setup(root, auth, localTest));
} catch (error) {
    roots.forEach(root => showMessage(
        root,
        'Không khởi tạo được xác thực điện thoại. Hãy tải lại trang.',
        true
    ));
}