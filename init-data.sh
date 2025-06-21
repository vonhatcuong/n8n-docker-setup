#!/bin/bash
# PostgreSQL initialization script for n8n 2025 setup
# Creates non-root user with proper permissions

set -e

echo "🔧 Initializing PostgreSQL for n8n..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create non-root user for n8n
    CREATE USER $POSTGRES_NON_ROOT_USER WITH PASSWORD '$POSTGRES_NON_ROOT_PASSWORD';
    
    -- Grant database privileges
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_NON_ROOT_USER;
    
    -- Grant schema privileges
    GRANT ALL ON SCHEMA public TO $POSTGRES_NON_ROOT_USER;
    
    -- Grant default privileges for future objects
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $POSTGRES_NON_ROOT_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $POSTGRES_NON_ROOT_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO $POSTGRES_NON_ROOT_USER;
    
    -- Show created user
    SELECT usename FROM pg_user WHERE usename = '$POSTGRES_NON_ROOT_USER';
EOSQL

echo "✅ PostgreSQL initialization complete!"
echo "   - Created user: $POSTGRES_NON_ROOT_USER"
echo "   - Database: $POSTGRES_DB"
echo "   - Privileges: ALL on database and schema"
