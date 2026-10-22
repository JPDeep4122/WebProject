<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

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
						<article class="border rounded-3 p-4 h-100">
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