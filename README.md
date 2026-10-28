# WebProject_Nhom_7 — TechSeven

Website bán hàng điện máy theo mô hình chuỗi cửa hàng. Dự án dùng Java 21, Spring Boot, JSP/JSTL, Bootstrap, Spring Data JPA, PostgreSQL/Neon, Redis và WebSocket.

Repository: <https://github.com/JPDeep4122/WebProject_Nhom_7>

## Yêu cầu

### Chạy bằng Docker Compose (khuyến nghị)

- Git
- Docker Engine và Docker Compose v2 trên Linux, hoặc Docker Desktop trên Windows
- Tài khoản PostgreSQL/Neon và database đã tạo

### Chạy Java trực tiếp trên máy

Ngoài PostgreSQL/Neon, cần Java 21. Redis có thể chạy riêng bằng Docker Compose.

Kiểm tra phiên bản:

```bash
git --version
docker --version
docker compose version
java -version
```

Khi chạy Java trực tiếp, `java -version` cần hiển thị phiên bản 21.

## 1. Tải mã nguồn

### Linux (Terminal)

```bash
git clone https://github.com/JPDeep4122/WebProject_Nhom_7.git
cd WebProject_Nhom_7
```

### Windows (PowerShell)

```powershell
git clone https://github.com/JPDeep4122/WebProject_Nhom_7.git
Set-Location WebProject_Nhom_7
```

Nếu thư mục chứa `pom.xml`, `compose.yaml` và `Dockerfile` nằm bên trong một thư mục con, hãy `cd` vào thư mục đó trước các bước tiếp theo.

## 2. Cấu hình database và secrets

Tạo file môi trường từ mẫu trong thư mục dự án:

### Linux

```bash
cp .env.docker.example .env.docker
nano .env.docker
```

### Windows (PowerShell)

```powershell
Copy-Item .env.docker.example .env.docker
notepad .env.docker
```

Điền các giá trị bắt buộc trong `.env.docker`:

| Biến | Ý nghĩa |
|---|---|
| `DB_URL` | JDBC URL PostgreSQL/Neon, ví dụ `jdbc:postgresql://<host>/neondb?sslmode=require` |
| `DB_USERNAME` | Tên người dùng database |
| `DB_PASSWORD` | Mật khẩu database |
| `JWT_SECRET` | Chuỗi bí mật ngẫu nhiên, tối thiểu 32 bytes |

`APP_PORT` mặc định là `8080`. Các biến tích hợp email, Cloudinary, VNPay và Google Maps là tùy chọn; xem `.env.docker.example` để biết tên biến. Thay placeholder bằng thông tin thật trước khi chạy. Không commit/chia sẻ `.env.docker`; file này đã được Git ignore.

> Nếu secret hoặc mật khẩu đã bị đưa lên Git hay gửi công khai, hãy tạo giá trị mới tại nhà cung cấp và cập nhật file môi trường.

## 3. Chuẩn bị schema database

Trong Neon, chọn đúng project, branch và database trước khi chạy SQL. Với database mới, chạy lần lượt:

1. `src/main/resources/db/manual/01_schema.sql` — tạo schema; chỉ dùng cho database rỗng.
2. `src/main/resources/db/manual/02_indexes.sql` — tạo các index truy vấn.

SQL không tự chạy khi khởi động ứng dụng. Không chạy `01_schema.sql` lên database đang có dữ liệu. Cách thêm dữ liệu mẫu, migration và hướng dẫn các SQL khác nằm trong [`src/main/resources/db/manual/README.md`](src/main/resources/db/manual/README.md).

## 4. Chạy ứng dụng và Redis bằng Docker Compose

Compose sẽ build ứng dụng trên Java 21, khởi động Redis, đợi Redis khỏe rồi mới khởi động ứng dụng. App dùng PostgreSQL/Neon theo thông tin trong `.env.docker`.

### Linux

```bash
sudo docker compose --env-file .env.docker up --build -d
```

Nếu tài khoản Linux đã được cấp quyền dùng Docker, bỏ `sudo`:

```bash
docker compose --env-file .env.docker up --build -d
```

### Windows (PowerShell)

Cài và mở Docker Desktop, chờ Docker báo đang chạy, rồi trong thư mục dự án thực hiện:

```powershell
docker compose --env-file .env.docker up --build -d
```

Mở website tại <http://localhost:8080>.

### Kiểm tra trạng thái, Redis và log

Linux (thêm `sudo` nếu cần):

```bash
sudo docker compose --env-file .env.docker ps
sudo docker compose --env-file .env.docker exec redis redis-cli ping
sudo docker compose --env-file .env.docker logs -f app
```

Windows PowerShell:

```powershell
docker compose --env-file .env.docker ps
docker compose --env-file .env.docker exec redis redis-cli ping
docker compose --env-file .env.docker logs -f app
```

Redis chạy đúng khi lệnh `ping` trả về `PONG`. Nhấn `Ctrl+C` để thoát xem log.

### Dừng ứng dụng

Linux:

```bash
sudo docker compose --env-file .env.docker down
```

