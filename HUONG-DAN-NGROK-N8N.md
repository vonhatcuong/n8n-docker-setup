# 🚀 Hướng dẫn cấu hình ngrok + n8n - 2025 Edition

Hướng dẫn chi tiết cách thiết lập n8n với ngrok để tạo webhook công khai và truy cập từ internet.

## 📋 Mục lục

1. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
2. [Thiết lập ngrok](#thiết-lập-ngrok)
3. [Cấu hình n8n](#cấu-hình-n8n)
4. [Khởi động hệ thống](#khởi-động-hệ-thống)
5. [Sử dụng webhook](#sử-dụng-webhook)
6. [Troubleshooting](#troubleshooting)

## 🛠️ Yêu cầu hệ thống

- Docker & Docker Compose
- Tài khoản ngrok (miễn phí tại [ngrok.com](https://ngrok.com))
- Port 5678 và 4040 trống

## 🔧 Thiết lập ngrok

### 1. Đăng ký tài khoản ngrok

1. Truy cập [https://ngrok.com](https://ngrok.com)
2. Đăng ký tài khoản miễn phí
3. Xác thực email

### 2. Lấy Authtoken

1. Đăng nhập vào dashboard ngrok
2. Truy cập [https://dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)
3. Copy authtoken (dạng `2abc...`)

### 3. (Tùy chọn) Tạo domain tĩnh

Với tài khoản miễn phí, bạn có thể tạo 1 domain tĩnh:

1. Truy cập [https://dashboard.ngrok.com/cloud-edge/domains](https://dashboard.ngrok.com/cloud-edge/domains)
2. Tạo domain mới (ví dụ: `your-app-name.ngrok-free.app`)
3. Cập nhật domain trong file `ngrok.yml`

## ⚙️ Cấu hình n8n

### 1. Setup ban đầu

```bash
cd n8n-docker-setup

# Chạy setup với authtoken của bạn
chmod +x setup-ngrok-n8n.sh
./setup-ngrok-n8n.sh YOUR_NGROK_AUTHTOKEN
```

### 2. Kiểm tra cấu hình

File `.env` sẽ được tạo với cấu hình:

```bash
# Kiểm tra cấu hình
cat .env | grep NGROK
```

### 3. Tùy chỉnh cấu hình (nếu cần)

Chỉnh sửa file `.env` nếu muốn:
- Thay đổi mật khẩu admin
- Cấu hình timezone
- Thêm API keys cho AI services

## 🚀 Khởi động hệ thống

### 1. Khởi động tất cả services

```bash
chmod +x manage-ngrok-n8n.sh
./manage-ngrok-n8n.sh start
```

### 2. Kiểm tra trạng thái

```bash
./manage-ngrok-n8n.sh status
```

### 3. Xem logs

```bash
./manage-ngrok-n8n.sh logs
```

## 🌐 Truy cập n8n

Sau khi khởi động thành công:

- **n8n Web Interface**: `https://brief-perfect-mayfly.ngrok-free.app`
- **Username**: `admin`
- **Password**: `d8c60508d30dad2f642d57391cd58919`
- **ngrok Dashboard**: `http://localhost:4040`

## 📡 Sử dụng webhook trong n8n

### 1. Tạo workflow với webhook

1. Đăng nhập vào n8n
2. Tạo workflow mới
3. Thêm node "Webhook"
4. Cấu hình:
   - **HTTP Method**: GET hoặc POST
   - **Path**: `/webhook/test` (tùy chọn)

### 2. URL webhook hoàn chỉnh

URL webhook sẽ có dạng:
```
https://brief-perfect-mayfly.ngrok-free.app/webhook/test
```

### 3. Test webhook

```bash
# Test với curl
curl -X POST https://brief-perfect-mayfly.ngrok-free.app/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello from webhook!"}'
```

## 🔄 Quản lý hệ thống

### Các lệnh thường dùng

```bash
# Khởi động
./manage-ngrok-n8n.sh start

# Dừng
./manage-ngrok-n8n.sh stop

# Khởi động lại
./manage-ngrok-n8n.sh restart

# Xem trạng thái
./manage-ngrok-n8n.sh status

# Lấy URL ngrok hiện tại
./manage-ngrok-n8n.sh ngrok-url

# Cập nhật URL ngrok vào .env
./manage-ngrok-n8n.sh update-env

# Tạo backup
./manage-ngrok-n8n.sh backup
```

## 🔧 Troubleshooting

### Lỗi thường gặp

#### 1. ngrok không khởi động được

**Triệu chứng**: Container ngrok exit

**Giải pháp**:
```bash
# Kiểm tra authtoken
docker-compose logs ngrok

# Cập nhật authtoken trong .env
nano .env
```

#### 2. n8n không truy cập được qua ngrok

**Triệu chứng**: 502 Bad Gateway

**Giải pháp**:
```bash
# Kiểm tra n8n đã chạy chưa
./manage-ngrok-n8n.sh status

# Xem logs n8n
docker-compose logs n8n

# Restart services
./manage-ngrok-n8n.sh restart
```

#### 3. Webhook không hoạt động

**Triệu chứng**: 404 Not Found khi gọi webhook

**Kiểm tra**:
1. Workflow đã được activate chưa
2. Webhook node đã được cấu hình đúng path chưa
3. URL có đúng format: `https://domain.ngrok-free.app/webhook/path`

#### 4. URL ngrok thay đổi

**Nguyên nhân**: Mỗi lần restart ngrok với tài khoản miễn phí

**Giải pháp**:
```bash
# Lấy URL mới
./manage-ngrok-n8n.sh ngrok-url

# Cập nhật vào .env
./manage-ngrok-n8n.sh update-env

# Restart n8n
./manage-ngrok-n8n.sh restart
```

### Kiểm tra kỹ thuật

#### 1. Kiểm tra network connectivity

```bash
# Test kết nối từ ngrok container đến n8n
docker-compose exec ngrok curl -I http://n8n:5678

# Test ngrok API
curl http://localhost:4040/api/tunnels
```

#### 2. Kiểm tra DNS resolution

```bash
# Từ máy host
nslookup brief-perfect-mayfly.ngrok-free.app

# Test HTTPS
curl -I https://brief-perfect-mayfly.ngrok-free.app
```

#### 3. Debug mode

```bash
# Chạy với debug logs
docker-compose -f docker-compose.yml up --build
```

## 📁 Cấu trúc file quan trọng

```
n8n-docker-setup/
├── .env                      # Cấu hình môi trường
├── docker-compose.yml        # Docker services
├── ngrok.yml                 # Cấu hình ngrok
├── setup-ngrok-n8n.sh       # Script setup ban đầu
├── manage-ngrok-n8n.sh      # Script quản lý
├── n8n_data/                # Data n8n
├── postgres_data/           # Database data
└── backups/                 # Backup files
```

## 🔒 Bảo mật

### Khuyến nghị bảo mật

1. **Thay đổi mật khẩu mặc định**:
```bash
# Tạo mật khẩu mới
openssl rand -hex 16

# Cập nhật vào .env
nano .env
```

2. **Sử domain riêng** (tài khoản trả phí):
```yaml
# Trong ngrok.yml
domain: your-domain.com
```

3. **Cấu hình IP whitelist** (ngrok Pro):
```yaml
# Trong ngrok.yml
restrictions:
  allow:
    - "192.168.1.0/24"
```

4. **Sử dụng basic auth từ ngrok**:
```yaml
# Trong ngrok.yml
auth: "username:password"
```

## 📈 Monitoring & Logging

### 1. Xem metrics

- n8n metrics: `https://your-domain.ngrok-free.app/metrics`
- ngrok dashboard: `http://localhost:4040`

### 2. Log files

```bash
# n8n logs
docker-compose logs -f n8n

# PostgreSQL logs
docker-compose logs -f postgres

# ngrok logs
docker-compose logs -f ngrok
```

### 3. Health checks

```bash
# Script tự động check
./manage-ngrok-n8n.sh status

# Manual checks
curl -f http://localhost:5678/healthz
curl -f http://localhost:4040/api/tunnels
```

## 🆘 Hỗ trợ

Nếu gặp vấn đề:

1. Kiểm tra logs: `./manage-ngrok-n8n.sh logs`
2. Xem trạng thái: `./manage-ngrok-n8n.sh status`
3. Tham khảo [n8n Documentation](https://docs.n8n.io/)
4. Tham khảo [ngrok Documentation](https://ngrok.com/docs)

## 📚 Tài liệu tham khảo

- [n8n Official Docs](https://docs.n8n.io/)
- [ngrok Documentation](https://ngrok.com/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)

---

*Cập nhật lần cuối: 2025-01-21*