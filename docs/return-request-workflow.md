# Quy trình yêu cầu trả hàng / hoàn tiền

Phần 1 tiếp nhận và xét duyệt yêu cầu. Phần 2 hoàn tất việc nhận lại hàng,
hoàn kho và ghi nhận hoàn tiền.

1. Khách hàng chỉ được gửi yêu cầu cho đơn của mình đang ở trạng thái `DELIVERED`.
2. Yêu cầu cần lý do từ 10 đến 1000 ký tự và lưu số tiền hoàn dự kiến tại thời điểm gửi.
3. Mỗi đơn chỉ có một yêu cầu `PENDING` hoặc `APPROVED` đang hoạt động.
4. STAFF chỉ xem và xét duyệt yêu cầu thuộc chi nhánh được gán; ADMIN có thể xử lý toàn hệ thống.
5. Khi duyệt, đơn chuyển sang `RETURN_REQUESTED`. Khi từ chối, đơn vẫn là `DELIVERED` và bắt buộc có lý do.
6. Yêu cầu `APPROVED` chờ chi nhánh nhận lại hàng. Khi nhân viên bấm **Hoàn tất
   trả hàng**, hệ thống khóa yêu cầu, đơn hàng và từng dòng tồn kho để ngăn xử
   lý lặp.
7. Số lượng của từng sản phẩm được cộng lại vào `branch_inventory`; mỗi thay
   đổi được lưu trong `inventory_adjustments` cùng người thực hiện và mã đơn.
8. Thanh toán thành công, hoặc COD đang ở trạng thái chờ, được chuyển thành
   `REFUNDED`. Thanh toán online chưa thành công không được phép hoàn tất.
9. Cuối cùng, đơn chuyển từ `RETURN_REQUESTED` sang `RETURNED`, yêu cầu chuyển
   sang `COMPLETED` và lưu số tiền hoàn, người hoàn tất, thời gian, ghi chú.

Các cập nhật tồn kho, thanh toán, đơn hàng và yêu cầu nằm trong cùng một giao
dịch. Nếu thiếu bản ghi tồn kho hoặc thanh toán không hợp lệ, toàn bộ thay đổi
được hoàn tác.
