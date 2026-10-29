# Quản lý tồn kho chi nhánh

Trang `/admin/inventory` cho phép ADMIN, BRANCH_MANAGER và STAFF xem tồn kho theo sản phẩm, tìm bằng tên hoặc SKU và sửa trực tiếp số lượng thực tế.

- ADMIN có thể chọn một chi nhánh hoặc xem toàn bộ hệ thống.
- STAFF và BRANCH_MANAGER chỉ được sửa chi nhánh của mình. Khi tra cứu chi nhánh khác, chỉ thấy tồn khả dụng và thông tin liên hệ; không có form sửa và backend từ chối yêu cầu sửa.
- Tồn kho mới không được âm hoặc thấp hơn tổng giữ đơn, giữ điều chuyển cũ và hàng cách ly.
- Mỗi thay đổi yêu cầu lý do và được ghi vào `inventory_adjustments` với số lượng trước/sau, người thực hiện và thời điểm.
- Bản ghi tồn kho được khóa khi cập nhật. Nếu số tồn đã đổi so với lúc mở form, hệ thống yêu cầu tải lại trang trước khi lưu.
- Thay đổi có hiệu lực ngay, không cần bước duyệt phiếu. Cache danh mục khách hàng được xóa sau khi cập nhật thành công.
- Luồng điều chuyển kho đã được gỡ khỏi giao diện và backend. Dữ liệu lịch sử và lượng hàng giữ từ phiếu cũ được giữ nguyên, không tự giải phóng hoặc xóa trong database.
