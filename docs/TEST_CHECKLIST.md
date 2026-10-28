# TECHSEVEN — Checklist kiểm thử theo source hiện tại

Ngày lập: 27/10/2026. Đối chiếu controller, service, cấu hình và 21 file test Java hiện có, bao gồm bản sửa hủy đơn PENDING chưa commit.

Tài liệu gồm **160 ca kiểm thử**, chia theo chức năng và mức ưu tiên, cùng **6 giới hạn cần ghi nhận riêng**. Mỗi dòng là một kịch bản; những dòng có nhiều dữ liệu biên nên được tách thành từng lần chạy trong báo cáo kết quả.

**Các kết quả mong đợi bên dưới là tiêu chí để kiểm thử, không phải xác nhận mọi ca đã đạt.** Lượt lập checklist này chưa chạy lại bộ test, chưa kiểm thử browser, chưa gọi dịch vụ thật và chưa thay đổi dữ liệu Neon.

Bằng chứng chạy tự động gần nhất: `mvn verify`, **131 lượt test, 0 failure, 0 error**. Các test tích hợp dùng H2/mocks hoặc server kiểm thử; kết quả đó không thay thế việc kiểm thử trên PostgreSQL và môi trường deploy thật.

## 1. Cách dùng checklist

| Mức | Ý nghĩa |
|---|---|
| P0 | Tiền, kho, quyền truy cập hoặc dữ liệu quan trọng: cần kiểm tra trước khi đưa bản mới vào sử dụng |
| P1 | Chức năng chính, dữ liệu đầu vào và tích hợp: cần kiểm tra trước demo/release |
| P2 | Trải nghiệm, trình bày và độ bền: kiểm tra sau các ca quan trọng |

Với mỗi ID, ghi một trạng thái: **CHƯA TEST / PASS / FAIL / BLOCKED**. `BLOCKED` dùng khi thiếu cấu hình, tài khoản hoặc dịch vụ ngoài; không đánh PASS cho ca chưa thực hiện được.

Khi FAIL, lưu URL, vai trò đang dùng, dữ liệu đầu vào, bước tái hiện, kết quả thực tế, screenshot/log đã bỏ secret, mã đơn và thay đổi database liên quan. Phải kiểm cả dữ liệu sau thao tác, không chỉ thông báo thành công trên giao diện.

Các ca thay đổi kho, khóa user, đặt/trả hàng và thay cấu hình nên chạy trên môi trường test/database test, với VNPay sandbox. Mỗi ca tiền/kho cần một bộ dữ liệu hoặc đơn mới; không dùng kết quả của ca trước làm baseline ngoài ý muốn.

### 1.1. Dữ liệu nên chuẩn bị

| Dữ liệu | Chuẩn bị |
|---|---|
| Tài khoản | Admin; customer A và B; staff A/B; shipper A/B; một tài khoản chờ OTP; một tài khoản bị khóa |
| Chi nhánh | A và B đều hoạt động, có tỉnh/thành; một chi nhánh ngừng hoạt động |
| Kho | Sản phẩm S: stock 10, reserved 2, available 8 ở A; dữ liệu tồn khác ở B |
| Sản phẩm | S đang bán; một sản phẩm hết hàng; một sản phẩm ngừng bán; một sản phẩm không có khuyến mãi |
| Khuyến mãi | Mã 10% đang hiệu lực; hết hạn; chưa bắt đầu; đã tắt; còn đúng 1 lượt |
| Đơn hàng | Các đơn độc lập ở PENDING, CONFIRMED, PROCESSING, SHIPPING, DELIVERED, CANCELLED |
| Thanh toán | COD/PENDING; VNPay/PENDING; VNPay/SUCCESS; FAILED; URL còn hạn và hết hạn |
| Tích hợp | SMTP test, Google login hợp lệ, Firebase phone test đã cấu hình, Cloudinary, Routes API, Gemini, VNPay sandbox |
| Trình duyệt | Hai browser profile hoặc một cửa sổ thường + một ẩn danh để tách tài khoản/session |

### 1.2. Hai bảng đối chiếu tiền/kho

**Kho của đơn mua 3 sản phẩm S tại A:**

| Mốc | Stock | Reserved | Available |
|---|---:|---:|---:|
| Ban đầu | 10 | 2 | 8 |
| Tạo đơn PENDING | 10 | 2 | 8 |
| Hủy ngay khi PENDING | 10 | 2 | 8 |
| Xác nhận một đơn mới mua 3 | 7 | 2 | 5 |
| Hủy hợp lệ đơn đã xác nhận đó | 10 | 2 | 8 |

Hủy lặp không được thay đổi kho. Checkout hiện chưa giữ kho theo đơn trong thời gian chờ thanh toán; xem phần giới hạn cuối tài liệu.

**Ví dụ tính tiền:** giá gốc 1.000.000, giá bán 1.000.000, giá giảm 900.000; mua 2; voucher 10%; phí ship 15.000:

```text
Giá áp dụng     = 900.000
Subtotal       = 1.800.000
Discount       = 180.000
Final amount   = 1.800.000 + 15.000 - 180.000 = 1.635.000
vnp_Amount     = 163500000
```

Phí ship 15.000 trong ví dụ phải được tạo bằng quote phù hợp hoặc fixture test; không mặc định mọi địa chỉ đều có phí này.

## 2. Danh sách nên chạy trước

Nếu đang chuẩn bị demo/release, làm trước các ca này, sau đó tiếp tục checklist đầy đủ:

1. DEP-01, DEP-02: website, database và schema hoạt động.
2. AUTH-03: login email đúng và sai.
3. SEC-04: tài khoản A không xem/thanh toán đơn B.
4. SEC-05: staff A không được xem trực tiếp chi tiết đơn chi nhánh B.
5. CART-01, CART-04: thêm/cập nhật giỏ và kiểm tra giới hạn tồn.
6. CHECK-01, CHECK-03: tạo đơn COD và đối chiếu tiền.
7. CHECK-04: guest nhập email trùng tài khoản khác.
8. STOCK-01, STOCK-02: hủy PENDING và hủy sau xác nhận.
9. PAY-01, PAY-02: VNPay thành công và thất bại/hủy.
10. PAY-05: chưa thanh toán không được giao đơn VNPay.
11. DELIVERY-01: nhân viên phân công, shipper giao thành công.
12. RACE-01, RACE-02: hai checkout/xác nhận đồng thời không tạo/trừ hai lần.

## 3. Bảo mật và phân quyền

