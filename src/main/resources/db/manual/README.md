# SQL schema cho PostgreSQL / Neon

`01_schema.sql` định nghĩa schema cho các bảng và cột mà ứng dụng Spring Boot
hiện ánh xạ qua JPA. Tên bảng/cột dùng tiếng Anh `snake_case`, khớp với
`@Table`, `@Column`, các quan hệ JPA và truy vấn native/`@Formula`.
`02_indexes.sql` tạo index hỗ trợ truy vấn của ứng dụng.

## Tối ưu truy vấn giao diện khách hàng

`11_customer_ui_query_indexes.sql` bổ sung một số index PostgreSQL cho các luồng
đọc thường dùng: duyệt/lọc sản phẩm đang bán, sắp xếp theo giá/ưa thích, kiểm tra
tồn kho theo chi nhánh, tra sản phẩm trong giỏ và xem lịch sử đơn theo trạng thái.
Chạy file này thủ công sau `01_schema.sql` và `02_indexes.sql` trên đúng database.
Các lệnh `CREATE INDEX IF NOT EXISTS` có thể chạy lại an toàn, nhưng index vẫn
tốn dung lượng và làm tăng nhẹ chi phí ghi/cập nhật dữ liệu.

Không partition `products`, `orders` hay `cart_items` chỉ để tăng tốc giao diện:
truy vấn hiện tại không lọc theo khóa ngày phân vùng nên PostgreSQL vẫn phải quét
các phân vùng; partition có thể làm truy vấn phức tạp hơn. Các tab bán chạy/đánh
giá dùng giá trị tổng hợp động, nên cần đo `EXPLAIN (ANALYZE, BUFFERS)` trên dữ
liệu thực trước khi chọn giải pháp tiếp theo. Redis hiện đã cache một số dữ liệu
catalog; sau khi thay đổi sản phẩm, cache catalog được xóa qua luồng quản trị.

## Tạo schema mới

Trên database/branch Neon mới hoặc đã được chủ dự án xóa và xác nhận rỗng:

1. Chạy toàn bộ `01_schema.sql`.
2. Chạy toàn bộ `02_indexes.sql`.
3. Nếu cần dữ liệu mẫu, chạy toàn bộ `04_seed_demo_data.sql`. Hai khách hàng
   `khach1@example.test` và `khach2@example.test` có mật khẩu `Demo@12345`.
   Mật khẩu admin/staff/shipper được tạo ngẫu nhiên; xem
   `private/04_seed_demo_accounts.txt` tính từ thư mục gốc project.
   Các file demo này được `.gitignore` bỏ qua; file tài khoản trong `private/`
   cũng được loại khỏi Docker/Vercel upload.

## Thêm dữ liệu demo vào database đang dùng

Chỉ chạy `04_seed_demo_data.sql` trên đúng database trong `DB_URL`, sau khi schema
đã có đầy đủ các cột hiện tại. Không chạy lại `01_schema.sql` để thêm dữ liệu.
Script tạo tối đa 9 tài khoản (7 hoạt động, 1 chưa kích hoạt, 1 bị khóa), 2 chi
nhánh demo, 6 sản phẩm, tồn kho ở các chi nhánh active và voucher `DEMO10`.
Nhân viên/shipper A và B được gán vào hai chi nhánh active có ID nhỏ nhất; xem
cột `branch` trong kết quả chạy SQL.

Các tài khoản có kết quả `TAO_MOI` dùng được mật khẩu trong file hướng dẫn.
Nếu email đã tồn tại, kết quả là `DA_CO_GIU_NGUYEN`: script giữ nguyên mật khẩu,
trạng thái và quyền, không tự mở khóa hoặc nâng quyền. Chạy lại không reset tồn
kho, lượt dùng/hạn voucher và không tạo đơn hàng hay giao dịch thanh toán giả.
Email `example.test` chỉ dùng cho form email/mật khẩu; không nhận được OTP email.
Thêm dữ liệu vào đúng database đang dùng không yêu cầu build/deploy lại website.

## 05 - Bổ sung catalog đầy đủ theo danh mục

