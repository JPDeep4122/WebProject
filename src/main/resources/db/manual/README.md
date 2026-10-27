# SQL schema cho PostgreSQL / Neon

`01_schema.sql` định nghĩa schema cho các bảng và cột mà ứng dụng Spring Boot
hiện ánh xạ qua JPA. Tên bảng/cột dùng tiếng Anh `snake_case`, khớp với
`@Table`, `@Column`, các quan hệ JPA và truy vấn native/`@Formula`.
`02_indexes.sql` tạo index hỗ trợ truy vấn của ứng dụng.

## Tạo schema mới

Trên database/branch Neon mới hoặc đã được chủ dự án xóa và xác nhận rỗng:

1. Chạy toàn bộ `01_schema.sql`.
2. Chạy toàn bộ `02_indexes.sql`.
3. Nếu cần dữ liệu mẫu, chạy `04_seed_demo_data.sql` (mật khẩu demo là
   `Demo@12345`). File seed trong máy cá nhân có thể bị `.gitignore` bỏ qua.

Không chạy `03_current_app_order_domain.sql` sau hai bước trên: đây là script cũ
chỉ tạo một phần bảng nghiệp vụ; `01_schema.sql` hiện đã bao gồm các bảng đó.
`04_guest_checkout_payment_links.sql` là migration dành cho database cũ. Schema
mới đã có `orders.recipient_email`, `payments.payment_url` và
`payments.payment_expires_at`, nên không cần chạy file này khi tạo database mới.

Các file SQL là thao tác thủ công, không tự chạy khi Spring Boot khởi động và
không tự xóa database Neon. Trước khi chạy DDL, bảo đảm đang chọn đúng project,
branch và database cho ứng dụng, đồng thời database rỗng. Cấu hình các biến
`DB_URL`, `DB_USERNAME` và `DB_PASSWORD` trỏ tới đúng database đó trong Vercel.

VNPay cần `VNPAY_TMN_CODE`, `VNPAY_HASH_SECRET` và `VNPAY_RETURN_URL`. URL trả về
phải khớp môi trường, ví dụ local là
`http://localhost:8080/payment/vnpay-return`, production là
`https://<ten-mien>/payment/vnpay-return`. Endpoint IPN hiện có vẫn là nơi cập
nhật kết quả thanh toán; URL trả về trình duyệt không tự đánh dấu đơn đã thanh
toán.

Luồng tiếp tục thanh toán chỉ mở lại URL đã lưu khi đơn còn chờ thanh toán và URL
chưa hết hạn. Đơn cũ chưa có URL, đơn đã thất bại hoặc hết hạn không được tạo lại
giao dịch bằng cùng mã tham chiếu. Checkout kiểm tra tồn kho tại chi nhánh được
chọn; cơ chế trừ kho hiện tại vẫn chạy khi nhân viên xác nhận đơn, chưa giữ kho
trong suốt thời gian khách thanh toán.

## Lưu ý

Schema bao gồm các bảng hiện có trong entity JPA, kể cả `users.is_blocked` để
tránh lỗi đăng nhập do thiếu cột. Khi entity thay đổi, cần cập nhật migration SQL
tương ứng. Không xem `spring.jpa.hibernate.ddl-auto=update` là migration đã được
quản lý cho production. Các file này không di chuyển dữ liệu từ SQL Server hay
schema Neon cũ.
