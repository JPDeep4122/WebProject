<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div class="mega-menu-wrapper d-none d-md-block">

	<button class="mega-btn-trigger shadow-sm" id="btnMegaMenu"
		type="button">
		<i class="bi bi-list fs-5"></i> <span>Danh mục</span>
	</button>

	<div class="mega-menu-panel shadow-lg">
		<div class="d-flex h-100">

			<div class="mega-sidebar">
				<ul class="nav flex-column" id="megaMenuTabs" role="tablist">
					<li class="nav-item" role="presentation">
						<button class="nav-link active" id="tab-hot-btn"
							data-bs-toggle="pill" data-bs-target="#tab-hot" type="button"
							role="tab">
							<span><i class="bi bi-fire text-danger me-2"></i> Chương
								trình hot</span> <i class="bi bi-chevron-right small text-muted"></i>
						</button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-dientu-btn" data-bs-toggle="pill"
							data-bs-target="#tab-dientu" type="button" role="tab">
							<span><i class="bi bi-tv text-primary me-2"></i> Điện tử,
								điện lạnh</span> <i class="bi bi-chevron-right small text-muted"></i>
						</button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-giadung-btn"
							data-bs-toggle="pill" data-bs-target="#tab-giadung" type="button"
							role="tab">
							<span><i class="bi bi-lightning-charge text-warning me-2"></i>
								Điện gia dụng</span> <i class="bi bi-chevron-right small text-muted"></i>
						</button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-nhabep-btn" data-bs-toggle="pill"
							data-bs-target="#tab-nhabep" type="button" role="tab">
							<span><i class="bi bi-cup-hot text-success me-2"></i> Đồ
								gia dụng nhà bếp</span> <i class="bi bi-chevron-right small text-muted"></i>
						</button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-phukien-btn"
							data-bs-toggle="pill" data-bs-target="#tab-phukien" type="button"
							role="tab">
							<span><i class="bi bi-phone text-info me-2"></i> Thiết bị
								di động & Phụ kiện</span> <i
								class="bi bi-chevron-right small text-muted"></i>
						</button>
					</li>
				</ul>
			</div>

			<div class="mega-content flex-grow-1">
				<div class="tab-content" id="megaMenuTabsContent">

					<div class="tab-pane fade show active" id="tab-hot" role="tabpanel">
						<div
							class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
							<h6 class="fw-bold text-uppercase text-danger mb-0 small">
								<i class="bi bi-stars"></i> Ưu đãi & Khuyến mãi sốc
							</h6>
							<a href="${pageContext.request.contextPath}/products"
								class="text-decoration-none small text-primary fw-bold">Xem
								tất cả ></a>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?sort=discount"
								class="mega-sub-item">
								<div class="mega-sub-icon bg-danger-subtle text-danger">
									<i class="bi bi-lightning-fill"></i>
								</div> <span>Flash Sale đến 50%</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?sortBy=bestseller"
								class="mega-sub-item">
								<div class="mega-sub-icon bg-warning-subtle text-dark">
									<i class="bi bi-gift-fill"></i>
								</div> <span>Gia dụng Online - Quà 0đ</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=noi+com"
								class="mega-sub-item">
								<div class="mega-sub-icon bg-info-subtle text-primary">
									<i class="bi bi-arrow-repeat"></i>
								</div> <span>Đổi nồi cơm cũ lấy mới</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=may+xay"
								class="mega-sub-item">
								<div class="mega-sub-icon bg-success-subtle text-success">
									<i class="bi bi-cup-straw"></i>
								</div> <span>Máy xay ép tiện lợi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=may+loc+nuoc"
								class="mega-sub-item">
								<div class="mega-sub-icon bg-primary-subtle text-primary">
									<i class="bi bi-droplet-fill"></i>
								</div> <span>Máy lọc RO giá tốt</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?sort=clearance"
								class="mega-sub-item">
								<div class="mega-sub-icon bg-danger-subtle text-danger">
									<i class="bi bi-tag-fill"></i>
								</div> <span>Xả kho giá sốc</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-dientu" role="tabpanel">
						<div
							class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
							<h6 class="fw-bold text-uppercase text-primary mb-0 small">Điện
								máy lớn & Giải trí gia đình</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products/category/tivi"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-tv"></i>
								</div> <span>Google / Smart Tivi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products/category/tu-lanh"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-snow2"></i>
								</div> <span>Tủ lạnh Inverter</span>
							</a> <a
								href="${pageContext.request.contextPath}/products/category/may-giat"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-water"></i>
								</div> <span>Máy giặt cửa trước</span>
							</a> <a
								href="${pageContext.request.contextPath}/products/category/may-lanh"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-wind"></i>
								</div> <span>Máy lạnh 1 HP - 2 HP</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+sấy"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-fire text-danger"></i>
								</div> <span>Máy sấy quần áo</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=tủ+đông"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-box2-fill"></i>
								</div> <span>Tủ đông kháng khuẩn</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-giadung" role="tabpanel">
						<div
							class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
							<h6 class="fw-bold text-uppercase text-warning mb-0 small">Thiết
								bị điện gia đình tiện nghi</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?keyword=nồi+cơm+điện"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-egg-fried"></i>
								</div> <span>Nồi cơm điện</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+lọc+nước"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-droplet-half"></i>
								</div> <span>Máy lọc nước</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=quạt+điều+hoà"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-snow"></i>
								</div> <span>Quạt điều hoà</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=quạt"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-fan"></i>
								</div> <span>Quạt đứng mát</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+hút+bụi"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-tornado"></i>
								</div> <span>Máy hút bụi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=robot+hút+bụi"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-disc"></i>
								</div> <span>Robot hút bụi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+lọc+không+khí"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-virus2"></i>
								</div> <span>Máy lọc không khí</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+xay+sinh+tố"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-cup-straw"></i>
								</div> <span>Máy xay sinh tố</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+ép+trái+cây"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-droplet"></i>
								</div> <span>Máy ép chậm</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bếp+từ"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-dash-circle-dotted"></i>
								</div> <span>Bếp từ đôi / đơn</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bàn+ủi"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-steam"></i>
								</div> <span>Bàn ủi hơi nước</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+hút+ẩm"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-moisture"></i>
								</div> <span>Máy hút ẩm</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+sấy+tóc"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-brush"></i>
								</div> <span>Máy sấy tóc</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=lò+vi+sóng"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-inbox"></i>
								</div> <span>Lò vi sóng</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=nồi+chiên+không+dầu"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-badge-ad"></i>
								</div> <span>Nồi chiên không dầu</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bình+đun+siêu+tốc"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-cup"></i>
								</div> <span>Bình đun siêu tốc</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=quạt+trần"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-brightness-high"></i>
								</div> <span>Quạt trần</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=cây+nước+nóng+lạnh"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-cup-hot"></i>
								</div> <span>Cây nước nóng lạnh</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-nhabep" role="tabpanel">
						<div
							class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
							<h6 class="fw-bold text-uppercase text-success mb-0 small">Dụng
								cụ nấu nướng & Bàn ăn</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?keyword=chảo+chống+dính"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-circle"></i>
								</div> <span>Chảo chống dính</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bộ+nồi"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-layers"></i>
								</div> <span>Bộ nồi Inox cao cấp</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=dao+kéo"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-slash-lg"></i>
								</div> <span>Dao, thớt, kéo bếp</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=hộp+thực+phẩm"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-box"></i>
								</div> <span>Hộp bảo quản Lock&Lock</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-phukien" role="tabpanel">
						<div
							class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
							<h6 class="fw-bold text-uppercase text-info mb-0 small">Phụ
								kiện công nghệ chính hãng</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?keyword=tai+nghe"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-headphones"></i>
								</div> <span>Tai nghe Bluetooth</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=pin+sạc"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-battery-charging"></i>
								</div> <span>Pin sạc dự phòng</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=cáp+sạc"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-plug"></i>
								</div> <span>Cáp sạc Type-C / Lightning</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=loa+bluetooth"
								class="mega-sub-item">
								<div class="mega-sub-icon">
									<i class="bi bi-speaker"></i>
								</div> <span>Loa nghe nhạc</span>
							</a>
						</div>
					</div>

				</div>
			</div>

		</div>
	</div>
</div>