<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Điều chuyển hàng liên chi nhánh</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
<div class="d-flex">
    <jsp:include page="fragments/sidebar.jsp"/>
    <main class="flex-grow-1 bg-light p-4" style="min-width:0">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="mb-1">Điều chuyển hàng liên chi nhánh</h3>
                <div class="text-secondary">Quy trình 2 đầu: Yêu cầu (Bên nhận) → Duyệt giữ hàng &amp; Xuất kho (Bên xuất) → Nghiệm thu (Bên nhận)</div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/inventory" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-boxes"></i> Về trang Tồn kho
            </a>
        </div>

        <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>

        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white fw-bold py-3">
                <i class="bi bi-plus-circle me-1"></i> Tạo phiếu yêu cầu điều chuyển mới
            </div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/admin/transfers" class="row g-3 align-items-end">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Chi nhánh xuất hàng</label>
                        <select class="form-select" name="fromBranchId" required>
                            <option value="">-- Chọn chi nhánh xuất --</option>
                            <c:forEach items="${branches}" var="b">
                                <c:if test="${empty actorBranch or actorBranch.id ne b.id or isAdmin}">
                                    <option value="${b.id}"><c:out value="${b.name}"/></option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Chi nhánh nhận hàng</label>
                        <c:choose>
                            <c:when test="${isAdmin}">
                                <select class="form-select" name="toBranchId" required>
                                    <option value="">-- Chọn chi nhánh nhận --</option>
                                    <c:forEach items="${branches}" var="b">
                                        <option value="${b.id}"><c:out value="${b.name}"/></option>
                                    </c:forEach>
                                </select>
                            </c:when>
                            <c:otherwise>
                                <input type="text" class="form-control bg-light" value="${actorBranch.name}" readonly>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Sản phẩm cần điều chuyển</label>
                        <select class="form-select" name="productId" required>
                            <option value="">-- Chọn sản phẩm --</option>
                            <c:forEach items="${products}" var="p">
                                <option value="${p.id}"><c:out value="${p.name}"/> (${p.sku})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-1">
                        <label class="form-label fw-semibold">Số lượng</label>
                        <input type="number" class="form-control" name="quantity" min="1" value="1" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Ghi chú</label>
                        <input type="text" class="form-control" name="note" placeholder="Lý do điều chuyển">
                    </div>
                    <div class="col-12">
                        <button class="btn btn-primary"><i class="bi bi-send"></i> Gửi yêu cầu điều chuyển</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>Mã phiếu</th>
                            <th>Sản phẩm</th>
                            <th>Từ CN (Xuất)</th>
                            <th>Đến CN (Nhận)</th>
                            <th class="text-center">SL Yêu cầu / Xuất / Nhận</th>
                            <th>Trạng thái</th>
                            <th style="min-width:300px">Thao tác nghiệp vụ</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${transfers}" var="t">
                        <tr>
                            <td>
                                <div class="fw-bold"><c:out value="${t.transferCode}"/></div>
                                <small class="text-secondary">${t.requestedAt}</small>
                            </td>
                            <td>
                                <div class="fw-semibold"><c:out value="${t.product.name}"/></div>
                                <small class="text-secondary">SKU: <c:out value="${t.product.sku}"/></small>
                            </td>
                            <td><c:out value="${t.fromBranch.name}"/></td>
                            <td><c:out value="${t.toBranch.name}"/></td>
                            <td class="text-center">
                                <span class="badge text-bg-secondary">YC: ${t.requestedQuantity}</span>
                                <c:if test="${not empty t.shippedQuantity}">
                                    <span class="badge text-bg-primary">Xuất: ${t.shippedQuantity}</span>
                                </c:if>
                                <c:if test="${not empty t.receivedGoodQuantity}">
                                    <span class="badge text-bg-success">Tốt: ${t.receivedGoodQuantity}</span>
                                </c:if>
                                <c:if test="${not empty t.receivedQuarantineQuantity and t.receivedQuarantineQuantity gt 0}">
                                    <span class="badge text-bg-danger">Lỗi: ${t.receivedQuarantineQuantity}</span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.status eq 'REQUESTED'}"><span class="badge text-bg-warning">Chờ CN Xuất duyệt</span></c:when>
                                    <c:when test="${t.status eq 'APPROVED'}"><span class="badge text-bg-info">Đã giữ hàng - Chờ xuất</span></c:when>
                                    <c:when test="${t.status eq 'IN_TRANSIT'}"><span class="badge text-bg-primary">Đang vận chuyển</span></c:when>
                                    <c:when test="${t.status eq 'RECEIVED'}"><span class="badge text-bg-success">Đã nhận đủ</span></c:when>
                                    <c:when test="${t.status eq 'DISPUTED'}"><span class="badge text-bg-danger">Lệch / Có hàng cách ly</span></c:when>
                                    <c:otherwise><span class="badge text-bg-secondary">${t.status}</span></c:otherwise>
                                </c:choose>
                                <c:if test="${not empty t.disputeNote}">
                                    <div class="small text-danger mt-1"><c:out value="${t.disputeNote}"/></div>
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${canApproveOrConfirm}">
                                    <c:if test="${t.status eq 'REQUESTED' and (isAdmin or actorBranch.id eq t.fromBranch.id)}">
                                        <div class="d-flex gap-2">
                                            <form method="post" action="${pageContext.request.contextPath}/admin/transfers/${t.id}/approve">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <input type="hidden" name="decision" value="APPROVED">
                                                <button class="btn btn-sm btn-success"><i class="bi bi-check-circle"></i> Duyệt &amp; Giữ hàng</button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/transfers/${t.id}/approve">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <input type="hidden" name="decision" value="REJECTED">
                                                <button class="btn btn-sm btn-outline-danger">Từ chối</button>
                                            </form>
                                        </div>
                                    </c:if>
                                    <c:if test="${t.status eq 'APPROVED' and (isAdmin or actorBranch.id eq t.fromBranch.id)}">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/transfers/${t.id}/ship">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button class="btn btn-sm btn-primary"><i class="bi bi-truck"></i> Xác nhận Xuất kho</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${t.status eq 'IN_TRANSIT' and (isAdmin or actorBranch.id eq t.toBranch.id)}">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/transfers/${t.id}/receive" class="row g-1">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <div class="col-6">
                                                <input type="number" class="form-control form-control-sm" name="goodQty" min="0" max="${t.shippedQuantity}" value="${t.shippedQuantity}" placeholder="SL Tốt" required>
                                            </div>
                                            <div class="col-6">
                                                <input type="number" class="form-control form-control-sm" name="quarantineQty" min="0" max="${t.shippedQuantity}" value="0" placeholder="SL Lỗi/Cách ly" required>
                                            </div>
                                            <div class="col-12">
                                                <input type="text" class="form-control form-control-sm" name="disputeNote" placeholder="Ghi chú biên bản (bắt buộc nếu lệch/lỗi)">
                                            </div>
                                            <div class="col-12">
                                                <button class="btn btn-sm btn-success w-100"><i class="bi bi-box-arrow-in-down"></i> Xác nhận Nhận hàng</button>
                                            </div>
                                        </form>
                                    </c:if>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty transfers}">
                        <tr><td colspan="7" class="text-center text-secondary py-5">Chưa có phiếu điều chuyển liên chi nhánh nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>
</body>
</html>