# Thống kê giao hàng của shipper

Trang `/shipper/statistics` thống kê riêng các đơn giao thành công của shipper đang đăng nhập.

- Chế độ ngày hiển thị kết quả của một ngày.
- Chế độ tuần tính từ thứ Hai đến Chủ nhật và hiển thị đủ bảy ngày.
- Chế độ tháng hiển thị từng ngày trong tháng đã chọn.
- Chỉ bản ghi `DELIVERED_SUCCESS` có `completedAt` trong kỳ mới được tính.
- Tổng giá trị sử dụng `finalAmount` của đơn; đây là giá trị đơn đã giao, không phải thu nhập của shipper.
- Truy vấn luôn giới hạn theo email shipper để không lộ thống kê của người khác.
