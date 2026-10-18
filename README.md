# VideoHub — WebProject_De04_new_5.10.26

- Sinh viên: Thái Đoàn Thịnh
- MSSV: 24133058
- Mã đề: Đề số 04
- Sản phẩm: Video

## Công nghệ

- Java 17
- Spring Boot 2.7.18
- Spring MVC, JSP, JSTL
- JDBC và SQL Server
- Bootstrap
- Maven
- VNPay Sandbox

## Chức năng

- Đăng ký, đăng nhập tài khoản.
- Hiển thị video theo danh mục và phân trang.
- Giỏ hàng: thêm, xóa, cập nhật số lượng trong giới hạn tồn kho.
- Đặt hàng bằng COD.
- Thanh toán trực tuyến qua VNPay Sandbox.
- Kiểm tra chữ ký và đối chiếu số tiền thanh toán VNPay.
- Lịch sử đặt hàng, lọc theo trạng thái:
  - Đơn hàng mới.
  - Đã xác nhận.
  - Chuẩn bị hàng.
  - Vận chuyển.
  - Giao hàng.
  - Đã giao.
  - Đơn hàng hủy.
  - Đơn hàng hoàn.
- Mở quyền xem video sau khi thanh toán VNPay thành công hoặc đơn COD đã giao.

## Cấu hình

Cấu hình chung nằm trong:

```text
src/main/resources/application.properties
```

Để dùng cấu hình riêng trên máy, thêm vào file trên:

```properties
spring.config.import=optional:file:./application-local.properties
```

Tạo `application-local.properties` tại thư mục gốc project, cùng cấp với `pom.xml`:

```properties
# VNPay Sandbox
vnpay.tmn-code=YOUR_SANDBOX_TMN_CODE
vnpay.hash-secret=YOUR_SANDBOX_HASH_SECRET
vnpay.pay-url=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
vnpay.return-url=http://localhost:8081/payment/vnpay-return

# Gmail App Password
spring.mail.password=....
```

## Kiểm thử chức năng

### Giỏ hàng

1. Mở danh sách video.
2. Thêm video vào giỏ.
3. Thay đổi số lượng và bấm cập nhật.
4. Thử nhập số lượng vượt tồn kho.
5. Xóa video khỏi giỏ.

Kết quả mong đợi: số lượng hợp lệ được cập nhật, số lượng vượt tồn kho bị từ chối.

### COD

1. Đăng nhập.
2. Thêm video vào giỏ.
3. Mở trang thanh toán và chọn COD.
4. Nhập thông tin nhận hàng rồi xác nhận.
5. Kiểm tra đơn trong lịch sử đặt hàng.

### VNPay Sandbox

1. Cấu hình đúng cặp TmnCode và HashSecret do VNPay Sandbox cấp.
2. Đăng nhập, thêm video vào giỏ và chọn VNPay.
3. Thanh toán trên trang Sandbox.
4. Quay lại website và kiểm tra trạng thái thanh toán.
5. Mở lịch sử đơn hàng để xem video đã mua.

Các endpoint:

```text
/payment/vnpay-return
/payment/vnpay-ipn
```

Return URL đưa trình duyệt về website. IPN cần địa chỉ HTTPS công khai để máy chủ VNPay gọi tới.

Nếu VNPay báo “Không tìm thấy website”, kiểm tra mã merchant Sandbox được cấp và môi trường đang sử dụng.

### Link video online

Upload video lên dịch vụ lưu trữ, lấy URL phát video và lưu vào cột `VideoUrl`:

```sql
UPDATE Videos
SET VideoUrl = N'https://your-host.example/video.mp4'
WHERE VideoId = 'V01';
```

Có thể sử dụng URL video Cloudinary hoặc URL nhúng YouTube:

```text
https://www.youtube.com/embed/VIDEO_ID
```

Cloudinary hiện có cấu hình thông tin kết nối; cấu hình này chưa tự tạo chức năng upload video trong website.

Quyền truy cập được kiểm tra theo tài khoản và đơn hàng. URL phát video vẫn có thể thấy từ trình duyệt; chức năng này không phải DRM.

### Lịch sử và trạng thái đơn hàng

1. Tạo đơn hàng.
2. Thay đổi cột `Status` trong bảng `Orders`.
3. Tải lại lịch sử và chọn bộ lọc tương ứng.

Giá trị trạng thái hợp lệ được định nghĩa trong:

```text
src/main/java/com/example/demo/model/OrderStatus_24133058.java
```

Trạng thái đơn hàng và trạng thái thanh toán được quản lý riêng.

## Cấu trúc chính

```text
src/main/java/com/example/demo/
├── controller/   # Xử lý request
├── dao/          # Truy cập database bằng JDBC
├── model/        # Video, giỏ hàng, đơn hàng và trạng thái
└── service/      # Xử lý nghiệp vụ và VNPay

src/main/resources/
└── application.properties

src/main/webapp/WEB-INF/views/
└── web/          # Giao diện JSP
```

## Tài liệu VNPay

- Đăng ký Sandbox: http://sandbox.vnpayment.vn/devreg/
- Tài liệu tích hợp: https://sandbox.vnpayment.vn/apis/docs/thanh-toan-pay/pay.html

## Lưu ý trước khi public repository

Không đưa mật khẩu database, Gmail App Password, Cloudinary API Secret hoặc VNPay HashSecret vào source và lịch sử Git.