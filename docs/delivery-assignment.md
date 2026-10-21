# Phân công giao hàng thủ công

Trang `/admin/orders` cho phép ADMIN hoặc STAFF phân công đơn đang ở trạng thái
`PROCESSING` cho một tài khoản `ROLE_SHIPPER` đang hoạt động. Shipper phải thuộc
cùng chi nhánh với đơn hàng.

## Cách sử dụng

1. ADMIN tạo tài khoản shipper tại `/admin/users`, chọn vai trò **Shipper** và chi nhánh.
2. Xác nhận đơn và chuyển đơn sang bước chuẩn bị hàng.
3. Tại cột **Giao hàng**, chọn shipper rồi bấm **Phân công**.
4. Có thể đổi shipper khi đơn vẫn còn ở trạng thái `PROCESSING`.
5. Nút **Bắt đầu giao** chỉ xuất hiện sau khi đơn đã được phân công.

Service khóa bản ghi đơn trong lúc phân công để hai yêu cầu đồng thời không tạo
hai bản ghi `delivery_assignments` cho cùng một đơn.
