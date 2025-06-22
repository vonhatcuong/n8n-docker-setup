#!/bin/bash

# ====================================================================
# N8N + NGROK Management Script - 2025 Edition
# ====================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_help() {
    echo -e "${BLUE}🚀 N8N + NGROK Management Script${NC}"
    echo ""
    echo "Usage: ./manage-ngrok-n8n.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start         - Khởi động n8n + ngrok"
    echo "  stop          - Dừng tất cả services"
    echo "  restart       - Khởi động lại services"
    echo "  logs          - Xem logs"
    echo "  status        - Kiểm tra trạng thái"
    echo "  ngrok-url     - Lấy URL ngrok hiện tại"
    echo "  update-env    - Cập nhật URL ngrok vào .env"
    echo "  backup        - Tạo backup"
    echo "  clean         - Dọn dẹp (⚠️ Xóa dữ liệu)"
    echo "  setup         - Setup ban đầu"
    echo ""
}

check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker không được cài đặt!${NC}"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose không được cài đặt!${NC}"
        exit 1
    fi

    if [ ! -f ".env" ]; then
        echo -e "${RED}❌ File .env không tồn tại!${NC}"
        echo "Chạy: ./setup-ngrok-n8n.sh <your_ngrok_authtoken>"
        exit 1
    fi
}

start_services() {
    echo -e "${GREEN}🚀 Khởi động n8n + ngrok...${NC}"
    docker-compose up -d

    echo -e "${YELLOW}⏳ Đợi services khởi động...${NC}"
    sleep 10

    show_status
    show_access_info
}

stop_services() {
    echo -e "${YELLOW}🛑 Dừng tất cả services...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Đã dừng tất cả services${NC}"
}

restart_services() {
    echo -e "${YELLOW}🔄 Khởi động lại services...${NC}"
    docker-compose restart

    echo -e "${YELLOW}⏳ Đợi services khởi động...${NC}"
    sleep 10

    show_status
}

show_logs() {
    echo -e "${BLUE}📋 Hiển thị logs (Ctrl+C để thoát)...${NC}"
    docker-compose logs -f
}

show_status() {
    echo -e "${BLUE}📊 Trạng thái services:${NC}"
    docker-compose ps
    echo ""

    # Kiểm tra health của từng service
    echo -e "${BLUE}🏥 Health check:${NC}"

    # Check n8n
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200\|401"; then
        echo -e "${GREEN}✅ n8n: Running${NC}"
    else
        echo -e "${RED}❌ n8n: Not accessible${NC}"
    fi

    # Check ngrok
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:4040 | grep -q "200"; then
        echo -e "${GREEN}✅ ngrok: Running${NC}"
    else
        echo -e "${RED}❌ ngrok: Not accessible${NC}"
    fi

    # Check postgres
    if docker-compose exec postgres pg_isready -U postgres &> /dev/null; then
        echo -e "${GREEN}✅ PostgreSQL: Running${NC}"
    else
        echo -e "${RED}❌ PostgreSQL: Not accessible${NC}"
    fi

    echo ""
}

get_ngrok_url() {
    echo -e "${BLUE}🌐 Lấy URL ngrok hiện tại...${NC}"

    # Thử lấy URL từ ngrok API
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")

    if [ -n "$NGROK_URL" ] && [ "$NGROK_URL" != "null" ]; then
        echo -e "${GREEN}📍 URL hiện tại: $NGROK_URL${NC}"
        echo "$NGROK_URL"
    else
        echo -e "${YELLOW}⚠️  Không thể lấy URL từ ngrok API${NC}"
        echo -e "${BLUE}📍 URL từ config: https://brief-perfect-mayfly.ngrok-free.app${NC}"
    fi
}

update_env_with_ngrok_url() {
    echo -e "${BLUE}🔄 Cập nhật URL ngrok vào .env...${NC}"

    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")

    if [ -n "$NGROK_URL" ] && [ "$NGROK_URL" != "null" ]; then
        # Cập nhật .env file
        sed -i.bak "s|NGROK_PUBLIC_URL=.*|NGROK_PUBLIC_URL=$NGROK_URL|g" .env
        sed -i.bak "s|WEBHOOK_URL=.*|WEBHOOK_URL=$NGROK_URL|g" .env
        sed -i.bak "s|N8N_HOST=.*|N8N_HOST=${NGROK_URL#https://}|g" .env

        echo -e "${GREEN}✅ Đã cập nhật .env với URL: $NGROK_URL${NC}"
        echo -e "${YELLOW}⚠️  Cần restart n8n để áp dụng thay đổi${NC}"
    else
        echo -e "${RED}❌ Không thể lấy URL từ ngrok${NC}"
    fi
}

create_backup() {
    echo -e "${BLUE}💾 Tạo backup...${NC}"
    if [ -f "backup.sh" ]; then
        ./backup.sh
    else
        echo -e "${RED}❌ Script backup.sh không tồn tại${NC}"
    fi
}

clean_all() {
    echo -e "${RED}⚠️  CẢNH BÁO: Thao tác này sẽ xóa TẤT CẢ dữ liệu!${NC}"
    echo -e "${YELLOW}Nhấn Enter để tiếp tục, Ctrl+C để hủy...${NC}"
    read

    echo -e "${YELLOW}🧹 Dọn dẹp tất cả...${NC}"
    docker-compose down -v --remove-orphans
    docker system prune -f

    echo -e "${YELLOW}🗑️  Xóa thư mục dữ liệu...${NC}"
    sudo rm -rf n8n_data postgres_data

    echo -e "${GREEN}✅ Đã dọn dẹp xong${NC}"
}

show_access_info() {
    echo -e "${GREEN}🎉 Services đã sẵn sàng!${NC}"
    echo ""
    echo -e "${BLUE}📱 Thông tin truy cập:${NC}"
    echo -e "  🌐 n8n Web: ${GREEN}https://brief-perfect-mayfly.ngrok-free.app${NC}"
    echo -e "  👤 Username: ${GREEN}admin${NC}"
    echo -e "  🔑 Password: ${GREEN}d8c60508d30dad2f642d57391cd58919${NC}"
    echo ""
    echo -e "${BLUE}🔧 Debug interfaces:${NC}"
    echo -e "  🕳️  ngrok Web: ${GREEN}http://localhost:4040${NC}"
    echo -e "  🗄️  n8n Local: ${GREEN}http://localhost:5678${NC}"
    echo ""
    echo -e "${YELLOW}💡 Lệnh hữu ích:${NC}"
    echo -e "  ./manage-ngrok-n8n.sh logs     - Xem logs"
    echo -e "  ./manage-ngrok-n8n.sh status   - Kiểm tra trạng thái"
    echo -e "  ./manage-ngrok-n8n.sh ngrok-url - Lấy URL hiện tại"
    echo ""
}

# Main script
case "$1" in
    start)
        check_requirements
        start_services
        ;;
    stop)
        check_requirements
        stop_services
        ;;
    restart)
        check_requirements
        restart_services
        ;;
    logs)
        check_requirements
        show_logs
        ;;
    status)
        check_requirements
        show_status
        ;;
    ngrok-url)
        get_ngrok_url
        ;;
    update-env)
        check_requirements
        update_env_with_ngrok_url
        ;;
    backup)
        check_requirements
        create_backup
        ;;
    clean)
        check_requirements
        clean_all
        ;;
    setup)
        echo "Chạy setup-ngrok-n8n.sh với authtoken của bạn"
        ;;
    *)
        print_help
        ;;
esac