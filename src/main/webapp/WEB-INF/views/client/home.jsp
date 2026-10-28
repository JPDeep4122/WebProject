<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<!-- Nhúng Header -->
<jsp:include page="fragments/header.jsp" />

<main class="bb-home-main pb-5">

	<section class="bb-top-showcase pt-4 pb-3">
		<div class="storefront-container">

			<!-- Dark Flagship Banner -->
			<div class="bb-dark-hero">
				<div class="bb-dark-hero__content">
					<div class="bb-dark-hero__eyebrow">
						<i class="bi bi-lightning-charge-fill text-warning"></i>
						<span>TECHSEVEN FLAGSHIP</span>
					</div>
					<h1 class="bb-dark-hero__title">
						Nhận ngay ưu đãi đến 1.000.000 ₫ khi nâng cấp Điện máy thế hệ mới.
					</h1>
					<p class="bb-dark-hero__subtitle">
						Trải nghiệm chuẩn hình ảnh OLED 4K, tủ lạnh Inverter AI và giải pháp gia dụng thông minh. Giao lắp miễn phí tận nơi.
					</p>
					<div class="d-flex flex-wrap align-items-center gap-3 mt-3">
						<a href="${pageContext.request.contextPath}/products"
							class="bb-btn-light">Khám phá ngay</a>
						<a href="${pageContext.request.contextPath}/vouchers"
							class="bb-link-light">Nhận mã giảm giá <i class="bi bi-arrow-right"></i></a>
					</div>
				</div>

				<div class="bb-dark-hero__visual">
					<div class="bb-dark-hero__glow" aria-hidden="true"></div>
					<a href="${pageContext.request.contextPath}/products/category/tivi"
						class="bb-dark-hero__img-wrap">
						<img src="${pageContext.request.contextPath}/images/categories/tivi.png"
							alt="Smart Tivi thế hệ mới" width="380" height="260"
							fetchpriority="high" decoding="async">
					</a>
					<span class="bb-dark-hero__badge">MỚI 2026</span>
				</div>
			</div>

			<!-- 4-Card "New" Spotlight Bento Panel -->
			<div class="bb-spotlight-panel mt-4">
				<div class="bb-spotlight-grid">

					<!-- Card 1 -->
					<article class="bb-spotlight-card">
						<div class="bb-spotlight-card__header">
							<span class="bb-spotlight-card__tag">New</span>
							<h2 class="bb-spotlight-card__title">Smart Tivi QLED 4K</h2>
						</div>
						<a href="${pageContext.request.contextPath}/products/category/tivi"
							class="bb-spotlight-card__media">
							<img src="${pageContext.request.contextPath}/images/categories/tivi.png"
								alt="Smart Tivi QLED 4K" width="220" height="180" decoding="async">
						</a>
						<div class="bb-spotlight-card__body">
							<p>Hình ảnh sắc nét chuẩn điện ảnh cùng tần số quét mượt mà cho phòng khách hiện đại.</p>
							<div class="bb-spotlight-card__footer">
								<a href="${pageContext.request.contextPath}/products/category/tivi"
									class="bb-btn-primary-sm">Khám phá</a>
								<i class="bi bi-info-circle text-muted small" title="Bảo hành chính hãng 24 tháng"></i>
							</div>
						</div>
					</article>

					<!-- Card 2 -->
					<article class="bb-spotlight-card">
						<div class="bb-spotlight-card__header">
							<span class="bb-spotlight-card__tag">New</span>
							<h2 class="bb-spotlight-card__title">Tủ lạnh Side by Side</h2>
						</div>
						<a href="${pageContext.request.contextPath}/products/category/tu-lanh"
							class="bb-spotlight-card__media">
							<img src="${pageContext.request.contextPath}/images/categories/tu-lanh.png"
								alt="Tủ lạnh Side by Side" width="220" height="180" decoding="async">
						</a>
						<div class="bb-spotlight-card__body">
							<p>Công nghệ Inverter tiết kiệm điện, cấp đông mềm giữ trọn độ tươi ngon mỗi ngày.</p>
							<div class="bb-spotlight-card__footer">
								<a href="${pageContext.request.contextPath}/products/category/tu-lanh"
									class="bb-btn-primary-sm">Khám phá</a>
								<i class="bi bi-info-circle text-muted small" title="Miễn phí lắp đặt tận nhà"></i>
							</div>
						</div>
					</article>

					<!-- Card 3 -->
					<article class="bb-spotlight-card">
						<div class="bb-spotlight-card__header">
							<span class="bb-spotlight-card__tag">New</span>
							<h2 class="bb-spotlight-card__title">Máy giặt sấy AI Eco</h2>
						</div>
						<a href="${pageContext.request.contextPath}/products/category/may-giat"
							class="bb-spotlight-card__media">
							<img src="${pageContext.request.contextPath}/images/categories/may-giat.png"
								alt="Máy giặt sấy AI" width="220" height="180" decoding="async">
						</a>
						<div class="bb-spotlight-card__body">
							<p>Tự động phân bổ nước giặt, diệt khuẩn chuyên sâu và bảo vệ sợi vải tối ưu.</p>
							<div class="bb-spotlight-card__footer">
								<a href="${pageContext.request.contextPath}/products/category/may-giat"
									class="bb-btn-primary-sm">Mua ngay</a>
								<i class="bi bi-info-circle text-muted small" title="Đổi trả trong 30 ngày nếu lỗi"></i>
							</div>
						</div>
					</article>

					<!-- Card 4 -->
					<article class="bb-spotlight-card">
						<div class="bb-spotlight-card__header">
							<span class="bb-spotlight-card__tag">New</span>
							<h2 class="bb-spotlight-card__title">Điều hòa &amp; Lọc khí</h2>
						</div>
						<a href="${pageContext.request.contextPath}/products/category/may-lanh"
							class="bb-spotlight-card__media">
							<img src="${pageContext.request.contextPath}/images/categories/may-lanh.png"
								alt="Điều hòa Inverter" width="220" height="180" decoding="async">
						</a>
						<div class="bb-spotlight-card__body">
							<p>Làm lạnh nhanh tức thì, lọc sạch bụi mịn PM2.5 mang lại giấc ngủ êm ái.</p>
							<div class="bb-spotlight-card__footer">
								<a href="${pageContext.request.contextPath}/products/category/may-lanh"
									class="bb-btn-primary-sm">Mua ngay</a>
								<i class="bi bi-info-circle text-muted small" title="Hỗ trợ trả góp 0%"></i>
							</div>
						</div>
					</article>

				</div>
			</div>

			<!-- Sign-in / Member Bar -->
			<div class="bb-signin-strip mt-3">
				<c:choose>
					<c:when test="${empty pageContext.request.userPrincipal}">
						<div class="bb-signin-strip__text">
							<i class="bi bi-person-circle fs-4 text-primary"></i>
							<span>
								<strong>Đăng nhập để nhận ưu đãi giao hàng miễn phí*</strong>, gợi ý sản phẩm phù hợp và theo dõi đơn hàng dễ dàng.
								<a href="${pageContext.request.contextPath}/info/shopping-guide" class="ms-1">Tìm hiểu thêm.</a>
							</span>
						</div>
						<div class="bb-signin-strip__actions">
							<a href="${pageContext.request.contextPath}/login"
								class="bb-btn-signin">Đăng nhập</a>
							<a href="${pageContext.request.contextPath}/login?view=register"
								class="bb-btn-outline-signin">Tạo tài khoản</a>
						</div>
					</c:when>
					<c:otherwise>
						<div class="bb-signin-strip__text">
							<i class="bi bi-patch-check-fill fs-4 text-primary"></i>
							<span>
								Chào mừng thành viên <strong><c:out value="${pageContext.request.userPrincipal.name}" /></strong>! Khám phá ngay đặc quyền voucher và theo dõi tiến độ giao hàng thời gian thực.
							</span>
						</div>
						<div class="bb-signin-strip__actions">
							<a href="${pageContext.request.contextPath}/vouchers"
								class="bb-btn-signin">Săn Voucher</a>
							<a href="${pageContext.request.contextPath}/orders"
								class="bb-btn-outline-signin">Đơn hàng của tôi</a>
						</div>
					</c:otherwise>
				</c:choose>
			</div>

		</div>
	</section>

	<section class="bb-dual-section py-3" id="bbBuildHomeSection">
		<div class="storefront-container">
			<div class="bb-dual-grid">

				<!-- CỘT TRÁI: TRENDING NOW -->
				<div class="bb-panel-card">
					<div class="bb-panel-header">
						<div>
							<h2 class="bb-panel-title">Xu hướng nổi bật</h2>
							<p class="bb-panel-subtitle">Sản phẩm được quan tâm nhiều nhất trong 24 giờ qua</p>
						</div>
						<div class="bb-rail-nav">
							<button type="button" class="bb-rail-btn" onclick="scrollRail('trendingRail', -1)" aria-label="Trượt sang trái">
								<i class="bi bi-chevron-left"></i>
							</button>
							<button type="button" class="bb-rail-btn" onclick="scrollRail('trendingRail', 1)" aria-label="Trượt sang phải">
								<i class="bi bi-chevron-right"></i>
							</button>
						</div>
					</div>

					<c:set var="trendingList" value="${not empty topBestseller ? topBestseller : topNewest}" />

					<div class="bb-trending-rail" id="trendingRail">
						<c:forEach items="${trendingList}" var="prod" begin="0" end="7">
							<div class="bb-mini-product">
								<div class="bb-mini-product__thumb">
									<button type="button" class="bb-wish-btn" title="Yêu thích"
										onclick="this.classList.toggle('is-active')">
										<i class="bi bi-heart"></i>
									</button>
									<a href="${pageContext.request.contextPath}/products/${prod.slug}">
										<img src="${prod.mainImageUrl}" alt="<c:out value='${prod.name}'/>"
											width="160" height="160" loading="lazy" decoding="async">
									</a>
								</div>
								<a href="${pageContext.request.contextPath}/products/${prod.slug}"
									class="bb-mini-product__name" title="<c:out value='${prod.name}'/>">
									<c:out value="${prod.name}" />
								</a>
								<div class="bb-mini-product__rating">
									<i class="bi bi-star-fill text-warning"></i>
									<span><fmt:formatNumber value="${prod.rating}" minFractionDigits="1" maxFractionDigits="1" /></span>
									<small class="text-muted">(${prod.reviewCount})</small>
								</div>
								<div class="bb-mini-product__price">
									<fmt:formatNumber value="${prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
								</div>
								<c:if test="${prod.sellingPrice < prod.originalPrice}">
									<div class="bb-mini-product__old-price">
										<fmt:formatNumber value="${prod.originalPrice}" type="number" groupingUsed="true" /> ₫
									</div>
								</c:if>
							</div>
						</c:forEach>
					</div>
				</div>

				<div class="bb-panel-card">
					<div class="bb-panel-header mb-2">
						<div>
							<h2 class="bb-panel-title">Kiến tạo tổ ấm với công nghệ mới</h2>
						</div>
						<a href="javascript:void(0)" onclick="toggleAllCategoriesDrawer()"
							class="bb-view-all-link">
							Xem tất cả (${fn:length(categories)}) <i class="bi bi-grid-3x3-gap ms-1"></i>
						</a>
					</div>

					<div class="bb-room-pills" role="tablist" aria-label="Chọn không gian sống">
						<button type="button" class="bb-room-pill active"
							onclick="switchRoomTab('kitchen', this)">Phòng bếp</button>
						<button type="button" class="bb-room-pill"
							onclick="switchRoomTab('living', this)">Phòng khách</button>
						<button type="button" class="bb-room-pill"
							onclick="switchRoomTab('cooling', this)">Làm mát &amp; Phòng ngủ</button>
						<button type="button" class="bb-room-pill"
							onclick="switchRoomTab('cleaning', this)">Giặt giũ &amp; Vệ sinh</button>
						<button type="button" class="bb-room-pill"
							onclick="switchRoomTab('personal', this)">Cá nhân &amp; Phụ kiện</button>
					</div>

					<div class="bb-room-pane is-active" id="room-kitchen">
						<div class="bb-room-showcase">
							<div class="bb-room-banner bb-room-banner--kitchen">
								<span class="bb-room-banner__tag">Không gian bếp</span>
								<h3>Căn bếp hiện đại, giữ trọn vị ngon</h3>
								<p>Nấu nướng thảnh thơi với tủ lạnh, nồi chiên và thiết bị bếp thông minh.</p>
								<a href="${pageContext.request.contextPath}/products/category/tu-lanh"
									class="bb-room-banner__cta">Khám phá ngay <i class="bi bi-arrow-right"></i></a>
							</div>
							<div class="bb-circle-grid">
								<a href="${pageContext.request.contextPath}/products/category/tu-lanh" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/tu-lanh.png" alt="Tủ lạnh" loading="lazy"></span>
									<span class="bb-circle-cat__label">Tủ lạnh</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/noi-chien-khong-dau" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/noi-chien-khong-dau.png" alt="Nồi chiên không dầu" loading="lazy"></span>
									<span class="bb-circle-cat__label">Nồi chiên không dầu</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/noi-com-dien" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/noi-com-dien.png" alt="Nồi cơm điện" loading="lazy"></span>
									<span class="bb-circle-cat__label">Nồi cơm điện</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/bep-tu" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/bep-tu.png" alt="Bếp từ" loading="lazy"></span>
									<span class="bb-circle-cat__label">Bếp từ</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/lo-vi-song" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/lo-vi-song.png" alt="Lò vi sóng" loading="lazy"></span>
									<span class="bb-circle-cat__label">Lò vi sóng</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-loc-nuoc" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-loc-nuoc.png" alt="Máy lọc nước" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy lọc nước</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-xay-sinh-to" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-xay-sinh-to.png" alt="Máy xay sinh tố" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy xay &amp; Ép</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/bo-noi" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/bo-noi.png" alt="Bộ nồi & Chảo" loading="lazy"></span>
									<span class="bb-circle-cat__label">Bộ nồi &amp; Chảo</span>
								</a>
							</div>
						</div>
					</div>

					<div class="bb-room-pane" id="room-living">
						<div class="bb-room-showcase">
							<div class="bb-room-banner bb-room-banner--living">
								<span class="bb-room-banner__tag">Giải trí tại gia</span>
								<h3>Rạp phim sống động ngay tại phòng khách</h3>
								<p>Đắm chìm trong không gian hình ảnh 4K và âm thanh vòm đỉnh cao.</p>
								<a href="${pageContext.request.contextPath}/products/category/tivi"
									class="bb-room-banner__cta">Xem Tivi &amp; Loa <i class="bi bi-arrow-right"></i></a>
							</div>
							<div class="bb-circle-grid">
								<a href="${pageContext.request.contextPath}/products/category/tivi" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/tivi.png" alt="Tivi" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Smart Tivi</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/loa" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/loa.png" alt="Loa" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Loa âm thanh</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-loc-khong-khi" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-loc-khong-khi.png" alt="Máy lọc không khí" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy lọc không khí</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/cay-nuoc-nong-lanh" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/cay-nuoc-nong-lanh.png" alt="Cây nước nóng lạnh" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Cây nước nóng lạnh</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/robot-hut-bui" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/robot-hut-bui.png" alt="Robot hút bụi" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Robot hút bụi</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/quat-tran" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/quat-tran.png" alt="Quạt trần" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Quạt trần</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/quat-dieu-hoa" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/quat-dieu-hoa.png" alt="Quạt điều hòa" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Quạt điều hòa</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/tai-nghe" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/tai-nghe.png" alt="Tai nghe" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Tai nghe</span>
								</a>
							</div>
						</div>
					</div>

					<div class="bb-room-pane" id="room-cooling">
						<div class="bb-room-showcase">
							<div class="bb-room-banner bb-room-banner--cooling">
								<span class="bb-room-banner__tag">Khí hậu trong lành</span>
								<h3>Mát lạnh êm ái, giấc ngủ trọn vẹn</h3>
								<p>Giải pháp điều hòa nhiệt độ và cân bằng độ ẩm tối ưu cho mọi thời tiết.</p>
								<a href="${pageContext.request.contextPath}/products/category/may-lanh"
									class="bb-room-banner__cta">Xem thiết bị làm mát <i class="bi bi-arrow-right"></i></a>
							</div>
							<div class="bb-circle-grid">
								<a href="${pageContext.request.contextPath}/products/category/may-lanh" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-lanh.png" alt="Máy lạnh" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy lạnh</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/quat-dieu-hoa" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/quat-dieu-hoa.png" alt="Quạt điều hòa" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Quạt điều hòa</span>
								</a>
								<a href="${pageContext.request.contextPath}/products?keyword=quat" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/quat-dung.png" alt="Quạt điện" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Quạt điện</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/quat-tran" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/quat-tran.png" alt="Quạt trần" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Quạt trần</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-loc-khong-khi" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-loc-khong-khi.png" alt="Máy lọc không khí" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Lọc không khí</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-hut-am" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-hut-am.png" alt="Máy hút ẩm" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy hút ẩm</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/tu-dong" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/tu-dong.png" alt="Tủ đông" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Tủ đông</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/tu-lanh" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/tu-lanh.png" alt="Tủ lạnh" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Tủ lạnh mini</span>
								</a>
							</div>
						</div>
					</div>

					<div class="bb-room-pane" id="room-cleaning">
						<div class="bb-room-showcase">
							<div class="bb-room-banner bb-room-banner--cleaning">
								<span class="bb-room-banner__tag">Chăm sóc nhà cửa</span>
								<h3>Nhà sạch tinh tươm, quần áo thơm mới</h3>
								<p>Giải phóng sức lao động với hệ sinh thái giặt sấy và hút bụi tự động.</p>
								<a href="${pageContext.request.contextPath}/products/category/may-giat"
									class="bb-room-banner__cta">Khám phá ngay <i class="bi bi-arrow-right"></i></a>
							</div>
							<div class="bb-circle-grid">
								<a href="${pageContext.request.contextPath}/products/category/may-giat" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-giat.png" alt="Máy giặt" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy giặt</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-say-quan-ao" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-say-quan-ao.png" alt="Máy sấy quần áo" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy sấy quần áo</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/robot-hut-bui" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/robot-hut-bui.png" alt="Robot hút bụi" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Robot hút bụi</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-hut-bui" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-hut-bui.png" alt="Máy hút bụi" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy hút bụi</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/ban-ui" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/ban-ui.png" alt="Bàn ủi" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Bàn ủi hơi nước</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-hut-am" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-hut-am.png" alt="Máy hút ẩm" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy hút ẩm</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-loc-khong-khi" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-loc-khong-khi.png" alt="Máy lọc không khí" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy lọc khí</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-loc-nuoc" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-loc-nuoc.png" alt="Máy lọc nước" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy lọc nước</span>
								</a>
							</div>
						</div>
					</div>

					<div class="bb-room-pane" id="room-personal">
						<div class="bb-room-showcase">
							<div class="bb-room-banner bb-room-banner--personal">
								<span class="bb-room-banner__tag">Tiện ích mỗi ngày</span>
								<h3>Chăm sóc bản thân &amp; Phụ kiện số</h3>
								<p>Đồng hành cùng nhịp sống năng động với phụ kiện sạc nhanh, âm thanh và làm đẹp.</p>
								<a href="${pageContext.request.contextPath}/products"
									class="bb-room-banner__cta">Xem tất cả <i class="bi bi-arrow-right"></i></a>
							</div>
							<div class="bb-circle-grid">
								<a href="${pageContext.request.contextPath}/products/category/may-say-toc" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-say-toc.png" alt="Máy sấy tóc" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy sấy tóc</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/tai-nghe" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/tai-nghe.png" alt="Tai nghe" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Tai nghe</span>
								</a>
								<a href="${pageContext.request.contextPath}/products?keyword=pin+sac" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/pin-sac.png" alt="Pin sạc dự phòng" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Pin sạc dự phòng</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/cap-sac" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/cap-sac.png" alt="Cáp sạc" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Cáp &amp; Củ sạc</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/binh-dun-sieu-toc" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/binh-dun-sieu-toc.png" alt="Bình đun siêu tốc" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Bình đun siêu tốc</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/may-ep-trai-cay" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/may-ep-trai-cay.png" alt="Máy ép trái cây" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Máy ép trái cây</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/hop-thuc-pham" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/hop-thuc-pham.png" alt="Hộp thực phẩm" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Hộp thực phẩm</span>
								</a>
								<a href="${pageContext.request.contextPath}/products/category/loa" class="bb-circle-cat">
									<span class="bb-circle-cat__avatar"><img src="${pageContext.request.contextPath}/images/categories/loa.png" alt="Loa" fetchpriority="low" loading="lazy"></span>
									<span class="bb-circle-cat__label">Loa di động</span>
								</a>
							</div>
						</div>
					</div>

				</div>

			</div>

			<div class="bb-all-categories-drawer d-none mt-3" id="allCategoriesDrawer">
				<div class="bb-panel-card">
					<div class="d-flex justify-content-between align-items-center mb-3">
						<h3 class="h5 fw-bold mb-0">Tất cả danh mục ngành hàng</h3>
						<button type="button" class="btn-close" aria-label="Đóng"
							onclick="toggleAllCategoriesDrawer()"></button>
					</div>
					<div class="bb-all-cat-circles">
						<c:forEach items="${categories}" var="cat">
							<c:if test="${cat.active}">
								<c:set var="catImgName" value="${cat.slug}" />
								<c:if test="${cat.slug eq 'chao-chong-dinh'}"><c:set var="catImgName" value="chao" /></c:if>
								<c:if test="${cat.slug eq 'dao-keo-nha-bep'}"><c:set var="catImgName" value="dao" /></c:if>
								<c:if test="${cat.slug eq 'pin-sac-du-phong'}"><c:set var="catImgName" value="pin-sac" /></c:if>
								<c:if test="${cat.slug eq 'quat-dien'}"><c:set var="catImgName" value="quat-dung" /></c:if>

								<a href="${pageContext.request.contextPath}/products/category/${cat.slug}"
									class="bb-circle-cat">
									<span class="bb-circle-cat__avatar">
										<img src="${pageContext.request.contextPath}/images/categories/${catImgName}.png"
											alt="<c:out value='${cat.name}'/>" loading="lazy"
											onerror="this.style.display='none'; this.nextElementSibling.classList.remove('d-none');">
										<i class="bi <c:out value='${not empty cat.icon ? cat.icon : \"bi-box-seam\"}'/> d-none fs-3 text-primary"></i>
									</span>
									<span class="bb-circle-cat__label"><c:out value="${cat.name}" /></span>
								</a>
							</c:if>
						</c:forEach>
					</div>
				</div>
			</div>

		</div>
	</section>

	<section class="py-3" id="bbNoteworthySection">
		<div class="storefront-container">
			<div class="bb-feature-shelf bb-feature-shelf--blue">
				<div class="bb-feature-shelf__intro">
					<div>
						<p class="bb-feature-shelf__desc">
							Khám phá những phát minh công nghệ đột phá và các thiết bị điện máy vừa ra mắt.
						</p>
						<a href="${pageContext.request.contextPath}/products?sortBy=newest"
							class="bb-feature-shelf__link">Mua sắm ngay <i class="bi bi-arrow-right"></i></a>
					</div>
					<h2 class="bb-feature-shelf__heading">
						New and<br>Noteworthy
						<small class="d-block fs-6 fw-normal opacity-75 mt-1">Mới &amp; Đáng chú ý</small>
					</h2>
				</div>

				<div class="bb-feature-shelf__rail">
					<c:forEach items="${topNewest}" var="prod" begin="0" end="5">
						<article class="bb-shelf-card">
							<div class="bb-shelf-card__top">
								<c:choose>
									<c:when test="${prod.sellingPrice < prod.originalPrice}">
										<span class="bb-save-badge">
											Giảm <fmt:formatNumber value="${prod.originalPrice - prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
										</span>
									</c:when>
									<c:otherwise>
										<span class="bb-new-badge">Mới ra mắt</span>
									</c:otherwise>
								</c:choose>
								<button type="button" class="bb-wish-btn" title="Lưu sản phẩm"
									onclick="this.classList.toggle('is-active')">
									<i class="bi bi-heart"></i>
								</button>
							</div>

							<a href="${pageContext.request.contextPath}/products/${prod.slug}"
								class="bb-shelf-card__img">
								<img src="${prod.mainImageUrl}" alt="<c:out value='${prod.name}'/>"
									width="160" height="160" loading="lazy" decoding="async">
							</a>

							<a href="${pageContext.request.contextPath}/products/${prod.slug}"
								class="bb-shelf-card__title" title="<c:out value='${prod.name}'/>">
								<c:out value="${prod.name}" />
							</a>

							<div class="mt-auto pt-2">
								<div class="bb-shelf-card__price">
									<fmt:formatNumber value="${prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
								</div>
								<c:if test="${prod.sellingPrice < prod.originalPrice}">
									<div class="bb-shelf-card__old-price">
										<fmt:formatNumber value="${prod.originalPrice}" type="number" groupingUsed="true" /> ₫
									</div>
								</c:if>
							</div>
						</article>
					</c:forEach>
				</div>
			</div>
		</div>
	</section>

	<section class="py-3 bb-deferred-section">
		<div class="storefront-container">

			<!-- Bento Banner: Discover ideas and inspiration -->
			<div class="bb-discover-grid mb-4">
				<div class="bb-discover-bento">
					<div class="bb-discover-bento__copy">
						<h2>
							<span class="text-warning">Khám phá</span> ý tưởng và cảm hứng cho tiện nghi gia đình bạn.
						</h2>
						<a href="${pageContext.request.contextPath}/products"
							class="bb-btn-light mt-3">Bắt đầu khám phá</a>
					</div>
					<div class="bb-discover-bento__mosaic">
						<a href="${pageContext.request.contextPath}/products/category/tai-nghe"
							class="bb-mosaic-tile bb-mosaic-tile--purple">
							<img src="${pageContext.request.contextPath}/images/categories/tai-nghe.png"
								alt="Tai nghe" loading="lazy">
						</a>
						<a href="${pageContext.request.contextPath}/products/category/robot-hut-bui"
							class="bb-mosaic-tile bb-mosaic-tile--magenta">
							<img src="${pageContext.request.contextPath}/images/categories/robot-hut-bui.png"
								alt="Robot hút bụi" loading="lazy">
						</a>
						<a href="${pageContext.request.contextPath}/products/category/may-ep-trai-cay"
							class="bb-mosaic-tile bb-mosaic-tile--tall">
							<img src="${pageContext.request.contextPath}/images/categories/may-ep-trai-cay.png"
								alt="Máy ép trái cây" loading="lazy">
						</a>
					</div>
				</div>

				<!-- Promo Card bên phải: Voucher & Deal -->
				<div class="bb-promo-highlight">
					<span class="bb-promo-highlight__badge">ĐẶC QUYỀN TECHSEVEN</span>
					<h3>Săn Deal Hời — Tiết kiệm thêm cùng Kho Voucher</h3>
					<p>Áp dụng trực tiếp khi thanh toán đơn hàng COD hoặc VNPay.</p>
					<div class="bb-promo-highlight__visual">
						<img src="${pageContext.request.contextPath}/images/categories/noi-chien-khong-dau.png"
							alt="Nồi chiên không dầu" width="150" height="150" loading="lazy">
						<img src="${pageContext.request.contextPath}/images/categories/may-loc-khong-khi.png"
							alt="Máy lọc không khí" width="150" height="150" loading="lazy">
					</div>
					<a href="${pageContext.request.contextPath}/vouchers"
						class="bb-btn-primary-sm align-self-start mt-auto">Lấy mã ưu đãi ngay</a>
				</div>
			</div>

			<!-- Warm Shelf: Bữa ngon trọn vị / Đánh giá cao -->
			<c:set var="warmShelfList" value="${not empty topRating ? topRating : topNewest}" />
			<div class="bb-feature-shelf bb-feature-shelf--warm">
				<div class="bb-feature-shelf__intro">
					<div>
						<h2 class="bb-warm-title">Chuẩn bị bữa ngon thật dễ dàng</h2>
						<p class="bb-warm-desc">
							Trang bị thiết bị gia dụng &amp; điện máy được khách hàng đánh giá cao nhất cho tổ ấm.
						</p>
						<a href="${pageContext.request.contextPath}/products?sortBy=rating"
							class="bb-warm-link">Xem các sản phẩm được yêu thích <i class="bi bi-arrow-right"></i></a>
					</div>
					<div class="bb-warm-visual">
						<img src="${pageContext.request.contextPath}/images/categories/noi-com-dien.png"
							alt="Gia dụng nhà bếp" loading="lazy">
						<img src="${pageContext.request.contextPath}/images/categories/bep-tu.png"
							alt="Bếp từ" loading="lazy">
					</div>
				</div>

				<div class="bb-feature-shelf__rail">
					<c:forEach items="${warmShelfList}" var="prod" begin="0" end="5">
						<article class="bb-shelf-card">
							<div class="bb-shelf-card__top">
								<c:choose>
									<c:when test="${prod.sellingPrice < prod.originalPrice}">
										<span class="bb-save-badge">
											Giảm <fmt:formatNumber value="${prod.originalPrice - prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
										</span>
									</c:when>
									<c:otherwise>
										<span class="bb-save-badge">⭐ ${prod.rating} Đánh giá cao</span>
									</c:otherwise>
								</c:choose>
								<button type="button" class="bb-wish-btn" title="Lưu sản phẩm"
									onclick="this.classList.toggle('is-active')">
									<i class="bi bi-heart"></i>
								</button>
							</div>

							<a href="${pageContext.request.contextPath}/products/${prod.slug}"
								class="bb-shelf-card__img">
								<img src="${prod.mainImageUrl}" alt="<c:out value='${prod.name}'/>"
									width="160" height="160" loading="lazy" decoding="async">
							</a>

							<a href="${pageContext.request.contextPath}/products/${prod.slug}"
								class="bb-shelf-card__title" title="<c:out value='${prod.name}'/>">
								<c:out value="${prod.name}" />
							</a>

							<div class="mt-auto pt-2">
								<div class="bb-shelf-card__price">
									<fmt:formatNumber value="${prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
								</div>
								<c:if test="${prod.sellingPrice < prod.originalPrice}">
									<div class="bb-shelf-card__old-price">
										<fmt:formatNumber value="${prod.originalPrice}" type="number" groupingUsed="true" /> ₫
									</div>
								</c:if>
							</div>
						</article>
					</c:forEach>
				</div>
			</div>

		</div>
	</section>

	<section class="py-4 bb-deferred-section" id="top20-section">
		<div class="storefront-container">
			<div class="bb-panel-card">
				<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3 border-bottom pb-3">
					<div>
						<h2 class="bb-panel-title mb-1">
							Khám phá Top 20 Sản phẩm Hàng đầu
						</h2>
						<p class="bb-panel-subtitle mb-0">Các dòng thiết bị điện máy chính hãng được săn đón nhiều nhất tại TECHSEVEN</p>
					</div>

					<ul class="nav nav-pills gap-2" id="top20Tabs" role="tablist">
						<li class="nav-item" role="presentation">
							<button class="bb-room-pill active"
								id="newest-tab" data-bs-toggle="pill" data-bs-target="#tab-newest"
								type="button" role="tab">
								<i class="bi bi-stars me-1"></i> Mới Nhất
							</button>
						</li>
						<li class="nav-item" role="presentation">
							<button class="bb-room-pill" id="bestseller-tab"
								data-bs-toggle="pill" data-bs-target="#tab-bestseller"
								type="button" role="tab">
								<i class="bi bi-fire text-danger me-1"></i> Bán Chạy
							</button>
						</li>
						<li class="nav-item" role="presentation">
							<button class="bb-room-pill" id="rating-tab"
								data-bs-toggle="pill" data-bs-target="#tab-rating" type="button"
								role="tab">
								<i class="bi bi-star-fill text-warning me-1"></i> Đánh Giá Cao
							</button>
						</li>
						<li class="nav-item" role="presentation">
							<button class="bb-room-pill" id="favorite-tab"
								data-bs-toggle="pill" data-bs-target="#tab-favorite" type="button"
								role="tab">
								<i class="bi bi-heart-fill text-danger me-1"></i> Yêu Thích
							</button>
						</li>
					</ul>
				</div>

				<!-- NỘI DUNG CÁC TAB -->
				<div class="tab-content" id="top20TabsContent">

					<!-- TAB 1: MỚI NHẤT -->
					<div class="tab-pane fade show active" id="tab-newest" role="tabpanel">
						<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
							<c:forEach items="${topNewest}" var="prod" varStatus="loop">
								<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
									<div class="bb-catalog-card h-100">
										<div class="bb-catalog-card__badges">
											<c:choose>
												<c:when test="${prod.sellingPrice < prod.originalPrice}">
													<span class="bb-save-badge">
														Tiết kiệm <fmt:formatNumber value="${prod.originalPrice - prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
													</span>
												</c:when>
												<c:otherwise>
													<span class="bb-new-badge">Mới</span>
												</c:otherwise>
											</c:choose>
										</div>
										<a href="${pageContext.request.contextPath}/products/${prod.slug}"
											class="bb-catalog-card__media">
											<img src="${prod.mainImageUrl}" alt="<c:out value='${prod.name}'/>"
												loading="lazy" decoding="async">
										</a>
										<div class="bb-catalog-card__body">
											<small class="bb-catalog-card__meta">${prod.brand.name} • ${prod.category.name}</small>
											<a href="${pageContext.request.contextPath}/products/${prod.slug}"
												class="bb-catalog-card__title" title="<c:out value='${prod.name}'/>">
												<c:out value="${prod.name}" />
											</a>
											<div class="bb-catalog-card__rating">
												<c:choose>
													<c:when test="${prod.reviewCount gt 0}">
														<span class="bb-stars">
															<i class="bi bi-star-fill text-warning"></i>
															<strong><fmt:formatNumber value="${prod.rating}" minFractionDigits="1" maxFractionDigits="1" /></strong>
															<span class="text-muted">(${prod.reviewCount})</span>
														</span>
													</c:when>
													<c:otherwise>
														<span class="small text-muted">Chưa có đánh giá</span>
													</c:otherwise>
												</c:choose>
												<small class="text-muted">Đã bán ${not empty prod.soldQuantity ? prod.soldQuantity : 0}</small>
											</div>
											<div class="mt-auto pt-2">
												<div class="bb-catalog-card__price-row">
													<span class="bb-catalog-card__price">
														<fmt:formatNumber value="${prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
													</span>
													<c:if test="${prod.sellingPrice < prod.originalPrice}">
														<span class="bb-catalog-card__old-price">
															<fmt:formatNumber value="${prod.originalPrice}" type="number" groupingUsed="true" /> ₫
														</span>
													</c:if>
												</div>
												<button type="button" class="bb-btn-add-cart mt-3"
													onclick="addToCart(${prod.id}, 1, this)">
													<i class="bi bi-cart-plus-fill me-1"></i> Thêm vào giỏ
												</button>
											</div>
										</div>
									</div>
								</div>
							</c:forEach>
						</div>
						<c:if test="${fn:length(topNewest) > 8}">
							<div class="text-center mt-4">
								<button class="bb-btn-loadmore" onclick="loadMore(this)">
									Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
								</button>
							</div>
						</c:if>
					</div>

					<!-- TAB 2: BÁN CHẠY -->
					<div class="tab-pane fade" id="tab-bestseller" role="tabpanel">
						<c:if test="${empty topBestseller}">
							<p class="text-muted py-4 text-center">Chưa có sản phẩm ghi nhận giao hàng thành công.</p>
						</c:if>
						<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
							<c:forEach items="${topBestseller}" var="prod" varStatus="loop">
								<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
									<div class="bb-catalog-card h-100">
										<div class="bb-catalog-card__badges">
											<span class="bb-hot-badge">Bán chạy 🔥</span>
										</div>
										<a href="${pageContext.request.contextPath}/products/${prod.slug}"
											class="bb-catalog-card__media">
											<img src="${prod.mainImageUrl}" alt="<c:out value='${prod.name}'/>"
												loading="lazy" decoding="async">
										</a>
										<div class="bb-catalog-card__body">
											<small class="bb-catalog-card__meta">${prod.brand.name} • ${prod.category.name}</small>
											<a href="${pageContext.request.contextPath}/products/${prod.slug}"
												class="bb-catalog-card__title" title="<c:out value='${prod.name}'/>">
												<c:out value="${prod.name}" />
											</a>
											<div class="bb-catalog-card__rating">
												<c:choose>
													<c:when test="${prod.reviewCount gt 0}">
														<span class="bb-stars">
															<i class="bi bi-star-fill text-warning"></i>
															<strong><fmt:formatNumber value="${prod.rating}" minFractionDigits="1" maxFractionDigits="1" /></strong>
															<span class="text-muted">(${prod.reviewCount})</span>
														</span>
													</c:when>
													<c:otherwise>
														<span class="small text-muted">Chưa có đánh giá</span>
													</c:otherwise>
												</c:choose>
												<small class="text-muted">Đã bán ${not empty prod.soldQuantity ? prod.soldQuantity : 0}</small>
											</div>
											<div class="mt-auto pt-2">
												<div class="bb-catalog-card__price-row">
													<span class="bb-catalog-card__price">
														<fmt:formatNumber value="${prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
													</span>
													<c:if test="${prod.sellingPrice < prod.originalPrice}">
														<span class="bb-catalog-card__old-price">
															<fmt:formatNumber value="${prod.originalPrice}" type="number" groupingUsed="true" /> ₫
														</span>
													</c:if>
												</div>
												<button type="button" class="bb-btn-add-cart mt-3"
													onclick="addToCart(${prod.id}, 1, this)">
													<i class="bi bi-cart-plus-fill me-1"></i> Thêm vào giỏ
												</button>
											</div>
										</div>
									</div>
								</div>
							</c:forEach>
						</div>
						<c:if test="${fn:length(topBestseller) > 8}">
							<div class="text-center mt-4">
								<button class="bb-btn-loadmore" onclick="loadMore(this)">
									Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
								</button>
							</div>
						</c:if>
					</div>

					<!-- TAB 3: ĐÁNH GIÁ CAO -->
					<div class="tab-pane fade" id="tab-rating" role="tabpanel">
						<c:if test="${empty topRating}">
							<p class="text-muted py-4 text-center">Chưa có sản phẩm đạt từ 4 sao với đánh giá thực tế.</p>
						</c:if>
						<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
							<c:forEach items="${topRating}" var="prod" varStatus="loop">
								<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
									<div class="bb-catalog-card h-100">
										<div class="bb-catalog-card__badges">
											<span class="bb-save-badge">⭐ ${prod.rating}</span>
										</div>
										<a href="${pageContext.request.contextPath}/products/${prod.slug}"
											class="bb-catalog-card__media">
											<img src="${prod.mainImageUrl}" alt="<c:out value='${prod.name}'/>"
												loading="lazy" decoding="async">
										</a>
										<div class="bb-catalog-card__body">
											<small class="bb-catalog-card__meta">${prod.brand.name} • ${prod.category.name}</small>
											<a href="${pageContext.request.contextPath}/products/${prod.slug}"
												class="bb-catalog-card__title" title="<c:out value='${prod.name}'/>">
												<c:out value="${prod.name}" />
											</a>
											<div class="bb-catalog-card__rating">
												<c:choose>
													<c:when test="${prod.reviewCount gt 0}">
														<span class="bb-stars">
															<i class="bi bi-star-fill text-warning"></i>
															<strong><fmt:formatNumber value="${prod.rating}" minFractionDigits="1" maxFractionDigits="1" /></strong>
															<span class="text-muted">(${prod.reviewCount})</span>
														</span>
													</c:when>
													<c:otherwise>
														<span class="small text-muted">Chưa có đánh giá</span>
													</c:otherwise>
												</c:choose>
												<small class="text-muted">Đã bán ${not empty prod.soldQuantity ? prod.soldQuantity : 0}</small>
											</div>
											<div class="mt-auto pt-2">
												<div class="bb-catalog-card__price-row">
													<span class="bb-catalog-card__price">
														<fmt:formatNumber value="${prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
													</span>
													<c:if test="${prod.sellingPrice < prod.originalPrice}">
														<span class="bb-catalog-card__old-price">
															<fmt:formatNumber value="${prod.originalPrice}" type="number" groupingUsed="true" /> ₫
														</span>
													</c:if>
												</div>
												<button type="button" class="bb-btn-add-cart mt-3"
													onclick="addToCart(${prod.id}, 1, this)">
													<i class="bi bi-cart-plus-fill me-1"></i> Thêm vào giỏ
												</button>
											</div>
										</div>
									</div>
								</div>
							</c:forEach>
						</div>
						<c:if test="${fn:length(topRating) > 8}">
							<div class="text-center mt-4">
								<button class="bb-btn-loadmore" onclick="loadMore(this)">
									Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
								</button>
							</div>
						</c:if>
					</div>

					<!-- TAB 4: YÊU THÍCH -->
					<div class="tab-pane fade" id="tab-favorite" role="tabpanel">
						<c:if test="${empty topFavorite}">
							<p class="text-muted py-4 text-center">Chưa có dữ liệu sản phẩm được yêu thích.</p>
						</c:if>
						<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4 product-grid">
							<c:forEach items="${topFavorite}" var="prod" varStatus="loop">
								<div class="col product-item ${loop.index >= 8 ? 'd-none' : ''}">
									<div class="bb-catalog-card h-100">
										<div class="bb-catalog-card__badges">
											<span class="bb-hot-badge">❤️ ${prod.favoriteCount}</span>
										</div>
										<a href="${pageContext.request.contextPath}/products/${prod.slug}"
											class="bb-catalog-card__media">
											<img src="${prod.mainImageUrl}" alt="<c:out value='${prod.name}'/>"
												loading="lazy" decoding="async">
										</a>
										<div class="bb-catalog-card__body">
											<small class="bb-catalog-card__meta">${prod.brand.name} • ${prod.category.name}</small>
											<a href="${pageContext.request.contextPath}/products/${prod.slug}"
												class="bb-catalog-card__title" title="<c:out value='${prod.name}'/>">
												<c:out value="${prod.name}" />
											</a>
											<div class="bb-catalog-card__rating">
												<c:choose>
													<c:when test="${prod.reviewCount gt 0}">
														<span class="bb-stars">
															<i class="bi bi-star-fill text-warning"></i>
															<strong><fmt:formatNumber value="${prod.rating}" minFractionDigits="1" maxFractionDigits="1" /></strong>
															<span class="text-muted">(${prod.reviewCount})</span>
														</span>
													</c:when>
													<c:otherwise>
														<span class="small text-muted">Chưa có đánh giá</span>
													</c:otherwise>
												</c:choose>
												<small class="text-muted">Đã bán ${not empty prod.soldQuantity ? prod.soldQuantity : 0}</small>
											</div>
											<div class="mt-auto pt-2">
												<div class="bb-catalog-card__price-row">
													<span class="bb-catalog-card__price">
														<fmt:formatNumber value="${prod.sellingPrice}" type="number" groupingUsed="true" /> ₫
													</span>
													<c:if test="${prod.sellingPrice < prod.originalPrice}">
														<span class="bb-catalog-card__old-price">
															<fmt:formatNumber value="${prod.originalPrice}" type="number" groupingUsed="true" /> ₫
														</span>
													</c:if>
												</div>
												<button type="button" class="bb-btn-add-cart mt-3"
													onclick="addToCart(${prod.id}, 1, this)">
													<i class="bi bi-cart-plus-fill me-1"></i> Thêm vào giỏ
												</button>
											</div>
										</div>
									</div>
								</div>
							</c:forEach>
						</div>
						<c:if test="${fn:length(topFavorite) > 8}">
							<div class="text-center mt-4">
								<button class="bb-btn-loadmore" onclick="loadMore(this)">
									Xem thêm sản phẩm <i class="bi bi-chevron-down ms-1"></i>
								</button>
							</div>
						</c:if>
					</div>

				</div>
			</div>
		</div>
	</section>

	<section class="pt-3 pb-2 bb-deferred-section">
		<div class="storefront-container">
			<div class="bb-value-bar">
								<div class="bb-value-bar__brand">
					<a href="${pageContext.request.contextPath}/" aria-label="TECHSEVEN - Trang chủ" class="d-inline-block">
						<img src="${pageContext.request.contextPath}/images/brand/techseven-logo-dark.svg"
							alt="TECHSEVEN" width="220" height="50"
							class="img-fluid bb-value-bar__logo" loading="lazy" decoding="async">
					</a>
				</div>

				<div class="bb-value-bar__item">
					<h3>Giá trị vượt trội cho bạn</h3>
					<p>Tận hưởng mức giá chính hãng cạnh tranh, kho voucher ưu đãi mỗi ngày và đặc quyền thành viên.</p>
				</div>

				<div class="bb-value-bar__item">
					<h3>Dịch vụ &amp; Bảo hành tận tâm</h3>
					<p>Bao gồm tư vấn chuyên sâu, lắp đặt tận nơi, bảo hành chính hãng và hỗ trợ đổi trả minh bạch.</p>
				</div>

				<div class="bb-value-bar__item">
					<h3>Giao hàng nhanh trong ngày</h3>
					<p>Nhận hàng trực tiếp tại chi nhánh gần nhất hoặc giao lắp tận nhà nhanh chóng, đúng hẹn.</p>
				</div>

				<div class="bb-value-bar__item">
					<h3>Đa dạng lựa chọn, dễ mua sắm</h3>
					<p>Từ thiết bị gia dụng thiết yếu đến điện máy cao cấp, dễ dàng tìm thấy sản phẩm phù hợp với bạn.</p>
				</div>
			</div>
		</div>
	</section>

