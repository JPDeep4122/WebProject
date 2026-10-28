<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Nhật ký hệ thống</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
	<div class="d-flex"><jsp:include page="fragments/sidebar.jsp" /><main
			class="flex-grow-1 bg-light p-4">
			<h3>Nhật ký khuyến mãi và hệ thống</h3>
			<div class="card">
				<div class="table-responsive">
					<table class="table table-striped align-middle mb-0">
						<thead>
							<tr>
								<th>Thời gian</th>
								<th>Hành động</th>
								<th>Đối tượng</th>
								<th>Người thực hiện</th>
								<th>Chi tiết</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${logs}" var="log">
								<tr>
									<td>${log.createdAt}</td>
									<td><span class="badge bg-secondary">${log.action}</span></td>
									<td><code>${log.entityType}#${log.entityId}</code></td>
									<td>${log.actor}</td>
									<td>${log.details}</td>
								</tr>
							</c:forEach>
							<c:if test="${empty logs}">
								<tr>
									<td colspan="5" class="text-center text-muted py-4">Chưa có nhật ký nào.</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>

				<!-- ĐẶT card-footer BÊN TRONG THẺ card -->
				<c:if test="${logsPage.totalPages gt 1}">
					<div class="card-footer bg-white d-flex justify-content-between align-items-center py-2">
						<small class="text-muted">
							Hiển thị <b>${logsPage.numberOfElements}</b> / Tổng số <b>${logsPage.totalElements}</b> dòng nhật ký
						</small>
						<nav>
							<ul class="pagination pagination-sm justify-content-center mb-0">
								<li class="page-item ${logsPage.first ? 'disabled' : ''}">
									<a class="page-link" href="/admin/audit-logs?page=${logsPage.number - 1}">&laquo; Trước</a>
								</li>
								<c:forEach begin="0" end="${logsPage.totalPages - 1}" var="index">
									<li class="page-item ${logsPage.number eq index ? 'active' : ''}">
										<a class="page-link" href="/admin/audit-logs?page=${index}">${index + 1}</a>
									</li>
								</c:forEach>
								<li class="page-item ${logsPage.last ? 'disabled' : ''}">
									<a class="page-link" href="/admin/audit-logs?page=${logsPage.number + 1}">Sau &raquo;</a>
								</li>
							</ul>
						</nav>
					</div>
				</c:if>
			</div>
		</main>
	</div>
</body>
</html>