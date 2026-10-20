(function () {
    const root = document.getElementById('orderRealtime');
    if (!root || typeof SockJS === 'undefined' || typeof Stomp === 'undefined') return;

    const contextPath = root.dataset.contextPath || '';
    const currentOrderCode = root.dataset.orderCode || '';
    const token = localStorage.getItem('jwtToken') || localStorage.getItem('accessToken');
    if (!token) return;

    const labels = {
        CONFIRMED: 'Đơn hàng đã được xác nhận',
        PROCESSING: 'Chi nhánh đang chuẩn bị hàng',
        SHIPPING: 'Đơn hàng đang được giao',
        DELIVERED: 'Đơn hàng đã giao thành công',
        CANCELLED: 'Đơn hàng đã bị hủy',
        RETURN_REQUESTED: 'Đã ghi nhận yêu cầu trả hàng',
        RETURNED: 'Đã hoàn tất trả hàng'
    };
    let reconnectTimer;

    function showUpdate(update) {
        if (currentOrderCode && update.orderCode !== currentOrderCode) return;

        const alert = document.createElement('div');
        alert.className = 'alert alert-info position-fixed top-0 start-50 translate-middle-x mt-3 shadow';
        alert.style.zIndex = '2000';
        alert.setAttribute('role', 'status');
        alert.textContent = '#' + update.orderCode + ': '
                + (labels[update.status] || ('Trạng thái mới: ' + update.status));
        document.body.appendChild(alert);
        window.setTimeout(function () { window.location.reload(); }, 900);
    }

    function connect() {
        const socket = new SockJS(contextPath + '/ws');
        const client = Stomp.over(socket);
        client.debug = null;
        client.connect(
            { Authorization: 'Bearer ' + token },
            function () {
                client.subscribe('/user/queue/order-status', function (message) {
                    try { showUpdate(JSON.parse(message.body)); }
                    catch (error) { console.error('Dữ liệu trạng thái đơn không hợp lệ.', error); }
                });
            },
            function () {
                window.clearTimeout(reconnectTimer);
                reconnectTimer = window.setTimeout(connect, 5000);
            }
        );
    }

    document.addEventListener('DOMContentLoaded', connect);
})();
