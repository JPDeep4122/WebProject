<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Dashboard — TECHSEVEN</title>

<!-- Bootstrap 5 & Icons -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
	rel="stylesheet">

<!-- Chart.js 4.x -->
<script
	src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>

<jsp:include page="/WEB-INF/views/shared/security.jsp" />
<jsp:include page="fragments/theme.jsp" />

<style>
:root {
	--apex-bg: #f8fafc;
	--apex-card-bg: #ffffff;
	--apex-border: #f1f5f9;
	--apex-emerald: #10b981;
	--apex-emerald-dark: #059669;
	--apex-text-main: #0f172a;
	--apex-text-muted: #64748b;
}

body {
	background-color: var(--apex-bg);
	color: var(--apex-text-main);
	font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
}

.dashboard-main {
	min-height: 100vh;
	background-color: var(--apex-bg);
}

/* Modern Card */
.apex-card {
	background: var(--apex-card-bg);
	border: 1px solid var(--apex-border);
	border-radius: 1.25rem; /* 20px */
	box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.04), 0 1px 2px -1px
		rgba(0, 0, 0, 0.02);
	transition: transform .2s ease, box-shadow .2s ease;
	position: relative;
	overflow: hidden;
}

.apex-card:hover {
	box-shadow: 0 4px 15px 0 rgba(0, 0, 0, 0.06);
}

/* Top Header Search & Button */
.apex-search-box {
	position: relative;
	min-width: 280px;
}

.apex-search-box input {
	border-radius: 9999px;
	background: #ffffff;
	border: 1px solid #e2e8f0;
	padding-left: 2.25rem;
	padding-right: 3rem;
	font-size: 0.875rem;
	height: 38px;
}

.apex-search-box .search-icon {
	position: absolute;
	left: 0.85rem;
	top: 50%;
	transform: translateY(-50%);
	color: var(--apex-text-muted);
	font-size: 0.875rem;
}

.apex-search-box .shortcut-badge {
	position: absolute;
	right: 0.75rem;
	top: 50%;
	transform: translateY(-50%);
	background: #f1f5f9;
	color: #94a3b8;
	font-size: 0.7rem;
	padding: 2px 6px;
	border-radius: 4px;
	font-weight: 600;
}

.btn-apex-emerald {
	background-color: var(--apex-emerald-dark);
	color: #ffffff;
	border-radius: 0.6rem;
	font-weight: 600;
	font-size: 0.875rem;
	padding: 0.45rem 1rem;
	border: none;
	display: inline-flex;
	align-items: center;
	gap: 0.35rem;
	transition: background-color 0.15s ease;
}

.btn-apex-emerald:hover {
	background-color: #047857;
	color: #ffffff;
}

/* 4 KPI Top Cards */
.kpi-title {
	font-size: 0.8125rem;
	color: var(--apex-text-muted);
	font-weight: 500;
	margin-bottom: 0.4rem;
}

.kpi-value {
	font-size: 1.65rem;
	font-weight: 700;
	color: var(--apex-text-main);
	letter-spacing: -0.02em;
	margin-bottom: 0.35rem;
}

.kpi-trend {
	font-size: 0.75rem;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 0.2rem;
}

.trend-up {
	color: #059669;
}

.trend-down {
	color: #dc2626;
}

.kpi-icon-pill {
	width: 44px;
	height: 44px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 1.25rem;
	flex-shrink: 0;
}

.pill-emerald {
	background: #ecfdf5;
	color: #059669;
}

.pill-teal {
	background: #f0fdfa;
	color: #0d9488;
}

.pill-blue {
	background: #eff6ff;
	color: #2563eb;
}

.pill-amber {
	background: #fffbeb;
	color: #d97706;
}

/* KPI Bottom Waves */
.kpi-wave-container {
	margin-left: -1.25rem;
	margin-right: -1.25rem;
	margin-bottom: -1.25rem;
	overflow: hidden;
	line-height: 0;
	margin-top: 0.5rem;
}

/* Segmented Pills in Card Header */
.nav-pills-apex {
	background: #f1f5f9;
	padding: 3px;
	border-radius: 9999px;
	display: inline-flex;
	gap: 2px;
}