Nguồn: [SecurityConfig.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/security/SecurityConfig.java), [AuthTokenFilter.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/security/jwt/AuthTokenFilter.java), [AdminOrderController.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/controller/admin/AdminOrderController.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| SEC-01 | P0 | Chưa đăng nhập, mở trực tiếp trang quản trị, shipper, hồ sơ; gọi POST quản trị bằng API client. | Bị yêu cầu đăng nhập hoặc từ chối quyền; dữ liệu không thay đổi. |
| SEC-02 | P0 | Dùng customer gọi URL/API admin; staff gọi quản lý user/danh mục; shipper gọi thao tác nhân viên. | Từ chối các chức năng ngoài vai trò theo chính sách SecurityConfig; ẩn menu không phải kiểm tra đủ. |
| SEC-03 | P0 | Dùng JWT sai chữ ký, bị sửa payload hoặc hết hạn để truy cập chức năng cần đăng nhập. | Không được coi là người đã xác thực; không lộ dữ liệu cần bảo vệ. |
| SEC-04 | P0 | Đăng nhập A, thay mã đơn trong URL chi tiết, hủy, trả hàng và tiếp tục thanh toán thành đơn của B. | Không đọc/sửa được đơn B; API/view phản hồi lỗi phù hợp và dữ liệu B giữ nguyên. |
| SEC-05 | P0 | Đăng nhập staff A, nhập thẳng `/admin/orders/{id}` của đơn chi nhánh B; làm tương tự với các POST xử lý đơn. | Không được xem dữ liệu hoặc thao tác ngoài chi nhánh. **Điểm nghi ngờ hiện tại:** method `orderDetail()` chưa kiểm branch dù màn danh sách có lọc. Cần ghi bug nếu xem được. |
| SEC-06 | P0 | Staff sửa `branchId`/`shipperId` trong request phân công hoặc điều chỉnh kho sang chi nhánh khác. | Không vượt phạm vi chi nhánh; không có thay đổi DB ngoài quyền. |
| SEC-07 | P0 | Gửi POST/PUT/DELETE có cookie đăng nhập nhưng thiếu hoặc sai CSRF token. | Request thay đổi dữ liệu bị từ chối; request hợp lệ có token vẫn chạy. |
| SEC-08 | P0 | Admin khóa một user; dùng lại token cũ của user cho trang/API cần đăng nhập. | User bị khóa không tiếp tục thao tác được; kiểm cả HTTP và kết nối realtime ở RT-05. |
| SEC-09 | P0 | Trong form hồ sơ, gửi thêm ID/email/role/active/password của người khác. | Chỉ cập nhật field cho phép của đúng principal; không đổi danh tính, quyền hoặc mật khẩu ngoài form được thiết kế. |
| SEC-10 | P1 | Nhập tên/bình luận có ký tự HTML và chuỗi JavaScript thử nghiệm trên môi trường test; kiểm trang công khai/admin. | Hiển thị như dữ liệu, không thực thi script; không có lỗi 500 hoặc lộ stack trace/secret. |

## 4. Đăng ký, đăng nhập và OTP email

Nguồn: [AuthServiceImpl.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/AuthServiceImpl.java), [RegisterRequest.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/dto/auth/RegisterRequest.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| AUTH-01 | P1 | Đăng ký email mới và dữ liệu hợp lệ; xem email gửi tới. | Tạo tài khoản chưa active, password lưu dạng hash, nhận OTP cho đúng địa chỉ; role mặc định customer. |
| AUTH-02 | P1 | Bỏ trống tên/email/phone; email sai; password 5 ký tự rồi 6 ký tự; đăng ký lại email đã active. | Bắt lỗi theo DTO/chính sách hiện tại; không ghi user trùng. Register hiện min 6, khác form đổi mật khẩu min 8. |
| AUTH-03 | P0 | Login email/password đúng, password sai, user không tồn tại; kiểm cookie/header và trang sau login. | Chỉ thông tin đúng mới được cấp JWT và truy cập chức năng của tài khoản; không thành công giả trên UI. |
| AUTH-04 | P0 | Login khi chưa xác thực; login user bị khóa; thử đăng ký/gửi OTP cho user bị khóa. | Không cấp quyền đăng nhập và không mở khóa tài khoản qua OTP. |
| AUTH-05 | P1 | Xác thực OTP đúng; sau đó dùng lại đúng OTP một lần nữa. | Chỉ lần hợp lệ đầu được consume/kích hoạt; OTP đã dùng không còn hiệu lực. |
| AUTH-06 | P0 | Nhập OTP sai 5 lần, rồi nhập mã đúng ở lần tiếp theo. | Tăng failedAttempts, mã bị vô hiệu hóa sau giới hạn; mã đúng không vượt được giới hạn đã khóa. |
| AUTH-07 | P1 | Dùng OTP quá 5 phút; xin mã mới rồi thử mã cũ. | Mã hết hạn hoặc mã cũ bị từ chối; chỉ mã mới nhất hợp lệ mới được dùng. |
| AUTH-08 | P1 | Gửi lại trước 60 giây, sau 60 giây; đạt giới hạn 5 lần/email/giờ rồi gửi thêm. | Giới hạn được thực thi ở backend, có thông báo; gửi ở các request/browser khác không được bỏ qua giới hạn DB. |
| AUTH-09 | P0 | Xin mã mới, consume mã mới, sau đó thử lại mã cũ chưa dùng; dùng OTP REGISTER cho reset password và ngược lại. | Không tái sử dụng được OTP cũ hoặc sai mục đích. |
| AUTH-10 | P1 | Quên/reset mật khẩu bằng OTP đúng/sai/hết hạn; login bằng mật khẩu cũ và mới sau reset. | Chỉ mã đúng cho phép đổi; password mới dùng được, password cũ không còn login được. |
| AUTH-11 | P1 | Cấu hình SMTP thiếu/sai hoặc mô phỏng mail server lỗi; thử đăng ký/gửi lại mã. | Có thông báo lỗi gửi mail, không báo đã gửi thành công; không lộ credentials. Kiểm trạng thái account/OTP vì SMTP nằm ngoài transaction DB. |

## 5. Hồ sơ, Google login và điện thoại

Nguồn: [AccountService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/auth/AccountService.java), [GoogleAuthService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/auth/GoogleAuthService.java), [PhoneAuthService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/auth/PhoneAuthService.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| PROFILE-01 | P1 | Mở/sửa hồ sơ hợp lệ, tải lại; xóa số liên hệ tùy chọn. | Tên/phone đúng sau reload; không tự thay số điện thoại đã xác minh/binding Firebase. |
| PROFILE-02 | P1 | Tên rỗng/quá dài, số liên hệ sai; mở hồ sơ bằng các role được phép. | Validation và quyền đọc/sửa hoạt động; không lưu dữ liệu sai. |
| PROFILE-03 | P0 | Đổi mật khẩu đúng/sai current password; confirm không khớp; mật khẩu mới giống cũ hoặc dưới 8 ký tự. | Chỉ trường hợp hợp lệ được lưu; password không bị render lại trong HTML. |
| PROFILE-04 | P1 | Mật khẩu Unicode vượt 72 byte UTF-8, ký tự khoảng trắng hợp lệ, đăng nhập lại sau đổi. | Giới hạn byte được kiểm đúng; không tùy tiện trim password; password mới xác thực được. |
| PROFILE-05 | P1 | Logout rồi dùng Back/Refresh và truy cập trang bảo vệ. | UI xóa trạng thái login và không lộ trang nhạy cảm từ cache. Không coi logout phía browser là cơ chế thu hồi mọi JWT đã phát hành. |
| IDENTITY-01 | P1 | Login Google bằng tài khoản mới và tài khoản đã liên kết. | Xác minh ID token, tạo/tìm đúng customer, cấp JWT website; không tạo user trùng mỗi lần login. |
| IDENTITY-02 | P0 | Gửi Google token sai/hết hạn/audience sai/email chưa xác minh; login Google vào tài khoản đang khóa. | Bị từ chối; không tạo binding hoặc quyền đăng nhập từ token không hợp lệ. |
| IDENTITY-03 | P0 | Google login trùng email user hiện có; thử sub khác hoặc email ngoài chính sách auto-link của source. | Không chiếm tài khoản/binding người khác; xử lý đúng quy tắc Gmail/active/sub trong service. |
| IDENTITY-04 | P1 | Nhập số dạng `0...`, `84...`, `+84...`; xác thực bằng Firebase test phone đã cấu hình. | Chuẩn hóa đúng số; nhận/xác nhận mã đúng và backend nhận ID token, không chỉ tin phone client gửi. |
| IDENTITY-05 | P0 | Gửi token Firebase giả, provider khác phone, token xác thực quá cũ; dùng token hợp lệ nhưng user bị khóa. | Backend từ chối; không liên kết hoặc login. |
| IDENTITY-06 | P0 | A liên kết số đã thuộc B; hoặc user đã có binding X muốn ghi đè thành Y. | Không chiếm/ghi đè binding ngoài chính sách. Liên kết lại đúng cùng binding không tạo dữ liệu trùng. |
| IDENTITY-07 | P1 | Login phone chưa liên kết; login phone đã liên kết; Firebase bị tắt/reCAPTCHA hoặc SMS lỗi. | Phone chưa liên kết được yêu cầu liên kết trước; phone đã liên kết vào đúng account; lỗi ngoài được thông báo rõ. |

## 6. Catalog, tìm kiếm và giá bán

Nguồn: [ProductSpecification.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/repository/specification/ProductSpecification.java), [ProductController.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/controller/client/ProductController.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| CAT-01 | P1 | Mở home/list/detail, sản phẩm có và không có giảm giá. | Nội dung đúng; dùng chung sellingPrice: discountPrice → price → originalPrice. |
| CAT-02 | P1 | Tìm theo tên/model, tiếng Việt, chữ hoa/thường, ký tự đặc biệt; tìm từ không có kết quả. | Trả đúng hoặc trạng thái rỗng, không crash và không lộ SQL. |
| CAT-03 | P1 | Kết hợp category, nhiều brand, min/max price, rating và còn hàng. | Các điều kiện cùng được áp dụng; giá filter đúng giá hiển thị. |
| CAT-04 | P1 | Chọn branch có hàng, branch hết hàng, branch inactive; một sản phẩm còn ở nhiều branch. | Lọc đúng branch active/còn hàng và không lặp một product thành nhiều dòng. |
| CAT-05 | P1 | Sort giá tăng/giảm, mới nhất, bán chạy, rating/favorite; gửi sort không hợp lệ. | Thứ tự đúng/ổn định; sort sai về mặc định theo service, không tạo query tùy ý. |
| CAT-06 | P1 | Sang trang, quay lại, clear filter, page âm/quá lớn, size quá lớn. | Giữ query phù hợp, clamp page/size theo service; không kéo toàn bộ dữ liệu. |
| CAT-07 | P1 | Mở slug không tồn tại, sản phẩm đã inactive hoặc category/brand thiếu. | Không trả trang 500; hiển thị lỗi/not-found phù hợp. Đây là ca âm cần test, không khẳng định hiện đã được xử lý đủ. |
| CAT-08 | P2 | Ảnh hỏng, tên dài, màn hình mobile, mở/đóng filter và menu bằng chuột/bàn phím. | Có trạng thái hiển thị hợp lý; không tràn bố cục, mất thao tác hoặc kẹt menu. |
| CAT-09 | P2 | Mở các tab sản phẩm trên home; các trang `/info/about`, `/info/branches`, `/info/warranty`, `/info/shopping-guide`, `/info/returns` và page không tồn tại. | Link/menu dẫn đúng trang; thông tin và danh sách branch active đúng; page lạ trả 404, không có link chết hoặc nội dung lỗi. |

## 7. Giỏ hàng

Nguồn: [CartServiceImpl.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/CartServiceImpl.java), [PurchaseValidator.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/checkout/PurchaseValidator.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| CART-01 | P1 | Thêm một món; thêm lại cùng product; tăng/giảm/xóa; tải lại trang. | Quantity cộng đúng, item không lặp ngoài ý muốn, subtotal/badge/tổng cập nhật và lưu được. |
| CART-02 | P0 | Thêm bằng ID sản phẩm inactive, không tồn tại, quantity null/0/âm hoặc số cực lớn. | Bị từ chối theo validation; không tạo item lỗi hay overflow. |
| CART-03 | P1 | Chọn/bỏ chọn một món hoặc tất cả. | Tổng được chọn và checkout chỉ chứa các món selected. |
| CART-04 | P0 | Có 2 trong giỏ, available 4: thêm 2 rồi thử thêm 1; PUT quantity thành 5. | Cho tổng tới 4, từ chối vượt 4; kiểm tổng hiện có + số thêm chứ không chỉ số vừa gửi. |
| CART-05 | P0 | Thêm hàng, sau đó admin ngừng bán/đổi giá/giảm kho, rồi cập nhật giỏ và checkout. | Backend kiểm lại trạng thái/giá/kho hiện tại; không chỉ tin dữ liệu trang cũ. |
| CART-06 | P1 | Mua ngay khi giỏ có nhiều món, có target rồi và chưa có target. | Chọn đúng món/quantity mục tiêu; món khác còn trong giỏ nhưng bỏ chọn. |
| CART-07 | P0 | A sửa/xóa/toggle item ID của B; guest cửa sổ thứ hai truy cập item của guest thứ nhất. | Không thao tác được item ngoài giỏ của mình. |
| CART-08 | P1 | Guest refresh, mở tab cùng session, mở ẩn danh; login khi đang có giỏ khách và khi account có giỏ riêng. | Xác định được giỏ nào được dùng, không mất/trộn sang user khác. Không mặc định project đã hỗ trợ tự merge giỏ nếu source không có luồng đó. |
| CART-09 | P1 | Hai tab tăng số lượng/đặt hàng trên cùng giỏ; một tab xóa item trong lúc tab kia hiển thị cũ. | Không mất cập nhật, tạo quantity sai hoặc xóa lại dòng cũ gây lỗi dữ liệu; đối chiếu thêm RACE-01. |

## 8. Checkout và thông tin đơn

Nguồn: [CheckoutServiceImpl.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/CheckoutServiceImpl.java), [CheckoutController.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/controller/client/CheckoutController.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| CHECK-01 | P0 | Customer đặt COD với thông tin đầy đủ và món selected. | Tạo đúng 1 Order PENDING, OrderItem và Payment COD/PENDING; gỡ đúng món đã đặt; không gọi VNPay. |
| CHECK-02 | P1 | Giỏ rỗng, không chọn món; thiếu tên/phone/address/province, email sai hoặc field quá dài. | Không tạo đơn lỗi; có lỗi form/redirect phù hợp. |
| CHECK-03 | P0 | Dùng bộ dữ liệu tiền ở phần 1.2; đối chiếu UI, Order, OrderItem, Payment và vnp_Amount. | Mọi tổng tiền khớp công thức; không lệch giá giảm/giá bán hoặc làm tròn sai. |
| CHECK-04 | P0 | Guest nhập email trùng customer B và đặt đơn. | Order.user null, lưu recipientEmail riêng; không tạo user giả và không đưa đơn vào lịch sử B. |
| CHECK-05 | P0 | Customer A nhập người nhận/email là B để đặt hàng. | Đơn vẫn thuộc A theo principal; B chỉ là thông tin người nhận. |
| CHECK-06 | P0 | Branch được shipping quote chọn chỉ còn 1 nhưng đơn mua 2, dù branch khác có đủ. | Không tạo đơn tại branch thiếu hàng, giữ nguyên giỏ; ghi nhận hạn chế chưa tự chuyển branch. |
| CHECK-07 | P0 | Thiếu config VNPay; trong integration test mock tạo URL ném lỗi sau khi đã bắt đầu tạo đơn/voucher. | Không có order/payment/voucher-used/cart bị commit một phần; form có lỗi và giỏ còn nguyên. |
| CHECK-08 | P0 | Thay giá, subtotal, discount, shippingFee, userId hoặc paymentMethod không hỗ trợ trong request. | Backend tính lại các số tiền/quyền theo dữ liệu tin cậy; chỉ COD/VNPAY được chấp nhận. |
| CHECK-09 | P0 | Guest sau đặt hàng mở order-success/tiếp tục payment; dùng session khác hoặc chỉ biết email/code truy cập. | Chỉ session có quyền hoặc owner account được truy cập luồng được bảo vệ; không suy quyền từ recipientEmail. |
| CHECK-10 | P1 | Đặt đơn xong, admin đổi giá Product; đọc lại lịch sử/chi tiết OrderItem. | Giá snapshot của đơn cũ không đổi theo catalog. |
| CHECK-11 | P0 | A có địa chỉ đã lưu, B có địa chỉ khác; mở checkout bằng từng tài khoản và guest; chọn địa chỉ rồi sửa tay. | Chỉ nạp địa chỉ thuộc user hiện tại; guest không thấy địa chỉ riêng của user; thông tin thực gửi, phí ship và Order khớp lựa chọn cuối. |

### 8.1. Lịch sử, tra cứu và mua lại đơn

Nguồn: [OrderController.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/controller/client/OrderController.java), [OrderServiceImpl.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/OrderServiceImpl.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| ORD-01 | P1 | Customer A/B mở `/orders`, lọc trạng thái, kỳ không có đơn; thử status sai và guest chưa login. | Chỉ lịch sử của đúng user, thứ tự mới nhất và số đếm đúng; status sai xử lý có kiểm soát; guest được yêu cầu login. |
| ORD-02 | P0 | Mở detail/snapshot của đơn mình và đổi code thành đơn người khác; thử code có/không có dấu gạch. | Chuẩn hóa code không bỏ qua ownership; snapshot không làm lộ đơn B. |
| ORD-03 | P1 | Guest tra cứu `/orders/tracking` bằng đúng mã đơn và đúng số điện thoại người nhận. | Hiển thị đúng đơn theo cơ chế tra cứu công khai; không cần đăng nhập cho riêng thao tác tra cứu này. |
| ORD-04 | P0 | Tra cứu với mã đúng + phone sai, phone đúng + mã sai; thử chỉ email/code, input rỗng và khoảng trắng. | Không lộ chi tiết nếu thiếu cặp thông tin hợp lệ; phản hồi không chứa dữ liệu đơn không khớp. |
| ORD-05 | P1 | Tra cứu mã có/không dấu gạch, chữ hoa/thường; phone có khoảng trắng; gọi code không tồn tại trên dữ liệu nhiều đơn. | Chuẩn hóa nhất quán với service; không trả nhầm đơn hoặc timeout bất thường. Source có fallback `findAll()`, cần đo tải bằng dữ liệu test khi số đơn tăng. |
| ORD-06 | P0 | Guest vừa tra cứu thành công thử gọi hủy/trả hàng/mua lại đơn hoặc tiếp tục thanh toán bằng session khác. | Quyền xem qua tracking không tự cấp quyền thay đổi đơn hoặc quyền tiếp tục payment của session checkout. |
| ORD-07 | P1 | Owner mua lại đơn cũ khi mọi món còn active/đủ kho; thay đổi giá hiện tại trước khi mua lại; giả code đơn B. | Thêm đúng product/quantity vào giỏ theo giá hiện tại và kiểm tồn hiện tại; không đổi đơn cũ và không mua lại đơn người khác. |
| ORD-08 | P1 | Mua lại đơn nhiều món, một món hết hàng/ngừng bán; thử khi món đã có trong giỏ hoặc bấm lặp. | Không vượt kho; đối chiếu từng item và thông báo cho khách. Controller hiện thêm từng món rồi bỏ qua exception, nên cần ghi nhận khả năng chỉ thêm một phần hoặc thất bại nhưng không báo rõ. |

## 9. Voucher và promotion

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| VOUCH-01 | P1 | Áp mã đang active/đúng khoảng ngày; mã có khoảng trắng/chữ thường; mã không có. | Code chuẩn hóa hợp lý, giảm đúng hoặc báo không hợp lệ. |
| VOUCH-02 | P1 | Áp mã chưa bắt đầu/hết hạn/tắt/hết lượt hoặc percent ngoài (0,100]. | Từ chối; không tăng usedCount. |
| VOUCH-03 | P0 | Bấm áp voucher nhiều lần trên trang nhưng chưa đặt; đặt thành công một lần. | Preview không đốt lượt; giao dịch tạo đơn thành công tăng đúng lượt theo source. |
| VOUCH-04 | P0 | Tạo đơn dùng voucher nhưng bước tạo URL/database thất bại. | usedCount cùng order/cart được rollback. |
| VOUCH-05 | P0 | Hai khách cùng dùng mã còn đúng 1 lượt, với hai giỏ khác nhau. | Không vượt maxUses; đơn bị từ chối không mất giỏ hoặc tạo payment rác. |
| VOUCH-06 | P1 | Mã legacy DIENMAY50K ở subtotal 499.999 và 500.000; SALE10; FREESHIP khi phí ship 0. | Khớp chính sách code: DIENMAY50K có ngưỡng; FREESHIP hiện giảm cố định 30.000, chưa phải luôn miễn đúng phí vận chuyển. |
| VOUCH-07 | P0 | Nhập subtotal giả ở API preview rồi đặt đơn thật. | Preview không được quyết định số giảm cuối; checkout tính lại theo sản phẩm đã chọn. |
| VOUCH-08 | P1 | Mở `/vouchers`, dùng nút sao chép rồi áp mã tại checkout; so nội dung ngày/điều kiện/mức giảm hiển thị với backend. | Copy đúng code, thông tin không làm khách hiểu sai điều kiện; mã hết hạn hoặc chưa hỗ trợ không được quảng bá như đang áp dụng được. |

## 10. Địa chỉ, chi nhánh và phí ship

Nguồn: [GoogleMapsShippingService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/GoogleMapsShippingService.java), [information.jsp](D:/Semester_5/Project/WebProject/src/main/webapp/WEB-INF/views/client/information.jsp).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| SHIP-01 | P1 | Địa chỉ cùng tỉnh với branch active; các cách viết TP.HCM/HCM/Hồ Chí Minh. | Chuẩn hóa và nhận đúng nhánh cùng tỉnh; phí 0 theo code. |
| SHIP-02 | P1 | Địa chỉ khác tỉnh với Routes API hoạt động. | Lấy tuyến hợp lệ, chọn branch phù hợp theo thuật toán khoảng cách và trả fee/distance rõ. |
| SHIP-03 | P1 | Kiểm boundary 50/100/200 km và vừa vượt ngưỡng bằng unit test/mock route. | <=50:15k; <=100:30k; <=200:50k; >200:50k + ceil((km-200)/20)*5k. |
| SHIP-04 | P1 | Address/province trống, không có branch active hoặc thiếu dữ liệu tỉnh. | Không quote giả/không crash; có lỗi phù hợp. |
| SHIP-05 | P1 | Thiếu/sai key, Google timeout, route không tìm thấy. | Không treo vô hạn hoặc tiếp tục đặt với số tiền không được xác định hợp lệ. |
| SHIP-06 | P1 | Đổi địa chỉ/tỉnh nhanh, quote cũ trả về sau quote mới, rồi đặt hàng. | UI không giữ nhầm phí của địa chỉ trước; backend tính lại quote khi placeOrder. |
| SHIP-07 | P2 | Nhấn Xem vị trí/Chỉ đường cho địa chỉ có dấu, dấu &, nhiều khoảng trắng. | URL encode đúng, mở đúng Google Maps/tab mới; không cần key cho hai liên kết này. |

## 11. VNPay và trạng thái tiền

Nguồn: [VnPayServiceImpl.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/VnPayServiceImpl.java), [PaymentController.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/controller/client/PaymentController.java).

Các ca IPN sai tham số/chữ ký nên chạy bằng test tự động có signing key test và repository test. Gửi query giả từ browser không thay thế việc kiểm một thông điệp IPN được ký hợp lệ.

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| PAY-01 | P0 | Đặt VNPay, hoàn thành giao dịch sandbox, quan sát IPN và Return trên domain deploy. | Đúng amount/order reference; Payment SUCCESS sau IPN hợp lệ; không tự giao/nhân đôi đơn. |
| PAY-02 | P0 | Hủy hoặc thanh toán thất bại trên sandbox. | Payment không bị đánh SUCCESS giả; order/payment có trạng thái nhất quán để xử lý tiếp. Nếu IPN chưa tới thì UI phải thể hiện đang chờ, không đoán đã paid. |
| PAY-03 | P0 | Return đến trước IPN; sửa query return thành response code 00. | Trang đọc trạng thái DB; không đánh paid chỉ do browser nói thành công. |
| PAY-04 | P0 | IPN có chữ ký sai/merchant sai, số tiền sai, reference không tồn tại. | Không cập nhật payment; source hiện trả RspCode 97/04/01 tương ứng khi đi tới đúng nhánh kiểm tra. |
| PAY-05 | P0 | Nhân viên/shipper giao đơn VNPay PENDING hoặc FAILED; sau đó thử đơn SUCCESS. | PENDING/FAILED bị chặn trước SHIPPING/DELIVERED; SUCCESS được tiếp tục nếu các điều kiện khác đủ. |
| PAY-06 | P0 | Gửi lặp IPN thành công; sau đó IPN thất bại cho payment đã thành công. | Không ghi đè kết quả đã xử lý; không phát sinh hiệu ứng tài chính/kho lần hai. |
| PAY-07 | P0 | IPN có chữ ký hợp lệ nhưng transaction number thiếu/0 hoặc payment date không hợp lệ. | Không ghi SUCCESS; trả lỗi dữ liệu phù hợp, không lỗi parse gây ghi dở. |
| PAY-08 | P1 | Đóng tab VNPay rồi vào chi tiết đơn, bấm tiếp tục trong hạn 15 phút. | Mở lại URL/attempt đã lưu, không tạo thêm Order/Payment hoặc reference mới. |
| PAY-09 | P0 | Tiếp tục URL hết hạn; payment SUCCESS/FAILED; đơn CANCELLED; account/session khác. | Từ chối đúng lý do/quyền; không reset trạng thái thành PENDING để thử lại tùy ý. |
| PAY-10 | P1 | Sai/thiếu VNPAY_RETURN_URL, wrong scheme; amount cuối bằng 0; kiểm riêng URL localhost bị cấu hình nhầm trên production. | URL thiếu/sai HTTP(S) hoặc amount không dương bị chặn trước commit. URL production phải dẫn về domain thật; validator hiện chỉ kiểm scheme/host, không tự chặn localhost hợp lệ về cú pháp. |
| PAY-11 | P0 | Hai đơn mới tạo gần nhau, nhiều checkout trong ngày. | Order code/reference không đụng; IPN chỉ cập nhật đúng payment. |
| PAY-12 | P0 | Hủy đơn trong lúc khách còn mở cổng thanh toán; sau đó gửi kết quả thanh toán hợp lệ tới muộn. | Phải ghi nhận đúng tiền thực nhận và nhu cầu đối soát/hoàn; không giao đơn đã hủy. **Luồng đối soát/hoàn tiền sau hủy chưa hoàn chỉnh; xem GAP-02.** |
| PAY-13 | P0 | PlaceOrder commit thành công nhưng browser mất mạng trước/sau redirect; người dùng bấm lại. | Không coi lỗi mạng là chắc chắn chưa có đơn; kiểm DB và quyền tiếp tục đơn đã tạo; không thu/đặt hai lần. |
| PAY-14 | P1 | Đọc payment của COD đã giao, VNPay đã trả và các báo cáo revenue. | Không đồng nhất DELIVERED với SUCCESS một cách tùy tiện; đối chiếu quy tắc ghi nhận tiền COD hiện tại. |

## 12. Xác nhận, hủy đơn và kho

Nguồn: [OrderConfirmationService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/order/OrderConfirmationService.java), [OrderFulfillmentService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/order/OrderFulfillmentService.java), [BranchInventoryManagementService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/branch/BranchInventoryManagementService.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| STOCK-01 | P0 | Staff hủy PENDING mua 3 với stock10/reserved2; hủy lặp. | Stock10/reserved2/available8 không đổi, đơn CANCELLED; lần hủy sau bị từ chối. |
| STOCK-02 | P0 | Xác nhận đơn mua 3 rồi hủy; thử khi CONFIRMED, PROCESSING và SHIPPING bằng các đơn riêng. | Xác nhận còn 7/2/5; hủy hợp lệ về 10/2/8 đúng một lần. |
| STOCK-03 | P0 | Hủy PENDING khi chưa có inventory record cho sản phẩm. | Vẫn hủy được, không tạo hoặc cộng kho vì đơn chưa trừ kho. |
| STOCK-04 | P0 | Xác nhận đơn có nhiều product, product thứ hai thiếu kho/không có inventory. | Toàn bộ thao tác rollback: product đầu không bị trừ một phần, đơn chưa CONFIRMED. |
| STOCK-05 | P0 | Xác nhận/hủy cùng đơn nhiều lần hoặc hai request đồng thời. | Guard và lock ngăn trừ/hoàn hai lần; kết quả được đối chiếu DB. |
| STOCK-06 | P0 | Nhảy PENDING sang SHIPPING, CONFIRMED sang DELIVERED, hủy DELIVERED. | Chuyển trạng thái không hợp lệ bị từ chối; kho/status/payment không bị thay đổi dở. |
| STOCK-07 | P0 | Tạo hai dòng cùng product trong đơn test; xác nhận. | Tổng quantity được gộp trước so kho; không vượt tồn bằng cách chia dòng. |
| STOCK-08 | P1 | Điều chỉnh kho thành số âm, thấp hơn reserved, không đổi, thiếu lý do, reason quá 500 ký tự. | Từ chối dữ liệu sai; không ghi adjustment giả. |
| STOCK-09 | P0 | Điều chỉnh hợp lệ bằng staff đúng branch/admin, rồi dùng staff sai branch. | Ca hợp lệ cập nhật cả stock/available và log trước/sau/actor; ca ngoài quyền không ghi gì. |
| STOCK-10 | P1 | Customer tự hủy đơn của mình ở PENDING và khi đã CONFIRMED. | Chỉ trạng thái PENDING được phép theo luồng khách; không tăng kho và không hủy đơn người khác. |

## 13. Phân công và shipper

Nguồn: [DeliveryAssignmentService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/order/DeliveryAssignmentService.java), [DeliveryStatusService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/order/DeliveryStatusService.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| DELIVERY-01 | P1 | CONFIRMED → PROCESSING → phân công → bắt đầu giao → giao thành công. | Order và DeliveryAssignment đồng bộ, có timestamps đúng, không trừ kho lần hai. |
| DELIVERY-02 | P0 | Phân công trước PROCESSING; chọn user không phải shipper, inactive hoặc khác branch. | Bị từ chối; assignment cũ không bị cập nhật một phần. |
| DELIVERY-03 | P0 | Shipper A đổi assignment ID thành đơn của shipper B. | Không xem/sửa được dữ liệu ngoài người được phân công. |
| DELIVERY-04 | P1 | Giao thất bại có/không có lý do; lý do quá dài; giao lại sau thất bại. | Lý do hợp lệ được lưu, status đúng; không lý do/quá dài bị chặn; retry theo cạnh được phép. |
| DELIVERY-05 | P0 | Bấm giao thành công hai lần, hoặc sửa status trực tiếp để bỏ qua bước giao. | Không phát sinh cập nhật sai/hoàn kho; chuyển trái quy tắc bị từ chối. |
| DELIVERY-06 | P1 | Danh sách và thống kê của từng shipper với ngày/tuần/tháng, kỳ rỗng và ranh giới cuối ngày. | Chỉ dữ liệu của shipper đó; tổng/số đơn/trung bình và chuỗi ngày đúng, không chia 0. |
| DELIVERY-07 | P0 | Đơn cũ đã SHIPPING nhưng VNPay còn PENDING; shipper bắt đầu/tiếp tục giao. | Payment guard vẫn chặn, không bỏ qua vì status đã là SHIPPING. |

## 14. Trả hàng và ghi nhận hoàn tiền

Nguồn: [ReturnRequestService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/order/ReturnRequestService.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| RETURN-01 | P1 | Owner gửi yêu cầu cho đơn DELIVERED với lý do hợp lệ; thử PENDING/SHIPPING/đơn người khác. | Chỉ đúng owner/DELIVERED tạo được request; input sai bị từ chối. |
| RETURN-02 | P0 | Gửi lại khi đã có request PENDING/APPROVED; gửi đồng thời hai yêu cầu. | Không có nhiều yêu cầu đang xử lý cho cùng đơn. |
| RETURN-03 | P1 | Staff/admin approve hoặc reject; reject thiếu lý do; người sai branch xét duyệt. | Đúng quyền/trạng thái, lý do bắt buộc theo nhánh reject; approve cập nhật order theo luồng. |
| RETURN-04 | P0 | Hoàn tất request đã APPROVED rồi hoàn tất lại; thử hoàn tất request PENDING/REJECTED. | Chỉ hoàn kho/ghi nhận tiền một lần; ca sai trạng thái không có thay đổi. |
| RETURN-05 | P0 | Hoàn tất đơn VNPay chưa SUCCESS/FAILED và đơn đã REFUNDED; thử payment COD theo chính sách hiện tại. | Không ghi hoàn tiền vô điều kiện; validation đúng theo method/status. |
| RETURN-06 | P0 | Đối chiếu order, request, payment, inventory, adjustment sau complete và khi mô phỏng lỗi giữa chừng. | Thành công ghi nhất quán; lỗi rollback. `REFUNDED` trong DB không tự chứng minh cổng VNPay đã chuyển tiền hoàn thực tế. |

## 15. Review và media

Nguồn: [ReviewServiceImpl.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/ReviewServiceImpl.java), [CloudinaryServiceImpl.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/impl/CloudinaryServiceImpl.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| REVIEW-01 | P1 | Khách đã mua product trong đơn của mình DELIVERED gửi review hợp lệ. | Lưu đúng user/product/order; hiển thị trong danh sách và thống kê sao. |
| REVIEW-02 | P0 | Guest, user chưa mua, đơn chưa giao, giả orderCode người khác, tài khoản inactive. | Không được tạo review trái điều kiện, kể cả gọi API trực tiếp. |
| REVIEW-03 | P1 | Rating 0/6/null; comment 49/50/5000/5001 ký tự; review lại cùng product. | Đúng boundary; không lưu trùng theo quy tắc hiện tại. |
| REVIEW-04 | P1 | Gửi ảnh/video hợp lệ; kiểm URL Cloudinary, kiểu media và thumbnail. | Review liên kết đúng media; không hiển thị file sai loại hoặc ảnh của review khác. |
| REVIEW-05 | P1 | File >10 MB, request >50 MB, file lỗi/sai MIME, Cloudinary thiếu config hoặc timeout. | Có kết quả rõ, không trang lỗi thô hoặc file nguy hiểm được thực thi. Code review hiện có nhánh bỏ qua lỗi upload: cần ghi nhận review có thể lưu dù media thất bại. |
| REVIEW-06 | P1 | Thêm review các mức sao và có HTML; xem trang detail/catalog. | Average/count/percentage khớp dữ liệu active, email được mask và nội dung không thực thi script. |

## 16. Gemini chatbot

Nguồn: [GeminiChatService.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/service/chat/GeminiChatService.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| AI-01 | P1 | Hỏi loại sản phẩm + brand + ngân sách, ví dụ “máy giặt LG dưới 10 triệu”. | Chỉ card sản phẩm thật, active/còn hàng và phù hợp filter; tên/giá/link khớp DB, tối đa 5 card theo service. |
| AI-02 | P1 | Chào hỏi, câu ngoài phạm vi, thiếu nhu cầu, brand/category không có, không có hàng phù hợp. | Hỏi làm rõ hoặc báo không tìm thấy; không bịa sản phẩm/giá. |
| AI-03 | P1 | Biên “dưới”, “trên”, “tối đa”, 500 nghìn/10 triệu; min>max và output JSON/ID sai qua mock. | Parse/bounds đúng hoặc từ chối có kiểm soát; không chạy query từ output AI chưa kiểm tra. |
| AI-04 | P1 | Input trống, 500/501 ký tự, câu yêu cầu model bỏ chỉ dẫn hoặc đưa giá giả. | Validation đúng; output vẫn bị ràng buộc bằng dữ liệu catalog/backend. |
| AI-05 | P1 | Gọi 7 lần trong một phút vào cùng instance; thiếu key, timeout hoặc dịch vụ trả lỗi. | Theo source, lần vượt giới hạn trả 429, dịch vụ không khả dụng trả lỗi phù hợp; đây là bộ đếm chung từng instance. |
| AI-06 | P1 | Click card, ảnh hỏng, giá có giảm; kiểm DevTools Network/source frontend. | Link/giá đúng và không có Gemini secret bị gửi xuống browser; lỗi ảnh không phá giao diện. |

## 17. Realtime và polling

Nguồn: [order-realtime.js](D:/Semester_5/Project/WebProject/src/main/resources/static/js/order-realtime.js), [WebSocketAuthInterceptor.java](D:/Semester_5/Project/WebProject/src/main/java/com/dienmay/config/websocket/WebSocketAuthInterceptor.java).

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| RT-01 | P1 | Mở trang khách/admin/staff; đổi trạng thái đơn bằng browser khác. | Đúng người/branch nhận cập nhật, hiển thị trạng thái đúng sau commit. |
| RT-02 | P0 | Subscribe private user khác, admin topic bằng customer, branch B bằng staff A; không có/giả JWT. | Không nhận được dữ liệu ngoài quyền. |
| RT-03 | P0 | Gây rollback sau khi phát event trong test. | Không đẩy thông báo về một thay đổi chưa commit. |
| RT-04 | P1 | Ngắt socket/mất mạng rồi kết nối lại; thiếu SockJS/STOMP hoặc không có token. | Không reconnect dồn dập; polling dự phòng hoạt động theo điều kiện code, không nhân nhiều timer. |
| RT-05 | P0 | Khóa user sau khi đã mở WebSocket; thử subscribe/gửi frame tiếp. | Không tiếp tục tạo subscription/thao tác ngoài quyền. Kiểm riêng khả năng nhận qua subscription đã mở; không mặc định token check ở frame vào đã đóng mọi subscription. |
| RT-06 | P1 | Đơn guest đổi trạng thái và khách/admin kết nối các container khác nhau khi deploy. | Branch/admin không mất event chỉ vì user null; ghi nhận giới hạn simple broker từng instance và polling không luôn chạy khi socket đã kết nối. |

## 18. Quản trị, dữ liệu nền và báo cáo

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| ADMIN-01 | P1 | Tạo/sửa/ngừng bán product, slug/SKU trùng, field thiếu và upload ảnh. | Dữ liệu hợp lệ được lưu; trùng/input sai có lỗi phù hợp; đơn cũ vẫn giữ giá snapshot. |
| ADMIN-02 | P1 | Tạo cây category, chọn chính nó hoặc con của nó làm parent; xóa category còn con/được product dùng. | Không có chu trình hoặc dữ liệu FK bị hỏng; thông báo lỗi dễ hiểu. |
| ADMIN-03 | P1 | Tạo/sửa/đóng branch; kiểm catalog, quote, inventory và phân công sau thay đổi. | Branch inactive không được chọn như đang phục vụ ở các luồng có điều kiện active; dữ liệu lịch sử không bị mất. |
| ADMIN-04 | P0 | Tạo/sửa role user; gán staff/shipper có/không có branch; khóa/mở user. | Đúng quyền và quy tắc branch; password lưu hash, không bị lộ trong response/view. |
| ADMIN-05 | P1 | Tạo/sửa/tắt promotion và xem audit; điều chỉnh kho và xem adjustment. | Log gắn đúng entity/actor/thời gian, before/after và lý do; lỗi rollback không tạo nhật ký thành công giả. |
| ADMIN-06 | P1 | Dashboard với payment SUCCESS/PENDING/FAILED, order CANCELLED/RETURNED; thống kê branch và kỳ rỗng. | Tổng đối chiếu được với query và dữ liệu chuẩn; xác định rõ quy tắc refund/COD, không tự coi đây là báo cáo kế toán hoàn chỉnh. |
| ADMIN-07 | P2 | Pagination/filter/sort, tên dài, mobile/tablet, nhấn Back sau POST quản trị. | Không mất filter quan trọng, không submit lặp ngoài ý muốn, bảng/form còn dùng được. |

## 19. Deploy, môi trường và hồi quy giao diện

| ID | Mức | Thao tác cần test | Kết quả mong đợi |
|---|---|---|---|
| DEP-01 | P0 | Mở `/health`, home/products/login sau cold start và sau ứng dụng ready. | Health phản ánh readiness + DB; các trang thật render HTML đầy đủ, không chỉ container báo chạy. |
| DEP-02 | P0 | Kiểm đúng DB và schema: user_id nullable, recipient_email, payment_url, payment_expires_at; bản sửa PENDING đã có trong revision chạy. | Không có lỗi thiếu cột/not-null; code chạy đúng revision mong muốn. Bản sửa PENDING không cần migration mới riêng. |
| DEP-03 | P1 | Truy cập HTTPS/domain thật; thanh toán quay lại, Google login và Firebase authorized domain. | Không return localhost, mixed content hoặc lỗi domain cấu hình. Chỉ đánh PASS sau khi đã thử tích hợp. |
| DEP-04 | P0 | Guest thêm giỏ/đặt đơn, refresh qua nhiều request; restart/redeploy hoặc chuyển instance. | Kiểm session/guest cart/quyền xem đơn có còn không. Nếu mất do state local thì ghi GAP, không coi cookie CSRF là đã giải quyết session chia sẻ. |
| DEP-05 | P1 | Theo dõi startup/warmup, pool DB, bộ nhớ và tải đồng thời phù hợp demo. | Không OOM, treo pool, request timeout hàng loạt hoặc restart lặp. |
| DEP-06 | P1 | Mở trang trên desktop/mobile, Chrome/Edge và thêm một browser khác nếu có. | Menu/modal/form/login/cart/checkout hoạt động, không có lỗi JS chặn chức năng; kiểm CDN khi mạng chậm. |
| DEP-07 | P1 | Build `mvn verify`, build container và chạy image với env test; kiểm route/JSP từ artifact thật. | Java/JSP/test/package qua; runtime image khởi động được; test bị skip trong Docker build không được coi là bằng chứng test đã chạy. |
| DEP-08 | P1 | Push/PR vào nhánh workflow theo dõi, theo dõi CI; sau deploy so revision và chức năng chính. | CI thật sự chạy và qua; hosting nhận đúng commit. Repo có Java CI; việc tự động deploy do nền tảng hosting cấu hình riêng. |

## 20. Các ca chạy đồng thời và rollback cần tự động hóa

Nên chạy bằng H2/PostgreSQL test với nhiều transaction độc lập, latch/barrier; thao tác bằng hai tab đơn thuần chưa đảm bảo đã tạo đúng interleaving.

| ID | Mức | Kịch bản | Bất biến phải giữ |
|---|---|---|---|
| RACE-01 | P0 | Hai request checkout một giỏ; hoặc trang preview cũ sau khi request khác đã checkout. | Chỉ một đơn được tạo từ các món đó; không xóa item cũ lần hai hay mất giỏ khi rollback. |
| RACE-02 | P0 | Hai xác nhận cùng đơn; hai đơn khác nhau cạnh tranh một inventory. | Cùng đơn trừ một lần; tổng hàng đã trừ không vượt available. |
| RACE-03 | P0 | Một request xác nhận, một request hủy cùng order PENDING. | Kết thúc CANCELLED không làm stock vượt baseline; nếu đã trừ thì hoàn đúng lượng, nếu chưa trừ thì không cộng. |
| RACE-04 | P0 | Hai IPN, IPN và tiếp tục thanh toán, hoặc IPN và hủy đơn chạy đồng thời. | Không có payment bị xử lý lặp/ghi đè sai; trường hợp tiền đến sau hủy cần luồng đối soát riêng. |
| RACE-05 | P0 | Hai người dùng mã còn một lượt; lỗi database/sinh URL giữa transaction tạo đơn. | Không vượt lượt, không commit dở Order/Payment/voucher/cart. |

## 21. Những điểm cần ghi nhận là giới hạn, không đánh PASS nhầm

| ID | Điểm cần kiểm | Hiện trạng/điều cần ghi lại |
|---|---|---|
| GAP-01 | Hai khách cùng thanh toán sản phẩm cuối cùng trước xác nhận. | Checkout mới validate kho, chưa giữ chỗ theo đơn trong 15 phút; có nguy cơ đã thu tiền nhưng một đơn không đủ hàng. |
| GAP-02 | Thanh toán thành công sau khi đơn đã hủy. | Có cập nhật payment từ IPN nhưng chưa thấy đầy đủ cơ chế đối soát/hoàn tiền sau hủy. Không sửa bằng cách bỏ qua tiền đã nhận. |
| GAP-03 | Hoàn tiền VNPay thực tế. | `PaymentStatus.REFUNDED` trong DB chưa chứng minh đã gọi/nhận kết quả refund của cổng; tách test ghi nhận nghiệp vụ và test chuyển tiền. |
| GAP-04 | Session/realtime/rate limit khi có nhiều container. | Guest authorization dùng session; broker và counter chatbot ở RAM instance; cần test deploy thực tế thay vì suy từ localhost. |
| GAP-05 | Đổi mật khẩu/logout có thu hồi token cũ không. | Không thấy hệ refresh/revocation hoàn chỉnh. Ghi nhận token cũ còn hiệu lực như một giới hạn cần quyết định, không mặc định đã bị thu hồi. |
| GAP-06 | Đọc trực tiếp chi tiết order quản trị khác branch. | `AdminOrderController.orderDetail()` chưa có kiểm branch ở method hiện tại; ưu tiên SEC-05, không chỉ kiểm màn danh sách. |

## 22. Đối chiếu với bộ test tự động đang có

Tên lớp dưới đây chỉ cho biết có test liên quan. Không có nghĩa mọi dòng checklist của module đều đã được tự động hóa hoặc đã thử qua dịch vụ thật.

| Nhóm | File test liên quan |
|---|---|
| Hồ sơ/security HTTP | [AccountProfileIntegrationTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/controller/AccountProfileIntegrationTests.java) |
| Catalog/filter/page | [ProductCatalogFilterTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/ProductCatalogFilterTests.java), [ProductCatalogControllerTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/controller/ProductCatalogControllerTests.java) |
| Giá giỏ/order/invariant | [CartItemPricingTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/entity/cart/CartItemPricingTests.java), [OrderItemTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/entity/order/OrderItemTests.java), [BranchInventoryTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/entity/branch/BranchInventoryTests.java) |
| Checkout/guest/rollback/race | [CheckoutCartIntegrationTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/CheckoutCartIntegrationTests.java), [CheckoutControllerTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/controller/CheckoutControllerTests.java) |
| VNPay logic/URL/chữ ký | [PaymentConfirmationTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/PaymentConfirmationTests.java), [VnPayPaymentUrlTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/VnPayPaymentUrlTests.java) |
| State machine/xác nhận/hủy | [OrderStateMachineTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/OrderStateMachineTests.java), [OrderConfirmationTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/OrderConfirmationTests.java) |
| Quản lý kho | [BranchInventoryManagementServiceTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/BranchInventoryManagementServiceTests.java) |
| Assignment/giao hàng/thống kê | [DeliveryAssignmentRepositoryTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/repository/DeliveryAssignmentRepositoryTests.java), [DeliveryAssignmentServiceTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/DeliveryAssignmentServiceTests.java), [DeliveryStatusServiceTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/DeliveryStatusServiceTests.java), [DeliveryStatisticsServiceTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/DeliveryStatisticsServiceTests.java) |
| Trả hàng/hoàn kho | [ReturnRequestServiceTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/ReturnRequestServiceTests.java) |
| WebSocket/event | [WebSocketAuthInterceptorTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/config/WebSocketAuthInterceptorTests.java), [OrderStatusWebSocketNotifierTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/service/OrderStatusWebSocketNotifierTests.java), [OrderWebSocketIntegrationTests.java](D:/Semester_5/Project/WebProject/src/test/java/com/dienmay/config/OrderWebSocketIntegrationTests.java) |

Những vùng nên bổ sung test tự động rõ hơn: đăng ký/OTP/reset; Google/Firebase binding; boundary Routes API; voucher còn một lượt; upload/review; Gemini parser/output không hợp lệ; quyền đọc trực tiếp chi tiết đơn quản trị. Dù có integration test, email/Google/SMS/media/VNPay thực tế vẫn cần kiểm thử riêng theo môi trường đã cấu hình.

### 22.1. Lệnh chạy

Tại `D:/Semester_5/Project/WebProject`:

```powershell
.\mvnw.cmd verify
```

Chạy nhóm kho/đơn:

```powershell
.\mvnw.cmd '-Dtest=OrderConfirmationTests,OrderStateMachineTests,BranchInventoryManagementServiceTests' test
```

Chạy nhóm checkout/VNPay:

```powershell
.\mvnw.cmd '-Dtest=CheckoutCartIntegrationTests,CheckoutControllerTests,PaymentConfirmationTests,VnPayPaymentUrlTests' test
```

Nếu PowerShell dùng JDK khác project, chọn Java 21 trước khi chạy. Không đưa password/API key vào lệnh được chia sẻ trong báo cáo test.

## 23. Mẫu ghi kết quả một ca

```text
ID: STOCK-01
Môi trường/revision:
Vai trò/tài khoản test:
Mã đơn:
Dữ liệu trước: PENDING; stock=10; reserved=2; available=8; quantity=3
Bước chạy: staff hủy; reload; hủy lại
Mong đợi: CANCELLED; 10/2/8; hủy lặp bị từ chối
Thực tế:
Kết quả: CHƯA TEST / PASS / FAIL / BLOCKED
Bằng chứng:
Bug/ghi chú:
```

Để chốt một vòng kiểm thử, tổng hợp số ca PASS/FAIL/BLOCKED theo mức P0/P1/P2, liệt kê các GAP chưa giải quyết và ghi rõ môi trường/revision. Không lấy con số test tự động làm số ca manual đã hoàn thành.
