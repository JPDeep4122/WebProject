<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="jakarta.tags.core"%><%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Sửa sản phẩm</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp" />
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
	<div class="d-flex"><jsp:include page="fragments/sidebar.jsp" /><main
			class="flex-grow-1 bg-light p-4">
			<h3>Sửa sản phẩm</h3>
			<c:if test="${not empty validationErrors}">
				<div class="alert alert-danger" role="alert">
					<c:forEach items="${validationErrors}" var="validationError">
						<div><c:out value="${validationError}"/></div>
					</c:forEach>
				</div>
			</c:if>

			<c:url var="editProductUrl" value="/admin/products/${productId}/edit">
				<c:param name="${_csrf.parameterName}" value="${_csrf.token}" />
			</c:url>

			<form method="post" enctype="multipart/form-data"
				action="${editProductUrl}" class="card card-body row g-3">
				<input type="hidden" name="${_csrf.parameterName}"
					value="${_csrf.token}">
				<div class="col-12"><small class="text-secondary">Các mục có dấu <span class="text-danger fw-bold">*</span> là bắt buộc.</small></div>
				<div class="col-md-6">
					<label class="form-label">Tên <span class="text-danger fw-bold" aria-hidden="true">*</span><span class="visually-hidden">(bắt buộc)</span></label><input class="form-control"
						name="name" value="${fn:escapeXml(form.name)}" required>
				</div>
				<div class="col-md-6">
					<label class="form-label">Slug <span class="text-danger fw-bold" aria-hidden="true">*</span><span class="visually-hidden">(bắt buộc)</span></label><input class="form-control"
						name="slug" value="${fn:escapeXml(form.slug)}" required>
				</div>
				<div class="col-md-4">
					<label class="form-label">SKU <span class="text-danger fw-bold" aria-hidden="true">*</span><span class="visually-hidden">(bắt buộc)</span></label><input class="form-control"
						name="sku" value="${fn:escapeXml(form.sku)}" required>
				</div>
				<div class="col-md-4">
					<label class="form-label">Giá gốc <span class="text-danger fw-bold" aria-hidden="true">*</span><span class="visually-hidden">(bắt buộc)</span></label><input
						class="form-control" name="originalPrice" type="number" min="0"
						step="0.01" value="${form.originalPrice}" required>
				</div>
				<div class="col-md-4">
					<label class="form-label">Giá khuyến mãi</label><input
						class="form-control" name="discountPrice" type="number" min="0"
						step="0.01" value="${form.discountPrice}">
				</div>
				<div class="col-md-6">
					<label class="form-label">Danh mục <span class="text-danger fw-bold" aria-hidden="true">*</span><span class="visually-hidden">(bắt buộc)</span></label><select
						class="form-select" name="categoryId"><c:forEach
							items="${categories}" var="c">
							<option value="${c.id}"
								${c.id == form.categoryId ? 'selected' : ''}>${c.name}</option>
						</c:forEach></select>
				</div>
				<div class="col-md-6">
					<label class="form-label">Thương hiệu <span class="text-danger fw-bold" aria-hidden="true">*</span><span class="visually-hidden">(bắt buộc)</span></label><select
						class="form-select" name="brandId"><c:forEach
							items="${brands}" var="b">
							<option value="${b.id}" ${b.id == form.brandId ? 'selected' : ''}>${b.name}</option>
						</c:forEach></select>
				</div>
				<div class="col-md-6">
					<label class="form-label">Ảnh đại diện mới</label><input
						class="form-control" name="mainImage" type="file" accept="image/*">
				</div>
				<div class="col-md-6">
					<label class="form-label">Ảnh chi tiết bổ sung</label><input
						class="form-control" name="galleryImages" type="file"
						accept="image/*" multiple>
				</div>
				<div class="col-12">
					<label class="form-label">Mô tả ngắn</label>
					<textarea class="form-control" name="shortDescription">${fn:escapeXml(form.shortDescription)}</textarea>
				</div>
				<div class="col-12">
					<label class="form-label">Mô tả</label>
					<textarea class="form-control" name="description">${fn:escapeXml(form.description)}</textarea>
				</div>
				<div class="col-12">
					<label class="form-label">Thông số kỹ thuật</label>
					<textarea class="form-control" name="specifications" rows="8">${fn:escapeXml(form.specifications)}</textarea>
				</div>
				<div class="col-md-3">
					<label class="form-label">Trạng thái</label><select
						class="form-select" name="active"><option value="true"
							${form.active ? 'selected' : ''}>Đang bán</option>
						<option value="false" ${!form.active ? 'selected' : ''}>Đã
							ẩn</option></select>
				</div>
				<div class="col-md-3">
					<label class="form-label">Nổi bật</label><select
						class="form-select" name="featured"><option value="true"
							${form.featured ? 'selected' : ''}>Có</option>
						<option value="false" ${!form.featured ? 'selected' : ''}>Không</option></select>
				</div>
				<div class="col-12">
					<button class="btn btn-primary">Lưu</button>
					<a class="btn btn-secondary" href="/admin/products">Quay lại</a>
				</div>
			</form>
		</main>
	</div>
</body>
</html>
