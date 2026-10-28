(function () {
  const contextPath = window.CONTEXT_PATH || '';
  const apiUrl = contextPath + '/api/notifications';
  const badge = document.getElementById('notificationUnreadBadge');
  const list = document.getElementById('notificationList');
  const errorBox = document.getElementById('notificationPageMessage');
  const markAllButton = document.getElementById('markAllNotificationsRead');

  function updateBadge(count) {
    if (!badge) return;
    badge.textContent = count > 99 ? '99+' : String(count || 0);
    badge.classList.toggle('d-none', !count);
  }

  function notificationHref(item) {
    if (item.referenceType === 'ORDER' && item.referenceKey) {
      return contextPath + '/orders/' + encodeURIComponent(item.referenceKey);
    }
    if (item.referenceType === 'PROMOTION') {
      return contextPath + '/vouchers' + (item.referenceKey ? '?code=' + encodeURIComponent(item.referenceKey) : '');
    }
    return contextPath + '/notifications';
  }

  function showError(message) {
    if (!errorBox) return;
    errorBox.textContent = message;
    errorBox.classList.remove('d-none');
  }

  async function loadNotifications() {
    try {
      const response = await fetch(apiUrl, { headers: { Accept: 'application/json' }, credentials: 'same-origin' });
      if (!response.ok) throw new Error(response.status === 401 ? 'Vui lòng đăng nhập để xem thông báo.' : 'Không tải được thông báo.');
      const feed = await response.json();
      updateBadge(feed.unreadCount);
      if (!list) return;
      list.replaceChildren();
      if (!feed.items || !feed.items.length) {
        const empty = document.createElement('div');
        empty.className = 'list-group-item text-center text-muted py-5';
        empty.textContent = 'Bạn chưa có thông báo nào.';
        list.appendChild(empty);
        if (markAllButton) markAllButton.disabled = true;
        return;
      }
      if (markAllButton) markAllButton.disabled = feed.unreadCount === 0;
      feed.items.forEach(item => {
        const link = document.createElement('a');
        link.className = 'list-group-item list-group-item-action py-3' + (item.read ? '' : ' notification-unread');
        link.href = notificationHref(item);
        const title = document.createElement('div');
        title.className = 'd-flex justify-content-between gap-3 fw-semibold';
        const titleText = document.createElement('span');
        titleText.textContent = item.title;
        const date = document.createElement('small');
        date.className = 'text-muted text-nowrap fw-normal';
        date.textContent = item.createdAt ? new Date(item.createdAt).toLocaleString('vi-VN') : '';
        title.append(titleText, date);
        const message = document.createElement('div');
        message.className = 'text-muted mt-1';
        message.textContent = item.message;
        link.append(title, message);
        link.addEventListener('click', () => {
          if (!item.read && window.csrfFetch) csrfFetch(apiUrl + '/' + item.id + '/read', {
            method: 'POST', credentials: 'same-origin'
          }).catch(() => {});
        });
        list.appendChild(link);
      });
    } catch (error) {
      updateBadge(0);
      if (list) list.innerHTML = '<div class="list-group-item text-muted">Không thể tải thông báo.</div>';
      showError(error.message || 'Không thể tải thông báo.');
    }
  }

  if (markAllButton) {
    markAllButton.addEventListener('click', async () => {
      try {
        const response = window.csrfFetch
          ? await csrfFetch(apiUrl + '/read-all', { method: 'POST', credentials: 'same-origin' })
          : await fetch(apiUrl + '/read-all', { method: 'POST', credentials: 'same-origin' });
        if (!response.ok) throw new Error('Không thể cập nhật trạng thái đã đọc.');
        await loadNotifications();
      } catch (error) {
        showError(error.message);
      }
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', loadNotifications);
  else loadNotifications();
})();
