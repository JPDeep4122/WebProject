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
<div class="d-flex">
    <jsp:include page="fragments/sidebar.jsp"/>
    <main class="flex-grow-1 bg-light p-4" style="min-width:0">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="mb-1">Tồn kho chi nhánh</h3>
                <div class="text-secondary">Cập nhật tồn thực tế tại chi nhánh và tra cứu tồn khả dụng liên chi nhánh</div>
            </div>
            <div class="d-flex gap-2 align-items-center">
                <span class="badge text-bg-primary fs-6">${inventoryPage.totalElements} sản phẩm</span>
            </div>
        </div>

        <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
        <c:if test="${not empty warning}"><div class="alert alert-info"><i class="bi bi-info-circle me-1"></i><c:out value="${warning}"/></div></c:if>
        <c:if test="${canEditInventory}">
            <div class="alert alert-info">Nhập số tồn thực tế mới và lý do để lưu trực tiếp.
                Số tồn mới phải đủ cho hàng đang giữ và hàng cách ly. Các mục có <span class="text-danger">*</span> là bắt buộc.</div>
        </c:if>

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
                            <th class="text-center">Giữ ĐC cũ</th>
                            <th class="text-center">Cách ly</th>
                        </c:if>
                        <th class="text-center">Khả dụng</th>
                        <th>Cập nhật lúc</th>
                        <c:if test="${canEditInventory}"><th>Cập nhật tồn thực tế</th></c:if>
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
                            <td><small class="text-secondary"><i class="bi bi-clock me-1"></i><c:out value="${inventory.updatedAt}"/></small></td>
                            <c:if test="${canEditInventory}">
                                <td style="min-width:300px">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/inventory/${inventory.id}/stock" class="d-flex flex-column gap-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="expectedStock" value="${inventory.stockQuantity}">
                                        <c:if test="${not empty selectedBranchId}"><input type="hidden" name="branchId" value="${selectedBranchId}"></c:if>
                                        <div>
                                            <label for="stock-${inventory.id}" class="form-label small mb-1">Tồn thực tế mới <span class="text-danger">*</span></label>
                                            <input id="stock-${inventory.id}" name="newStock" type="number" class="form-control form-control-sm"
                                                   min="${inventory.totalHeldAndQuarantine}" max="2147483647" step="1" value="${inventory.stockQuantity}" required>
                                        </div>
                                        <div>
                                            <label for="stock-reason-${inventory.id}" class="form-label small mb-1">Lý do cập nhật <span class="text-danger">*</span></label>
                                            <input id="stock-reason-${inventory.id}" name="reason" class="form-control form-control-sm"
                                                   maxlength="500" placeholder="Ví dụ: nhập thêm hàng, kiểm kê thực tế" required>
                                        </div>
                                        <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-check-lg"></i> Lưu tồn kho</button>
                                    </form>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty inventoryPage.content}">
                        <tr><td colspan="${empty warning ? (canEditInventory ? 9 : 8) : 4}" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Không có dữ liệu tồn kho phù hợp.</td></tr>
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

    </main>
</div>
</body>
</html>
