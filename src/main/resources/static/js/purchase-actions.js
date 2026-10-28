(function () {
    'use strict';
    const contextPath = document.currentScript?.dataset.context || '';
    let preparingPurchase = false;

    window.buyProductNow = async function (productId, quantity, button) {
        if (preparingPurchase || button?.disabled) return;
        const count = Number(quantity);
        if (!Number.isSafeInteger(count) || count < 1) return;

        const host = button?.parentElement;
        let errorBox = host?.querySelector('[data-purchase-error]');
        if (errorBox) errorBox.remove();
        const originalHtml = button?.innerHTML;
        let redirecting = false;
        preparingPurchase = true;
        if (button) {
            button.disabled = true;
            button.textContent = 'Đang chuyển đến thanh toán...';
        }

        try {
            const token = localStorage.getItem('accessToken') || localStorage.getItem('jwtToken');
            const headers = {'Content-Type': 'application/json'};
            if (token) headers.Authorization = 'Bearer ' + token;
            const response = await csrfFetch(contextPath + '/api/cart/buy-now', {
                method: 'POST', headers,
                body: JSON.stringify({productId, quantity: count})
            });
            const result = await response.json().catch(() => null);
            if (!response.ok || !result?.success) {
                throw new Error(result?.message || 'Chưa thể mua ngay. Vui lòng thử lại.');
            }
            const badge = document.getElementById('cartBadge');
            if (badge && result.data) badge.textContent = result.data.totalQuantity;
            // Checkout vẫn kiểm tra đăng nhập ở server; khách vãng lai sẽ được mời đăng nhập.
            window.location.assign(contextPath + '/checkout');
            redirecting = true;
        } catch (error) {
            if (host) {
                errorBox = document.createElement('div');
                errorBox.dataset.purchaseError = '';
                errorBox.className = 'small text-danger mt-2';
                errorBox.setAttribute('role', 'alert');
                errorBox.textContent = error.message || 'Không kết nối được máy chủ.';
                host.append(errorBox);
            }
        } finally {
            if (!redirecting) {
                preparingPurchase = false;
                if (button) {
                    button.disabled = false;
                    button.innerHTML = originalHtml;
                }
            }
        }
    };
})();
