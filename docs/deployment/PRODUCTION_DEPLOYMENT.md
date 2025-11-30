# Production Deployment Guide

This guide covers deploying the Daily AI Agent API to production servers and cloud platforms.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [VPS Deployment](#vps-deployment)
3. [Heroku Deployment](#heroku-deployment)
4. [Cloud Platform Deployment](#cloud-platform-deployment)
5. [Environment Configuration](#environment-configuration)
6. [Process Management](#process-management)
7. [Monitoring & Maintenance](#monitoring--maintenance)

## Prerequisites

### System Requirements
- Ruby 3.2+
- PostgreSQL 14+
- Redis 6+
- Nginx (recommended)
- SSL Certificate

### Domain & DNS
- Domain name configured
- DNS records pointing to your server
- SSL certificate (Let's Encrypt recommended)

## VPS Deployment

### 1. Server Setup (Ubuntu/Debian)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl git build-essential libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev

# Install Ruby (using rbenv)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 3.2.0
rbenv global 3.2.0
gem install bundler

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo -u postgres createuser --superuser $USER
sudo -u postgres createdb $USER

# Install Redis
sudo apt install -y redis-server
sudo systemctl enable redis-server

# Install Nginx
sudo apt install -y nginx
sudo systemctl enable nginx
```

### 2. Application Deployment

```bash
# Clone repository
git clone https://github.com/your-username/daily_ai_agent_api.git
cd daily_ai_agent_api

# Install gems
bundle install --deployment --without development test

# Configure environment
cp .env.example .env
# Edit .env with production values

# Setup database
RAILS_ENV=production rails db:create db:migrate

# Precompile assets (if any)
RAILS_ENV=production rails assets:precompile

# Set file permissions
chmod 600 .env
```

### 3. Nginx Configuration

Create `/etc/nginx/sites-available/daily_ai_agent_api`:

```nginx
upstream puma {
  server unix:///home/deploy/daily_ai_agent_api/shared/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name yourdomain.com www.yourdomain.com;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name yourdomain.com www.yourdomain.com;

  root /home/deploy/daily_ai_agent_api/public;

  ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

  location / {
    proxy_pass http://puma;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/daily_ai_agent_api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 4. SSL Setup with Let's Encrypt

```bash
# Install certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal (already set up by certbot)
sudo crontab -l | grep certbot
```

## Heroku Deployment

### 1. Setup Heroku CLI

```bash
# Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Login
heroku login
```

### 2. Create Heroku App

```bash
# Create app
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Add Redis
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set RAILS_ENV=production
heroku config:set SECRET_KEY_BASE=$(rails secret)
heroku config:set JWT_SECRET_KEY=$(rails secret)
heroku config:set LOCKBOX_MASTER_KEY=$(ruby -e "require 'securerandom'; puts SecureRandom.hex(32)")

# Add other environment variables
heroku config:set GOOGLE_CLIENT_ID=your_google_client_id
heroku config:set GOOGLE_CLIENT_SECRET=your_google_client_secret
# ... add all required environment variables
```

### 3. Deploy

```bash
# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate

# Check logs
heroku logs --tail
```

## Cloud Platform Deployment

### AWS (Elastic Beanstalk)

1. **Setup EB CLI**
```bash
pip install awsebcli
eb init
```

2. **Configure Environment**
```bash
eb create production
eb setenv RAILS_ENV=production SECRET_KEY_BASE=your_secret
# Set other environment variables
```

3. **Deploy**
```bash
eb deploy
```

### DigitalOcean App Platform

1. **Create App**
   - Connect GitHub repository
   - Configure environment variables
   - Set build and run commands

2. **Database**
   - Add managed PostgreSQL database
   - Add managed Redis cluster

3. **Domain**
   - Configure custom domain
   - Enable SSL

## Environment Configuration

### Production Environment Variables

```bash
# Database
DB_HOST=your_db_host
DB_NAME=daily_ai_agent_api_production
DB_USERNAME=your_db_user
DB_PASSWORD=secure_password

# Security
RAILS_ENV=production
SECRET_KEY_BASE=64_character_random_string
JWT_SECRET_KEY=secure_jwt_secret
LOCKBOX_MASTER_KEY=64_character_hex_key

# External Services
GOOGLE_CLIENT_ID=production_google_id
GOOGLE_CLIENT_SECRET=production_google_secret
OPENAI_API_KEY=production_openai_key

# Performance
RAILS_MAX_THREADS=10
WEB_CONCURRENCY=2
RAILS_LOG_TO_STDOUT=true

# Security
FORCE_SSL=true
ALLOWED_ORIGINS=https://yourdomain.com
```

### Security Best Practices

- Use strong, unique passwords
- Keep environment variables secure
- Enable SSL/TLS everywhere
- Regular security updates
- Monitor access logs
- Use SSH keys for server access

## Process Management

### Systemd Services

Create `/etc/systemd/system/daily-ai-agent.service`:

```ini
[Unit]
Description=Daily AI Agent API
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/daily_ai_agent_api
Environment=RAILS_ENV=production
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
```

Create `/etc/systemd/system/daily-ai-agent-sidekiq.service`:

```ini
[Unit]
Description=Daily AI Agent Sidekiq
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/daily_ai_agent_api
Environment=RAILS_ENV=production
ExecStart=/home/deploy/.rbenv/shims/bundle exec sidekiq
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start services:
```bash
sudo systemctl enable daily-ai-agent daily-ai-agent-sidekiq
sudo systemctl start daily-ai-agent daily-ai-agent-sidekiq
```

## Monitoring & Maintenance

### Health Checks

```bash
# API health check
curl https://yourdomain.com/health

# Database connection
RAILS_ENV=production rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1').first"

# Redis connection
redis-cli ping
```

### Log Management

```bash
# Application logs
tail -f log/production.log

# System logs
sudo journalctl -u daily-ai-agent -f
sudo journalctl -u daily-ai-agent-sidekiq -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Backup Strategy

```bash
# Database backup
pg_dump daily_ai_agent_api_production > backup_$(date +%Y%m%d).sql

# Automated backups (cron)
0 2 * * * pg_dump daily_ai_agent_api_production | gzip > /backups/db_$(date +\%Y\%m\%d).sql.gz
```

### Performance Monitoring

- **Application Performance Monitoring** (e.g., New Relic, Scout)
- **Server monitoring** (e.g., Datadog, Prometheus)
- **Log aggregation** (e.g., ELK stack, Papertrail)
- **Uptime monitoring** (e.g., Pingdom, UptimeRobot)

### Updates & Maintenance

```bash
# Application updates
git pull origin main
bundle install --deployment
RAILS_ENV=production rails db:migrate
sudo systemctl restart daily-ai-agent

# System updates
sudo apt update && sudo apt upgrade -y
sudo reboot  # if kernel updates
```

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Check file ownership and permissions
   - Ensure deploy user has proper access

2. **Database Connection**
   - Verify PostgreSQL is running
   - Check connection credentials
   - Confirm firewall rules

3. **SSL Issues**
   - Verify certificate validity
   - Check nginx configuration
   - Ensure proper domain DNS

4. **Performance Issues**
   - Monitor resource usage
   - Check database query performance
   - Review application logs

## Support

For deployment support:
- Check [Setup Guide](../setup/SETUP_GUIDE.md)
- Review [API Documentation](../api/API_DOCUMENTATION.md)
- See [Contributing Guidelines](../development/CONTRIBUTING.md)
