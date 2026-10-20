<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="fragments/header.jsp" />

<div class="container-fluid py-4">

	<!-- BREADCRUMB -->
	<nav aria-label="breadcrumb" class="mb-4">
		<ol class="breadcrumb small">
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/"
				class="text-decoration-none">Trang chủ</a></li>
			<li class="breadcrumb-item active">Giỏ hàng của bạn</li>
		</ol>
	</nav>

	<h3 class="fw-bold mb-4 text-primary">
		<i class="bi bi-cart3 me-2"></i>GIỎ HÀNG (${cart.totalQuantity} sản
		phẩm)
	</h3>

	<c:choose>
		<c:when test="${empty cart.items}">
			<div class="text-center py-5 bg-white rounded-4 shadow-sm border">
				<i class="bi bi-cart-x fs-1 text-muted"></i>
				<h5 class="mt-3 fw-bold">Giỏ hàng của bạn đang trống</h5>
				<p class="text-muted small">Hãy dạo một vòng để chọn cho mình
					sản phẩm ưng ý nhé!</p>
				<a href="${pageContext.request.contextPath}/products"
					class="btn btn-primary rounded-pill px-4 fw-bold btn-sm"> Tiếp
					tục mua sắm </a>
			</div>
		</c:when>

		<c:otherwise>
			<div class="row g-4">

				<!-- BẢNG DANH SÁCH MÓN HÀNG -->
				<div class="col-lg-8">
					<div class="bg-white p-3 rounded-4 shadow-sm border mb-3">
						<div
							class="d-flex align-items-center justify-content-between pb-2 border-bottom">
							<div class="form-check">
								<input class="form-check-input" type="checkbox" id="checkAll"
									onchange="toggleSelectAll(this.checked)" checked> <label
									class="form-check-label fw-bold" for="checkAll">Chọn
									tất cả (${cart.items.size()} sản phẩm)</label>
							</div>
							<span class="text-muted small">Đơn giá / Thành tiền</span>
						</div>

						<!-- DANH SÁCH CART ITEMS -->
						<div class="d-flex flex-column gap-3 mt-3">
							<c:forEach items="${cart.items}" var="item">
								<div
									class="d-flex align-items-center justify-content-between p-2 border rounded-3 cart-item-row"
									id="item-row-${item.id}">

									<!-- Checkbox & Ảnh -->
									<div class="d-flex align-items-center gap-3">
										<input class="form-check-input item-checkbox" type="checkbox"
											onchange="toggleSelectItem(${item.id}, this.checked)"
											${item.selected ? 'checked' : ''}> <a
											href="${pageContext.request.contextPath}/products/${item.productSlug}">
											<img src="${item.productImageUrl}"
											class="rounded-3 object-fit-contain border p-1"
											style="width: 75px; height: 75px;" alt="${item.productName}">
										</a>
										<div>
											<a
												href="${pageContext.request.contextPath}/products/${item.productSlug}"
												class="text-decoration-none text-dark">
												<h6 class="fw-bold mb-1 text-truncate"
													style="max-width: 250px;" title="${item.productName}">${item.productName}</h6>
											</a> <span class="text-danger fw-bold"> <fmt:formatNumber
													value="${item.unitPrice}" type="number" groupingUsed="true" />
												₫
											</span>
										</div>
									</div>

									<!-- Bộ tăng giảm số lượng & Thành tiền -->
									<div class="d-flex align-items-center gap-4">
										<div class="input-group input-group-sm" style="width: 100px;">
											<button class="btn btn-outline-secondary" type="button"
												onclick="updateQty(${item.id}, ${item.quantity - 1})">-</button>
											<input type="text"
												class="form-control text-center fw-bold bg-white"
												value="${item.quantity}" readonly>
											<button class="btn btn-outline-secondary" type="button"
												onclick="updateQty(${item.id}, ${item.quantity + 1})">+</button>
										</div>

										<span class="text-danger fw-bold text-end"
											style="min-width: 110px;"> <fmt:formatNumber
												value="${item.subtotal}" type="number" groupingUsed="true" />
											₫
										</span>

										<!-- Nút xóa -->
										<button class="btn btn-link text-danger p-0"
											title="Xóa món này" onclick="removeItem(${item.id})">
											<i class="bi bi-trash fs-5"></i>
										</button>
									</div>

								</div>
							</c:forEach>
						</div>
					</div>
				</div>

				<!-- CỘT TỔNG TIỀN VÀ NÚT THANH TOÁN -->
				<div class="col-lg-4">
					<div
						class="bg-white p-4 rounded-4 shadow-sm border position-sticky"
						style="top: 20px;">
						<h5 class="fw-bold mb-3 border-bottom pb-2">Tóm Tắt Đơn Hàng</h5>

						<div class="d-flex justify-content-between mb-2">
							<span class="text-muted">Tổng số món:</span> <span
								class="fw-bold" id="summaryTotalQty">${cart.totalQuantity}</span>
						</div>

						<div class="d-flex justify-content-between mb-3">
							<span class="text-muted">Tổng tiền tạm tính:</span> <span
								class="text-danger fs-4 fw-bold" id="summaryTotalAmount">
								<fmt:formatNumber value="${cart.totalSelectedAmount}"
									type="number" groupingUsed="true" /> ₫
							</span>
						</div>

						<div class="small text-muted mb-4">
							<i class="bi bi-shield-check text-success me-1"></i>Đã bao gồm
							thuế VAT và bảo hành chính hãng.
						</div>

						<a href="${pageContext.request.contextPath}/checkout"
							class="btn btn-danger w-100 rounded-pill py-3 fw-bold fs-5 shadow">
							MUA HÀNG NGAY <i class="bi bi-arrow-right ms-1"></i>
						</a> <a href="${pageContext.request.contextPath}/products"
							class="btn btn-outline-secondary w-100 rounded-pill mt-2 btn-sm">
							<i class="bi bi-arrow-left me-1"></i>Chọn thêm sản phẩm khác
						</a>
					</div>
				</div>

			</div>
		</c:otherwise>
	</c:choose>

