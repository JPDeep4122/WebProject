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