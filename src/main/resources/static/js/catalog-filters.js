document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('catalogFiltersForm');
    if (!form) return;

    const sidebar = document.querySelector('.catalog-sidebar');
    const toggle = document.getElementById('catalogFilterToggle');
    const minPrice = document.getElementById('filterMinPrice');
    const maxPrice = document.getElementById('filterMaxPrice');
    const presets = form.querySelectorAll('[name="pricePreset"]');
    const brandAll = document.getElementById('filterBrandAll');
    const brandChecks = form.querySelectorAll('[name="brandIds"]');

    if (brandAll) {
        brandAll.addEventListener('change', function () {
            if (brandAll.checked) {
                brandChecks.forEach(function (cb) { cb.checked = false; });
                form.requestSubmit();
            } else {
                const anyChecked = Array.from(brandChecks).some(function (cb) { return cb.checked; });
                if (!anyChecked) brandAll.checked = true;
            }
        });

        brandChecks.forEach(function (cb) {
            cb.addEventListener('change', function () {
                const anyChecked = Array.from(brandChecks).some(function (item) { return item.checked; });
                brandAll.checked = !anyChecked;
            });
        });
    }

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
        presets.forEach(function (preset) { preset.disabled = true; });
        if (brandAll) brandAll.disabled = true;
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

    window.addEventListener('pageshow', function () {
        form.querySelectorAll('input, select').forEach(function (input) { input.disabled = false; });
    });
});