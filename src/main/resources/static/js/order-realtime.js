(function () {
    const root = document.getElementById('orderRealtime');
    if (!root || typeof SockJS === 'undefined' || typeof Stomp === 'undefined') return;

    const contextPath = root.dataset.contextPath || '';
    const currentOrderCode = root.dataset.orderCode || '';
    const destination = root.dataset.destination || '/user/queue/order-status';
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
    let reconnectDelay = 2000;
    let stopped = false;
    let client;

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
        if (stopped || !navigator.onLine) return;
        const socket = new SockJS(contextPath + '/ws');
        client = Stomp.over(socket);
        client.debug = null;
        client.connect(
            { Authorization: 'Bearer ' + token },
            function () {
                reconnectDelay = 2000;
                client.subscribe(destination, function (message) {
                    try { showUpdate(JSON.parse(message.body)); }
                    catch (error) { console.error('Dữ liệu trạng thái đơn không hợp lệ.', error); }
                });
            },
            function () {
                window.clearTimeout(reconnectTimer);
                if (!stopped) {
                    reconnectTimer = window.setTimeout(connect, reconnectDelay);
                    reconnectDelay = Math.min(reconnectDelay * 2, 30000);
                }
            }
        );
    }

    document.addEventListener('DOMContentLoaded', connect);
    window.addEventListener('online', function () {
        window.clearTimeout(reconnectTimer);
        reconnectDelay = 2000;
        connect();
    });
    window.addEventListener('beforeunload', function () {
        stopped = true;
        window.clearTimeout(reconnectTimer);
        if (client && client.connected) client.disconnect(function () {});
    });
})();
