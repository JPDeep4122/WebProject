# Xác nhận đơn hàng tại chi nhánh

1. Đăng nhập bằng tài khoản ADMIN hoặc STAFF đang hoạt động.
2. Mở `/admin/orders`, lọc trạng thái `PENDING`.
3. Bấm **Xác nhận đơn**. Khi đủ tồn kho, đơn chuyển sang `CONFIRMED`.
4. Với đơn `CONFIRMED`, bấm **Bắt đầu lấy hàng** để chuyển sang `PROCESSING`.

STAFF chỉ xác nhận đơn thuộc chi nhánh được gán. ADMIN có thể xác nhận ở mọi
chi nhánh. Đơn phải có chi nhánh, có sản phẩm và mỗi sản phẩm phải có bản ghi
trong `branch_inventory`.

Hàng có thể bán = `stock_quantity - reserved_quantity`. Khi xác nhận, hệ thống
trừ số lượng đặt khỏi `stock_quantity`, giữ nguyên lượng đã giữ chỗ cho các
nghiệp vụ khác và cập nhật `available_quantity`. Ví dụ tồn 10, giữ chỗ 2,
đơn đặt 3: sau xác nhận tồn 7, giữ chỗ 2, có thể bán 5.

Nếu bất kỳ sản phẩm nào thiếu hàng, toàn bộ đơn giữ nguyên trạng thái và tồn
kho. Các dòng trùng sản phẩm được cộng lại trước khi kiểm tra. Khóa đơn và
khóa tồn kho được giữ đến khi giao dịch kết thúc, tránh trừ hai lần và bán
vượt tồn kho khi nhiều người cùng thao tác.

Thanh toán VNPay thành công chỉ cập nhật thanh toán; đơn vẫn chờ chi nhánh
xác nhận tồn kho. Nút xác nhận có bảo vệ CSRF. Hủy đơn chờ xác nhận dùng cùng
khóa đơn để không tranh chấp với xác nhận.

State machine phần 1 chỉ cho phép `PENDING → CONFIRMED → PROCESSING`. Đơn
`PENDING` cũng có thể chuyển sang `CANCELLED` theo luồng khách hủy. Không thể
bỏ qua bước, lùi trạng thái hoặc thực hiện lại cùng một thao tác.

Kiểm thử tích hợp `OrderConfirmationTests` dùng H2 riêng, không thay đổi dữ
liệu ứng dụng. Các ca bao gồm xác nhận lặp, thiếu hàng, thiếu bản ghi tồn kho,
sai chi nhánh, tài khoản khóa, đơn đã hủy, sản phẩm trùng, xác nhận đồng thời
và hai đơn tranh hàng. `PaymentConfirmationTests` kiểm tra thanh toán không
bỏ qua bước xác nhận kho.

Không tự tạo số lượng tồn kho mẫu trong database thật. Dữ liệu cần được nhóm
nhập đúng vào `branch_inventory`; `branch_products` là bảng khác.
