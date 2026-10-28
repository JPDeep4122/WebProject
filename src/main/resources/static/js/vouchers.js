(function () {
    'use strict';
    const cards = [...document.querySelectorAll('.voucher-card-item')];
    const tabs = [...document.querySelectorAll('#voucherFilterTabs [data-filter]')];
    function filter(type) {
        let visible = 0;
        cards.forEach(card => {
            const match = type === 'all' || card.dataset.type === type
                || (type === 'VNPAY' && card.dataset.payment === 'VNPAY');
            card.hidden = !match;
            if (match) visible++;
        });
        tabs.forEach(tab => {
            const active = tab.dataset.filter === type;
            tab.classList.toggle('active', active);
            tab.setAttribute('aria-pressed', String(active));
        });
        document.getElementById('voucherVisibleCount').textContent = visible + ' mã ưu đãi';
        document.getElementById('voucherEmptyState').hidden = visible > 0;
    }
    tabs.forEach(tab => tab.addEventListener('click', () => filter(tab.dataset.filter)));
    document.querySelectorAll('[data-copy-code]').forEach(button => {
        button.addEventListener('click', async () => {
            const original = button.innerHTML;
            const status = document.getElementById('voucherCopyStatus');
            try {
                await navigator.clipboard.writeText(button.dataset.copyCode);
                status.textContent = 'Đã sao chép mã ' + button.dataset.copyCode + '.';
                button.textContent = 'Đã sao chép';
                button.disabled = true;
                setTimeout(() => { button.innerHTML = original; button.disabled = false; }, 1400);
            } catch (error) {
                status.textContent = 'Chưa sao chép được. Bạn có thể chọn và sao chép trực tiếp mã trên thẻ.';
            }
        });
    });
    filter('all');
})();
