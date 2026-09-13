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
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/products"
				class="text-decoration-none">Sản phẩm</a></li>
			<li class="breadcrumb-item active text-truncate"
				style="max-width: 300px;">${product.name}</li>
		</ol>
	</nav>

	<div class="row g-4 mb-5">

		<!-- CỘT 1: HÌNH ẢNH SẢN PHẨM -->
		<div class="col-lg-5">
			<div
				class="bg-white p-4 rounded-4 shadow-sm border text-center position-relative">
				<c:if
					test="${product.discountPrice != null && product.discountPrice < product.originalPrice}">
					<span
						class="position-absolute top-0 start-0 bg-danger text-white px-3 py-1 m-3 rounded-pill small fw-bold">
						Giảm sốc </span>
				</c:if>
				<img src="${product.mainImageUrl}"
					class="img-fluid rounded-4 object-fit-contain"
					style="max-height: 380px;" alt="${product.name}">
			</div>
		</div>

		<!-- CỘT 2: THÔNG TIN SẢN PHẨM & MUA HÀNG -->
		<div class="col-lg-7">
			<div
				class="bg-white p-4 rounded-4 shadow-sm border h-100 d-flex flex-column">

				<!-- Thương hiệu & Mã SKU -->
				<div class="d-flex justify-content-between align-items-center mb-2">
					<span
						class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-2 rounded-pill">
						${product.brand.name} </span> <span class="text-muted small">Mã
						SKU: <b>${product.sku}</b>
					</span>
				</div>

				<!-- Tên sản phẩm -->
				<h3 class="fw-bold text-dark mb-3">${product.name}</h3>

				<!-- Giá tiền -->
				<div
					class="p-3 bg-light rounded-3 mb-3 d-flex align-items-baseline gap-3">
					<span class="text-danger display-6 fw-bold"> <fmt:formatNumber
							value="${product.discountPrice}" type="number"
							groupingUsed="true" /> ₫
					</span>
					<c:if test="${product.discountPrice < product.originalPrice}">
						<span class="text-muted text-decoration-line-through fs-5">
							<fmt:formatNumber value="${product.originalPrice}" type="number"
								groupingUsed="true" /> ₫
						</span>
					</c:if>
					<span class="badge bg-success ms-auto py-2 px-3 rounded-pill">
						<c:choose>
							<c:when test="${totalStock > 0}">Còn ${totalStock} sản phẩm toàn hệ thống</c:when>
							<c:otherwise>Tạm hết hàng</c:otherwise>
						</c:choose>
					</span>
				</div>

				<!-- Mô tả tóm tắt -->
				<p class="text-muted mb-4">${product.shortDescription}</p>

				<!-- ĐẶC TRƯNG CHUỖI CỬA HÀNG: TRA CỨU TỒN KHO TẠI CHI NHÁNH -->
				<div class="card border-primary-subtle mb-4 rounded-3">
					<div
						class="card-header bg-primary-subtle text-primary fw-bold py-2 small">
						<i class="bi bi-geo-alt-fill me-1"></i> CỬA HÀNG CÒN SẢN PHẨM NÀY
						(BẤM ĐỂ CHỌN NƠI MUA GẦN BẠN):
					</div>
					<ul class="list-group list-group-flush small">
						<c:forEach items="${branchStocks}" var="stock">
							<li
								class="list-group-item d-flex justify-content-between align-items-center py-2">
								<div>
									<b class="text-dark">${stock.branch.name}</b>: <span
										class="text-muted">${stock.branch.address}</span>
									<div class="text-muted" style="font-size: 11px;">
										<i class="bi bi-telephone"></i> ${stock.branch.phone}
									</div>
								</div>
								<div>
									<c:choose>
										<c:when test="${stock.quantity > 0}">
											<span
												class="badge bg-success-subtle text-success border border-success rounded-pill px-2 py-1">
												Còn ${stock.quantity} máy </span>
										</c:when>
										<c:otherwise>
											<span
												class="badge bg-danger-subtle text-danger border border-danger rounded-pill px-2 py-1">
												Hết hàng </span>
										</c:otherwise>
									</c:choose>
								</div>
							</li>
						</c:forEach>
					</ul>
				</div>

				<!-- Chọn số lượng & Nút Thêm vào giỏ -->
				<div class="d-flex gap-3 align-items-center mt-auto">
					<div class="input-group" style="width: 130px;">
						<button class="btn btn-outline-secondary" type="button"
							onclick="changeQty(-1)">-</button>
						<input type="number" id="buyQty"
							class="form-control text-center fw-bold" value="1" min="1"
							max="${totalStock > 0 ? totalStock : 1}">
						<button class="btn btn-outline-secondary" type="button"
							onclick="changeQty(1)">+</button>
					</div>
					<button
						class="btn btn-outline-primary btn-lg flex-grow-1 rounded-pill fw-bold"
						type="button"
						onclick="addToCart(${product.id}, document.getElementById('buyQty').value, this)">
						<i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ hàng
					</button>
					<button
						class="btn btn-danger btn-lg flex-grow-1 rounded-pill fw-bold"
						type="button">MUA NGAY</button>
				</div>

			</div>
		</div>

	</div>

	<!-- PHẦN MÔ TẢ CHI TIẾT & BẢO HÀNH -->
	<div class="bg-white p-4 rounded-4 shadow-sm border mb-5">
		<h4 class="fw-bold mb-3 border-bottom pb-2">Mô Tả Chi Tiết &
			Chính Sách Bảo Hành</h4>
		<div class="text-secondary leading-relaxed">
			<p>${product.description}</p>
			<div class="row g-3 mt-3">
				<div class="col-md-4">
					<div class="p-3 bg-light rounded-3 text-center">
						<i class="bi bi-patch-check-fill text-primary fs-3"></i>
						<h6 class="fw-bold mt-2 mb-1">100% Chính Hãng</h6>
						<small class="text-muted">Bảo hành 24 tháng toàn quốc</small>
					</div>
				</div>
				<div class="col-md-4">
					<div class="p-3 bg-light rounded-3 text-center">
						<i class="bi bi-arrow-repeat text-success fs-3"></i>
						<h6 class="fw-bold mt-2 mb-1">Lỗi 1 Đổi 1</h6>
						<small class="text-muted">Trong vòng 30 ngày đầu tiên</small>
					</div>
				</div>
				<div class="col-md-4">
					<div class="p-3 bg-light rounded-3 text-center">
						<i class="bi bi-truck text-warning fs-3"></i>
						<h6 class="fw-bold mt-2 mb-1">Giao Hàng Siêu Tốc</h6>
						<small class="text-muted">Giao trong 2h tại nội thành
							TP.HCM</small>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- SẢN PHẨM LIÊN QUAN -->
	<c:if test="${not empty relatedProducts}">
		<div class="mb-4">
			<h4 class="fw-bold mb-3">Sản Phẩm Cùng Danh Mục</h4>
			<div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-3">
				<c:forEach items="${relatedProducts}" var="rel">
					<div class="col">
						<div class="card h-100 border-0 shadow-sm rounded-4 p-3 bg-white">
							<a href="${pageContext.request.contextPath}/products/${rel.slug}"
								class="text-center mb-2"> <img src="${rel.mainImageUrl}"
								class="img-fluid object-fit-contain" style="height: 160px;"
								alt="${rel.name}">
							</a> <a
								href="${pageContext.request.contextPath}/products/${rel.slug}"
								class="text-decoration-none text-dark">
								<h6 class="card-title fw-bold text-truncate" title="${rel.name}">${rel.name}</h6>
							</a> <span class="text-danger fw-bold"> <fmt:formatNumber
									value="${rel.discountPrice}" type="number" groupingUsed="true" />
								₫
							</span>
						</div>
					</div>
				</c:forEach>
			</div>
		</div>
	</c:if>

</div>

<jsp:include page="fragments/footer.jsp" />

<script>
  function changeQty(delta) {
    const input = document.getElementById('buyQty');
    let val = parseInt(input.value) + delta;
    if (val < 1) val = 1;
    input.value = val;
  }

  

</script>