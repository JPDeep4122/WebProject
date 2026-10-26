(function () {
    const root = document.getElementById('orderRealtime');
    if (!root) return;

    const contextPath = root.dataset.contextPath || '';
    const currentOrderCode = root.dataset.orderCode || '';
    const destination = root.dataset.destination || '/user/queue/order-status';
    const pollUrl = root.dataset.pollUrl || '';
    const token = localStorage.getItem('jwtToken') || localStorage.getItem('accessToken');

    const labels = {
        CONFIRMED: 'Đơn hàng đã được xác nhận',
        PROCESSING: 'Chi nhánh đang chuẩn bị hàng',
        SHIPPING: 'Đơn hàng đang được giao',
        DELIVERED: 'Đơn hàng đã giao thành công',
        CANCELLED: 'Đơn hàng đã bị hủy',
        RETURN_REQUESTED: 'Đã ghi nhận yêu cầu trả hàng',
        RETURNED: 'Đã hoàn tất trả hàng',
        REFUNDED: 'Đã hoàn tiền'
    };
    let reconnectTimer;
    let reconnectDelay = 2000;
    let pollTimer;
    let knownStatuses;
    let stopped = false;
    let client;

    function showUpdate(update) {
        if (!update || !update.orderCode || !update.status) return;
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

    async function pollStatuses() {
        if (stopped || !pollUrl || !navigator.onLine) return;
        const headers = { Accept: 'application/json' };
        if (token) headers.Authorization = 'Bearer ' + token;
        try {
            const response = await fetch(pollUrl, {
                method: 'GET',
                headers: headers,
                credentials: 'same-origin',
                cache: 'no-store'
            });
            if (!response.ok) return;
            const snapshots = await response.json();
            const safeSnapshots = Array.isArray(snapshots) ? snapshots : [];
            const nextStatuses = new Map();
            safeSnapshots.forEach(function (snapshot) {
                nextStatuses.set(snapshot.orderCode, snapshot.status);
            });
            if (knownStatuses) {
                for (const snapshot of safeSnapshots) {
                    const previousStatus = knownStatuses.get(snapshot.orderCode);
                    if (previousStatus && previousStatus !== snapshot.status) {
                        showUpdate(snapshot);
                        break;
                    }
                }
            }
            knownStatuses = nextStatuses;
        } catch (error) {
            console.debug('Polling trạng thái đơn tạm thời thất bại.', error);
        }
    }

    function startPolling() {
        if (!pollUrl || pollTimer) return;
        pollStatuses();
        pollTimer = window.setInterval(pollStatuses, 15000);
    }

    function stopPolling() {
        if (!pollTimer) return;
        window.clearInterval(pollTimer);
        pollTimer = null;
    }

    function connect() {
        if (stopped || !navigator.onLine) return;
        if (typeof SockJS === 'undefined' || typeof Stomp === 'undefined' || !token) {
            startPolling();
            return;
        }
        const socket = new SockJS(contextPath + '/ws');
        client = Stomp.over(socket);
        client.debug = null;
        client.connect(
            { Authorization: 'Bearer ' + token },
            function () {
                reconnectDelay = 2000;
                stopPolling();
                client.subscribe(destination, function (message) {
                    try { showUpdate(JSON.parse(message.body)); }
                    catch (error) { console.error('Dữ liệu trạng thái đơn không hợp lệ.', error); }
                });
            },
            function () {
                startPolling();
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
        knownStatuses = null;
        startPolling();
        connect();
    });
    window.addEventListener('beforeunload', function () {
        stopped = true;
        window.clearTimeout(reconnectTimer);
        stopPolling();
        if (client && client.connected) client.disconnect(function () {});
    });
})();