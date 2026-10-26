# SQL schema cho PostgreSQL / Neon

Thư mục này lưu bộ SQL thủ công tạo schema theo sơ đồ `Untitled Diagram.drawio`.
Tên bảng dùng tiếng Việt không dấu để tránh vấn đề tương thích giữa PostgreSQL,
ORM và công cụ quản trị; tên cột dùng tiếng Anh theo `snake_case`.

## Thứ tự chạy

Trên một database Neon mới hoặc database đã được backup và chuẩn bị trước:

1. `01_schema.sql`
2. `02_indexes.sql`

Schema hiện hành của ứng dụng vẫn dùng tên bảng tiếng Anh. Để tạo riêng phần
nghiệp vụ của Thành viên 2 trên database ứng dụng hiện tại, chạy
`03_current_app_order_domain.sql` sau khi các bảng `users`, `branches` và
`products` đã tồn tại. Không chạy file này cùng `01_schema.sql`, vì hai bộ SQL
đại diện cho hai phương án đặt tên schema khác nhau.

Chạy bằng Neon SQL Editor hoặc `psql`. Các file này là DDL thủ công, không tự chạy
khi ứng dụng Spring Boot khởi động. Không chạy trực tiếp lên database đang có dữ
liệu trước khi so sánh schema và tạo backup.

Với database ứng dụng hiện tại đã có bảng `orders` và `payments`, chạy
`04_guest_checkout_payment_links.sql` trước khi deploy bản checkout mới. File này
cho phép đơn khách vãng lai không gắn tài khoản, thêm email liên hệ và lưu URL/
thời hạn thanh toán VNPay. Script có thể chạy lại và không chuyển quyền sở hữu
đơn cũ. Không cần chạy lại các script tạo schema 01–03 trên database đang hoạt động.

VNPay cần `VNPAY_TMN_CODE`, `VNPAY_HASH_SECRET` và `VNPAY_RETURN_URL`.
URL trả về phải khớp môi trường, ví dụ local là
`http://localhost:8080/payment/vnpay-return`, production là
`https://<ten-mien>/payment/vnpay-return`. Endpoint IPN hiện có vẫn là nơi cập nhật
kết quả thanh toán; URL trả về trình duyệt không tự đánh dấu đơn đã thanh toán.

Luồng tiếp tục thanh toán chỉ mở lại URL đã lưu khi đơn còn chờ thanh toán và
URL chưa hết hạn. Đơn cũ chưa có URL, đơn đã thất bại hoặc hết hạn không được tạo
lại giao dịch bằng cùng mã tham chiếu. Checkout kiểm tra tồn kho tại chi nhánh được
chọn; cơ chế trừ kho hiện tại vẫn chạy khi nhân viên xác nhận đơn, chưa giữ kho
trong suốt thời gian khách thanh toán.

## Nhận xét thiết kế và điều chỉnh

- Sơ đồ có nền tảng hợp lý: tách tài khoản/khách hàng, danh mục, sản phẩm, biến
  thể, tồn kho theo chi nhánh, giỏ hàng, đơn hàng, thanh toán, khuyến mãi và đánh giá.
- Quan hệ chi tiết giỏ hàng trong sơ đồ đang nối nhầm mã giỏ hàng với mã biến thể.
  Schema dùng `cart_id` và `variant_id` riêng.
- Tồn kho cần tham chiếu trực tiếp biến thể sản phẩm. Bảng giá trị thuộc tính chỉ
  mô tả biến thể thông qua bảng nối `bien_the_thuoc_tinh`.
- Chi tiết hóa đơn lưu biến thể cùng tên và SKU chụp tại thời điểm mua, để giá và
  tên lịch sử không đổi khi thông tin sản phẩm được sửa.
- Số lượng tồn được quản lý theo chi nhánh ở `ton_kho_chi_nhanh`, tránh lưu trùng
  ở cả biến thể và kho.
- Các trường sai/chưa nhất quán trong sơ đồ được chuẩn hóa sang `quantity`,
  `updated_at`, `created_at`, `discount_value` và các tên tiếng Anh tương ứng.

## Lưu ý với ứng dụng hiện tại

Các entity JPA hiện vẫn khai báo tên bảng tiếng Anh như `users`, `products`,
`orders` và còn có một số bảng nghiệp vụ chưa xuất hiện trong sơ đồ. Bộ SQL này
chưa được ánh xạ lại tự động sang các entity đó; cần cập nhật `@Table`, tên cột,
quan hệ và service/repository trước khi dùng bộ schema này làm database chạy ứng
dụng. Các file này cũng không di chuyển dữ liệu hiện có từ SQL Server hay schema
Neon cũ.
