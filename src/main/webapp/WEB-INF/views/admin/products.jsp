<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="jakarta.tags.core"%><%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
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
				<div class="alert alert-success">${success}</div>
			</c:if>
			<c:if test="${not empty error}">
				<div class="alert alert-danger">${error}</div>
			</c:if>
			<div class="card my-3">
				<div class="card-header">Thêm sản phẩm</div>
				<div class="card-body">
					<c:url var="createProductUrl" value="/admin/products">
						<c:param name="${_csrf.parameterName}" value="${_csrf.token}" />
					</c:url>

					<form method="post" enctype="multipart/form-data"
						action="${createProductUrl}" class="row g-2">
						<input type="hidden" name="${_csrf.parameterName}"
							value="${_csrf.token}">
						<div class="col-md-4">
							<input class="form-control" name="name"
								placeholder="Tên sản phẩm" required>
						</div>
						<div class="col-md-4">
							<input class="form-control" name="slug" placeholder="Slug"
								required>
						</div>
						<div class="col-md-4">
							<input class="form-control" name="sku" placeholder="SKU" required>
						</div>
						<div class="col-md-3">
							<input class="form-control" name="originalPrice" type="number"
								min="0" step="0.01" placeholder="Giá gốc" required>
						</div>
						<div class="col-md-3">
							<input class="form-control" name="discountPrice" type="number"
								min="0" step="0.01" placeholder="Giá khuyến mãi">
						</div>
						<div class="col-md-3">
							<select class="form-select" name="categoryId" required><option
									value="">Danh mục</option>
								<c:forEach items="${categories}" var="c">
									<option value="${c.id}">${c.name}</option>
								</c:forEach></select>
						</div>
						<div class="col-md-3">
							<select class="form-select" name="brandId" required><option
									value="">Thương hiệu</option>
								<c:forEach items="${brands}" var="b">
									<option value="${b.id}">${b.name}</option>
								</c:forEach></select>
						</div>
						<div class="col-md-6">
							<input class="form-control" name="mainImage" type="file"
								accept="image/*"><small class="text-muted">Ảnh
								đại diện</small>
						</div>
						<div class="col-md-6">
							<input class="form-control" name="galleryImages" type="file"
								accept="image/*" multiple><small class="text-muted">Ảnh
								chi tiết, có thể chọn nhiều ảnh</small>
						</div>
						<div class="col-md-6">
							<input class="form-control" name="shortDescription"
								placeholder="Mô tả ngắn">
						</div>
						<div class="col-12">
							<textarea class="form-control" name="description"
								placeholder="Mô tả chi tiết"></textarea>
						</div>
						<div class="col-12">
							<label class="form-label">Thông số kỹ thuật</label>
							<textarea class="form-control" name="specifications" rows="6"
								placeholder="Màn hình: 6.1 inch&#10;RAM: 8 GB&#10;Bộ nhớ: 256 GB&#10;Chip: Apple A17 Pro&#10;Pin: 3279 mAh"></textarea>
						</div>
						<div class="col-12">
							<button class="btn btn-primary">Tạo sản phẩm</button>
						</div>
					</form>
				</div>
			</div>
			<div class="card">
				<div class="table-responsive">
					<table class="table table-striped align-middle mb-0">
						<thead>
							<tr>
								<th>ID</th>
								<th>Sản phẩm</th>
								<th>SKU</th>
								<th>Danh mục</th>
								<th>Giá bán / khuyến mãi</th>
								<th>Trạng thái</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${products}" var="p">
								<tr>
									<td>${p.id}</td>
									<td>${p.name}</td>
									<td>${p.sku}</td>
									<td>${p.category.name}</td>
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
									<td>${p.active ? 'Đang bán' : 'Đã ẩn'}</td>
									<td class="text-nowrap"><a
										class="btn btn-sm btn-outline-primary"
										href="/admin/products/${p.id}/edit">Sửa</a>
										<form method="post" action="/admin/products/${p.id}/delete"
											class="d-inline"
											onsubmit="return confirm('Ẩn sản phẩm này khỏi cửa hàng?')">
											<input type="hidden" name="${_csrf.parameterName}"
												value="${_csrf.token}">
											<button class="btn btn-sm btn-outline-danger">Xóa</button>
										</form></td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>
			</div>
		</main>
	</div>
</body>
</html>
