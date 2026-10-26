# Quản lý tồn kho chi nhánh

Trang `/admin/inventory` cho phép ADMIN và STAFF xem tồn kho theo sản phẩm, tìm bằng tên hoặc SKU và điều chỉnh số lượng thực tế.

- ADMIN có thể chọn một chi nhánh hoặc xem toàn bộ hệ thống.
- STAFF luôn bị giới hạn trong chi nhánh được gán, kể cả khi tự sửa tham số URL.
- Tồn kho mới không được âm hoặc thấp hơn số lượng đang giữ chỗ.
- Mỗi thay đổi yêu cầu lý do và được ghi vào `inventory_adjustments` với số lượng trước/sau, người thực hiện và thời điểm.
- Bản ghi tồn kho được khóa khi điều chỉnh để tránh hai thao tác đồng thời ghi đè nhau.
