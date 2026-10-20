# Quy trình yêu cầu trả hàng — phần 1

Phần 1 tiếp nhận và xét duyệt yêu cầu, chưa hoàn kho hoặc cập nhật thanh toán thành `REFUNDED`.

1. Khách hàng chỉ được gửi yêu cầu cho đơn của mình đang ở trạng thái `DELIVERED`.
2. Yêu cầu cần lý do từ 10 đến 1000 ký tự và lưu số tiền hoàn dự kiến tại thời điểm gửi.
3. Mỗi đơn chỉ có một yêu cầu `PENDING` hoặc `APPROVED` đang hoạt động.
4. STAFF chỉ xem và xét duyệt yêu cầu thuộc chi nhánh được gán; ADMIN có thể xử lý toàn hệ thống.
5. Khi duyệt, đơn chuyển sang `RETURN_REQUESTED`. Khi từ chối, đơn vẫn là `DELIVERED` và bắt buộc có lý do.
6. Hoàn hàng vào kho và hoàn tiền thực tế được thực hiện ở phần 2.
