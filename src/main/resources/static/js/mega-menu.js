document.addEventListener('DOMContentLoaded', function () {
    const wrapper = document.querySelector('.mega-menu-wrapper');
    const panel = document.getElementById('megaMenuPanel');
    const trigger = document.getElementById('btnMegaMenu');
    const backdrop = document.querySelector('.mega-menu-backdrop');
    if (!wrapper || !panel || !trigger) return;

    const hoverPointer = window.matchMedia('(hover: hover) and (pointer: fine)');
    const desktop = window.matchMedia('(min-width: 768px)');
    let hideTimeout;

    function positionMenu() {
        panel.style.left = '0px';
        const bounds = panel.getBoundingClientRect();
        panel.style.left = Math.min(0, window.innerWidth - 24 - bounds.right) + 'px';
        wrapper.style.setProperty('--mega-available-height',
            Math.max(0, window.innerHeight - bounds.top - 16) + 'px');
        if (backdrop) {
            const header = wrapper.closest('header');
            const top = header ? header.getBoundingClientRect().bottom : bounds.top;
            backdrop.style.setProperty('--mega-backdrop-top', Math.max(0, top) + 'px');
        }
    }

    function openMenu() {
        if (!desktop.matches) return;
        clearTimeout(hideTimeout);
        panel.classList.add('show');
        wrapper.classList.add('is-open');
        trigger.setAttribute('aria-expanded', 'true');
        positionMenu();
    }

    function closeMenu() {
        clearTimeout(hideTimeout);
        panel.classList.remove('show');
        wrapper.classList.remove('is-open');
        trigger.setAttribute('aria-expanded', 'false');
    }

    wrapper.addEventListener('mouseenter', function () {
        if (hoverPointer.matches) openMenu();
    });

    wrapper.addEventListener('mouseleave', function () {
        if (!hoverPointer.matches) return;
        hideTimeout = setTimeout(function () {
            const focused = document.activeElement;
            if (panel.contains(focused) && focused.matches(':focus-visible')) return;
            closeMenu();
        }, 180);
    });

    trigger.addEventListener('click', function (event) {
        if (panel.classList.contains('show') && (!hoverPointer.matches || event.detail === 0)) {
            closeMenu();
        } else {
            openMenu();
        }
    });

    trigger.addEventListener('keydown', function (event) {
        if (event.key !== 'ArrowDown') return;
        event.preventDefault();
        openMenu();
        panel.querySelector('[role="tab"].active').focus();
    });

    wrapper.addEventListener('keydown', function (event) {
        if (event.key !== 'Escape' || !panel.classList.contains('show')) return;
        event.preventDefault();
        closeMenu();
        trigger.focus({ preventScroll: true });
    });

    wrapper.addEventListener('focusout', function (event) {
        if (!wrapper.contains(event.relatedTarget)) closeMenu();
    });

    document.addEventListener('click', function (event) {
        if (!wrapper.contains(event.target)) closeMenu();
    });

    const tabs = panel.querySelectorAll('[data-bs-toggle="pill"]');
    tabs.forEach(function (button) {
        button.addEventListener('mouseenter', function () {
            if (hoverPointer.matches && window.bootstrap) {
                window.bootstrap.Tab.getOrCreateInstance(button).show();
            }
        });
        button.addEventListener('shown.bs.tab', function () {
            panel.querySelector('.mega-content').scrollTop = 0;
        });
    });

    window.addEventListener('resize', function () {
        if (!desktop.matches) closeMenu();
        else if (panel.classList.contains('show')) positionMenu();
    });
    window.addEventListener('scroll', function () {
        if (panel.classList.contains('show')) positionMenu();
    }, { passive: true });
});
