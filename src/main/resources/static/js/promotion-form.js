document.addEventListener('DOMContentLoaded', function () {
    'use strict';
    const labels = {
        name: 'tên chương trình voucher', code: 'mã voucher',
        discountPercent: 'phần trăm giảm', discountAmount: 'số tiền giảm',
        maxDiscountAmount: 'mức giảm tối đa', minOrderAmount: 'giá trị đơn tối thiểu',
        maxUses: 'tổng số lượt', perUserLimit: 'lượt dùng mỗi khách',
        startsAt: 'thời gian bắt đầu', endsAt: 'thời gian kết thúc'
    };

    document.querySelectorAll('[data-voucher-form]').forEach(wrap => {
        const form = wrap.closest('form');
        if (!form) return;
        const fields = [...wrap.querySelectorAll('input:not([type="hidden"]),select')];
        const end = wrap.querySelector('[name="endsAt"]');
        const start = wrap.querySelector('[name="startsAt"]');

        function validate(input) {
            input.setCustomValidity('');
            if (input.disabled) return;
            const label = labels[input.name] || 'thông tin này';
            const validity = input.validity;
            let message = '';
            if (validity.valueMissing) message = 'Vui lòng nhập ' + label + '.';
            else if (validity.badInput || validity.typeMismatch) message = 'Vui lòng nhập đúng định dạng ' + label + '.';
            else if (validity.rangeUnderflow) {
                message = input.name === 'maxUses'
                    ? 'Tổng số lượt phải từ 1 trở lên; để trống nếu không giới hạn.'
                    : input.name === 'perUserLimit'
                    ? 'Lượt dùng mỗi khách phải từ 1 trở lên; để trống nếu không giới hạn.'
                    : 'Giá trị ' + label + ' phải từ ' + input.min + ' trở lên.';
            } else if (validity.rangeOverflow) message = 'Giá trị ' + label + ' không được vượt quá ' + input.max + '.';
            else if (validity.stepMismatch) message = input.step === '1'
                    ? 'Vui lòng nhập số nguyên cho ' + label + '.'
                    : 'Vui lòng nhập ' + label + ' với tối đa hai chữ số thập phân.';
            else if (validity.patternMismatch) message = 'Mã voucher cần 2–50 ký tự, chỉ gồm chữ, số, dấu gạch ngang hoặc gạch dưới.';
            else if (validity.tooLong) message = 'Nội dung ' + label + ' quá dài.';
            if (!message && input === end && start?.value && end.value
                    && new Date(end.value) <= new Date(start.value)) {
                message = 'Thời gian kết thúc phải sau thời gian bắt đầu.';
            }
            input.setCustomValidity(message);
            return message;
        }

        function showError(input, message) {
            const parent = input.closest('.input-group') || input;
            let hint = parent.nextElementSibling;
            if (!hint?.hasAttribute('data-validation-error')) {
                hint = document.createElement('div');
                hint.dataset.validationError = '';
                hint.className = 'text-danger small mt-1';
                hint.setAttribute('role', 'alert');
                parent.insertAdjacentElement('afterend', hint);
            }
            hint.textContent = message || '';
            input.setAttribute('aria-invalid', String(Boolean(message)));
        }

        fields.forEach(input => {
            input.addEventListener('invalid', () => showError(input, validate(input)));
            input.addEventListener('input', () => {
                const message = validate(input);
                if (input.hasAttribute('aria-invalid')) showError(input, message);
                if (end && input === start) {
                    const dateMessage = validate(end);
                    if (end.hasAttribute('aria-invalid')) showError(end, dateMessage);
                }
            });
            input.addEventListener('change', () => {
                fields.forEach(field => {
                    const message = validate(field);
                    if (field.hasAttribute('aria-invalid')) showError(field, message);
                });
            });
            validate(input);
        });
        form.addEventListener('submit', event => {
            fields.forEach(validate);
            if (!form.reportValidity()) event.preventDefault();
        });
    });
});
