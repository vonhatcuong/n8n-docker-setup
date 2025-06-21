# 🚀 n8n Docker Setup - 2025 Edition

Production-ready n8n setup with Docker Compose, PostgreSQL, Redis Queue, and AI-optimized configuration following 2025 best practices.

## ✨ Features

-   🤖 **AI-Ready**: Optimized for OpenAI, Anthropic, Mistral integrations
-   ⚡ **Redis Queue**: Scalable workflow execution for heavy AI workloads
-   🔒 **Security First**: JWT secrets, basic auth, non-root PostgreSQL
-   🐳 **Docker Compose**: Easy deployment with official 2025 image
-   🗄️ **PostgreSQL 16**: Non-root user setup with optimized configuration
-   📊 **pgAdmin**: Database management interface (development mode)
-   🔄 **Task Runners**: Enhanced performance for code nodes
-   📁 **Shared Storage**: File sharing between workflows for AI processing
-   💾 **Automated Backups**: Regular backup script with cleanup
-   🛠️ **Development Tools**: Makefile for easy management

## 🚀 Quick Start

### 1. Initial Setup

```bash
# Clone or download this setup
cd n8n-docker-setup

# Run initial setup
make install

# Copy and configure environment variables
cp .env.example .env
# Edit .env with your secure passwords and keys
```

### 2. Generate Secure Keys

```bash
# Generate encryption key
openssl rand -base64 32

# Generate admin password
openssl rand -hex 16
```

### 3. Start n8n

```bash
# Start n8n services
make up

# Or start with development tools (includes pgAdmin)
make dev
```

### 4. Access Applications

-   **n8n Web Interface**: http://localhost:5678
-   **pgAdmin** (dev mode): http://localhost:8080

## 📋 Available Commands

```bash
make help         # Show all available commands
make up           # Start n8n services
make down         # Stop services
make restart      # Restart services
make logs         # Show live logs
make backup       # Create backup
make health       # Check service health
make dev          # Start with development tools (pgAdmin)
make queue        # Start with Redis queue (high-scale AI workflows)
make update       # Update to latest version
make migrate      # Migrate from old config to 2025
make clean        # Remove all data (⚠️ DANGEROUS)
```

## 🤖 AI Workflow Features

### Redis Queue for Scalable AI

```bash
# Start with Redis queue for heavy AI workloads
make queue
```

**Benefits:**

-   ⚡ Non-blocking AI workflow execution
-   🔄 Queue management for multiple AI tasks
-   📈 Better resource utilization
-   🚀 Scalable to multiple workers

### AI-Ready Configuration

The setup includes optimized settings for AI workflows:

```bash
# Enhanced settings in .env
N8N_AI_ENABLED=true
N8N_PAYLOAD_SIZE_MAX=32          # 32MB for large AI responses
N8N_WORKFLOW_TIMEOUT=300         # 5min timeout for AI processing
N8N_CONCURRENCY_PRODUCTION=2     # Concurrent executions
N8N_FUNCTION_ALLOW_EXTERNAL=*    # Allow external AI libraries
```

### Supported AI Integrations

Ready for popular AI services:

-   🧠 **OpenAI GPT**: ChatGPT, GPT-4, DALL-E
-   🤖 **Anthropic Claude**: Claude-3, Claude-2
-   ⚡ **Mistral AI**: Mixtral, Mistral-7B
-   🔧 **Custom AI APIs**: Flexible function support

## 🔧 Configuration

### Environment Variables (.env)

