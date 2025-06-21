# N8N Docker Management - 2025 Best Practices
.PHONY: help install up down restart logs backup health clean dev queue generate-keys update migrate status

# Default target
help:
	@echo "🚀 n8n Docker Management Commands (2025 Edition):"
	@echo ""
	@echo "  make install       - Initial setup with key generation"
	@echo "  make generate-keys - Generate new encryption & JWT keys"
	@echo "  make up            - Start n8n services"
	@echo "  make down          - Stop services"
	@echo "  make restart       - Restart services"
	@echo "  make logs          - Show live logs"
	@echo "  make backup        - Create backup"
	@echo "  make health        - Check service health"
	@echo "  make dev           - Start with development tools (pgAdmin)"
	@echo "  make queue         - Start with Redis queue (high-scale)"
	@echo "  make update        - Update to latest version"
	@echo "  make migrate       - Migrate from old config to 2025"
	@echo "  make clean         - Stop and remove all data (⚠️  DANGEROUS)"
	@echo "  make status        - Show detailed status"
	@echo ""

# Generate encryption keys
generate-keys:
	@echo "🔑 Generating new encryption keys..."
	@echo "N8N_ENCRYPTION_KEY=$$(openssl rand -base64 32)" >> .env.new
	@echo "N8N_USER_MANAGEMENT_JWT_SECRET=$$(openssl rand -base64 32)" >> .env.new
	@echo "✅ Keys generated in .env.new - please review and merge"

# Initial setup
install:
	@echo "🔧 Setting up n8n 2025 configuration..."
	mkdir -p n8n_data postgres_data backups shared
	chmod +x backup.sh init-data-2025.sh
	@if [ ! -f .env ]; then \
		echo "📋 Copying .env template..."; \
		cp .env.2025 .env; \
		echo "⚠️  Please edit .env with your passwords!"; \
	fi
	@echo "✅ Setup complete! Edit .env then run 'make up'"

# Start services (2025 version)
up:
	@echo "🚀 Starting n8n 2025 services..."
	docker compose -f docker-compose-2025.yml up -d
	@echo "✅ n8n is starting up..."
	@echo "🌐 Web interface: http://localhost:5678"
	@echo "👤 Username: admin"
	@echo "🔑 Password: Check .env file"

# Stop services
down:
	@echo "🛑 Stopping n8n services..."
	docker compose -f docker-compose-2025.yml down

# Restart services
restart:
	@echo "🔄 Restarting n8n services..."
	docker compose -f docker-compose-2025.yml restart

# Show logs
logs:
	@echo "�� Showing n8n logs (Ctrl+C to exit)..."
	docker compose -f docker-compose-2025.yml logs -f

# Create backup
backup:
	@echo "💾 Creating backup..."
	chmod +x backup.sh
	./backup.sh

# Development mode with pgAdmin
dev:
	@echo "🔧 Starting n8n with development tools..."
	docker compose -f docker-compose-2025.yml --profile dev up -d
	@echo "✅ n8n is starting up..."
	@echo "🌐 n8n Web interface: http://localhost:5678"
	@echo "🗄️  pgAdmin: http://localhost:8080"

# Queue mode with Redis
queue:
	@echo "⚡ Starting n8n with Redis queue (high-scale)..."
	docker compose -f docker-compose-2025.yml --profile queue up -d
	@echo "✅ n8n with queue mode starting..."
	@echo "📊 Redis cache enabled for better performance"

# Check health
health:
	@echo "🩺 Checking service health..."
	docker compose -f docker-compose-2025.yml ps
	@echo ""
	@echo "🌐 Testing web interface..."
	@curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:5678 || echo "❌ Web interface not accessible"

# Clean everything
clean:
	@echo "⚠️  This will remove ALL data. Press Ctrl+C to cancel, or Enter to continue..."
	@read
	docker compose -f docker-compose-2025.yml down -v --remove-orphans
	docker system prune -f
	sudo rm -rf n8n_data postgres_data backups shared
	@echo "🧹 All data cleaned"

# Update to latest version
update:
	@echo "🔄 Updating n8n to latest version..."
	docker compose -f docker-compose-2025.yml pull
	docker compose -f docker-compose-2025.yml up -d --force-recreate
	@echo "✅ Update complete!"

# Migration from old config
migrate:
	@echo "🔄 Migrating to 2025 configuration..."
	@echo "1. Stopping old services..."
	-docker compose down
	@echo "2. Backing up current data..."
	cp .env .env-backup-migration-$(shell date +%Y%m%d)
	cp docker-compose.yml docker-compose-backup-migration-$(shell date +%Y%m%d).yml
	@echo "3. Installing 2025 config..."
	cp .env.2025 .env
	cp docker-compose-2025.yml docker-compose.yml
	cp init-data-2025.sh init-data.sh
	@echo "4. Please review .env file and run 'make up'"
	@echo "✅ Migration prepared! Check .env then start with 'make up'"

# Detailed status
status:
	@echo "📊 n8n System Status:"
	@echo ""
	@echo "🐳 Docker Containers:"
	docker compose -f docker-compose-2025.yml ps
	@echo ""
	@echo "�� Disk Usage:"
	du -sh n8n_data postgres_data backups shared 2>/dev/null || echo "Data directories not found"
	@echo ""
	@echo "🌐 Network Status:"
	docker network ls | grep n8n || echo "No n8n networks found"
	@echo ""
	@echo "📋 Recent Logs:"
	docker compose -f docker-compose-2025.yml logs --tail=5 n8n 2>/dev/null || echo "No logs available"
