# Cập nhật trạng thái giao hàng

Shipper cập nhật trạng thái trực tiếp tại `/shipper/orders` theo luồng:

`ASSIGNED/PICKED_UP → DELIVERING → DELIVERED_SUCCESS hoặc DELIVERED_FAILED`

Đơn giao thất bại phải có lý do và có thể chuyển lại sang `DELIVERING` để giao lại.
Shipper chỉ được cập nhật bản phân công thuộc tài khoản đang đăng nhập.

Khi bắt đầu giao, trạng thái đơn hàng được chuyển từ `PROCESSING` sang `SHIPPING`.
Khi giao thành công, trạng thái đơn được chuyển từ `SHIPPING` sang `DELIVERED`.
Giao thất bại giữ đơn ở `SHIPPING` để chi nhánh quyết định giao lại hoặc hủy đơn.

Mọi cập nhật chạy trong một giao dịch và khóa bản ghi phân công cùng đơn hàng để
tránh hai yêu cầu đồng thời ghi đè trạng thái của nhau.
