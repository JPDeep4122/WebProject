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

Ngày 8 triển khai luồng phát sự kiện và client nhận riêng. Ngày 9 tiếp tục kiểm
thử kết nối tích hợp, xử lý mất kết nối và phối hợp các màn hình của thành viên
khác.
