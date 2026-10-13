# Chạy local bằng Docker

## Yêu cầu

- Docker Desktop hoặc Docker Engine có Docker Compose v2.
- Máy có thể cấp khoảng 4 GB RAM cho SQL Server và ứng dụng.

## Khởi chạy

Từ thư mục `demo`, tạo file cấu hình local rồi sửa các mật khẩu mẫu:

```bash
cp .env.docker.example .env.docker
```

Đặt `MSSQL_SA_PASSWORD` thành mật khẩu SQL Server đủ mạnh và đặt `JWT_SECRET` thành chuỗi ngẫu nhiên tối thiểu 32 byte. Sau đó chạy:

```bash
docker compose --env-file .env.docker up --build
```

Maven biên dịch ứng dụng trong giai đoạn build image, vì vậy máy host không cần cài Java hoặc Maven. Compose khởi động SQL Server 2022, chờ database khỏe rồi mới chạy ứng dụng. Hibernate tự tạo/cập nhật schema và dữ liệu mẫu được nạp khi database chưa có sản phẩm.

Mở [http://localhost:8080](http://localhost:8080). Có thể đổi cổng bằng `APP_PORT` và `DB_PORT` trong `.env.docker`.

## Lệnh thường dùng

```bash
# Xem log
docker compose --env-file .env.docker logs -f app

# Dừng stack, giữ dữ liệu database
docker compose --env-file .env.docker down

# Dừng và xóa cả dữ liệu database local
docker compose --env-file .env.docker down -v
```

File `.env.docker` chỉ dành cho máy local, không commit. Email OTP không gửi được cho tới khi điền `MAIL_USERNAME` và `MAIL_PASSWORD` hợp lệ.
