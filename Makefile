.PHONY: up down restart logs backup clean dev health install update

# Default target
help:
	@echo "🔧 n8n Docker Management Commands:"
	@echo ""
	@echo "  make up        - Start n8n services"
	@echo "  make down      - Stop n8n services"
	@echo "  make restart   - Restart n8n services"
	@echo "  make logs      - Show live logs"
	@echo "  make backup    - Create backup"
	@echo "  make clean     - Stop and remove all data (⚠️  DANGEROUS)"
	@echo "  make dev       - Start with development tools (pgAdmin)"
	@echo "  make health    - Check service health"
	@echo "  make install   - Initial setup"
	@echo "  make update    - Update to latest version"
	@echo ""

# Start services
up:
	@echo "🚀 Starting n8n services..."
	docker-compose up -d
	@echo "✅ n8n is starting up..."
	@echo "🌐 Web interface: http://localhost:5678"
	@echo "👤 Username: admin"
	@echo "🔑 Password: Check .env file"

# Stop services
down:
	@echo "🛑 Stopping n8n services..."
	docker-compose down

# Restart services
restart:
	@echo "🔄 Restarting n8n services..."
	docker-compose restart

# Show logs
logs:
	@echo "📋 Showing n8n logs (Ctrl+C to exit)..."
	docker-compose logs -f

# Create backup
backup:
	@echo "💾 Creating backup..."
	chmod +x backup.sh
	./backup.sh

# Clean everything (dangerous)
clean:
	@echo "⚠️  This will remove ALL data. Press Ctrl+C to cancel, or Enter to continue..."
	@read
	docker-compose down -v
	docker system prune -f
	sudo rm -rf n8n_data postgres_data backups
	@echo "🧹 All data cleaned"

# Start with development tools
dev:
	@echo "🔧 Starting n8n with development tools..."
	docker-compose --profile dev up -d
	@echo "✅ n8n is starting up..."
	@echo "🌐 n8n Web interface: http://localhost:5678"
	@echo "��️  pgAdmin: http://localhost:8080"

# Check health
health:
	@echo "🩺 Checking service health..."
	docker-compose ps
	@echo ""
	@echo "🌐 Testing web interface..."
	@curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:5678 || echo "❌ Web interface not accessible"

# Initial setup
install:
	@echo "🔧 Setting up n8n for the first time..."
	mkdir -p n8n_data postgres_data backups
	chmod +x backup.sh
	@echo "📁 Created data directories"
	@echo "✅ Setup complete! Run 'make up' to start"

# Update to latest version
update:
	@echo "🔄 Updating n8n..."
	docker-compose pull
	docker-compose up -d
	@echo "✅ Update complete!"
