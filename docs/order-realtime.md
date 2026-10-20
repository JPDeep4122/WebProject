# Cập nhật trạng thái đơn hàng realtime

Mỗi lần state machine đổi trạng thái thành công, hệ thống tạo sự kiện gồm mã đơn,
trạng thái cũ, trạng thái mới và thời điểm thay đổi. Sự kiện chỉ được gửi sau khi
giao dịch database commit, vì vậy thao tác bị rollback không tạo thông báo sai.

Server gửi dữ liệu STOMP riêng cho chủ đơn qua `/user/queue/order-status`. Client
kết nối SockJS tại `/ws`, xác thực bằng JWT trong STOMP `CONNECT`, rồi đăng ký
queue cá nhân. Không broadcast mã đơn hoặc trạng thái của khách hàng ra topic công
khai.

Trang `/orders` và `/orders/{orderCode}` tự kết nối khi người dùng đã đăng nhập.
Khi nhận trạng thái mới, trang hiển thị thông báo ngắn rồi tải lại để đồng bộ toàn
bộ nút, bộ đếm và tiến trình đơn hàng từ database.

Ngày 9 bổ sung tích hợp với trang quản trị: STAFF đăng ký topic đúng chi nhánh
`/topic/branches/{branchId}/order-status`, còn ADMIN khi xem toàn hệ thống dùng
`/topic/admin/order-status`. Interceptor từ chối nhân viên đăng ký topic của chi
nhánh khác và chỉ cho ADMIN dùng topic toàn hệ thống.

Client tự kết nối lại theo khoảng chờ tăng dần từ 2 đến 30 giây, kết nối lại ngay
khi trình duyệt online và đóng kết nối khi rời trang. Kiểm thử tích hợp xác nhận
một giao dịch đổi trạng thái đã commit sẽ gửi đồng thời tới khách hàng, chi nhánh
và quản trị viên; kiểm thử bảo mật kiểm tra JWT, kết nối ẩn danh và phạm vi chi
nhánh.
