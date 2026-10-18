# Deploy lên Render

1. Push bản sửa lên branch Render đang theo dõi, rồi chọn **Deploy latest commit**.
   Chỉ xóa build cache khi đang xử lý lỗi cache.
2. Trong **Settings → Health Checks**, đặt **Health Check Path** là `/health`.
   Endpoint này chỉ trả HTTP 200 sau khi khởi động hoàn tất và lấy được kết nối
   database hợp lệ; khi chưa sẵn sàng hoặc pool đầy, nó trả HTTP 503.
3. Giữ các biến `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET` và
   `VNPAY_RETURN_URL` đã cấu hình. Ứng dụng đọc `PORT` do Render cung cấp.

## Chẩn đoán hết kết nối

- Pool mặc định vẫn có tối đa 10 kết nối. `DB_POOL_SIZE` cho phép thay đổi khi đã
  xác định nhu cầu; tăng pool không xử lý kết nối bị giữ lâu.
- `DB_LEAK_DETECTION_MS` mặc định `20000`: log ghi vị trí lấy kết nối nếu giữ
  quá 20 giây. Đây là cảnh báo chẩn đoán, không tự thu hồi kết nối đang dùng.
  Sau khi xử lý xong, đặt biến này bằng `0` để tắt cảnh báo.
- Nếu còn `Connection is not available`, tìm log
  `Connection leak detection triggered` / `Apparent connection leak detected`
  xuất hiện trước đó và đọc stack trace để xác định luồng đang giữ kết nối.
- Nếu SQL đang bị khóa hoặc chạy lâu, kiểm tra `pg_stat_activity` trên đúng
  database Neon; log Hikari đầy pool không tự xác định được nguyên nhân phía DB.

Các cuộc gọi SMTP và Google Maps đã được đưa ra ngoài transaction ghi dữ liệu.
Hibernate được cấu hình trả kết nối sau mỗi transaction, kể cả khi JSP vẫn dùng
Open-in-View. Truy vấn lấy chi nhánh cũng kết thúc trước khi gọi Google Maps.
SMTP có timeout 5 giây; Google Maps có connect timeout 5 giây và read timeout
10 giây; JDBC có connect timeout 10 giây và socket timeout 30 giây.

## Email OTP

`MAIL_USERNAME` và `MAIL_PASSWORD` cần được cấu hình để dùng Gmail SMTP ở môi
trường cho phép SMTP. Tài khoản và OTP được commit trước khi gửi mail; nếu gửi
thất bại, API báo thất bại và có thể yêu cầu gửi lại OTP.

Render Free chặn SMTP cổng 25, 465 và 587. Timeout giúp request thoát khi SMTP
không phản hồi; để gửi OTP trên gói này cần tích hợp dịch vụ email qua HTTPS.
Các thay đổi hiện tại chưa thêm nhà cung cấp email HTTPS.

Tham khảo:
- [Render health checks](https://render.com/docs/health-checks)
- [Render Free limitations](https://render.com/docs/free)
- [HikariCP configuration](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)
