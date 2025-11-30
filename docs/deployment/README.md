# Deployment Documentation

This directory contains deployment guides and configurations for the Daily AI Agent API.

## 📋 Overview

The Daily AI Agent API supports native deployment on various platforms including VPS servers, Heroku, and cloud platforms.

## 📚 Documentation

### [🤖 Capistrano Deployment Guide](CAPISTRANO_DEPLOYMENT.md)
**Automated deployment with Capistrano (Recommended)**

- **Automated Deployments** - One-command deployments with rollback
- **Server Setup** - Complete server configuration automation
- **Service Management** - Puma, Sidekiq, and Nginx integration
- **SSL Automation** - Let's Encrypt integration
- **Database Management** - Migrations and backups
- **Monitoring** - Health checks and log management

### [🚀 Production Deployment Guide](PRODUCTION_DEPLOYMENT.md)
**Manual deployment for production environments**

- **VPS Deployment** - Traditional server setup with systemd services
- **Heroku Deployment** - Platform-as-a-Service deployment
- **Cloud Platforms** - AWS, GCP, DigitalOcean deployment
- **SSL Configuration** - HTTPS setup with Let's Encrypt  
- **Process Management** - systemd services and monitoring
- **Environment Configuration** - Production security settings

## 🚀 Quick Deployment Options

### Capistrano Automated Deployment (Recommended)
```bash
# Setup server and deploy in one go
bundle install
# Configure config/deploy/production.rb with server details
cap production deploy:initial_setup
cap production deploy
```

### VPS/Server Manual Deployment
```bash
# Server setup (Ubuntu/Debian)
sudo apt update && sudo apt install -y ruby postgresql redis nginx
git clone <repository-url>
cd daily_ai_agent_api
bundle install --deployment
cp .env.example .env
# Configure .env with production values
RAILS_ENV=production rails db:create db:migrate
```

### Heroku Deployment
```bash
heroku create your-app-name
heroku addons:create heroku-postgresql:mini
heroku addons:create heroku-redis:mini
git push heroku main
heroku run rails db:migrate
```

### Cloud Platform
- **AWS Elastic Beanstalk** - Managed application platform
- **DigitalOcean App Platform** - Simple container deployment
- **Google Cloud Run** - Serverless container deployment

## 🏗️ Deployment Requirements

### System Requirements
- **Ruby** 3.2+
- **PostgreSQL** 14+
- **Redis** 6+
- **Nginx** (recommended for reverse proxy)
- **SSL Certificate** (Let's Encrypt or commercial)

### Environment Configuration
```bash
# Core production settings
RAILS_ENV=production
SECRET_KEY_BASE=secure_64_character_string
JWT_SECRET_KEY=secure_jwt_secret
LOCKBOX_MASTER_KEY=64_character_hex_key

# Database
DB_HOST=your_production_db_host
DB_NAME=daily_ai_agent_api_production
DB_USERNAME=secure_db_user
DB_PASSWORD=secure_db_password

# External APIs
GOOGLE_CLIENT_ID=production_google_oauth_id
GOOGLE_CLIENT_SECRET=production_google_oauth_secret
OPENAI_API_KEY=production_openai_key
```

## 🔧 Process Management

### systemd Services (VPS)
- **Application Service** - Rails API server with Puma
- **Background Jobs** - Sidekiq worker processes
- **Automatic Restart** - Service recovery on failures
- **Log Management** - Centralized logging with journald

### Platform Services (Heroku/Cloud)
- **Web Dynos** - Application processes
- **Worker Dynos** - Background job processing  
- **Managed Databases** - PostgreSQL and Redis
- **Auto-scaling** - Based on load and metrics

## 🌐 Reverse Proxy Configuration

### nginx Configuration
```nginx
upstream puma {
  server unix:///path/to/app/tmp/sockets/puma.sock;
}

server {
  listen 443 ssl http2;
  server_name yourdomain.com;
  
  location / {
    proxy_pass http://puma;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

## 🔒 Security Configuration

### Production Security
- **SSL/TLS Encryption** - HTTPS everywhere
- **Environment Variables** - Secure secret management
- **Database Security** - Connection encryption and strong passwords
- **API Security** - Rate limiting and CORS configuration
- **Server Security** - Firewall, SSH keys, regular updates

### Monitoring & Alerts
- **Health Checks** - API endpoint monitoring
- **Performance Monitoring** - Response times and throughput
- **Error Tracking** - Application error alerts
- **Resource Monitoring** - CPU, memory, disk usage
- **Log Aggregation** - Centralized logging and analysis

## 📊 Deployment Verification

### Health Checks
```bash
# API health check
curl https://yourdomain.com/health

# Database connectivity
curl https://yourdomain.com/api/v1/health/database

# Background jobs status
curl https://yourdomain.com/api/v1/health/sidekiq
```

### Performance Tests
```bash
# Basic load test
ab -n 1000 -c 10 https://yourdomain.com/health

# API endpoint test
curl -X GET https://yourdomain.com/api/v1/users \
  -H "Authorization: Bearer your_token"
```

## 🛠️ Maintenance Tasks

### Regular Maintenance
- **Database Backups** - Automated daily backups
- **Log Rotation** - Prevent disk space issues
- **Security Updates** - System and dependency updates
- **Performance Monitoring** - Track metrics and optimize
- **SSL Certificate Renewal** - Automatic with Let's Encrypt

### Deployment Updates
```bash
# Application updates
git pull origin main
bundle install --deployment
RAILS_ENV=production rails db:migrate
sudo systemctl restart daily-ai-agent
```

## 🆘 Troubleshooting

### Common Deployment Issues
1. **Environment Variables** - Missing or incorrect configuration
2. **Database Connections** - Network or credential issues
3. **SSL Certificates** - Expired or misconfigured certificates
4. **Process Management** - Service startup or restart failures
5. **Resource Limits** - Memory or disk space constraints

### Debug Commands
```bash
# Check service status
sudo systemctl status daily-ai-agent

# View application logs
tail -f log/production.log

# Check nginx configuration
sudo nginx -t

# Verify SSL certificate
openssl s_client -connect yourdomain.com:443
```

## 🔗 Related Documentation

- [Setup Guide](../setup/SETUP_GUIDE.md) - Installation requirements
- [API Documentation](../api/API_DOCUMENTATION.md) - API reference
- [Database Schema](../database/DATABASE_SCHEMA.md) - Database structure
- [Development Guide](../development/CONTRIBUTING.md) - Development setup

---

**Next Steps:** Choose your deployment method and follow the detailed guide in [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)
