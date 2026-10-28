<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="fragments/header.jsp" />

<div class="container-fluid py-4">

	
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

		
		<div class="col-lg-5">
			<div
				class="bg-white p-4 rounded-4 shadow-sm border text-center position-relative">
				<c:if
					test="${product.sellingPrice != null && product.sellingPrice < product.originalPrice}">
					<span
						class="position-absolute top-0 start-0 bg-danger text-white px-3 py-1 m-3 rounded-pill small fw-bold">
						Giảm sốc </span>
				</c:if>
				<img src="${product.mainImageUrl}"
					class="img-fluid rounded-4 object-fit-contain"
					style="max-height: 380px;" alt="${product.name}">
				<div class="d-flex gap-2 flex-wrap mt-3">
					<c:forEach items="${product.images}" var="image">
						<img src="${image.imageUrl}"
							style="width: 72px; height: 72px; object-fit: cover"
							class="rounded border" alt="${product.name}">
					</c:forEach>
				</div>
			</div>
		</div>

		
		<div class="col-lg-7">
			<div
				class="bg-white p-4 rounded-4 shadow-sm border h-100 d-flex flex-column">

				
				<div class="d-flex justify-content-between align-items-center mb-2">
					<span
						class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-2 rounded-pill">
						${product.brand.name} </span> <span class="text-muted small">Mã
						SKU: <b>${product.sku}</b>
					</span>
				</div>

				
				<h3 class="fw-bold text-dark mb-3">${product.name}</h3>

				
				<div
					class="p-3 bg-light rounded-3 mb-3 d-flex align-items-baseline gap-3">
					<span class="text-danger display-6 fw-bold"> <fmt:formatNumber
							value="${product.sellingPrice}" type="number"
							groupingUsed="true" /> ₫
					</span>
					<c:if test="${product.sellingPrice < product.originalPrice}">
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

				
				<p class="text-muted mb-4">${product.shortDescription}</p>

				
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
										<c:when test="${stock.availableQuantity > 0}">
											<span
												class="badge bg-success-subtle text-success border border-success rounded-pill px-2 py-1">
												Còn ${stock.availableQuantity} máy </span>
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

				
				<div class="d-flex gap-3 align-items-center mt-auto">
					<div class="input-group" style="width: 130px;">
						<button class="btn btn-outline-secondary" type="button"
							onclick="changeQty(-1)">-</button>
						<input type="number" id="buyQty"
							class="form-control text-center fw-bold" value="1" min="1"
							step="1" max="${totalStock > 0 ? totalStock : 1}" required>
						<button class="btn btn-outline-secondary" type="button"
							onclick="changeQty(1)">+</button>
					</div>
					<button
						class="btn btn-outline-primary btn-lg flex-grow-1 rounded-pill fw-bold"
						type="button"
						onclick="addSelectedProductToCart(${product.id}, this)"
						${totalStock <= 0 ? 'disabled' : ''}>
						<i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ hàng
					</button>
										<button
						class="btn btn-danger btn-lg flex-grow-1 rounded-pill fw-bold"
						type="button" onclick="buyNow(${product.id}, this)"
						${totalStock <= 0 ? 'disabled' : ''}>${not empty pageContext.request.userPrincipal ? 'MUA NGAY' : 'Đăng nhập để mua ngay'}</button>
				</div>
				<div id="buyNowError" class="alert alert-danger mt-3 d-none"
					role="alert"></div>
			</div>
		</div>

	</div>

	
	<div class="bg-white p-4 rounded-4 shadow-sm border mb-5">
		<h4 class="fw-bold mb-3 border-bottom pb-2">Mô Tả Chi Tiết &
			Chính Sách Bảo Hành</h4>
		<div class="text-secondary leading-relaxed">
			<p>${product.description}</p>
			<c:if test="${not empty product.specifications}">
				<h5 class="mt-4">Thông số kỹ thuật</h5>
				<pre class="bg-light border rounded p-3"
					style="white-space: pre-wrap; font-family: inherit">${product.specifications}</pre>
			</c:if>
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

	
	<div id="reviewsSection"
		class="bg-white p-4 rounded-4 shadow-sm border mb-5">
		<div
			class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3 border-bottom pb-3">
			<div>
				<h4 class="fw-bold mb-1 text-dark">
					<i class="bi bi-star-fill text-warning me-2"></i>Đánh Giá & Nhận
					Xét Từ Khách Hàng
				</h4>
				<p class="text-muted small mb-0">Đánh giá thực tế từ khách hàng
					đã mua sản phẩm tại chuỗi Điện Máy</p>
			</div>

			<div>
				<c:choose>
					<c:when test="${pageContext.request.userPrincipal eq null}">
						<c:url var="reviewLoginUrl" value="/login">
							<c:param name="redirect" value="/products/${product.slug}#reviewsSection" />
						</c:url>
						<a href="<c:out value='${reviewLoginUrl}'/>" class="btn btn-outline-primary rounded-pill">Đăng nhập để đánh giá</a>
					</c:when>
					<c:when test="${canReview}">
						<button
							class="btn btn-warning rounded-pill px-4 py-2 fw-bold text-dark shadow-sm"
							data-bs-toggle="modal" data-bs-target="#reviewModal">
							<i class="bi bi-pencil-square me-1"></i> Viết đánh giá ngay
						</button>
					</c:when>
					<c:otherwise>
						<span class="badge bg-light text-muted border p-2 small"> <i
							class="bi bi-info-circle me-1"></i> Cần mua sản phẩm (đơn Đã
							giao) để đánh giá
						</span>
					</c:otherwise>
				</c:choose>
			</div>
		</div>

		<div class="row g-4 align-items-center mb-4 p-3 bg-light rounded-4">
			<div class="col-md-4 text-center border-end-md">
				<c:choose>
					<c:when test="${reviewStats.totalReviews gt 0}">
						<div class="display-4 fw-bold text-warning mb-1">
							<fmt:formatNumber value="${reviewStats.averageRating}"
								minFractionDigits="1" maxFractionDigits="1" />

							<span class="fs-4 text-muted fw-normal">/5</span>
						</div>

						<div class="text-warning fs-5 mb-2">
							<c:forEach begin="1" end="5" var="s">
								<i
									class="bi ${s <= reviewStats.averageRating
                            ? 'bi-star-fill' : 'bi-star'}"></i>
							</c:forEach>
						</div>

						<div class="text-muted small fw-semibold">
							<c:out value="${reviewStats.totalReviews}" />
							lượt đánh giá thực tế
						</div>
					</c:when>

					<c:otherwise>
						<p class="fw-semibold mb-1">Chưa có đánh giá</p>
						<p class="text-muted small mb-0">Chưa có khách hàng gửi đánh
							giá cho sản phẩm này.</p>
					</c:otherwise>
				</c:choose>
			</div>

			<div class="col-md-8">
				<div class="px-md-3">
					<div class="d-flex align-items-center gap-2 mb-1 small">
						<span class="fw-semibold text-nowrap" style="width: 50px;">5
							sao <i class="bi bi-star-fill text-warning"></i>
						</span>
						<div class="progress flex-grow-1" style="height: 8px;">
							<div class="progress-bar bg-warning"
								style="width: ${reviewStats.percent5Star}%;"></div>
						</div>
						<span class="text-muted text-end" style="width: 45px;">${reviewStats.count5Star}</span>
					</div>
					<div class="d-flex align-items-center gap-2 mb-1 small">
						<span class="fw-semibold text-nowrap" style="width: 50px;">4
							sao <i class="bi bi-star-fill text-warning"></i>
						</span>
						<div class="progress flex-grow-1" style="height: 8px;">
							<div class="progress-bar bg-warning"
								style="width: ${reviewStats.percent4Star}%;"></div>
						</div>
						<span class="text-muted text-end" style="width: 45px;">${reviewStats.count4Star}</span>
					</div>
					<div class="d-flex align-items-center gap-2 mb-1 small">
						<span class="fw-semibold text-nowrap" style="width: 50px;">3
							sao <i class="bi bi-star-fill text-warning"></i>
						</span>
						<div class="progress flex-grow-1" style="height: 8px;">
							<div class="progress-bar bg-warning"
								style="width: ${reviewStats.percent3Star}%;"></div>
						</div>
						<span class="text-muted text-end" style="width: 45px;">${reviewStats.count3Star}</span>
					</div>
					<div class="d-flex align-items-center gap-2 mb-1 small">
						<span class="fw-semibold text-nowrap" style="width: 50px;">2
							sao <i class="bi bi-star-fill text-warning"></i>
						</span>
						<div class="progress flex-grow-1" style="height: 8px;">
							<div class="progress-bar bg-warning"
								style="width: ${reviewStats.percent2Star}%;"></div>
						</div>
						<span class="text-muted text-end" style="width: 45px;">${reviewStats.count2Star}</span>
					</div>
					<div class="d-flex align-items-center gap-2 mb-1 small">
						<span class="fw-semibold text-nowrap" style="width: 50px;">1
							sao <i class="bi bi-star-fill text-warning"></i>
						</span>
						<div class="progress flex-grow-1" style="height: 8px;">
							<div class="progress-bar bg-warning"
								style="width: ${reviewStats.percent1Star}%;"></div>
						</div>
						<span class="text-muted text-end" style="width: 45px;">${reviewStats.count1Star}</span>
					</div>
				</div>
			</div>
		</div>

		<div class="review-list">
			<c:choose>
				<c:when test="${empty reviews}">
					<div class="text-center py-5">
						<i class="bi bi-chat-heart text-muted opacity-50"
							style="font-size: 3.5rem;"></i>
						<h6 class="fw-bold text-dark mt-3 mb-1">Chưa có đánh giá nào
							cho sản phẩm này</h6>
						<p class="text-muted small">Hãy mua hàng và trở thành người
							đầu tiên chia sẻ cảm nhận trải nghiệm nhé!</p>
					</div>
				</c:when>
				<c:otherwise>
					<c:forEach var="rev" items="${reviews}">
						<div class="border-bottom py-3">
							<div
								class="d-flex justify-content-between align-items-start mb-2">
								<div class="d-flex align-items-center gap-2">
									<div
										class="bg-primary-subtle text-primary fw-bold rounded-circle d-flex align-items-center justify-content-center"
										style="width: 40px; height: 40px; font-size: 1rem;">
										<c:out
											value="${rev.userFullName.substring(0, 1).toUpperCase()}" />
									</div>
									<div>
										<div class="fw-bold text-dark small">
											<c:out value="${rev.userFullName}" />
											<span class="text-muted fw-normal"> (<c:out
													value="${rev.userEmail}" />)
											</span>
										</div>
										<span
											class="badge bg-success-subtle text-success border border-success-subtle rounded-pill py-0 px-2"
											style="font-size: 10px;"> <i
											class="bi bi-patch-check-fill me-1"></i>Đã mua tại Điện Máy
										</span>
									</div>
								</div>
								<div class="text-muted small" style="font-size: 0.8rem;">
									${rev.createdAt.toLocalDate()}</div>
							</div>

							<div class="text-warning mb-2 small">
								<c:forEach begin="1" end="5" var="st">
									<i class="bi ${st <= rev.rating ? 'bi-star-fill' : 'bi-star'}"></i>
								</c:forEach>
							</div>

							<p class="text-secondary small mb-2" style="line-height: 1.6;">
								<c:out value="${rev.comment}" />
							</p>

							<c:if test="${not empty rev.mediaList}">
								<div class="d-flex flex-wrap gap-2 mt-2">
									<c:forEach var="media" items="${rev.mediaList}">
										<c:choose>
											<c:when test="${media.mediaType == 'VIDEO'}">
												<video src="${media.mediaUrl}" controls
													class="rounded-3 border"
													style="width: 110px; height: 110px; object-fit: cover;"></video>
											</c:when>
											<c:otherwise>
												<a href="${media.mediaUrl}" target="_blank"> <img
													src="${media.mediaUrl}"
													class="rounded-3 border object-fit-cover shadow-sm"
													style="width: 80px; height: 80px; cursor: pointer;"
													alt="Review ảnh">
												</a>
											</c:otherwise>
										</c:choose>
									</c:forEach>
								</div>
							</c:if>
						</div>
					</c:forEach>
				</c:otherwise>
			</c:choose>
		</div>
	</div>

	<div class="modal fade" id="reviewModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered modal-lg">
			<div class="modal-content rounded-4 border-0 shadow">
				<div class="modal-header border-bottom-0 pb-0">
					<h5 class="modal-title fw-bold text-dark">
						<i class="bi bi-star-fill text-warning me-2"></i>Đánh giá sản phẩm
					</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<form id="formReview" enctype="multipart/form-data">
					<input type="hidden" name="productId" value="${product.id}">
					<input type="hidden" id="selectedRating" name="rating" value="5">

					<div class="modal-body py-3">
						<div id="reviewAlert"
							class="alert d-none rounded-3 small py-2 px-3 mb-3"></div>
						<div
							class="d-flex align-items-center gap-3 p-2 bg-light rounded-3 mb-3">
							<img src="${product.mainImageUrl}" class="rounded-2 border"
								style="width: 50px; height: 50px; object-fit: contain;">
							<div class="small fw-bold text-dark text-truncate">${product.name}</div>
						</div>

						<div class="text-center mb-3">
							<div class="text-muted small mb-1">Mức độ hài lòng của bạn:</div>
							<div class="fs-2 text-warning" id="starPicker"
								style="cursor: pointer;">
								<i class="bi bi-star-fill star-item" data-val="1"></i> <i
									class="bi bi-star-fill star-item" data-val="2"></i> <i
									class="bi bi-star-fill star-item" data-val="3"></i> <i
									class="bi bi-star-fill star-item" data-val="4"></i> <i
									class="bi bi-star-fill star-item" data-val="5"></i>
							</div>
							<span id="ratingText"
								class="badge bg-warning-subtle text-dark border fw-bold px-3 py-1 mt-1">5
								sao - Rất hài lòng</span>
						</div>

						<div class="mb-3">
							<label class="form-label fw-bold small text-dark"> Nội
								dung đánh giá <span class="text-danger">*</span> (Tối thiểu 50
								ký tự)
							</label>
							<textarea class="form-control rounded-3" id="reviewComment"
								name="comment" rows="4"
								placeholder="Hãy chia sẻ cảm nhận về độ hoàn thiện, hiệu năng, đóng gói giao hàng... (Tối thiểu 50 ký tự để cộng đồng tham khảo)"
								required></textarea>
							<div
								class="d-flex justify-content-between align-items-center mt-1">
								<small id="charHelp" class="text-danger"
									style="font-size: 0.78rem;"> <i
									class="bi bi-exclamation-circle me-1"></i>Cần nhập thêm ít nhất
									<b id="remainChars">50</b> ký tự
								</small> <small class="text-muted" style="font-size: 0.78rem;">
									<span id="currentChars" class="fw-bold text-dark">0</span>/50
									ký tự
								</small>
							</div>
						</div>

						<div class="mb-2">
							<label class="form-label fw-bold small text-dark"> <i
								class="bi bi-camera-fill me-1 text-primary"></i>Đính kèm hình
								ảnh hoặc video thực tế (Tùy chọn)
							</label> <input type="file"
								class="form-control rounded-3 form-control-sm"
								id="reviewMediaInput" name="files" accept="image/*,video/*"
								multiple> <small class="text-muted"
								style="font-size: 0.75rem;">Hỗ trợ định dạng JPG, PNG,
								MP4. Tối đa 3 tệp.</small>
						</div>
					</div>

					<div class="modal-footer border-top-0 pt-0">
						<button type="button" class="btn btn-light rounded-pill px-4"
							data-bs-dismiss="modal">Đóng</button>
						<button type="submit" id="btnSubmitReview"
							class="btn btn-warning rounded-pill px-4 fw-bold text-dark shadow-sm"
							disabled>GỬI ĐÁNH GIÁ</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script>
	document.addEventListener('DOMContentLoaded', function() {
		const stars = document.querySelectorAll('#starPicker .star-item');
		const ratingInput = document.getElementById('selectedRating');
		const ratingText = document.getElementById('ratingText');
		const commentInput = document.getElementById('reviewComment');
		const currentChars = document.getElementById('currentChars');
		const remainChars = document.getElementById('remainChars');
		const charHelp = document.getElementById('charHelp');
		const btnSubmit = document.getElementById('btnSubmitReview');

		const ratingLabels = {
			1: '1 sao - Rất tệ',
			2: '2 sao - Chưa hài lòng',
			3: '3 sao - Bình thường',
			4: '4 sao - Hài lòng',
			5: '5 sao - Rất hài lòng'
		};

		
		stars.forEach(star => {
			star.addEventListener('click', function() {
				const val = parseInt(this.getAttribute('data-val'));
				ratingInput.value = val;
				ratingText.innerText = ratingLabels[val] || (val + ' sao');

				stars.forEach((s, idx) => {
					if (idx < val) {
						s.className = 'bi bi-star-fill star-item';
					} else {
						s.className = 'bi bi-star star-item';
					}
				});
			});
		});

		
		if (commentInput) {
			commentInput.addEventListener('input', function() {
				const len = this.value.trim().length;
				currentChars.innerText = len;

				if (len < 50) {
					charHelp.className = 'text-danger';
					charHelp.innerHTML = '<i class="bi bi-exclamation-circle me-1"></i>Cần nhập thêm ít nhất <b>' + (50 - len) + '</b> ký tự';
					btnSubmit.disabled = true;
				} else {
					charHelp.className = 'text-success';
					charHelp.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>Đã đạt độ dài hợp lệ!';
					btnSubmit.disabled = false;
				}
			});
		}

		
		const formReview = document.getElementById('formReview');
		if (formReview) {
			formReview.addEventListener('submit', async function(e) {
				e.preventDefault();

				const reviewAlert = document.getElementById('reviewAlert');
				reviewAlert.className = 'alert d-none'; 

				const textLen = commentInput.value.trim().length;
				if (textLen < 50) {
					reviewAlert.className = 'alert alert-warning rounded-3 small py-2 px-3 mb-3 d-flex align-items-center gap-2';
					reviewAlert.innerHTML = '<i class="bi bi-exclamation-triangle-fill text-warning fs-5"></i><span>Nội dung đánh giá phải có ít nhất 50 ký tự theo quy định!</span>';
					return;
				}

				btnSubmit.disabled = true;
				btnSubmit.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang tải ảnh lên Cloudinary & lưu đánh giá...';

				const formData = new FormData(this);

				try {
					const res = await csrfFetch('${pageContext.request.contextPath}/api/reviews', {
						method: 'POST',
						body: formData
					});
					const data = await res.json();

					if (data.success) {
						
						reviewAlert.className = 'alert alert-success rounded-3 small py-2 px-3 mb-3 d-flex align-items-center gap-2 shadow-sm';
						reviewAlert.innerHTML = '<i class="bi bi-check-circle-fill text-success fs-5"></i><div><strong class="d-block">Gửi đánh giá thành công!</strong><span class="text-muted">Cảm ơn bạn đã đóng góp ý kiến. Đang tải lại trang...</span></div>';
						
						btnSubmit.className = 'btn btn-success rounded-pill px-4 fw-bold text-white shadow-sm';
						btnSubmit.innerHTML = '<i class="bi bi-check-lg me-1"></i>Đã gửi thành công!';
						
						
						setTimeout(() => {
							const modal = bootstrap.Modal.getInstance(document.getElementById('reviewModal'));
							if (modal) modal.hide();
							window.location.reload();
						}, 1200);
					} else {
						reviewAlert.className = 'alert alert-danger rounded-3 small py-2 px-3 mb-3 d-flex align-items-center gap-2';
						reviewAlert.textContent =
						    data.message || 'Không thể gửi đánh giá!';						btnSubmit.disabled = false;
						btnSubmit.innerText = 'GỬI ĐÁNH GIÁ';
					}
				} catch (err) {
					reviewAlert.className = 'alert alert-danger rounded-3 small py-2 px-3 mb-3 d-flex align-items-center gap-2';
					reviewAlert.innerHTML = '<i class="bi bi-wifi-off text-danger fs-5"></i><span>Lỗi kết nối máy chủ! Vui lòng thử lại sau.</span>';
					btnSubmit.disabled = false;
					btnSubmit.innerText = 'GỬI ĐÁNH GIÁ';
				}
			});
		}
	});
	</script>

	
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
									value="${rel.sellingPrice}" type="number" groupingUsed="true" />
								₫
							</span>
							<button type="button" class="btn btn-primary mt-auto w-100 rounded-3 fw-bold"
							        onclick="buyProductNow(${rel.id}, 1, this)">
							    <i class="bi bi-lightning-charge-fill me-1"></i> Mua ngay
							</button>
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
    const current = Number(input.value);
    const maximum = Number(input.max);

    input.value = Math.min(
        maximum,
        Math.max(
            1,
            (Number.isFinite(current) ? current : 1) + delta
        )
    );

    validateQuantity();
}

function addSelectedProductToCart(productId, button) {
    const errorBox = document.getElementById('buyNowError');

    if (errorBox) {
        errorBox.textContent = '';
        errorBox.classList.add('d-none');
    }

    validateQuantity();

    if (!quantityInput.reportValidity()) {
        return;
    }

    addToCart(
        productId,
        Number(quantityInput.value),
        button
    );
}
  
  const quantityInput = document.getElementById('buyQty');

  function validateQuantity() {
      quantityInput.setCustomValidity('');

      if (quantityInput.validity.rangeOverflow) {
          quantityInput.setCustomValidity(
              'Sản phẩm hiện chỉ còn ' + quantityInput.max
              + ' sản phẩm. Vui lòng giảm số lượng.'
          );
      } else if (!quantityInput.validity.valid) {
          quantityInput.setCustomValidity(
              'Vui lòng nhập số lượng nguyên từ 1 đến '
              + quantityInput.max + '.'
          );
      }
  }

  quantityInput.addEventListener('input', validateQuantity);
  validateQuantity();

  async function buyNow(productId, button) {
      validateQuantity();
      if (!quantityInput.reportValidity()) return;
      await buyProductNow(productId, Number(quantityInput.value), button);
  }

</script>