</main>

<script>
	// 1. Xem thêm sản phẩm trong Top 20
	function loadMore(btn) {
		const tabPane = btn.closest('.tab-pane');
		const hiddenItems = tabPane.querySelectorAll('.product-item.d-none');

		for (let i = 0; i < Math.min(8, hiddenItems.length); i++) {
			hiddenItems[i].classList.remove('d-none');
		}

		if (tabPane.querySelectorAll('.product-item.d-none').length === 0) {
			btn.parentElement.style.display = 'none';
		}
	}

	// 2. Chuyển đổi tab không gian sống (Build your home with latest tech)
	function switchRoomTab(roomKey, btnEl) {
		const container = btnEl.closest('.bb-panel-card');
		container.querySelectorAll('.bb-room-pill').forEach(pill => pill.classList.remove('active'));
		btnEl.classList.add('active');

		container.querySelectorAll('.bb-room-pane').forEach(pane => pane.classList.remove('is-active'));
		const target = document.getElementById('room-' + roomKey);
		if (target) {
			target.classList.add('is-active');
		}
	}

	// 3. Trượt ngang danh sách Trending Now
	function scrollRail(railId, direction) {
		const rail = document.getElementById(railId);
		if (!rail) return;
		const scrollAmount = rail.clientWidth * 0.75;
		rail.scrollBy({ left: direction * scrollAmount, behavior: 'smooth' });
	}

	// 4. Bật/tắt ngăn kéo toàn bộ 32+ danh mục
	function toggleAllCategoriesDrawer() {
		const drawer = document.getElementById('allCategoriesDrawer');
		if (!drawer) return;
		drawer.classList.toggle('d-none');
		if (!drawer.classList.contains('d-none')) {
			drawer.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
		}
	}

	// 5. Đồng bộ trạng thái active cho các nút pill của Top 20 Tabs
	document.querySelectorAll('#top20Tabs button[data-bs-toggle="pill"]').forEach(btn => {
		btn.addEventListener('shown.bs.tab', function () {
			document.querySelectorAll('#top20Tabs .bb-room-pill').forEach(b => b.classList.remove('active'));
			this.classList.add('active');
		});
	});
</script>

<!-- Nhúng Footer -->
<jsp:include page="fragments/footer.jsp" />