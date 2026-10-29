<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu trả hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
<c:set var="canReviewReturns" value="${pageContext.request.isUserInRole('ADMIN') or pageContext.request.isUserInRole('BRANCH_MANAGER')}"/>
<div class="d-flex"><jsp:include page="fragments/sidebar.jsp"/>
<main class="flex-grow-1 bg-light p-4" style="min-width:0">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div><h3 class="mb-1">Yêu cầu trả hàng / hoàn tiền</h3><div class="text-secondary">Xét duyệt, nhận lại hàng, hoàn kho và ghi nhận hoàn tiền</div></div>
        <span class="badge text-bg-primary fs-6">${requestsPage.totalElements} yêu cầu</span>
    </div>
    <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
    <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
    <c:if test="${not empty warning}"><div class="alert alert-warning"><c:out value="${warning}"/></div></c:if>

    <div class="card border-0 shadow-sm mb-4"><div class="card-body">
        <form method="get" action="${pageContext.request.contextPath}/admin/returns" class="row g-3 align-items-end">
            <c:if test="${canChooseBranch}"><div class="col-md-4"><label class="form-label">Chi nhánh</label>
                <select class="form-select" name="branchId"><option value="">Tất cả chi nhánh</option>
                    <c:forEach items="${branches}" var="branch"><option value="${branch.id}" ${selectedBranchId eq branch.id ? 'selected' : ''}><c:out value="${branch.name}"/></option></c:forEach>
                </select></div></c:if>
            <div class="col-md-3"><label class="form-label">Trạng thái</label><select class="form-select" name="status">
                <option value="">Tất cả</option><c:forEach items="${statuses}" var="item"><option value="${item}" ${selectedStatus eq item.toString() ? 'selected' : ''}>${item}</option></c:forEach>
            </select></div>
            <div class="col-md-2"><label class="form-label">Số dòng</label><select class="form-select" name="size">
                <option value="10" ${pageSize eq 10 ? 'selected' : ''}>10</option><option value="20" ${pageSize eq 20 ? 'selected' : ''}>20</option><option value="50" ${pageSize eq 50 ? 'selected' : ''}>50</option>
            </select></div>
            <div class="col-md-3"><button class="btn btn-primary"><i class="bi bi-funnel"></i> Lọc</button> <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin/returns">Đặt lại</a></div>
        </form>
    </div></div>

    <div class="card border-0 shadow-sm"><div class="table-responsive"><table class="table table-hover align-middle mb-0">
        <thead class="table-dark"><tr><th>Đơn hàng</th><th>Khách hàng</th><th>Chi nhánh</th><th>Lý do</th><th class="text-end">Dự kiến hoàn</th><th>Trạng thái</th><th style="min-width:300px">Xét duyệt</th></tr></thead>
        <tbody><c:forEach items="${requestsPage.content}" var="request"><tr>
            <td><div class="fw-semibold"><c:out value="${request.order.orderCode}"/></div><small class="text-secondary">${request.requestedAt}</small></td>
            <td><div><c:out value="${request.requestedBy.fullName}"/></div><small class="text-secondary"><c:out value="${request.requestedBy.email}"/></small></td>
            <td><c:out value="${request.order.branch.name}" default="Chưa gán"/></td>
            <td style="min-width:240px"><c:out value="${request.reason}"/></td>
            <td class="text-end text-nowrap"><fmt:formatNumber value="${request.requestedRefundAmount}" type="number" groupingUsed="true"/> ₫</td>
            <td><c:choose><c:when test="${request.status eq 'PENDING'}"><span class="badge text-bg-warning">Chờ duyệt</span></c:when>
                <c:when test="${request.status eq 'APPROVED'}"><span class="badge text-bg-primary">Chờ nhận hàng</span></c:when>
                <c:when test="${request.status eq 'COMPLETED'}"><span class="badge text-bg-success">Đã hoàn tất</span></c:when>
                <c:otherwise><span class="badge text-bg-danger">Từ chối</span></c:otherwise></c:choose>
                <c:if test="${not empty request.reviewNote}"><div class="small text-secondary mt-1"><c:out value="${request.reviewNote}"/></div></c:if></td>
            <td><c:if test="${request.status eq 'PENDING' and canReviewReturns}">
                <form method="post" action="${pageContext.request.contextPath}/admin/returns/${request.id}/review" class="mb-2">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="decision" value="APPROVED"><input type="hidden" name="branchId" value="${selectedBranchId}">
                    <input class="form-control form-control-sm mb-2" name="reviewNote" maxlength="500" placeholder="Ghi chú duyệt (không bắt buộc)">
                    <button class="btn btn-sm btn-success w-100" onclick="return confirm('Duyệt yêu cầu trả hàng này?');"><i class="bi bi-check-circle"></i> Duyệt yêu cầu</button>
                </form>
                <form method="post" action="${pageContext.request.contextPath}/admin/returns/${request.id}/review">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="decision" value="REJECTED"><input type="hidden" name="branchId" value="${selectedBranchId}">
                    <input class="form-control form-control-sm mb-2" name="reviewNote" maxlength="500" placeholder="Lý do từ chối" required>
                    <button class="btn btn-sm btn-outline-danger w-100" onclick="return confirm('Từ chối yêu cầu trả hàng này?');"><i class="bi bi-x-circle"></i> Từ chối</button>
                </form></c:if>
                                <c:if test="${request.status eq 'APPROVED' and canReviewReturns}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/returns/${request.id}/complete">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="branchId" value="${selectedBranchId}">
                        <select class="form-select form-select-sm mb-2" name="disposition">
                            <option value="RESTOCK">Hàng nguyên vẹn — Nhập lại kho khả dụng</option>
                            <option value="QUARANTINE">Hàng lỗi/hỏng — Đưa vào kho cách ly</option>
                        </select>
                        <input class="form-control form-control-sm mb-2" name="completionNote" maxlength="500" placeholder="Ghi chú khi nhận lại hàng">
                        <button class="btn btn-sm btn-success w-100" onclick="return confirm('Xác nhận đã nhận hàng trả và hoàn tiền?');"><i class="bi bi-box-arrow-in-down"></i> Hoàn tất trả hàng</button>
                    </form>
                    <div class="small text-secondary mt-2">Đã duyệt bởi <c:out value="${request.reviewedBy.fullName}"/></div>
                </c:if>
                <c:if test="${not canReviewReturns and (request.status eq 'PENDING' or request.status eq 'APPROVED')}">
                    <span class="small text-secondary">Quản lý chi nhánh/Admin xử lý xét duyệt và hoàn tiền.</span>
                </c:if>
                <c:if test="${request.status eq 'REJECTED'}"><span class="small text-secondary">Đã từ chối bởi <c:out value="${request.reviewedBy.fullName}"/></span></c:if>
                <c:if test="${request.status eq 'COMPLETED'}">
                    <div class="small text-success fw-semibold">Đã hoàn <fmt:formatNumber value="${request.refundedAmount}" type="number" groupingUsed="true"/> ₫</div>
                    <div class="small text-secondary">Hoàn tất bởi <c:out value="${request.completedBy.fullName}"/> lúc ${request.completedAt}</div>
                    <c:if test="${not empty request.completionNote}"><div class="small text-secondary mt-1"><c:out value="${request.completionNote}"/></div></c:if>
                </c:if></td>
        </tr></c:forEach>
        <c:if test="${empty requestsPage.content}"><tr><td colspan="7" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Không có yêu cầu phù hợp.</td></tr></c:if></tbody>
    </table></div></div>
    <c:if test="${requestsPage.totalPages gt 1}"><nav class="mt-4"><ul class="pagination justify-content-center">
        <c:forEach begin="0" end="${requestsPage.totalPages - 1}" var="index"><c:url var="pageUrl" value="/admin/returns"><c:param name="page" value="${index}"/><c:param name="size" value="${pageSize}"/><c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}"/></c:if><c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if></c:url>
            <li class="page-item ${requestsPage.number eq index ? 'active' : ''}"><a class="page-link" href="${pageUrl}">${index + 1}</a></li></c:forEach>
    </ul></nav></c:if>
</main></div>
</body></html>
