<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tồn kho chi nhánh</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/shared/security.jsp"/>
    <jsp:include page="fragments/theme.jsp"/>
</head>
<body>
<c:set var="principalText">${pageContext.request.userPrincipal}</c:set>
<c:set var="canApproveInventory" value="${fn:contains(principalText, 'ROLE_ADMIN') or fn:contains(principalText, 'ROLE_BRANCH_MANAGER')}"/>
<div class="d-flex">
    <jsp:include page="fragments/sidebar.jsp"/>
    <main class="flex-grow-1 bg-light p-4" style="min-width:0">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="mb-1">Tồn kho chi nhánh</h3>
                <div class="text-secondary">Quản lý 5 thành phần tồn kho, tra cứu liên chi nhánh &amp; phê duyệt điều chỉnh kho</div>
            </div>
            <div class="d-flex gap-2 align-items-center">
                <a href="${pageContext.request.contextPath}/admin/transfers" class="btn btn-outline-primary btn-sm">
                    <i class="bi bi-arrow-left-right"></i> Phiếu điều chuyển liên chi nhánh
                </a>
                <span class="badge text-bg-primary fs-6">${inventoryPage.totalElements} sản phẩm</span>
            </div>
        </div>

        <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
        <c:if test="${not empty warning}"><div class="alert alert-info"><i class="bi bi-info-circle me-1"></i><c:out value="${warning}"/></div></c:if>

        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/inventory" class="row g-3 align-items-end">
                    <c:if test="${canChooseBranch}">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Chi nhánh</label>
                            <select class="form-select" name="branchId">
                                <option value="">Tất cả chi nhánh</option>
                                <c:forEach items="${branches}" var="branch">
                                    <option value="${branch.id}" ${selectedBranchId eq branch.id ? 'selected' : ''}>
                                        <c:out value="${branch.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Sản phẩm</label>
                        <input class="form-control" name="keyword" value="<c:out value='${keyword}'/>"
                               placeholder="Tên hoặc mã SKU">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Số dòng</label>
                        <select class="form-select" name="size">
                            <option value="10" ${pageSize eq 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${pageSize eq 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${pageSize eq 50 ? 'selected' : ''}>50</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button class="btn btn-primary"><i class="bi bi-search"></i> Lọc</button>
                        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin/inventory">Đặt lại</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card border-0 shadow-sm mb-4">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                    <tr>
                        <th>Sản phẩm</th>
                        <th>Chi nhánh &amp; Liên hệ</th>
                        <c:if test="${empty warning}">
                            <th class="text-center">Thực tế</th>
                            <th class="text-center">Giữ đơn</th>
                            <th class="text-center">Giữ ĐC</th>
                            <th class="text-center">Cách ly</th>
                        </c:if>
                        <th class="text-center">Khả dụng</th>
                        <th style="min-width:290px">${empty warning ? 'Lập phiếu điều chỉnh' : 'Cập nhật lúc'}</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${inventoryPage.content}" var="inventory">
                        <tr>
                            <td style="min-width:240px">
                                <div class="d-flex align-items-center gap-3">
                                    <c:if test="${not empty inventory.product.mainImageUrl}">
                                        <img src="${inventory.product.mainImageUrl}" alt="" width="48" height="48" class="rounded object-fit-cover">
                                    </c:if>
                                    <div><div class="fw-semibold"><c:out value="${inventory.product.name}"/></div>
                                        <small class="text-secondary">SKU: <c:out value="${inventory.product.sku}"/></small></div>
                                </div>
                            </td>
                            <td>
                                <div class="fw-semibold"><c:out value="${inventory.branch.name}"/></div>
                                <small class="text-secondary d-block"><c:out value="${inventory.branch.address}"/></small>
                                <c:if test="${not empty inventory.branch.phone}">
                                    <small class="text-primary"><i class="bi bi-telephone"></i> <c:out value="${inventory.branch.phone}"/></small>
                                </c:if>
                            </td>
                            <c:if test="${empty warning}">
                                <td class="text-center fs-5 fw-bold">${inventory.stockQuantity}</td>
                                <td class="text-center"><span class="badge text-bg-warning">${inventory.reservedQuantity}</span></td>
                                <td class="text-center"><span class="badge text-bg-info">${inventory.transferReservedQuantity}</span></td>
                                <td class="text-center"><span class="badge text-bg-secondary">${inventory.quarantineQuantity}</span></td>
                            </c:if>
                            <td class="text-center"><span class="badge ${inventory.availableQuantity le 2 ? 'text-bg-danger' : 'text-bg-success'} fs-6">${inventory.availableQuantity}</span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${empty warning}">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/inventory/${inventory.id}/adjust"
                                              class="row g-2" onsubmit="return confirm('Gửi phiếu yêu cầu điều chỉnh tồn kho cho sản phẩm này?');">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="branchId" value="${selectedBranchId}">
                                            <div class="col-4"><input class="form-control form-control-sm" type="number" name="newStock"
                                                 min="${inventory.totalHeldAndQuarantine}" value="${inventory.stockQuantity}" required aria-label="Tồn kho mới"></div>
                                            <div class="col-8"><input class="form-control form-control-sm" name="reason" maxlength="500"
                                                 placeholder="Lý do điều chỉnh" required></div>
                                            <div class="col-12"><button class="btn btn-sm btn-outline-primary w-100">
                                                <i class="bi bi-send-check"></i> Gửi yêu cầu điều chỉnh
                                            </button></div>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <small class="text-secondary"><i class="bi bi-clock me-1"></i><c:out value="${inventory.updatedAt}"/></small>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty inventoryPage.content}">
                        <tr><td colspan="8" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Không có dữ liệu tồn kho phù hợp.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <c:if test="${inventoryPage.totalPages gt 1}">
            <nav class="mb-4" aria-label="Phân trang tồn kho"><ul class="pagination justify-content-center flex-wrap">
                <c:url var="previousPageUrl" value="/admin/inventory">
                    <c:param name="page" value="${inventoryPage.number - 1}"/><c:param name="size" value="${pageSize}"/>
                    <c:param name="keyword" value="${keyword}"/>
                    <c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}"/></c:if>
                </c:url>
                <li class="page-item ${inventoryPage.first ? 'disabled' : ''}">
                    <a class="page-link" href="${previousPageUrl}" aria-label="Trang trước">‹</a>
                </li>
                <c:forEach items="${paginationPages}" var="pageNumber">
                    <c:if test="${pageNumber.gapBefore}"><li class="page-item disabled" aria-hidden="true"><span class="page-link">…</span></li></c:if>
                    <c:url var="pageUrl" value="/admin/inventory">
                        <c:param name="page" value="${pageNumber.index}"/><c:param name="size" value="${pageSize}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}"/></c:if>
                    </c:url>
                    <li class="page-item ${inventoryPage.number eq pageNumber.index ? 'active' : ''}"><a class="page-link" href="${pageUrl}">${pageNumber.index + 1}</a></li>
                </c:forEach>
                <c:url var="nextPageUrl" value="/admin/inventory">
                    <c:param name="page" value="${inventoryPage.number + 1}"/><c:param name="size" value="${pageSize}"/>
                    <c:param name="keyword" value="${keyword}"/>
                    <c:if test="${not empty selectedBranchId}"><c:param name="branchId" value="${selectedBranchId}"/></c:if>
                </c:url>
                <li class="page-item ${inventoryPage.last ? 'disabled' : ''}">
                    <a class="page-link" href="${nextPageUrl}" aria-label="Trang tiếp">›</a>
                </li>
            </ul></nav>
        </c:if>

        <c:if test="${empty warning}">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0"><i class="bi bi-clock-history"></i> Phiếu điều chỉnh kho gần đây (Maker-Checker)</h5>
                </div>
                <div class="table-responsive">
                    <table class="table table-sm align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Thời gian</th>
                                <th>Sản phẩm</th>
                                <th>Chi nhánh</th>
                                <th>Biến động (Δ)</th>
                                <th>Người lập</th>
                                <th>Lý do</th>
                                <th>Trạng thái</th>
                                <th>Phê duyệt</th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${adjustments}" var="item">
                            <tr>
                                <td class="text-nowrap small">${item.createdAt}</td>
                                <td><c:out value="${item.product.name}"/></td>
                                <td><c:out value="${item.branch.name}"/></td>
                                <td>
                                    <span class="fw-semibold">${item.previousStock}</span>
                                    <i class="bi bi-arrow-right"></i>
                                    <span class="fw-bold text-primary">${item.newStock}</span>
                                    <small class="text-secondary">(${item.deltaQuantity ge 0 ? '+' : ''}${item.deltaQuantity})</small>
                                </td>
                                <td><c:out value="${item.adjustedBy.fullName}"/></td>
                                <td><c:out value="${item.reason}"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.status eq 'PENDING'}"><span class="badge text-bg-warning">Chờ duyệt</span></c:when>
                                        <c:when test="${item.status eq 'APPROVED'}"><span class="badge text-bg-success">Đã duyệt</span></c:when>
                                        <c:otherwise><span class="badge text-bg-danger">Từ chối</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.status eq 'PENDING' and canApproveInventory}">
                                            <div class="d-flex gap-1">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/inventory/adjustments/${item.id}/review">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <input type="hidden" name="decision" value="APPROVED">
                                                    <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                    <button class="btn btn-sm btn-success"><i class="bi bi-check-lg"></i> Duyệt</button>
                                                </form>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/inventory/adjustments/${item.id}/review">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <input type="hidden" name="decision" value="REJECTED">
                                                    <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-x-lg"></i> Từ chối</button>
                                                </form>
                                            </div>
                                        </c:when>
                                        <c:when test="${not empty item.reviewedBy}">
                                            <small class="text-secondary"><c:out value="${item.reviewedBy.fullName}"/></small>
                                        </c:when>
                                        <c:otherwise>
                                            <small class="text-muted">Chờ Quản lý/Admin duyệt</small>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty adjustments}">
                            <tr><td colspan="8" class="text-center text-secondary py-4">Chưa có phiếu điều chỉnh kho.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>
    </main>
</div>
</body>
</html>
