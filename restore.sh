#!/bin/bash
# n8n Restore Script - 2025 Enhanced Version
# Restores n8n data from backup files

set -e

echo "🔄 Starting n8n restore process..."

# Check if backup directory exists
if [ ! -d "./backups" ]; then
    echo "❌ Backup directory not found!"
    exit 1
fi

# List available backups
echo "📋 Available backups:"
ls -la ./backups/n8n_db_*.sql | head -10

# Get the most recent backup automatically or allow user to specify
if [ -z "$1" ]; then
    # Find the most recent backup
    LATEST_BACKUP=$(ls -t ./backups/n8n_db_*.sql | head -1)
    if [ -z "$LATEST_BACKUP" ]; then
        echo "❌ No database backups found!"
        exit 1
    fi

    # Extract timestamp from filename
    TIMESTAMP=$(basename "$LATEST_BACKUP" | sed 's/n8n_db_//' | sed 's/.sql//')
    echo "📅 Using latest backup: $TIMESTAMP"
else
    TIMESTAMP="$1"
    LATEST_BACKUP="./backups/n8n_db_${TIMESTAMP}.sql"
    if [ ! -f "$LATEST_BACKUP" ]; then
        echo "❌ Backup file not found: $LATEST_BACKUP"
        exit 1
    fi
    echo "📅 Using specified backup: $TIMESTAMP"
fi

# Detect configuration type
if [ -f "docker-compose-2025.yml" ]; then
    COMPOSE_FILE="docker-compose-2025.yml"
    echo "📋 Using 2025 configuration"
else
    COMPOSE_FILE="docker-compose.yml"
    echo "📋 Using legacy configuration"
fi

# Get database credentials
if [ -f ".env" ]; then
    source .env
    if [ -n "$POSTGRES_NON_ROOT_USER" ]; then
        DB_USER="$POSTGRES_NON_ROOT_USER"
        DB_PASS="$POSTGRES_NON_ROOT_PASSWORD"
        echo "   Using non-root user: $DB_USER"
    else
        DB_USER="n8n"
        DB_PASS="n8n_secure_password_2024"
        echo "   Using legacy user: $DB_USER"
    fi
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "⚠️  WARNING: This will replace all current n8n data!"
echo "   Database backup: $LATEST_BACKUP"
echo "   n8n data backup: ./backups/n8n_data_${TIMESTAMP}.tar.gz"
echo "   Shared data backup: ./backups/shared_data_${TIMESTAMP}.tar.gz"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Restore cancelled."
    exit 1
fi

echo "🛑 Stopping n8n services..."
docker compose -f $COMPOSE_FILE down

echo "🗄️  Restoring PostgreSQL database..."
# Start only PostgreSQL
docker compose -f $COMPOSE_FILE up -d postgres

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 10

# Drop existing database and recreate
echo "🗑️  Dropping existing database..."
PGPASSWORD=$POSTGRES_PASSWORD docker exec n8n_postgres psql -U $POSTGRES_USER -c "DROP DATABASE IF EXISTS $POSTGRES_DB;"
PGPASSWORD=$POSTGRES_PASSWORD docker exec n8n_postgres psql -U $POSTGRES_USER -c "CREATE DATABASE $POSTGRES_DB OWNER $DB_USER;"

# Restore database
echo "📤 Restoring database from backup..."
PGPASSWORD=$DB_PASS docker exec -i n8n_postgres psql -U $DB_USER -d $POSTGRES_DB < "$LATEST_BACKUP"

echo "📁 Restoring n8n data directory..."
# Remove existing n8n data
if [ -d "./n8n_data" ]; then
    sudo rm -rf ./n8n_data
fi

# Restore n8n data
N8N_DATA_BACKUP="./backups/n8n_data_${TIMESTAMP}.tar.gz"
if [ -f "$N8N_DATA_BACKUP" ]; then
    tar -xzf "$N8N_DATA_BACKUP"
    echo "✅ n8n data restored"
else
    echo "⚠️  n8n data backup not found: $N8N_DATA_BACKUP"
    echo "   Creating empty n8n_data directory..."
    mkdir -p ./n8n_data
fi

echo "📂 Restoring shared directory..."
# Restore shared data (2025 feature)
SHARED_DATA_BACKUP="./backups/shared_data_${TIMESTAMP}.tar.gz"
if [ -f "$SHARED_DATA_BACKUP" ]; then
    if [ -d "./shared" ]; then
        sudo rm -rf ./shared
    fi
    tar -xzf "$SHARED_DATA_BACKUP"
    echo "✅ Shared data restored"
else
    echo "⚠️  Shared data backup not found: $SHARED_DATA_BACKUP"
    echo "   Creating empty shared directory..."
    mkdir -p ./shared
fi

echo "⚙️  Restoring configuration files..."
# Restore .env if backup exists
ENV_BACKUP="./backups/env_${TIMESTAMP}.backup"
if [ -f "$ENV_BACKUP" ]; then
    echo "🔧 Found environment backup. Do you want to restore it?"
    echo "   Current .env will be backed up as .env.before_restore"
    read -p "Restore environment file? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp .env .env.before_restore
        cp "$ENV_BACKUP" .env
        echo "✅ Environment file restored"
    fi
else
    echo "⚠️  Environment backup not found: $ENV_BACKUP"
fi

echo "🔧 Fixing permissions..."
# Fix permissions
sudo chown -R $(whoami):$(whoami) ./n8n_data 2>/dev/null || true
sudo chown -R $(whoami):$(whoami) ./shared 2>/dev/null || true

echo "🚀 Starting n8n services..."
docker compose -f $COMPOSE_FILE up -d

echo "⏳ Waiting for services to be ready..."
sleep 15

echo "🎉 Restore completed successfully!"
echo ""
echo "📊 Restore summary:"
echo "   - Database: ✅ Restored from $LATEST_BACKUP"
echo "   - n8n Data: ✅ Restored from $N8N_DATA_BACKUP"
echo "   - Shared Data: ✅ Restored from $SHARED_DATA_BACKUP"
echo "   - Configuration: $([ -f "$ENV_BACKUP" ] && echo "✅ Available" || echo "⚠️  Not found")"
echo ""
echo "🌐 Access n8n at: http://localhost:5678"
echo "🔍 Check logs with: docker compose -f $COMPOSE_FILE logs -f"
echo ""
echo "📝 Notes:"
echo "   - If you restored .env, please restart services: docker compose -f $COMPOSE_FILE restart"
echo "   - Check that all workflows are working correctly"
echo "   - Consider creating a new backup after verification"