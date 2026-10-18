# Deploy lên Render

1. Push bản sửa lên branch Render đang theo dõi, rồi chọn **Deploy latest commit**.
   Chỉ xóa build cache khi đang xử lý lỗi cache.
2. Trong **Settings → Health Checks**, đặt **Health Check Path** là `/health`.
   Endpoint này chỉ trả HTTP 200 sau khi khởi động hoàn tất và lấy được kết nối
   database hợp lệ; khi chưa sẵn sàng hoặc pool đầy, nó trả HTTP 503.
3. Giữ các biến `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET` và
   `VNPAY_RETURN_URL` đã cấu hình. Ứng dụng đọc `PORT` do Render cung cấp.

## Bộ nhớ trên Render Free

Docker kích hoạt profile `render` và đặt `JAVA_TOOL_OPTIONS` để giới hạn heap
ở 192 MB, metaspace ở 128 MB, code cache ở 32 MB và direct memory ở 16 MB.
Serial GC, một CPU logic và C1 JIT giúp giảm chi phí bộ nhớ/khởi động trên
instance nhỏ. Tổng RAM thực tế vẫn bao gồm thread, thư viện và bộ nhớ native;
`-Xmx` không phải giới hạn RAM của cả tiến trình.

Profile Render dùng tối đa 12 thread Tomcat, 3 kết nối database và tắt kiểm tra
biên dịch lại JSP ở chế độ phát triển. `TOMCAT_MAX_THREADS` và `DB_POOL_SIZE`
cho phép thay đổi sau khi kiểm tra nhu cầu. Nếu đã đặt `SPRING_PROFILES_ACTIVE`
hoặc `JAVA_TOOL_OPTIONS` trên dashboard, các giá trị đó sẽ thay thế mặc định
trong Docker; cần giữ profile `render` và giới hạn JVM tương ứng.

Maven biên dịch toàn bộ JSP bằng JspC trong bước process-classes; lỗi JSP làm
build thất bại. Profile Render đăng ký các servlet đã biên dịch và tắt servlet
JSP mặc định, tránh biên dịch JSP khi đang nhận request. Khi khởi động phải có
log Registered 22 precompiled JSP servlets (số lượng đổi khi thêm/bớt trang).

Docker giải nén WAR tại build và khởi động thư mục đã giải nén bằng WarLauncher.
Các thư viện được đọc từ file JAR trực tiếp thay vì quét JAR lồng trong WAR.

Profile Render tự mở nội bộ trang chủ, sản phẩm và đăng nhập sau khi seed dữ
liệu, trước khi báo sẵn sàng. Trong bước này `/health` trả 503 và log có dòng
`Warming Render page`.
Khi có `Render pages are ready`, ứng dụng mới sẵn sàng nhận traffic. Nếu một
trang lỗi hoặc hết timeout 180 giây, startup thất bại để tránh báo Live sai.

Sau deploy, thử `/health`, trang chủ và đăng nhập, rồi kiểm tra Memory trong
Metrics. Nếu vẫn vượt giới hạn khi dùng thực tế, cần giảm thêm mức sử dụng
bộ nhớ hoặc dùng instance có RAM lớn hơn; deploy Live không xác nhận đủ RAM
cho mọi trang và mọi mức tải.

## Xác nhận bản đang chạy và request chậm

Build Docker ghi commit vào WAR. Mọi HTTP response có header X-App-Revision;
kiểm tra header của /health để đối chiếu với commit trên dashboard. Khi build
ngoài Render mà không truyền revision, header là diagnostics-v2. Header này
đến từ WAR thực tế, không lấy nhãn deploy ở runtime.

Log khởi động có dòng Deployment diagnostics-v2, gồm revision, instance,
profile, cờ warmup và heap tối đa. Đối chiếu instance trước khi đọc lỗi
port scan để tránh ghép log các lần khởi động khác nhau.

Nếu GET trang chủ, /products hoặc /login còn chờ sau 15 giây, log tự ghi
Slow page request và stack của thread đang xử lý. Khi request kết thúc,
log ghi Slow page completed. Chỉ ghi đường dẫn cố định và stack frame,
không ghi token, cookie, query string hay nội dung request.

## Chẩn đoán hết kết nối

- Pool local có tối đa 10 kết nối, profile Render mặc định 3. `DB_POOL_SIZE` cho phép thay đổi khi đã
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
