<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="voucher-form-fields" data-voucher-form>

    <!-- NHÓM 1: ĐỊNH DANH & LOẠI VOUCHER -->
    <div class="voucher-form-group mb-3">
        <div class="voucher-form-group__title">
            <i class="bi bi-tag-fill text-primary me-1"></i> 1. Thông tin cơ bản &amp; Mức ưu đãi
        </div>
        <div class="row g-3">
            <div class="col-md-5">
                <label class="form-label fw-semibold small">Tên chương trình voucher <span class="text-danger">*</span></label>
                <input class="form-control" name="name" required maxlength="120"
                       placeholder="VD: Siêu sale Black Friday giảm 100.000đ"
                       value="<c:out value='${formPromotion.name}'/>">
            </div>

            <div class="col-md-4">
                <label class="form-label fw-semibold small">Mã voucher (Code) <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text bg-light fw-bold text-primary"><i class="bi bi-ticket-perforated"></i></span>
                    <input class="form-control text-uppercase fw-bold"
                           name="code"
                           required
                           maxlength="50"
                           pattern="[A-Za-z0-9][A-Za-z0-9_-]{1,49}"
                           placeholder="VD: TECH7SALE"
                           value="<c:out value='${formPromotion.code}'/>"
                           ${param.editMode == 'true' ? 'readonly' : ''}>
                </div>
            </div>

            <div class="col-md-3">
                <label class="form-label fw-semibold small">Loại ưu đãi <span class="text-danger">*</span></label>
                <select class="form-select fw-semibold" name="discountType" onchange="syncVoucherTypeFields(this)">
                    <option value="PERCENT" ${formPromotion.discountType == 'PERCENT' ? 'selected' : ''}>% Giảm theo phần trăm</option>
                    <option value="FIXED" ${formPromotion.discountType == 'FIXED' or empty formPromotion.discountType ? 'selected' : ''}>
                        ₫ Giảm số tiền cố định
                    </option>
                    <option value="SHIPPING" ${formPromotion.discountType == 'SHIPPING' ? 'selected' : ''}>
                        🚚 Miễn/Giảm phí vận chuyển
                    </option>
                </select>
            </div>

            <!-- Trường nhập thay đổi theo loại voucher. -->
                <div class="col-md-4" data-field-role="percent">
                    <label class="form-label fw-semibold small">Phần trăm giảm <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <input class="form-control" name="discountPercent"
                               type="number" min="0.01" max="100" step="0.01"
                               data-voucher-required="true"
                               value="${formPromotion.discountPercent}">
                        <span class="input-group-text fw-bold">%</span>
                    </div>
                </div>
            <!-- Ô Số tiền giảm cố định (Chỉ hiện khi chọn FIXED) -->
            <div class="col-md-4" data-field-role="fixed">
                <label class="form-label fw-semibold small">Số tiền giảm cố định <span class="text-danger">*</span></label>
                <div class="input-group">
                    <input class="form-control" name="discountAmount"
                           type="number" min="1" step="1"
                           data-voucher-required="true"
                           placeholder="VD: 100000"
                           value="${formPromotion.discountAmount}">
                    <span class="input-group-text fw-bold">₫</span>
                </div>
            </div>

            <!-- Thông báo khi chọn SHIPPING -->
            <div class="col-md-4 d-none" data-field-role="shipping-info">
                <label class="form-label fw-semibold small">Cơ chế giảm phí giao hàng</label>
                <div class="form-control bg-info-subtle text-info-emphasis border-info-subtle small d-flex align-items-center gap-2">
                    <i class="bi bi-truck fs-5"></i>
                    <span>Tự động giảm theo phí ship thực tế của đơn</span>
                </div>
            </div>

            <div class="col-md-4" data-field-role="max-discount">
                <label class="form-label fw-semibold small">Mức giảm tối đa <span class="text-muted fw-normal">(Trống = Không trần)</span></label>
                <div class="input-group">
                    <input class="form-control" name="maxDiscountAmount"
                           type="number" min="0.01" step="0.01"
                           placeholder="Không giới hạn"
                           value="${formPromotion.maxDiscountAmount}">
                    <span class="input-group-text">₫</span>
                </div>
            </div>

            <div class="col-md-4">
                <label class="form-label fw-semibold small">Đơn hàng tối thiểu <span class="text-danger">*</span></label>
                <div class="input-group">
                    <input class="form-control" name="minOrderAmount"
                           type="number" min="0" step="0.01" required
                           value="${not empty formPromotion.minOrderAmount ? formPromotion.minOrderAmount : 0}">
                    <span class="input-group-text">₫</span>
                </div>
            </div>
        </div>
    </div>

    <!-- NHÓM 2: ĐIỀU KIỆN SỬ DỤNG & THỜI HẠN -->
    <div class="voucher-form-group mb-3">
        <div class="voucher-form-group__title">
            <i class="bi bi-sliders text-primary me-1"></i> 2. Giới hạn lượt dùng, Thanh toán &amp; Thời gian hiệu lực
        </div>
        <div class="row g-3">
            <div class="col-md-3">
                <label class="form-label fw-semibold small">Phương thức thanh toán</label>
                <select class="form-select" name="requiredPaymentMethod">
                    <option value="">Tất cả (COD &amp; VNPay)</option>
                    <option value="COD" ${formPromotion.requiredPaymentMethod == 'COD' ? 'selected' : ''}>
                        Chỉ áp dụng COD
                    </option>
                    <option value="VNPAY" ${formPromotion.requiredPaymentMethod == 'VNPAY' ? 'selected' : ''}>
                        Chỉ áp dụng VNPay
                    </option>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label fw-semibold small">Tổng số lượt</label>
                <input class="form-control" name="maxUses"
                       type="number" min="1" step="1"
                       placeholder="Vô hạn"
                       value="${formPromotion.maxUses}">
                <small class="form-text text-muted">Để trống = không giới hạn; nếu nhập, tối thiểu 1 lượt.</small>
            </div>

            <div class="col-md-2">
                <label class="form-label fw-semibold small">Lượt / 1 khách</label>
                <input class="form-control" name="perUserLimit"
                       type="number" min="1" step="1"
                       placeholder="Vô hạn"
                       value="${formPromotion.perUserLimit}">
                <small class="form-text text-muted">Để trống = không giới hạn; nếu nhập, tối thiểu 1 lượt.</small>
            </div>

            <div class="col-md-5">
                <div class="row g-2">
                    <div class="col-sm-6">
                        <label class="form-label fw-semibold small">Bắt đầu (Giờ VN)</label>
                        <input class="form-control" name="startsAt"
                               type="datetime-local" step="1"
                               value="${fn:substring(formPromotion.startsAt, 0, 19)}">
                    </div>
                    <div class="col-sm-6">
                        <label class="form-label fw-semibold small">Kết thúc (Giờ VN)</label>
                        <input class="form-control" name="endsAt"
                               type="datetime-local" step="1"
                               value="${fn:substring(formPromotion.endsAt, 0, 19)}">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- NHÓM 3: PHẠM VI DANH MỤC & CỜ TRẠNG THÁI -->
    <div class="voucher-form-group">
        <input type="hidden" name="_categoryIds" value="on">

        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-2">
            <div class="voucher-form-group__title mb-0">
                <i class="bi bi-grid-3x3-gap-fill text-primary me-1"></i> 3. Danh mục áp dụng
                <span class="badge bg-primary-subtle text-primary ms-2 fw-semibold" data-cat-counter>
                    Không chọn = Áp dụng tất cả ngành hàng
                </span>
            </div>

            <div class="d-flex align-items-center gap-2">
                <input type="search" class="form-control form-control-sm" style="width: 190px;"
                       placeholder="Tìm nhanh danh mục..."
                       oninput="filterCategoryChips(this)">
                <button type="button" class="btn btn-sm btn-outline-secondary"
                        onclick="setAllCategoryChips(this, true)">Chọn hết</button>
                <button type="button" class="btn btn-sm btn-outline-secondary"
                        onclick="setAllCategoryChips(this, false)">Bỏ chọn (Toàn sàn)</button>
            </div>
        </div>

        <div class="voucher-cat-box">
            <c:forEach items="${categories}" var="category">
                <label class="voucher-cat-chip" data-cat-name="<c:out value='${category.name}'/>">
                    <input type="checkbox" name="categoryIds"
                           value="${category.id}"
                           onchange="updateCategoryCounter(this.closest('[data-voucher-form]'))"
                           ${formPromotion.categoryIds.contains(category.id) ? 'checked' : ''}>
                    <span><c:out value="${category.name}"/></span>
                </label>
            </c:forEach>
        </div>

        <div class="d-flex flex-wrap align-items-center gap-4 mt-3 pt-2 border-top">
            <div>
                <input type="hidden" name="_newCustomerOnly" value="on">
                <label class="form-check form-switch d-inline-flex align-items-center gap-2 mb-0 cursor-pointer">
                    <input class="form-check-input" type="checkbox" role="switch"
                           name="newCustomerOnly" value="true"
                           ${formPromotion.newCustomerOnly ? 'checked' : ''}>
                    <span class="fw-semibold small">Chỉ dành cho khách hàng mới (Chưa từng đặt đơn)</span>
                </label>
            </div>

            <div>
                <input type="hidden" name="_active" value="on">
                <label class="form-check form-switch d-inline-flex align-items-center gap-2 mb-0 cursor-pointer">
                    <input class="form-check-input" type="checkbox" role="switch"
                           name="active" value="true"
                           ${formPromotion.active ? 'checked' : ''}>
                    <span class="fw-semibold small text-success">Kích hoạt sử dụng ngay</span>
                </label>
            </div>
        </div>
    </div>

</div>
