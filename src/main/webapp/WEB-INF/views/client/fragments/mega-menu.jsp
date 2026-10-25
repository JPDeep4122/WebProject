<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div class="mega-menu-wrapper d-none d-md-block">

	<button class="mega-btn-trigger shadow-sm" id="btnMegaMenu"
		type="button" aria-expanded="false" aria-controls="megaMenuPanel">
		<i class="bi bi-list fs-5"></i> <span>Danh mục</span>
	</button>

	<div class="mega-menu-panel shadow-lg" id="megaMenuPanel"
		role="region" aria-label="Danh mục sản phẩm">
		<div class="mega-menu-layout">

			<div class="mega-sidebar">
				<ul class="nav flex-column" id="megaMenuTabs" role="tablist" aria-orientation="vertical">
					<li class="nav-item" role="presentation">
						<button class="nav-link active" id="tab-hot-btn"
							data-bs-toggle="pill" data-bs-target="#tab-hot" type="button"
							role="tab" aria-controls="tab-hot" aria-selected="true">
							<span>Chương
								trình hot</span> </button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-dientu-btn" data-bs-toggle="pill"
							data-bs-target="#tab-dientu" type="button" role="tab" aria-controls="tab-dientu" aria-selected="false">
							<span>Điện tử,
								điện lạnh</span> </button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-giadung-btn"
							data-bs-toggle="pill" data-bs-target="#tab-giadung" type="button"
							role="tab" aria-controls="tab-giadung" aria-selected="false">
							<span>Điện gia dụng</span> </button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-nhabep-btn" data-bs-toggle="pill"
							data-bs-target="#tab-nhabep" type="button" role="tab" aria-controls="tab-nhabep" aria-selected="false">
							<span>Đồ
								gia dụng nhà bếp</span> </button>
					</li>
					<li class="nav-item" role="presentation">
						<button class="nav-link" id="tab-phukien-btn"
							data-bs-toggle="pill" data-bs-target="#tab-phukien" type="button"
							role="tab" aria-controls="tab-phukien" aria-selected="false">
							<span>Thiết bị
								di động & Phụ kiện</span> </button>
					</li>
				</ul>
			</div>

			<div class="mega-content">
				<div class="tab-content" id="megaMenuTabsContent">

					<div class="tab-pane fade show active" id="tab-hot" role="tabpanel" aria-labelledby="tab-hot-btn">
						<div
							class="mega-section-heading">
							<h6 class="mega-section-title">
								Khám phá sản phẩm
							</h6>
							<a href="${pageContext.request.contextPath}/products"
								class="text-decoration-none small text-primary fw-bold">Xem
								tất cả ></a>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?sortBy=newest"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/noi-chien-khong-dau.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Sản phẩm mới</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?sortBy=bestseller"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/noi-com-dien.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Sản phẩm bán chạy</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=noi+com"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/noi-com-dien.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Nồi cơm điện</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=may+xay"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-xay-sinh-to.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy xay ép tiện lợi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=may+loc+nuoc"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-loc-nuoc.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy lọc nước</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?sortBy=rating"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/tu-lanh.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Sản phẩm đánh giá cao</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-dientu" role="tabpanel" aria-labelledby="tab-dientu-btn">
						<div
							class="mega-section-heading">
							<h6 class="mega-section-title">Điện
								máy lớn & Giải trí gia đình</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products/category/tivi"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/tivi.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Google / Smart Tivi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products/category/tu-lanh"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/tu-lanh.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Tủ lạnh Inverter</span>
							</a> <a
								href="${pageContext.request.contextPath}/products/category/may-giat"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-giat.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy giặt cửa trước</span>
							</a> <a
								href="${pageContext.request.contextPath}/products/category/may-lanh"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-lanh.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy lạnh 1 HP - 2 HP</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+sấy"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-say-quan-ao.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy sấy quần áo</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=tủ+đông"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/tu-dong.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Tủ đông kháng khuẩn</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-giadung" role="tabpanel" aria-labelledby="tab-giadung-btn">
						<div
							class="mega-section-heading">
							<h6 class="mega-section-title">Thiết
								bị điện gia đình tiện nghi</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?keyword=nồi+cơm+điện"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/noi-com-dien.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Nồi cơm điện</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+lọc+nước"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-loc-nuoc.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy lọc nước</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=quạt+điều+hoà"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/quat-dieu-hoa.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Quạt điều hoà</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=quạt"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/quat-dung.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Quạt đứng mát</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+hút+bụi"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-hut-bui.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy hút bụi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=robot+hút+bụi"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/robot-hut-bui.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Robot hút bụi</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+lọc+không+khí"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-loc-khong-khi.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy lọc không khí</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+xay+sinh+tố"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-xay-sinh-to.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy xay sinh tố</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+ép+trái+cây"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-ep-trai-cay.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy ép chậm</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bếp+từ"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/bep-tu.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Bếp từ đôi / đơn</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bàn+ủi"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/ban-ui.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Bàn ủi hơi nước</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+hút+ẩm"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-hut-am.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy hút ẩm</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=máy+sấy+tóc"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/may-say-toc.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Máy sấy tóc</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=lò+vi+sóng"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/lo-vi-song.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Lò vi sóng</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=nồi+chiên+không+dầu"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/noi-chien-khong-dau.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Nồi chiên không dầu</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bình+đun+siêu+tốc"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/binh-dun-sieu-toc.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Bình đun siêu tốc</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=quạt+trần"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/quat-tran.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Quạt trần</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=cây+nước+nóng+lạnh"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/cay-nuoc-nong-lanh.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Cây nước nóng lạnh</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-nhabep" role="tabpanel" aria-labelledby="tab-nhabep-btn">
						<div
							class="mega-section-heading">
							<h6 class="mega-section-title">Dụng
								cụ nấu nướng & Bàn ăn</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?keyword=chảo+chống+dính"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/chao.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Chảo chống dính</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=bộ+nồi"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/bo-noi.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Bộ nồi Inox cao cấp</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=dao+kéo"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/dao.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Dao, thớt, kéo bếp</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=hộp+thực+phẩm"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/hop-thuc-pham.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Hộp bảo quản Lock&Lock</span>
							</a>
						</div>
					</div>

					<div class="tab-pane fade" id="tab-phukien" role="tabpanel" aria-labelledby="tab-phukien-btn">
						<div
							class="mega-section-heading">
							<h6 class="mega-section-title">Phụ
								kiện công nghệ chính hãng</h6>
						</div>
						<div class="mega-grid">
							<a
								href="${pageContext.request.contextPath}/products?keyword=tai+nghe"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/tai-nghe.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Tai nghe Bluetooth</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=pin+sạc"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/pin-sac.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Pin sạc dự phòng</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=cáp+sạc"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/cap-sac.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Cáp sạc Type-C / Lightning</span>
							</a> <a
								href="${pageContext.request.contextPath}/products?keyword=loa+bluetooth"
								class="mega-sub-item">
								<img class="mega-sub-image"
								src="${pageContext.request.contextPath}/images/categories/loa.png"
								width="96" height="96" alt="" loading="lazy" decoding="async"> <span>Loa nghe nhạc</span>
							</a>
						</div>
					</div>

				</div>
			</div>

		</div>
	</div>
</div><div class="mega-menu-backdrop" aria-hidden="true"></div>
