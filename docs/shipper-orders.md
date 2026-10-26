# Danh sách đơn giao của shipper

Trang `/shipper/orders` dành riêng cho tài khoản có vai trò `ROLE_SHIPPER`.
Mỗi shipper chỉ xem được các bản ghi `delivery_assignments` gắn với email đăng nhập
của mình.

Trang hiển thị mã đơn, người nhận, số điện thoại, địa chỉ giao, chi nhánh lấy hàng,
số tiền cần thu, phương thức thanh toán, thời điểm phân công và trạng thái giao hàng.
Danh sách hỗ trợ lọc theo `DeliveryStatus`, phân trang và sắp xếp đơn mới được phân
công trước.

Các đường dẫn `/shipper/**` được bảo vệ bằng Spring Security và chỉ chấp nhận vai
trò `SHIPPER`.
