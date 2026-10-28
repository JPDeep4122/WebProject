(function () {
  'use strict';

  function init() {
    var contextPath = window.CONTEXT_PATH || '';
    var apiUrl = contextPath + '/api/notifications';
    var badge = document.getElementById('notificationUnreadBadge');
    var list = document.getElementById('notificationList');
    var errorBox = document.getElementById('notificationPageMessage');
    var markAllButton = document.getElementById('markAllNotificationsRead');
    var unreadCount = 0;
    var markingAll = false;

    if (!badge && !list) return;

    function updateBadge(count) {
      var value = Number(count);
      unreadCount = isFinite(value) && value > 0 ? Math.floor(value) : 0;

      if (!badge) return;

      badge.textContent = unreadCount > 99 ? '99+' : String(unreadCount);
      badge.classList.toggle('d-none', unreadCount === 0);
    }

    function clearError() {
      if (!errorBox) return;

      errorBox.textContent = '';
      errorBox.classList.add('d-none');
    }

    function showError(message) {
      if (!errorBox) return;

      errorBox.textContent = message || 'Không thể xử lý thông báo.';
      errorBox.classList.remove('d-none');
    }

    function notificationHref(item) {
      if (item.referenceType === 'ORDER' && item.referenceKey) {
        return contextPath + '/orders/' + encodeURIComponent(item.referenceKey);
      }

      if (item.referenceType === 'PROMOTION') {
        return contextPath + '/vouchers' +
          (item.referenceKey ? '?code=' + encodeURIComponent(item.referenceKey) : '');
      }

      return contextPath + '/notifications';
    }

    function post(url) {
      if (typeof window.csrfFetch !== 'function') {
        return Promise.reject(
          new Error('Thiếu hỗ trợ CSRF. Vui lòng tải lại trang.')
        );
      }

      return window.csrfFetch(url, {
        method: 'POST',
        credentials: 'same-origin'
      }).then(function (response) {
        if (!response.ok) {
          throw new Error(response.status === 401
            ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
            : 'Không thể cập nhật trạng thái đã đọc.');
        }
      });
    }

    function createLink(item) {
      var link = document.createElement('a');
      var title = document.createElement('div');
      var titleText = document.createElement('span');
      var date = document.createElement('small');
      var message = document.createElement('div');
      var reading = false;

      link.className = 'list-group-item list-group-item-action py-3' +
        (item.read ? '' : ' notification-unread');
      link.href = notificationHref(item);

      title.className = 'd-flex justify-content-between gap-3 fw-semibold';
      titleText.textContent = item.title || '';

      date.className = 'text-muted text-nowrap fw-normal';
      date.textContent = item.createdAt
        ? new Date(item.createdAt).toLocaleString('vi-VN') : '';

      message.className = 'text-muted mt-1';
      message.textContent = item.message || '';

      title.appendChild(titleText);
      title.appendChild(date);
      link.appendChild(title);
      link.appendChild(message);

      link.addEventListener('click', function (event) {
        if (item.read || event.ctrlKey || event.metaKey ||
            event.shiftKey || event.altKey || event.button > 0) {
          return;
        }

        event.preventDefault();

        if (reading) return;

        reading = true;
        clearError();

        post(apiUrl + '/' + encodeURIComponent(item.id) + '/read')
          .then(function () {
            item.read = true;
            updateBadge(unreadCount - 1);
            window.location.assign(link.href);
          })
          .catch(function (error) {
            reading = false;
            showError(error.message);
          });
      });

      return link;
    }

    function loadNotifications() {
      return window.fetch(apiUrl, {
        headers: { Accept: 'application/json' },
        credentials: 'same-origin'
      }).then(function (response) {
        if (!response.ok) {
          throw new Error(response.status === 401
            ? 'Vui lòng đăng nhập để xem thông báo.'
            : 'Không tải được thông báo.');
        }

        return response.json();
      }).then(function (feed) {
        if (!feed || !Array.isArray(feed.items)) {
          throw new Error('Dữ liệu thông báo không hợp lệ.');
        }

        clearError();
        updateBadge(feed.unreadCount);

        if (!list) return;

        while (list.firstChild) {
          list.removeChild(list.firstChild);
        }

        if (!feed.items.length) {
          var empty = document.createElement('div');
          empty.className = 'list-group-item text-center text-muted py-5';
          empty.textContent = 'Bạn chưa có thông báo nào.';
          list.appendChild(empty);
        } else {
          feed.items.forEach(function (item) {
            list.appendChild(createLink(item));
          });
        }

        if (markAllButton) {
          markAllButton.disabled = markingAll || unreadCount === 0;
        }
      }).catch(function (error) {
        if (list) {
          list.textContent = 'Không thể tải thông báo. Vui lòng thử lại.';
        }

        showError(error.message);
      });
    }

    if (markAllButton) {
      markAllButton.disabled = true;

      markAllButton.addEventListener('click', function () {
        if (markingAll) return;

        markingAll = true;
        markAllButton.disabled = true;
        clearError();

        post(apiUrl + '/read-all')
          .then(function () {
            return loadNotifications();
          })
          .catch(function (error) {
            showError(error.message);
          })
          .then(function () {
            markingAll = false;
            markAllButton.disabled = unreadCount === 0;
          });
      });
    }

    loadNotifications();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();