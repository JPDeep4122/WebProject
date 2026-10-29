<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="jakarta.tags.core"%><%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%><%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Quản lý sản phẩm</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp" />
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
	<div class="d-flex"><jsp:include page="fragments/sidebar.jsp" /><main
			class="flex-grow-1 bg-light p-4">
			<h3>Quản lý sản phẩm</h3>
			<c:if test="${not empty success}">
				<div class="alert alert-success"><c:out value="${success}"/></div>
			</c:if>
			<c:if test="${not empty error}">
				<div class="alert alert-danger"><c:out value="${error}"/></div>
			</c:if>

			<!-- 1. BỘ LỌC VÀ TÌM KIẾM SẢN PHẨM -->
			<div class="card my-3">
				<div class="card-header fw-bold">Tìm kiếm và lọc sản phẩm</div>
				<div class="card-body">
					<form method="get" action="/admin/products" class="row g-2 align-items-end">
						<div class="col-md-3">
							<label class="form-label small">Từ khóa (Tên / SKU)</label>
							<input class="form-control" type="text" name="keyword"
								value="${fn:escapeXml(selectedKeyword)}" placeholder="Nhập tên sản phẩm hoặc SKU...">
						</div>
						<div class="col-md-2">
							<label class="form-label small">Danh mục</label>
							<select class="form-select" name="categoryId">
								<option value="">Tất cả danh mục</option>
								<c:forEach items="${categories}" var="c">
									<option value="${c.id}" ${selectedCategoryId eq c.id ? 'selected' : ''}>${c.name}</option>
								</c:forEach>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label small">Thương hiệu</label>
							<select class="form-select" name="brandId">
								<option value="">Tất cả thương hiệu</option>
								<c:forEach items="${brands}" var="b">
									<option value="${b.id}" ${selectedBrandId eq b.id ? 'selected' : ''}>${b.name}</option>
								</c:forEach>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label small">Trạng thái</label>
							<select class="form-select" name="status">
								<option value="">Tất cả</option>
								<option value="ACTIVE" ${selectedStatus eq 'ACTIVE' ? 'selected' : ''}>Đang bán</option>
								<option value="INACTIVE" ${selectedStatus eq 'INACTIVE' ? 'selected' : ''}>Đã ẩn</option>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label small">Sắp xếp theo</label>
							<select class="form-select" name="sort">
								<option value="id" ${empty selectedSort or selectedSort eq 'id' ? 'selected' : ''}>Mới tạo (ID)</option>
								<option value="name" ${selectedSort eq 'name' ? 'selected' : ''}>Tên sản phẩm</option>
								<option value="originalPrice" ${selectedSort eq 'originalPrice' ? 'selected' : ''}>Giá gốc</option>
								<option value="discountPrice" ${selectedSort eq 'discountPrice' ? 'selected' : ''}>Giá khuyến mãi</option>
							</select>
						</div>
						<div class="col-md-1">
							<label class="form-label small">Thứ tự</label>
							<select class="form-select" name="direction">
								<option value="desc" ${empty selectedDirection or selectedDirection eq 'desc' ? 'selected' : ''}>Giảm</option>
								<option value="asc" ${selectedDirection eq 'asc' ? 'selected' : ''}>Tăng</option>
							</select>
						</div>
						<div class="col-md-2">
							<label class="form-label small">Số lượng / trang</label>
							<select class="form-select" name="size">
								<option value="10" ${pageSize eq 10 ? 'selected' : ''}>10 sản phẩm</option>
								<option value="15" ${empty pageSize or pageSize eq 15 ? 'selected' : ''}>15 sản phẩm</option>
								<option value="20" ${pageSize eq 20 ? 'selected' : ''}>20 sản phẩm</option>
								<option value="50" ${pageSize eq 50 ? 'selected' : ''}>50 sản phẩm</option>
							</select>
						</div>
						<div class="col-md-3 d-flex gap-1">
							<button class="btn btn-primary flex-grow-1">Lọc sản phẩm</button>
							<a class="btn btn-outline-secondary" href="/admin/products">Đặt lại</a>
						</div>
					</form>
				</div>
			</div>

			<!-- 2. FORM THÊM SẢN PHẨM -->
			<div class="card my-3">
				<div class="card-header fw-bold">Thêm sản phẩm mới</div>
				<div class="card-body">
					<c:url var="createProductUrl" value="/admin/products">
						<c:param name="${_csrf.parameterName}" value="${_csrf.token}" />
					</c:url>

					<form method="post" enctype="multipart/form-data" action="${createProductUrl}" class="row g-2">
						<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
						<div class="col-12"><small class="text-secondary">Các mục có dấu <span class="text-danger fw-bold">*</span> là bắt buộc.</small></div>
						<div class="col-md-4">
							<label class="form-label" for="product-name">Tên sản phẩm <span class="text-danger fw-bold">*</span></label>
							<input class="form-control" name="name" id="product-name" placeholder="Tên sản phẩm" required>
						</div>
						<div class="col-md-4">
							<label class="form-label" for="product-slug">Slug <span class="text-danger fw-bold">*</span></label>
							<input class="form-control" name="slug" placeholder="Slug" id="product-slug" required>
						</div>
						<div class="col-md-4">
							<label class="form-label" for="product-sku">SKU <span class="text-danger fw-bold">*</span></label>
							<input class="form-control" name="sku" id="product-sku" placeholder="SKU" required>
						</div>
						<div class="col-md-3">
							<label class="form-label" for="product-original-price">Giá gốc <span class="text-danger fw-bold">*</span></label>
							<input class="form-control" name="originalPrice" type="number" id="product-original-price" min="0" step="0.01" placeholder="Giá gốc" required>
						</div>
						<div class="col-md-3">
							<label class="form-label">Giá khuyến mãi</label>
							<input class="form-control" name="discountPrice" type="number" min="0" step="0.01" placeholder="Giá khuyến mãi">
						</div>
						<div class="col-md-3">
							<label class="form-label" for="product-category">Danh mục <span class="text-danger fw-bold">*</span></label>
							<select class="form-select" name="categoryId" id="product-category" required>
								<option value="">Chọn danh mục</option>
								<c:forEach items="${categories}" var="c">
									<option value="${c.id}">${c.name}</option>
								</c:forEach>
							</select>
						</div>
						<div class="col-md-3">
							<label class="form-label" for="product-brand">Thương hiệu <span class="text-danger fw-bold">*</span></label>
							<select class="form-select" name="brandId" id="product-brand" required>
								<option value="">Chọn thương hiệu</option>
								<c:forEach items="${brands}" var="b">
									<option value="${b.id}">${b.name}</option>
								</c:forEach>
							</select>
						</div>
						<div class="col-md-6">
							<input class="form-control" name="mainImage" type="file" accept="image/*"><small class="text-muted">Ảnh đại diện</small>
						</div>
						<div class="col-md-6">
							<input class="form-control" name="galleryImages" type="file" accept="image/*" multiple><small class="text-muted">Ảnh chi tiết, có thể chọn nhiều ảnh</small>
						</div>
						<div class="col-md-6">
							<input class="form-control" name="shortDescription" placeholder="Mô tả ngắn">
						</div>
						<div class="col-12">
							<textarea class="form-control" name="description" placeholder="Mô tả chi tiết"></textarea>
						</div>
						<div class="col-12">
							<label class="form-label">Thông số kỹ thuật</label>
							<textarea class="form-control" name="specifications" rows="4"
								placeholder="Màn hình: 6.1 inch&#10;RAM: 8 GB&#10;Bộ nhớ: 256 GB"></textarea>
						</div>
						<div class="col-12">
							<button class="btn btn-primary">Tạo sản phẩm</button>
						</div>
					</form>
				</div>
			</div>

			<!-- 3. DANH SÁCH SẢN PHẨM VÀ PHÂN TRANG -->
			<div class="card">
				<div class="table-responsive">
					<table class="table table-striped align-middle mb-0">
						<thead>
							<tr>
								<th>ID</th>
								<th>Sản phẩm</th>
								<th>SKU</th>
								<th>Danh mục</th>
								<th>Thương hiệu</th>
								<th>Giá bán / khuyến mãi</th>
								<th>Trạng thái</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${productsPage.content}" var="p">
								<tr>
									<td>${p.id}</td>
									<td><strong><c:out value="${p.name}"/></strong></td>
									<td><code><c:out value="${p.sku}"/></code></td>
									<td><c:out value="${p.category.name}"/></td>
									<td><c:out value="${p.brand.name}"/></td>
									<td>
										<c:choose>
											<c:when test="${p.discounted}">
												<div class="text-decoration-line-through text-secondary small"><fmt:formatNumber value="${p.originalPrice}" type="number" groupingUsed="true"/> ₫</div>
												<div class="text-danger fw-bold"><fmt:formatNumber value="${p.discountPrice}" type="number" groupingUsed="true"/> ₫</div>
												<span class="badge text-bg-danger">−<fmt:formatNumber value="${p.discountPercentage}" maxFractionDigits="0"/>%</span>
											</c:when>
											<c:otherwise><fmt:formatNumber value="${p.sellingPrice}" type="number" groupingUsed="true"/> ₫</c:otherwise>
										</c:choose>
									</td>
									<td>
										<span class="badge ${p.active ? 'bg-success' : 'bg-secondary'}">
											${p.active ? 'Đang bán' : 'Đã ẩn'}
										</span>
									</td>
									<td class="text-nowrap">
										<a class="btn btn-sm btn-outline-primary" href="/admin/products/${p.id}/edit">Sửa</a>
										<c:if test="${pageContext.request.isUserInRole('ADMIN')}">
										<form method="post" action="/admin/products/${p.id}/delete" class="d-inline"
											onsubmit="return confirm('Ẩn sản phẩm này khỏi cửa hàng?')">
											<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
											<button class="btn btn-sm btn-outline-danger">Ẩn/Xóa</button>
										</form>
										</c:if>
									</td>
								</tr>
							</c:forEach>
							<c:if test="${empty productsPage.content}">
								<tr>
									<td colspan="8" class="text-center text-muted py-4">Không tìm thấy sản phẩm nào phù hợp.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>
				<div class="card-footer bg-white d-flex flex-column flex-md-row justify-content-between align-items-center py-2">
					<small class="text-muted">
						Hiển thị <b>${productsPage.numberOfElements}</b> / Tổng số <b>${productsPage.totalElements}</b> sản phẩm (Trang ${productsPage.number + 1}/${productsPage.totalPages == 0 ? 1 : productsPage.totalPages})
					</small>

					<c:if test="${productsPage.totalPages gt 1}">
						<nav class="my-1">
							<ul class="pagination pagination-sm mb-0">
								<li class="page-item ${productsPage.first ? 'disabled' : ''}">
									<c:url var="prevUrl" value="/admin/products">
										<c:param name="page" value="${productsPage.number - 1}" />
										<c:param name="size" value="${pageSize}" />
										<c:if test="${not empty selectedKeyword}"><c:param name="keyword" value="${selectedKeyword}" /></c:if>
										<c:if test="${not empty selectedCategoryId}"><c:param name="categoryId" value="${selectedCategoryId}" /></c:if>
										<c:if test="${not empty selectedBrandId}"><c:param name="brandId" value="${selectedBrandId}" /></c:if>
										<c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}" /></c:if>
										<c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}" /></c:if>
										<c:if test="${not empty selectedDirection}"><c:param name="direction" value="${selectedDirection}" /></c:if>
									</c:url>
									<a class="page-link" href="${prevUrl}">&laquo; Trước</a>
								</li>
								<c:forEach begin="0" end="${productsPage.totalPages - 1}" var="index">
									<li class="page-item ${productsPage.number eq index ? 'active' : ''}">
										<c:url var="pageUrl" value="/admin/products">
											<c:param name="page" value="${index}" />
											<c:param name="size" value="${pageSize}" />
											<c:if test="${not empty selectedKeyword}"><c:param name="keyword" value="${selectedKeyword}" /></c:if>
											<c:if test="${not empty selectedCategoryId}"><c:param name="categoryId" value="${selectedCategoryId}" /></c:if>
											<c:if test="${not empty selectedBrandId}"><c:param name="brandId" value="${selectedBrandId}" /></c:if>
											<c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}" /></c:if>
											<c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}" /></c:if>
											<c:if test="${not empty selectedDirection}"><c:param name="direction" value="${selectedDirection}" /></c:if>
										</c:url>
										<a class="page-link" href="${pageUrl}">${index + 1}</a>
									</li>
								</c:forEach>
								<li class="page-item ${productsPage.last ? 'disabled' : ''}">
									<c:url var="nextUrl" value="/admin/products">
										<c:param name="page" value="${productsPage.number + 1}" />
										<c:param name="size" value="${pageSize}" />
										<c:if test="${not empty selectedKeyword}"><c:param name="keyword" value="${selectedKeyword}" /></c:if>
										<c:if test="${not empty selectedCategoryId}"><c:param name="categoryId" value="${selectedCategoryId}" /></c:if>
										<c:if test="${not empty selectedBrandId}"><c:param name="brandId" value="${selectedBrandId}" /></c:if>
										<c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}" /></c:if>
										<c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}" /></c:if>
										<c:if test="${not empty selectedDirection}"><c:param name="direction" value="${selectedDirection}" /></c:if>
									</c:url>
									<a class="page-link" href="${nextUrl}">Sau &raquo;</a>
								</li>
							</ul>
						</nav>
					</c:if>
				</div>
			</div>
		</main>
	</div>
</body>
</html>
