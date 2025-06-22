#!/bin/bash

# ====================================================================
# N8N + NGROK Setup Script - 2025 Edition
# ====================================================================

set -e

echo "🚀 Thiết lập n8n + ngrok setup..."

# Kiểm tra ngrok authtoken
if [ -z "$1" ]; then
    echo "❌ Vui lòng cung cấp ngrok authtoken!"
    echo "Usage: ./setup-ngrok-n8n.sh <your_ngrok_authtoken>"
    echo "Lấy authtoken tại: https://dashboard.ngrok.com/get-started/your-authtoken"
    exit 1
fi

NGROK_AUTHTOKEN=$1

# Tạo file .env
echo "📝 Tạo file .env..."
cat > .env << EOF
# ====================================================================
# N8N + NGROK CONFIGURATION - 2025 Edition
# ====================================================================

# Database Configuration
POSTGRES_DB=n8n
POSTGRES_USER=postgres_admin
POSTGRES_PASSWORD=n8n_secure_password_2024
POSTGRES_NON_ROOT_USER=n8n
POSTGRES_NON_ROOT_PASSWORD=n8n_user_password_2024

# ngrok Configuration
NGROK_AUTHTOKEN=$NGROK_AUTHTOKEN
NGROK_HOSTNAME=brief-perfect-mayfly.ngrok-free.app
NGROK_PUBLIC_URL=https://brief-perfect-mayfly.ngrok-free.app

# n8n Security Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=d8c60508d30dad2f642d57391cd58919

# n8n Core Settings
N8N_HOST=brief-perfect-mayfly.ngrok-free.app
N8N_PROTOCOL=https
N8N_PORT=5678
WEBHOOK_URL=https://brief-perfect-mayfly.ngrok-free.app

# Encryption Keys
N8N_ENCRYPTION_KEY=HN1nv7im6Q0JXROVFpLk+vOWrnzk6GtilSVkQoXFds8=
N8N_USER_MANAGEMENT_JWT_SECRET=HN1nv7im6Q0JXROVFpLk+vOWrnzk6GtilSVkQoXFds8=

# Timezone
GENERIC_TIMEZONE=Asia/Ho_Chi_Minh

# Performance Settings
N8N_PAYLOAD_SIZE_MAX=32
N8N_METRICS=true
N8N_RUNNERS_ENABLED=true
N8N_CONCURRENCY_PRODUCTION=2

# Security Settings
N8N_SECURE_COOKIE=true
N8N_DISABLE_UI=false

# Privacy Settings
N8N_DIAGNOSTICS_ENABLED=false
N8N_PERSONALIZATION_ENABLED=false

# Logging
N8N_LOG_LEVEL=info
EOF

# Tạo các thư mục cần thiết
echo "📁 Tạo các thư mục cần thiết..."
mkdir -p n8n_data postgres_data backups shared

# Cấp quyền thực thi cho các script
echo "🔐 Cấp quyền thực thi..."
chmod +x backup.sh
chmod +x init-data.sh
if [ -f "init-data-2025.sh" ]; then
    chmod +x init-data-2025.sh
fi

echo "✅ Setup hoàn tất!"
echo ""
echo "🔧 Các bước tiếp theo:"
echo "1. Kiểm tra file .env và cập nhật mật khẩu nếu cần"
echo "2. Chạy: docker-compose up -d"
echo "3. Truy cập n8n tại: https://brief-perfect-mayfly.ngrok-free.app"
echo "4. Đăng nhập với username: admin"
echo "5. Mật khẩu: d8c60508d30dad2f642d57391cd58919"
echo ""
echo "🌐 Ngrok web interface: http://localhost:4040"
echo "📊 Kiểm tra trạng thái: docker-compose ps"