</div>
<!-- MODAL XÁC NHẬN XÓA HIỆN ĐẠI -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1"
	aria-hidden="true">
	<div class="modal-dialog modal-dialog-centered modal-sm">
		<div class="modal-content rounded-4 border-0 shadow text-center p-3">
			<div class="modal-body p-2">
				<div class="text-danger mb-2">
					<i class="bi bi-trash3-fill display-5"></i>
				</div>
				<h5 class="fw-bold text-dark mb-1">Xóa sản phẩm?</h5>
				<p class="text-muted small mb-4">Bạn có chắc chắn muốn bỏ sản
					phẩm này khỏi giỏ hàng không?</p>

				<div class="d-flex gap-2 justify-content-center">
					<button type="button"
						class="btn btn-light rounded-pill px-3 py-2 btn-sm fw-bold flex-grow-1"
						data-bs-dismiss="modal">Giữ lại</button>
					<button type="button"
						class="btn btn-danger rounded-pill px-3 py-2 btn-sm fw-bold flex-grow-1 shadow-sm"
						id="btnConfirmDelete">Xác nhận xóa</button>
				</div>
			</div>
		</div>
	</div>
</div>

<jsp:include page="fragments/footer.jsp" />

<!-- JAVASCRIPT XỬ LÝ AJAX GIỎ HÀNG -->
<script>
  const ctx = '${pageContext.request.contextPath}';
  let itemToDeleteId = null;
  const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));

  // 1. Khi bấm icon thùng rác -> Mở Modal xác nhận đẹp mắt
  function removeItem(itemId) {
    itemToDeleteId = itemId;
    deleteModal.show();
  }

  // 2. Khi bấm nút "Xác nhận xóa" trong Modal
  document.getElementById('btnConfirmDelete').addEventListener('click', function() {
    if (!itemToDeleteId) return;

    csrfFetch(ctx + '/api/cart/items/' + itemToDeleteId, { method: 'DELETE' })
      .then(res => res.json())
      .then(res => {
        deleteModal.hide();
        if (res.success) {
          // Hiệu ứng mờ dần và xóa dòng sản phẩm không làm giật trang
          const row = document.getElementById('item-row-' + itemToDeleteId);
          if (row) {
            row.style.transition = 'all 0.3s ease';
            row.style.opacity = '0';
            row.style.transform = 'translateX(50px)';
            setTimeout(() => {
              location.reload(); // Tải lại để cập nhật danh sách và tổng tiền
            }, 300);
          } else {
            location.reload();
          }
        }
      })
      .catch(err => console.error(err));
  });

  // 3. Cập nhật số lượng (+ / -)
  function updateQty(itemId, newQty) {
    if (newQty <= 0) {
      removeItem(itemId); // Nếu giảm về 0 thì mở popup hỏi xóa
      return;
    }
    
    csrfFetch(ctx + '/api/cart/items/' + itemId + '/quantity?quantity=' + newQty, { method: 'PUT' })
      .then(res => res.json())
      .then(res => {
        if (res.success) {
          location.reload();
        }
      });
  }

  // 4. Chọn / Bỏ chọn 1 sản phẩm
  function toggleSelectItem(itemId, selected) {
    csrfFetch(ctx + '/api/cart/items/' + itemId + '/select?selected=' + selected, { method: 'PUT' })
      .then(res => res.json())
      .then(res => {
        if (res.success) {
          location.reload();
        }
      });
  }

  // 5. Chọn tất cả / Bỏ chọn tất cả
  function toggleSelectAll(selected) {
    csrfFetch(ctx + '/api/cart/select-all?selected=' + selected, { method: 'PUT' })
      .then(res => res.json())
      .then(res => {
        if (res.success) {
          location.reload();
        }
      });
  }
</script>