Chạy toàn bộ `05_insert_full_catalog.sql` để thêm **32 danh mục, 96 sản phẩm
(3 sản phẩm/danh mục), 35 thương hiệu**, ảnh minh họa và tồn kho. File có thể
chạy độc lập trên schema hiện tại hoặc sau `04_seed_demo_data.sql`; không yêu
cầu tạo lại database và không tạo thêm tài khoản.

| Nhóm nội dung trên menu | Danh mục trong file 05 |
|---|---|
| Điện tử, điện lạnh | Tivi, Tủ lạnh, Máy giặt, Máy lạnh, Máy sấy quần áo, Tủ đông |
| Điện gia dụng | Nồi cơm điện, Lò vi sóng, Nồi chiên không dầu, Bình đun siêu tốc, Bếp từ, Bàn ủi |
| Dụng cụ nhà bếp | Chảo chống dính, Bộ nồi, Dao kéo nhà bếp, Hộp thực phẩm |
| Phụ kiện | Tai nghe, Pin sạc dự phòng, Cáp sạc |
| Nước uống | Máy lọc nước, Cây nước nóng lạnh |
| Quạt, làm mát | Quạt điện, Quạt điều hòa, Quạt trần |
| Vệ sinh, không khí | Máy hút bụi, Robot hút bụi, Máy lọc không khí, Máy hút ẩm |
| Xay ép | Máy xay sinh tố, Máy ép trái cây |
| Chăm sóc cá nhân | Máy sấy tóc |
| Âm thanh | Loa |

Các danh mục mới được tạo cùng cấp vì bộ lọc hiện tại so sánh trực tiếp
`categoryId`/`categorySlug`, chưa tự cộng sản phẩm từ danh mục con. Danh mục
đã có giữ nguyên trạng thái và quan hệ cha/con. Nếu tên/slug danh mục hoặc
SKU/slug sản phẩm xung đột với dữ liệu khác, script báo lỗi và rollback.

SKU của bộ dữ liệu bắt đầu bằng `CAT05-`, slug sản phẩm bắt đầu bằng
`catalog05-`. Script thêm kho cho các sản phẩm này tại mọi chi nhánh active;
nếu chưa có chi nhánh active thì tạo hai chi nhánh mẫu. Chạy lại giữ nguyên
giá, thông số, trạng thái, tồn kho và gallery đã chỉnh trước đó.

Giá, mã model TS và thông số là dữ liệu mô phỏng để demo, không phải báo giá
hoặc thông số cam kết của nhà sản xuất. Ảnh dùng các file sẵn có trong
`static/images/categories/`, chung cho các sản phẩm cùng danh mục; không cần
gọi API ảnh. File 05 không tạo đơn, thanh toán hay review giả, nên không tự
giả lập số bán/đánh giá cho các tab xếp hạng.

Ba link tại tab “Chương trình hot” hiện dùng từ khóa không dấu `noi com`,
`may xay`, `may loc nuoc`. Bộ lọc tên sản phẩm hiện chưa tìm kiếm không dấu;
các link này cần xử lý riêng ở menu hoặc logic tìm kiếm. Những danh mục và
từ khóa tiếng Việt tương ứng đã có dữ liệu trong file 05.

Không chạy `03_current_app_order_domain.sql` trên schema đã tạo bằng `01_schema.sql`:
đây là script cũ
chỉ tạo một phần bảng nghiệp vụ; `01_schema.sql` hiện đã bao gồm các bảng đó.
`04_guest_checkout_payment_links.sql` là migration dành cho database cũ. Schema
mới đã có `orders.recipient_email`, `payments.payment_url` và
`payments.payment_expires_at`, nên không cần chạy file này khi tạo database mới.

Các file SQL là thao tác thủ công, không tự chạy khi Spring Boot khởi động và
không tự xóa database Neon. Trước khi chạy SQL, bảo đảm đang chọn đúng project,
branch và database cho ứng dụng. Riêng `01_schema.sql` yêu cầu database rỗng.
Cấu hình các biến
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

## Thông báo khách hàng

Với database hiện có, chạy `12_customer_notifications.sql` một lần (script có
thể chạy lại an toàn) để tạo hộp thư thông báo và các index. Database mới có
thể dùng `01_schema.sql` rồi `02_indexes.sql`, trong đó đã có bảng và index này.