.nav-pills-apex .nav-link {
	border-radius: 9999px;
	font-size: 0.75rem;
	font-weight: 600;
	color: var(--apex-text-muted);
	padding: 0.25rem 0.75rem;
	border: none;
	background: transparent;
}

.nav-pills-apex .nav-link.active {
	background: #ffffff;
	color: var(--apex-text-main);
	box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
}

/* Status List below Donut */
.status-legend-item {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0.4rem 0;
	text-decoration: none;
	color: inherit;
	transition: opacity 0.15s ease;
}

.status-legend-item:hover {
	opacity: 0.75;
}

.status-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	display: inline-block;
	margin-right: 0.5rem;
}
</style>
</head>

<body>
	<div class="d-flex">
		<!-- Sidebar -->
		<jsp:include page="fragments/sidebar.jsp" />

		<div class="dashboard-main flex-grow-1 p-4">

			<div
				class="d-flex justify-content-between align-items-center flex-wrap gap-3 pb-3 mb-4">
				<div>
					<h3 class="fw-bold mb-1 d-flex align-items-center gap-2"
						style="letter-spacing: -0.02em;">
						<span>Tổng quan kinh doanh</span> <span
							class="badge bg-success-subtle text-success border border-success-subtle rounded-pill fs-6 fw-normal px-3 py-1">
							<i class="bi bi-shop me-1"></i>
						<c:out value="${currentBranchName}" />
						</span>
					</h3>
					<p class="text-muted small mb-0">
						<i class="bi bi-calendar3 me-1"></i>Báo cáo hiệu suất bán hàng
						&amp; tiến trình vận hành hôm nay
					</p>
				</div>

				<div class="d-flex align-items-center flex-wrap gap-2">
					<div class="apex-search-box d-none d-md-block">
						<i class="bi bi-search search-icon"></i> <input type="text"
							class="form-control" placeholder="Tìm kiếm đơn, sản phẩm...">
						<span class="shortcut-badge">⌘K</span>
					</div>

					<a href="${pageContext.request.contextPath}/admin/orders"
						class="btn-apex-emerald text-decoration-none"> <i
						class="bi bi-plus-lg"></i> <span>+ Đơn hàng</span>
					</a>

					<c:if test="${canViewRevenue}">
						<button type="button"
							class="btn btn-outline-secondary btn-sm rounded-3">
							<i class="bi bi-download"></i>
						</button>
					</c:if>

					<a href="${pageContext.request.contextPath}/"
						class="btn btn-light btn-sm rounded-3 border"> <i
						class="bi bi-house"></i>
					</a>
				</div>
			</div>

			<c:choose>
				<c:when test="${canViewRevenue}">

					<!-- TOP 4 METRIC CARDS (Giống hệt 4 thẻ đầu trang trong ảnh) -->
					<section class="row g-3 mb-4">
						<!-- Card 1: Total Sales -->
						<div class="col-12 col-sm-6 col-xl-3">
							<div
								class="apex-card p-4 h-100 d-flex flex-column justify-content-between">
								<div class="d-flex justify-content-between align-items-start">
									<div>
										<div class="kpi-title">Tổng doanh thu</div>
										<div class="kpi-value">
											<fmt:formatNumber value="${totalRevenue}" type="number"
												maxFractionDigits="0" groupingUsed="true" />
											đ
										</div>
										<div class="kpi-trend trend-up">
											<i class="bi bi-graph-up-arrow"></i> +18.2%
										</div>
									</div>
									<div class="kpi-icon-pill pill-emerald">
										<i class="bi bi-currency-dollar"></i>
									</div>
								</div>
								<div class="kpi-wave-container">
									<svg width="100%" height="32" viewBox="0 0 100 25"
										preserveAspectRatio="none">
                                        <path
											d="M0,18 C20,10 35,22 55,14 C75,6 88,18 100,10" fill="none"
											stroke="#10b981" stroke-width="2.5" stroke-linecap="round" />
                                    </svg>
								</div>
							</div>
						</div>

						<!-- Card 2: Avg Order Value (AOV) -->
						<div class="col-12 col-sm-6 col-xl-3">
							<div
								class="apex-card p-4 h-100 d-flex flex-column justify-content-between">
								<div class="d-flex justify-content-between align-items-start">
									<div>
										<div class="kpi-title">Giá trị TB / đơn (AOV)</div>
										<div class="kpi-value">
											<fmt:formatNumber value="${aov}" type="number"
												maxFractionDigits="0" groupingUsed="true" />
											đ
										</div>
										<div class="kpi-trend trend-up">
											<i class="bi bi-graph-up-arrow"></i> +4.8%
										</div>
									</div>
									<div class="kpi-icon-pill pill-teal">
										<i class="bi bi-bag"></i>
									</div>
								</div>
								<div class="kpi-wave-container">
									<svg width="100%" height="32" viewBox="0 0 100 25"
										preserveAspectRatio="none">
                                        <path
											d="M0,15 C25,18 40,12 60,17 C75,20 85,10 100,14" fill="none"
											stroke="#0d9488" stroke-width="2.5" stroke-linecap="round" />
                                    </svg>
								</div>
							</div>
						</div>

						<!-- Card 3: Conversion / Khách hàng đã mua -->
						<div class="col-12 col-sm-6 col-xl-3">
							<div
								class="apex-card p-4 h-100 d-flex flex-column justify-content-between">
								<div class="d-flex justify-content-between align-items-start">
									<div>
										<div class="kpi-title">Khách hàng đã mua</div>
										<div class="kpi-value">
											<fmt:formatNumber value="${customerCount}" type="number"
												maxFractionDigits="0" />
											khách
										</div>
										<div class="kpi-trend trend-up">
											<i class="bi bi-people"></i> Khách thực tế
										</div>
									</div>
									<div class="kpi-icon-pill pill-blue">
										<i class="bi bi-graph-up"></i>
									</div>
								</div>
								<div class="kpi-wave-container">
									<svg width="100%" height="32" viewBox="0 0 100 25"
										preserveAspectRatio="none">
                                        <path
											d="M0,20 C18,12 35,16 55,10 C75,18 85,8 100,12" fill="none"
											stroke="#3b82f6" stroke-width="2.5" stroke-linecap="round" />
                                    </svg>
								</div>
							</div>
						</div>

						<!-- Card 4: Đơn thanh toán thành công -->
						<div class="col-12 col-sm-6 col-xl-3">
							<div
								class="apex-card p-4 h-100 d-flex flex-column justify-content-between">
								<div class="d-flex justify-content-between align-items-start">
									<div>
										<div class="kpi-title">Đơn hàng thành công</div>
										<div class="kpi-value">
											<fmt:formatNumber value="${successfulOrdersCount}"
												type="number" maxFractionDigits="0" />
											đơn
										</div>
										<div class="kpi-trend trend-up">
											<i class="bi bi-check2-circle"></i> Đã thanh toán
										</div>
									</div>
									<div class="kpi-icon-pill pill-amber">
										<i class="bi bi-arrow-repeat"></i>
									</div>
								</div>
								<div class="kpi-wave-container">
									<svg width="100%" height="32" viewBox="0 0 100 25"
										preserveAspectRatio="none">
                                        <path
											d="M0,16 C20,20 40,10 60,18 C78,14 88,22 100,15" fill="none"
											stroke="#f59e0b" stroke-width="2.5" stroke-linecap="round" />
                                    </svg>
								</div>
							</div>
						</div>
					</section>

					<!-- MIDDLE ROW: Sales Overview Area Chart & Order Status Donut Chart -->
					<section class="row g-3 mb-4">
						<!-- Sales Overview (Biểu đồ cong màu lục bảo với đổ bóng mờ) -->
						<div class="col-12 col-xl-8">
							<div class="apex-card p-4 h-100 d-flex flex-column">
								<div
									class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
									<div>
										<h5 class="fw-bold mb-1">Sales Overview</h5>
										<div class="text-muted small">Doanh thu theo ngày trong
											7 ngày gần nhất</div>
									</div>

									<div class="nav-pills-apex">
										<button class="nav-link active">Doanh thu</button>
										<button class="nav-link">Đơn hàng</button>
									</div>
								</div>

								<div class="flex-grow-1"
									style="min-height: 280px; position: relative;">
									<canvas id="salesOverviewChart"></canvas>
								</div>
							</div>
						</div>

						<!-- Order Status (Donut Chart & Phân bổ trạng thái) -->
						<div class="col-12 col-xl-4">
							<div class="apex-card p-4 h-100 d-flex flex-column">
								<div class="mb-3">
									<h5 class="fw-bold mb-1">Order Status</h5>
									<div class="text-muted small">Phân bổ trạng thái toàn bộ
										đơn hàng</div>
								</div>

								<!-- Donut Chart with Centered Number (Giống hệt ảnh 992 Orders) -->
								<div
									class="position-relative d-flex justify-content-center align-items-center my-auto"
									style="height: 190px;">
									<canvas id="orderStatusDonut"></canvas>
									<div class="position-absolute text-center"
										style="pointer-events: none;">
										<div class="fw-bold fs-3 text-dark mb-0 lh-1">
											<fmt:formatNumber value="${statusChartTotal}"
												maxFractionDigits="0" />
										</div>
										<div class="text-muted fw-semibold"
											style="font-size: 0.7rem; letter-spacing: 0.05em; text-transform: uppercase;">
											Orders</div>
									</div>
								</div>

								<!-- Legend list with counts -->
								<div class="mt-3 pt-2 border-top">
									<a class="status-legend-item"
										href="${pageContext.request.contextPath}/admin/orders?status=DELIVERED">
										<div class="d-flex align-items-center small">
											<span class="status-dot" style="background-color: #10b981;"></span>
											<span>Đã giao (Completed)</span>
										</div> <span class="fw-bold small"><fmt:formatNumber
												value="${deliveredOrderCount}" maxFractionDigits="0" /></span>
									</a> <a class="status-legend-item"
										href="${pageContext.request.contextPath}/admin/orders?status=PROCESSING">
										<div class="d-flex align-items-center small">
											<span class="status-dot" style="background-color: #06b6d4;"></span>
											<span>Đang chuẩn bị (Processing)</span>
										</div> <span class="fw-bold small"><fmt:formatNumber
												value="${processingOrderCount}" maxFractionDigits="0" /></span>
									</a> <a class="status-legend-item"
										href="${pageContext.request.contextPath}/admin/orders?status=SHIPPING">
										<div class="d-flex align-items-center small">
											<span class="status-dot" style="background-color: #718096;"></span>
											<span>Đang giao (Shipping)</span>
										</div> <span class="fw-bold small"><fmt:formatNumber
												value="${shippingOrderCount}" maxFractionDigits="0" /></span>
									</a> <a class="status-legend-item"
										href="${pageContext.request.contextPath}/admin/orders?status=PENDING">
										<div class="d-flex align-items-center small">
											<span class="status-dot" style="background-color: #3b82f6;"></span>
											<span>Chờ xác nhận (Pending)</span>
										</div> <span class="fw-bold small"><fmt:formatNumber
												value="${pendingOrderCount}" maxFractionDigits="0" /></span>
									</a>
								</div>
							</div>
						</div>
					</section>

					<!-- BOTTOM ROW: Top Selling Products & Sales by Branch (Category Style) -->
					<section class="row g-3 mb-4">
						<!-- Top Selling Products Table -->
						<div class="col-12 col-xl-8">
							<div class="apex-card p-4 h-100">
								<div
									class="d-flex justify-content-between align-items-center mb-3">
									<div>
										<h5 class="fw-bold mb-1">Top Selling Products</h5>
										<div class="text-muted small">Sản phẩm bán chạy nhất</div>
									</div>
									<a href="${pageContext.request.contextPath}/admin/products"
										class="text-decoration-none fw-semibold small text-success">
										Xem tất cả &rarr; </a>
								</div>

								<div class="table-responsive">
									<table class="table align-middle mb-0">
										<thead class="text-muted small border-bottom">
											<tr>
												<th style="width: 35px;" class="ps-2">#</th>
												<th>Sản phẩm</th>
												<th class="text-center">Đã bán</th>
												<th class="text-end">Doanh thu / Giá</th>
												<th class="text-center pe-3" style="width: 90px;">Xu
													hướng</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach items="${topSellingProducts}" var="prod"
												varStatus="loop">
												<tr>
													<td class="ps-2 text-muted fw-semibold small">${loop.index + 1}</td>
													<td>
														<div class="d-flex align-items-center gap-2">
															<c:choose>
																<c:when test="${not empty prod.mainImageUrl}">
																	<img src="${prod.mainImageUrl}" alt="${prod.name}"
																		class="rounded-3 border"
																		style="width: 40px; height: 40px; object-fit: contain; background: #fff;">
																</c:when>
																<c:otherwise>
																	<div
																		class="rounded-3 bg-light d-flex align-items-center justify-content-center text-muted"
																		style="width: 40px; height: 40px;">
																		<i class="bi bi-box"></i>
																	</div>
																</c:otherwise>
															</c:choose>
															<div class="d-flex flex-column text-truncate"
																style="max-width: 260px;">
																<span class="fw-bold text-dark text-truncate small"
																	title="${prod.name}"><c:out value="${prod.name}" /></span>
																<span class="text-muted" style="font-size: 0.75rem;"><c:out
																		value="${prod.category != null ? prod.category.name : 'Thiết bị gia dụng'}" /></span>
															</div>
														</div>
													</td>
													<td class="text-center fw-semibold text-dark small"><fmt:formatNumber
															value="${prod.soldQuantity != null ? prod.soldQuantity : 0}"
															maxFractionDigits="0" /></td>
													<td class="text-end fw-bold text-dark small"><fmt:formatNumber
															value="${prod.sellingPrice}" type="number"
															maxFractionDigits="0" groupingUsed="true" /> đ</td>
													<td class="text-center pe-3">
														<!-- Mini green sparkline wave as in the screenshot --> <svg
															width="55" height="18" viewBox="0 0 55 18" fill="none">
                                                            <path
																d="M2 13 C 12 15, 22 7, 32 10 C 40 14, 46 4, 53 3"
																stroke="#10b981" stroke-width="2" stroke-linecap="round" />
                                                        </svg>
													</td>
												</tr>
											</c:forEach>
											<c:if test="${empty topSellingProducts}">
												<tr>
													<td colspan="5" class="text-center text-muted py-4 small">Chưa
														có dữ liệu sản phẩm.</td>
												</tr>
											</c:if>
										</tbody>
									</table>
								</div>
							</div>
						</div>

						<!-- Sales by Branch (Phong cách thanh ngang bo góc giống Sales by Category) -->
						<div class="col-12 col-xl-4">
							<div class="apex-card p-4 h-100">
								<div class="mb-3">
									<h5 class="fw-bold mb-1">Sales by Branch</h5>
									<div class="text-muted small">Phân bổ doanh thu theo từng
										chi nhánh</div>
								</div>

								<div class="d-flex flex-column gap-3 mt-4">
									<c:forEach var="branch" items="${branches}">
										<div>
											<div
												class="d-flex justify-content-between align-items-center mb-1">
												<span class="fw-semibold text-dark small text-truncate"
													style="max-width: 170px;"><c:out
														value="${branch.name}" /></span> <span class="text-muted small">
													<strong class="text-dark"><fmt:formatNumber
															value="${branch.revenue}" maxFractionDigits="0"
															groupingUsed="true" /> đ</strong> <span class="text-secondary">(${branch.sharePercent}%)</span>
												</span>
											</div>
											<div class="progress"
												style="height: 12px; border-radius: 9999px; background-color: #f1f5f9;">
												<div class="progress-bar rounded-pill" role="progressbar"
													style="width: ${branch.sharePercent}%; background: linear-gradient(90deg, #0d9488, #14b8a6);"
													aria-valuenow="${branch.sharePercent}" aria-valuemin="0"
													aria-valuemax="100"></div>
											</div>
										</div>
									</c:forEach>
									<c:if test="${empty branches}">
										<p class="text-muted small text-center py-4">Chưa có dữ
											liệu chi nhánh.</p>
									</c:if>
								</div>
							</div>
						</div>
					</section>

					<!-- RECENT PAID ORDERS TABLE -->
					<div class="apex-card p-4 mb-4">
						<div
							class="d-flex justify-content-between align-items-center mb-3">
							<div>
								<h5 class="fw-bold mb-1">Đơn hàng thanh toán thành công gần
									đây</h5>
								<div class="text-muted small">Cập nhật trực tiếp từ hệ
									thống cổng thanh toán</div>
							</div>
							<a class="btn btn-sm btn-outline-secondary rounded-3"
								href="${pageContext.request.contextPath}/admin/invoices">
								Xem tất cả hóa đơn </a>
						</div>

						<div class="table-responsive">
							<table class="table table-hover align-middle mb-0">
								<thead class="text-muted small border-bottom">
									<tr>
										<th class="ps-2">Mã đơn</th>
										<th>Khách hàng</th>
										<th>Chi nhánh</th>
										<th>Thời gian đặt</th>
										<th class="text-end">Tổng tiền</th>
										<th class="text-center">Thao tác</th>
									</tr>
								</thead>
								<tbody>
									<c:forEach items="${successfulOrders}" var="order">
										<tr>
											<td class="ps-2"><strong class="text-primary"><c:out
														value="${order.orderCode}" /></strong></td>
											<td><span class="fw-semibold text-dark"><c:out
														value="${order.recipientName}" /></span><br> <small
												class="text-secondary"><i
													class="bi bi-telephone me-1"></i>
												<c:out value="${order.recipientPhone}" /></small></td>
											<td><c:out value="${order.branch.name}"
													default="Chưa gán" /></td>
											<td><c:set var="rawDate"
													value="${order.createdAt.toString()}" /> <span
												class="small text-nowrap text-secondary">${fn:replace(fn:substring(rawDate, 0, 16), 'T', ' ')}</span>
											</td>
											<td class="text-end fw-bold text-success"><fmt:formatNumber
													value="${order.finalAmount}" type="number"
													maxFractionDigits="0" groupingUsed="true" /> đ</td>
											<td class="text-center"><a
												class="btn btn-sm btn-light border rounded-pill px-3"
												href="${pageContext.request.contextPath}/admin/orders/${order.id}">
													Chi tiết </a></td>
										</tr>
									</c:forEach>
									<c:if test="${empty successfulOrders}">
										<tr>
											<td colspan="6" class="text-center text-muted py-4 small">Chưa
												có đơn hàng thanh toán thành công.</td>
										</tr>
									</c:if>
								</tbody>
							</table>
						</div>
					</div>

				</c:when>

				<c:otherwise>
					<!-- Chế độ xem dành riêng cho Nhân viên không có quyền xem doanh thu -->
					<div class="apex-card p-4">
						<h5 class="fw-bold text-primary mb-2">
							<i class="bi bi-person-workspace me-2"></i>Không gian làm việc
							Nhân viên Chi nhánh
						</h5>
						<p class="text-secondary mb-3">
							Bạn đang làm việc tại <strong><c:out
									value="${currentBranchName}" /></strong>. Dữ liệu tài chính chỉ hiển
							thị cho Quản lý chi nhánh và Admin tổng.
						</p>
						<div class="d-flex flex-wrap gap-2">
							<a href="${pageContext.request.contextPath}/admin/orders"
								class="btn btn-primary rounded-3"> <i
								class="bi bi-receipt me-1"></i>Xử lý đơn hàng chi nhánh
							</a> <a href="${pageContext.request.contextPath}/admin/inventory"
								class="btn btn-outline-primary rounded-3"> <i
								class="bi bi-boxes me-1"></i>Tồn kho &amp; Tra cứu
							</a>
						</div>
					</div>
				</c:otherwise>
			</c:choose>

		</div>
	</div>

	<!-- Realtime WebSocket Support -->
	<c:if test="${not empty orderRealtimeDestination}">
		<div id="orderRealtime"
			data-context-path="${pageContext.request.contextPath}"
			data-destination="${orderRealtimeDestination}"
			data-poll-url="${pageContext.request.contextPath}${orderStatusPollUrl}">
		</div>
		<script
			src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
		<script
			src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
		<script src="${pageContext.request.contextPath}/js/order-realtime.js"></script>
	</c:if>

	<!-- CHART.JS INITIALIZATION SCRIPT (Giống 100% hình mẫu) -->
	<script>
        document.addEventListener('DOMContentLoaded', function () {
            // 1. Sales Overview - Smooth Emerald Line / Area Chart
            const ctxRevenue = document.getElementById('salesOverviewChart');
            if (ctxRevenue) {
                const labels = [
                    <c:forEach items="${revenueTrend}" var="d" varStatus="loop">
                        "${d.dateLabel}"${!loop.last ? ',' : ''}
                    </c:forEach>
                ];
                const data = [
                    <c:forEach items="${revenueTrend}" var="d" varStatus="loop">
                        ${d.revenue}${!loop.last ? ',' : ''}
                    </c:forEach>
                ];

                const ctx = ctxRevenue.getContext('2d');
                const gradient = ctx.createLinearGradient(0, 0, 0, 260);
                gradient.addColorStop(0, 'rgba(16, 185, 129, 0.28)');
                gradient.addColorStop(1, 'rgba(16, 185, 129, 0.00)');

                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels.length > 0 ? labels : ['Feb 1', 'Feb 6', 'Feb 11', 'Feb 16', 'Feb 21', 'Feb 26'],
                        datasets: [{
                            label: 'Doanh thu',
                            data: data.length > 0 ? data : [0, 0, 0, 0, 0, 0],
                            borderColor: '#10b981',
                            borderWidth: 2.8,
                            pointBackgroundColor: '#10b981',
                            pointBorderColor: '#ffffff',
                            pointBorderWidth: 2,
                            pointRadius: 4,
                            pointHoverRadius: 6,
                            fill: true,
                            backgroundColor: gradient,
                            tension: 0.42 // Tạo đường cong mượt mà như ảnh mẫu
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#0f172a',
                                titleFont: { size: 12, weight: '600' },
                                bodyFont: { size: 13 },
                                padding: 10,
                                cornerRadius: 8,
                                callbacks: {
                                    label: function(context) {
                                        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                border: { dash: [5, 5] },
                                grid: { color: '#f1f5f9' },
                                ticks: {
                                    color: '#94a3b8',
                                    font: { size: 11 },
                                    callback: function(val) {
                                        if (val >= 1000000) return (val / 1000000).toFixed(1) + 'M';
                                        if (val >= 1000) return (val / 1000).toFixed(0) + 'k';
                                        return val;
                                    }
                                }
                            },
                            x: {
                                grid: { display: false },
                                ticks: { color: '#94a3b8', font: { size: 11 } }
                            }
                        }
                    }
                });
            }

            // 2. Order Status - Donut Chart
            const ctxDonut = document.getElementById('orderStatusDonut');
            if (ctxDonut) {
                const statusLabels = [
                    <c:forEach items="${orderStatusChart}" var="s" varStatus="loop">
                        "${s.label}"${!loop.last ? ',' : ''}
                    </c:forEach>
                ];
                const statusData = [
                    <c:forEach items="${orderStatusChart}" var="s" varStatus="loop">
                        ${s.count}${!loop.last ? ',' : ''}
                    </c:forEach>
                ];
                const statusColors = ['#10b981', '#06b6d4', '#718096', '#3b82f6', '#dc3545', '#9b59b6'];

                new Chart(ctxDonut.getContext('2d'), {
                    type: 'doughnut',
                    data: {
                        labels: statusLabels,
                        datasets: [{
                            data: statusData,
                            backgroundColor: statusColors,
                            borderWidth: 0,
                            hoverOffset: 5
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '74%', // Tạo khoảng rỗng lớn ở giữa để đặt số lượng
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#0f172a',
                                padding: 10,
                                cornerRadius: 8
                            }
                        }
                    }
                });
            }
        });
    </script>
</body>
</html>