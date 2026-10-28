window.csrfFetch = function (url, options = {}) {
    const target = new URL(url, window.location.href);
    const method = (options.method || 'GET').toUpperCase();
    const headers = new Headers(options.headers || {});

    const changesData =
        !['GET', 'HEAD', 'OPTIONS', 'TRACE'].includes(method);

    if (target.origin === window.location.origin && changesData) {
        const token = document
            .querySelector('meta[name="_csrf"]')?.content;

        const headerName = document
            .querySelector('meta[name="_csrf_header"]')?.content;

        if (!token || !headerName) {
            return Promise.reject(
                new Error('Thiếu CSRF token. Hãy tải lại trang.'));
        }

        headers.set(headerName, token);
    }

    return window.fetch(url, {
        ...options,
        headers
    });
};

window.loginDestination = function (user, contextPath = '') {
    const roles = Array.isArray(user?.roles) ? user.roles : [];
    const isInternal = roles.includes('ROLE_ADMIN')
        || roles.includes('ROLE_BRANCH_MANAGER')
        || roles.includes('ROLE_STAFF')
        || roles.includes('ROLE_SHIPPER');
    const fallback = (roles.includes('ROLE_ADMIN') || roles.includes('ROLE_BRANCH_MANAGER')) ? '/admin'
        : roles.includes('ROLE_STAFF') ? '/admin/orders'
        : roles.includes('ROLE_SHIPPER') ? '/shipper/orders' : '/';

    if (isInternal) {
        return contextPath + fallback;
    }

    const redirect = new URLSearchParams(window.location.search).get('redirect');
    if (redirect && redirect !== '/account/profile') {
        if (redirect.startsWith('/') && !redirect.startsWith('//')
                && !/[\\\r\n]/.test(redirect)) {
            try {
                const target = new URL(contextPath + redirect, window.location.origin);
                if (target.origin === window.location.origin) return target.href;
            } catch (error) { }
        }
    }
    return contextPath + fallback;
};