Windows PowerShell:

```powershell
docker compose --env-file .env.docker down
```

Lệnh `down` không xóa volume `redis_data`. Chỉ khi muốn xóa cả dữ liệu Redis local mới thêm `-v`:

```bash
sudo docker compose --env-file .env.docker down -v
```

Trên Windows dùng `docker compose --env-file .env.docker down -v`.

### Tự build lại khi sửa code

Compose Watch theo dõi `src`, `pom.xml` và `Dockerfile`, sau đó build lại app khi các file này thay đổi. Dùng Docker Compose v2 hỗ trợ Watch.

Linux:

```bash
sudo docker compose --env-file .env.docker watch
```

Windows PowerShell:

```powershell
docker compose --env-file .env.docker watch
```

Nếu Watch không có trên bản Docker Compose hiện tại, dùng lệnh build/recreate sau mỗi lần sửa:

```bash
docker compose --env-file .env.docker up --build -d
```

## 5. Chạy Java trực tiếp, Redis vẫn chạy trong Docker

Cách này hữu ích khi phát triển Java/JSP trên máy. Trước tiên khởi động Redis từ thư mục dự án:

```bash
docker compose --env-file .env.docker up -d redis
```

Sau đó cấu hình các biến `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET` và `REDIS_URL=redis://localhost:6379` trong terminal hoặc Run Configuration của IDE.

### Linux (Bash)

Thay các giá trị mẫu bằng thông tin database và secret của bạn. Đặt JDBC URL trong dấu nháy đơn để các ký tự `&` không bị shell hiểu thành toán tử:

```bash
export DB_URL='jdbc:postgresql://<host>/neondb?sslmode=require'
export DB_USERNAME='<database-user>'
export DB_PASSWORD='<database-password>'
export JWT_SECRET='<random-secret-at-least-32-bytes>'
export REDIS_URL='redis://localhost:6379'
./mvnw spring-boot:run
```

### Windows (PowerShell)

```powershell
$env:DB_URL = 'jdbc:postgresql://<host>/neondb?sslmode=require'
$env:DB_USERNAME = '<database-user>'
$env:DB_PASSWORD = '<database-password>'
$env:JWT_SECRET = '<random-secret-at-least-32-bytes>'
$env:REDIS_URL = 'redis://localhost:6379'
.\mvnw.cmd spring-boot:run
```

Dừng app bằng `Ctrl+C`. Các biến môi trường chỉ tồn tại trong terminal hiện tại. Không dùng `source .env.docker`: file Compose env không nhất thiết có cú pháp shell hợp lệ.

### Build WAR

Linux:

```bash
./mvnw -DskipTests package
java -jar target/dienmay-shop-0.0.1-SNAPSHOT.war
```

Windows PowerShell:

```powershell
.\mvnw.cmd -DskipTests package
java -jar target/dienmay-shop-0.0.1-SNAPSHOT.war
```

Cần giữ các biến môi trường và Redis hoạt động trong lúc chạy WAR.

## Redis cache

Ứng dụng đọc địa chỉ Redis từ `REDIS_URL`:

- Bên trong Docker Compose: `redis://redis:6379` (Compose tự đặt cho app).
- Khi chạy Java trực tiếp trên máy: `redis://localhost:6379`.

Redis cache được dùng cho một số dữ liệu catalog của khách hàng. TTL được định nghĩa trong `src/main/java/com/dienmay/config/cache/RedisCacheConfig.java`; một số thao tác quản trị sản phẩm, danh mục và chi nhánh xóa cache liên quan.

## Cấu hình trong source

- `compose.yaml` — app, Redis, health check, volume và Compose Watch.
- `Dockerfile` — build/runtime Java 21.
- `src/main/resources/application.properties` — Spring Boot, PostgreSQL, Redis, JWT và dịch vụ tích hợp.
- `src/main/java/com/dienmay/config/cache/RedisCacheConfig.java` — cache Redis và thời gian hết hạn.
- `src/main/resources/db/manual/README.md` — schema, indexes, seed và migration SQL.
- [`DEPLOY_RENDER.md`](DEPLOY_RENDER.md) — ghi chú triển khai Render.

## Lỗi thường gặp

- **Compose báo thiếu `JWT_SECRET` hoặc `DB_*`:** kiểm tra `.env.docker` đã được tạo từ file mẫu và đã điền đủ giá trị; chạy lệnh kèm `--env-file .env.docker`.
- **Cổng 8080 đã được sử dụng:** dừng tiến trình/container đang dùng cổng đó hoặc đổi `APP_PORT` trong `.env.docker`.
- **App không kết nối được PostgreSQL:** kiểm tra JDBC URL, thông tin tài khoản, quyền truy cập mạng và SSL của Neon.
- **App không kết nối được Redis khi chạy Java trực tiếp:** khởi động service Redis và đặt `REDIS_URL=redis://localhost:6379`.
- **Đăng nhập không hoạt động:** xem log app; kiểm tra schema đã đồng bộ và `JWT_SECRET` đã được cấu hình.
