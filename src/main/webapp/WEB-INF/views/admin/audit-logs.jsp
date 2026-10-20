<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Audit log</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<jsp:include page="/WEB-INF/views/shared/security.jsp"/>
</head>
<body>
	<div class="d-flex"><jsp:include page="fragments/sidebar.jsp" /><main
			class="flex-grow-1 bg-light p-4">
			<h3>Nhật ký khuyến mãi và hệ thống</h3>
			<div class="card">
				<div class="table-responsive">
					<table class="table table-striped">
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
									<td>${log.action}</td>
									<td>${log.entityType}#${log.entityId}</td>
									<td>${log.actor}</td>
									<td>${log.details}</td>
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
