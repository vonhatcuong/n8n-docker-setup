#!/bin/bash
# n8n Backup Script - 2025 Enhanced Version
# Supports both old and new configurations

set -e

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"

echo "🔄 Starting n8n 2025 backup process..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Detect configuration type
if [ -f "docker-compose-2025.yml" ]; then
    COMPOSE_FILE="docker-compose-2025.yml"
    echo "📋 Using 2025 configuration"
else
    COMPOSE_FILE="docker-compose.yml"
    echo "📋 Using legacy configuration"
fi

# Check if containers are running
if ! docker compose -f $COMPOSE_FILE ps | grep -q "Up"; then
    echo "❌ n8n containers are not running. Please start them first."
    exit 1
fi

echo "📦 Creating PostgreSQL backup..."
# Detect which user to use for backup
if grep -q "POSTGRES_NON_ROOT_USER" .env 2>/dev/null; then
    # 2025 configuration with non-root user
    DB_USER=$(grep "POSTGRES_NON_ROOT_USER=" .env | cut -d'=' -f2)
    DB_PASS=$(grep "POSTGRES_NON_ROOT_PASSWORD=" .env | cut -d'=' -f2)
    echo "   Using non-root user: $DB_USER"
else
    # Legacy configuration
    DB_USER="n8n"
    DB_PASS="n8n_secure_password_2024"
    echo "   Using legacy user: $DB_USER"
fi

# Backup PostgreSQL database
PGPASSWORD=$DB_PASS docker exec n8n_postgres pg_dump -U $DB_USER -d n8n > $BACKUP_DIR/n8n_db_$DATE.sql

echo "📁 Creating n8n data backup..."
# Backup n8n data directory
if [ -d "./n8n_data" ]; then
    tar -czf $BACKUP_DIR/n8n_data_$DATE.tar.gz ./n8n_data
else
    echo "⚠️  n8n_data directory not found, skipping..."
fi

# Backup shared directory (2025 feature)
if [ -d "./shared" ]; then
    echo "📂 Backing up shared directory..."
    tar -czf $BACKUP_DIR/shared_data_$DATE.tar.gz ./shared
fi

# Backup configuration files
echo "⚙️  Backing up configuration files..."
if [ -f ".env" ]; then
    cp .env $BACKUP_DIR/env_$DATE.backup
fi

if [ -f "$COMPOSE_FILE" ]; then
    cp $COMPOSE_FILE $BACKUP_DIR/docker-compose_$DATE.yml
fi

# Backup additional 2025 files
if [ -f "init-data-2025.sh" ]; then
    cp init-data-2025.sh $BACKUP_DIR/init-data_$DATE.sh
fi

if [ -f ".env.2025" ]; then
    cp .env.2025 $BACKUP_DIR/env-2025_$DATE.backup
fi

echo "🎉 Backup completed successfully!"
echo "📂 Backup files created:"
echo "   - Database: $BACKUP_DIR/n8n_db_$DATE.sql"
if [ -f "$BACKUP_DIR/n8n_data_$DATE.tar.gz" ]; then
    echo "   - n8n Data: $BACKUP_DIR/n8n_data_$DATE.tar.gz"
fi
if [ -f "$BACKUP_DIR/shared_data_$DATE.tar.gz" ]; then
    echo "   - Shared Data: $BACKUP_DIR/shared_data_$DATE.tar.gz"
fi
echo "   - Environment: $BACKUP_DIR/env_$DATE.backup"
echo "   - Docker Compose: $BACKUP_DIR/docker-compose_$DATE.yml"

# Show backup sizes
echo ""
echo "📊 Backup sizes:"
ls -lh $BACKUP_DIR/*$DATE* 2>/dev/null | awk '{print "   -", $9, "(" $5 ")"}'

# Clean old backups (keep only last 7 days)
find $BACKUP_DIR -name "n8n_*" -type f -mtime +7 -delete 2>/dev/null || true
find $BACKUP_DIR -name "env_*" -type f -mtime +7 -delete 2>/dev/null || true
find $BACKUP_DIR -name "docker-compose_*" -type f -mtime +7 -delete 2>/dev/null || true
find $BACKUP_DIR -name "shared_*" -type f -mtime +7 -delete 2>/dev/null || true

echo ""
echo "🧹 Old backups cleaned (kept last 7 days)"
