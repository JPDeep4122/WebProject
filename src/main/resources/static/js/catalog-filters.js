document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('catalogFiltersForm');
    if (!form) return;

    const sidebar = document.querySelector('.catalog-sidebar');
    const toggle = document.getElementById('catalogFilterToggle');
    const minPrice = document.getElementById('filterMinPrice');
    const maxPrice = document.getElementById('filterMaxPrice');
    const presets = form.querySelectorAll('[name="pricePreset"]');

    form.querySelectorAll('[name="categorySlug"]').forEach(function (category) {
        category.addEventListener('change', function () {
            // Thương hiệu của danh mục trước không được giữ lại để làm rỗng danh mục mới.
            form.querySelectorAll('[name="brandIds"]').forEach(function (brand) { brand.checked = false; });
            form.requestSubmit();
        });
    });

    if (toggle && sidebar) {
        toggle.addEventListener('click', function () {
            const open = sidebar.classList.toggle('is-open');
            toggle.setAttribute('aria-expanded', String(open));
            toggle.querySelector('span').textContent = open ? 'Ẩn bộ lọc' : 'Hiện bộ lọc';
        });
    }

    function validatePrices() {
        maxPrice.setCustomValidity('');
        if (minPrice.value && maxPrice.value && Number(minPrice.value) > Number(maxPrice.value)) {
            maxPrice.setCustomValidity('Giá tối đa phải lớn hơn hoặc bằng giá tối thiểu.');
        }
    }

    presets.forEach(function (preset) {
        preset.addEventListener('change', function () {
            const range = preset.value.split(':');
            minPrice.value = range[0];
            maxPrice.value = range[1];
            validatePrices();
        });
    });

    [minPrice, maxPrice].forEach(function (input) {
        input.addEventListener('input', function () {
            validatePrices();
            presets.forEach(function (preset) {
                const range = preset.value.split(':');
                preset.checked = minPrice.value === range[0] && maxPrice.value === range[1];
            });
        });
    });

    form.addEventListener('submit', function (event) {
        validatePrices();
        if (!form.reportValidity()) {
            event.preventDefault();
            return;
        }
        // Only the actual bounds belong in the URL; presets are a UI shortcut.
        presets.forEach(function (preset) { preset.disabled = true; });
        form.querySelectorAll('[name="minPrice"], [name="maxPrice"], [name="branchId"], [name="minRating"], [name="categorySlug"]')
            .forEach(function (input) { if (!input.value) input.disabled = true; });
    });

    const branch = document.getElementById('filterBranch');
    if (branch) {
        branch.addEventListener('change', function () {
            if (branch.value) document.getElementById('filterInStock').checked = true;
        });
    }

    const sort = document.getElementById('catalogSort');
    if (sort) sort.addEventListener('change', function () { form.requestSubmit(); });

    const header = document.querySelector('.sf-header');
    function updateStickyPosition() {
        if (header) document.documentElement.style.setProperty('--catalog-sticky-top', header.offsetHeight + 16 + 'px');
    }
    updateStickyPosition();
    if (header && typeof ResizeObserver !== 'undefined') {
        new ResizeObserver(updateStickyPosition).observe(header);
    }

    document.querySelectorAll('[data-catalog-product-image]').forEach(function (image) {
        function showPlaceholder() { image.hidden = true; }
        image.addEventListener('error', showPlaceholder);
        if (image.complete && image.naturalWidth === 0) showPlaceholder();
    });

    // A browser may restore a page from its back/forward cache after submission.
    window.addEventListener('pageshow', function () {
        form.querySelectorAll('input, select').forEach(function (input) { input.disabled = false; });
    });
});
