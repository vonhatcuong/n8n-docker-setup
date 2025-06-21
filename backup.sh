#!/bin/bash
# n8n Backup Script - Working Version

set -e

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"

echo "🔄 Starting n8n backup process..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ n8n containers are not running. Please start them first."
    exit 1
fi

echo "📦 Creating PostgreSQL backup..."
# Backup PostgreSQL database using docker exec with PGPASSWORD
docker exec -e PGPASSWORD=n8n_secure_password_2024 n8n_postgres pg_dump -U n8n -d n8n > $BACKUP_DIR/n8n_db_$DATE.sql

echo "📁 Creating n8n data backup..."
# Backup n8n data directory
if [ -d "./n8n_data" ]; then
    tar -czf $BACKUP_DIR/n8n_data_$DATE.tar.gz ./n8n_data
else
    echo "⚠️  n8n_data directory not found, skipping..."
fi

# Backup configuration files
if [ -f ".env" ]; then
    cp .env $BACKUP_DIR/env_$DATE.backup
fi

if [ -f "docker-compose.yml" ]; then
    cp docker-compose.yml $BACKUP_DIR/docker-compose_$DATE.yml
fi

echo "🎉 Backup completed successfully!"
echo "📂 Backup files created:"
echo "   - Database: $BACKUP_DIR/n8n_db_$DATE.sql"
if [ -f "$BACKUP_DIR/n8n_data_$DATE.tar.gz" ]; then
    echo "   - n8n Data: $BACKUP_DIR/n8n_data_$DATE.tar.gz"
fi
echo "   - Environment: $BACKUP_DIR/env_$DATE.backup"
echo "   - Docker Compose: $BACKUP_DIR/docker-compose_$DATE.yml"

# Show backup sizes
echo ""
echo "📊 Backup sizes:"
ls -lh $BACKUP_DIR/*$DATE* | awk '{print "   -", $9, "(" $5 ")"}'

# Clean old backups (keep only last 7 days)
find $BACKUP_DIR -name "n8n_*" -type f -mtime +7 -delete 2>/dev/null || true
find $BACKUP_DIR -name "env_*" -type f -mtime +7 -delete 2>/dev/null || true
find $BACKUP_DIR -name "docker-compose_*" -type f -mtime +7 -delete 2>/dev/null || true

echo ""
echo "🧹 Old backups cleaned (kept last 7 days)"
