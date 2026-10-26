<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="fragments/header.jsp" />

<main class="storefront-container py-4">

	<nav aria-label="Điều hướng">
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a
				href="${pageContext.request.contextPath}/"> Trang chủ </a></li>
			<li class="breadcrumb-item active" aria-current="page"><c:out
					value="${pageTitle}" /></li>
		</ol>
	</nav>

	<section class="bg-white border rounded-4 p-4 p-md-5">
		<h1 class="h3 fw-bold mb-4">
			<c:out value="${pageTitle}" />
		</h1>

		<c:forEach items="${pageParagraphs}" var="paragraph">
			<p class="mb-3">
				<c:out value="${paragraph}" />
			</p>
		</c:forEach>

		<c:if test="${showBranches}">
			<div class="row g-3">
				<c:forEach items="${branches}" var="branch">
					<div class="col-md-6">
						<article class="border rounded-3 p-4 h-100 d-flex flex-column">
							<h2 class="h5 fw-bold">
								<c:out value="${branch.name}" />
							</h2>

							<p class="mb-2">
								<strong>Địa chỉ:</strong>
								<c:out value="${branch.address}" />
							</p>

							<c:if test="${not empty branch.province}">
								<p class="mb-2">
									<strong>Tỉnh/thành:</strong>
									<c:out value="${branch.province}" />
								</p>
							</c:if>

							<c:if test="${not empty branch.phone}">
								<p class="mb-0">
									<strong>Điện thoại:</strong>
									<c:out value="${branch.phone}" />
								</p>
							</c:if>

							<c:if test="${not empty fn:trim(branch.address)}">

								<%-- Ghép địa chỉ đầy đủ để tìm trên Google Maps --%>
								<c:set var="mapsAddress" value="${fn:trim(branch.address)}" />

								<c:if test="${not empty fn:trim(branch.province)}">
									<c:set var="mapsAddress"
										value="${mapsAddress}, ${fn:trim(branch.province)}" />
								</c:if>

								<c:set var="mapsAddress" value="${mapsAddress}, Việt Nam" />

								<%-- Liên kết xem vị trí --%>
								<c:url var="mapsSearchUrl"
									value="https://www.google.com/maps/search/">
									<c:param name="api" value="1" />
									<c:param name="query" value="${mapsAddress}" />
								</c:url>

								<%-- Liên kết chỉ đường đến chi nhánh --%>
								<c:url var="mapsDirectionsUrl"
									value="https://www.google.com/maps/dir/">
									<c:param name="api" value="1" />
									<c:param name="destination" value="${mapsAddress}" />
								</c:url>

								<div class="d-flex flex-wrap gap-2 mt-auto pt-3">
									<a class="btn btn-outline-primary rounded-pill px-3"
										href="${fn:escapeXml(mapsSearchUrl)}" target="_blank"
										rel="noopener noreferrer"> <i class="bi bi-geo-alt me-1"
										aria-hidden="true"></i> Xem vị trí <span
										class="visually-hidden"> (mở tab mới)</span>
									</a> <a class="btn btn-primary rounded-pill px-3"
										href="${fn:escapeXml(mapsDirectionsUrl)}" target="_blank"
										rel="noopener noreferrer"> <i
										class="bi bi-signpost-2 me-1" aria-hidden="true"></i> Chỉ
										đường <span class="visually-hidden"> (mở tab mới)</span>
									</a>
								</div>

							</c:if>
						</article>
					</div>
				</c:forEach>
			</div>

			<c:if test="${empty branches}">
				<p class="text-muted mb-0">Chưa có thông tin chi nhánh đang hoạt
					động.</p>
			</c:if>
		</c:if>
	</section>

</main>

<jsp:include page="fragments/footer.jsp" />