| Variable                         | Description               | Example                                 |
| -------------------------------- | ------------------------- | --------------------------------------- |
| `POSTGRES_PASSWORD`              | Database password         | `secure_db_password`                    |
| `POSTGRES_NON_ROOT_USER`         | Non-root DB user          | `n8n`                                   |
| `POSTGRES_NON_ROOT_PASSWORD`     | Non-root DB password      | `secure_n8n_password`                   |
| `N8N_BASIC_AUTH_USER`            | Admin username            | `admin`                                 |
| `N8N_BASIC_AUTH_PASSWORD`        | Admin password            | `secure_admin_password`                 |
| `N8N_ENCRYPTION_KEY`             | Data encryption key       | Generate with `openssl rand -base64 32` |
| `N8N_USER_MANAGEMENT_JWT_SECRET` | JWT secret (2025 feature) | Generate with `openssl rand -base64 32` |
| `GENERIC_TIMEZONE`               | Server timezone           | `Asia/Ho_Chi_Minh`                      |
| `N8N_LOG_LEVEL`                  | Logging level             | `info`                                  |
| `N8N_AI_OPENAI_API_KEY`          | OpenAI API key (optional) | `sk-...`                                |
| `N8N_AI_ANTHROPIC_API_KEY`       | Anthropic API key         | `sk-ant-...`                            |
| `N8N_AI_MISTRAL_API_KEY`         | Mistral API key           | `...`                                   |

### Security Features

-   ✅ Basic authentication enabled
-   ✅ Strong encryption key
-   ✅ PostgreSQL with SCRAM-SHA-256 authentication
-   ✅ Services bound to localhost only
-   ✅ Resource limits configured
-   ✅ Secure logging configuration

## 💾 Backup & Restore

### Automatic Backup

```bash
# Create backup (includes database and n8n data)
make backup
```

### Manual Restore

```bash
# Stop services
make down

# Restore database
cat backups/n8n_db_YYYYMMDD_HHMMSS.sql | docker-compose exec -T postgres psql -U n8n -d n8n

# Restore n8n data
tar -xzf backups/n8n_data_YYYYMMDD_HHMMSS.tar.gz

# Start services
make up
```

## 🔍 Monitoring & Maintenance

### Health Check

```bash
make health
```

### View Logs

```bash
# Live logs
make logs

# Container-specific logs
docker-compose logs -f n8n
docker-compose logs -f postgres
```

### Performance Monitoring

-   n8n metrics are enabled (`N8N_METRICS=true`)
-   PostgreSQL logging configured for slow queries
-   Resource limits prevent memory issues

## 🛠️ Development

### With pgAdmin

```bash
# Start with development tools
make dev

# Access pgAdmin at http://localhost:8080
# Email: admin@localhost.com
# Password: Same as N8N_BASIC_AUTH_PASSWORD
```

### Custom PostgreSQL Configuration

Edit `postgres.conf` to tune database performance for your needs.

## 📁 Directory Structure

```
n8n-docker-setup/
├── docker-compose.yml      # Main compose file
├── .env                    # Environment variables (private)
├── .env.example           # Environment template
├── postgres.conf          # PostgreSQL configuration
├── backup.sh              # Backup script
├── Makefile               # Management commands
├── README.md              # This file
├── .gitignore             # Git ignore rules
├── backups/               # Backup storage
├── n8n_data/              # n8n application data
└── postgres_data/         # PostgreSQL data
```

## 🚨 Important Security Notes

1. **Change Default Passwords**: Update all passwords in `.env`
2. **Secure Encryption Key**: Generate a strong encryption key
3. **Keep Backups Safe**: Store backups in a secure location
4. **Regular Updates**: Keep n8n and PostgreSQL updated
5. **Monitor Logs**: Check logs regularly for security issues

## 🔄 Updating n8n

```bash
# Update to latest version
make update

# Or update to specific version
# Edit docker-compose.yml and change image tag
# Then run: make down && make up
```

## 🆘 Troubleshooting

### Common Issues

**Service won't start:**

```bash
# Check logs
make logs

# Check health
make health

# Reset everything (⚠️ loses data)
make clean && make install && make up
```

**Database connection issues:**

```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Reset database
make down
sudo rm -rf postgres_data
make up
```

**Permission issues:**

```bash
# Fix permissions
chmod +x backup.sh
sudo chown -R $(whoami):$(whoami) n8n_data postgres_data
```

## 📞 Support

-   [n8n Documentation](https://docs.n8n.io/)
-   [n8n Community Forum](https://community.n8n.io/)
-   [Docker Compose Documentation](https://docs.docker.com/compose/)

## 📄 License

This setup is provided as-is under MIT License. n8n has its own licensing terms.
