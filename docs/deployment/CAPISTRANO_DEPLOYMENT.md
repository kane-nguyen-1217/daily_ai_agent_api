# Capistrano Deployment Guide

This guide covers automated deployment of the Daily AI Agent API using Capistrano.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Server Setup](#server-setup)
3. [Local Setup](#local-setup)
4. [Configuration](#configuration)
5. [First Deployment](#first-deployment)
6. [Regular Deployments](#regular-deployments)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Local Machine
- Ruby 3.3.0+
- Git access to the repository
- SSH key pair for server access

### Production Server
- Ubuntu 20.04+ or Debian 10+
- SSH access with sudo privileges
- Domain name pointing to server (for SSL)

## Server Setup

### 1. Initial Server Configuration

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl git build-essential libssl-dev libreadline-dev zlib1g-dev \
  libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
  xz-utils tk-dev libffi-dev liblzma-dev

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo -u postgres createuser --superuser deploy
sudo -u postgres createdb deploy

# Install Redis
sudo apt install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Install Nginx
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Create deploy user
sudo useradd -m -s /bin/bash deploy
sudo mkdir -p /home/deploy/.ssh
sudo chown -R deploy:deploy /home/deploy
```

### 2. Setup SSH Access

```bash
# On your local machine, copy your public key
cat ~/.ssh/id_rsa.pub

# On the server, add your public key
sudo -u deploy tee /home/deploy/.ssh/authorized_keys << 'EOF'
your_public_key_content_here
EOF

sudo chmod 600 /home/deploy/.ssh/authorized_keys
sudo chmod 700 /home/deploy/.ssh
sudo chown -R deploy:deploy /home/deploy/.ssh
```

### 3. Install Ruby (as deploy user)

```bash
# Switch to deploy user
sudo -u deploy -H bash

# Install rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby
rbenv install 3.3.0
rbenv global 3.3.0
gem install bundler
```

### 4. Database Setup

```bash
# Create production database and user
sudo -u postgres psql << 'EOF'
CREATE USER daily_ai_agent_user WITH PASSWORD 'secure_password_here';
CREATE DATABASE daily_ai_agent_api_production OWNER daily_ai_agent_user;
GRANT ALL PRIVILEGES ON DATABASE daily_ai_agent_api_production TO daily_ai_agent_user;
\q
EOF
```

## Local Setup

### 1. Install Capistrano Dependencies

```bash
# Already included in Gemfile, just run:
bundle install
```

### 2. Configure SSH

```bash
# Test SSH connection to your server
ssh deploy@your-server.com

# If using SSH keys with different names, configure ~/.ssh/config:
cat << 'EOF' >> ~/.ssh/config
Host production-server
  HostName your-server-ip-or-domain
  User deploy
  IdentityFile ~/.ssh/your-key-name
  ForwardAgent yes
EOF
```

## Configuration

### 1. Update Production Server Configuration

Edit `config/deploy/production.rb`:

```ruby
# Replace with your actual server details
server "your-server.com", user: "deploy", roles: %w{app db web}, primary: true

# Optional: Set server name for nginx configuration
set :server_name, "your-domain.com"
```

### 2. Create Production Environment File

Create `.env.production` locally with your production settings:

```bash
# Copy template and edit
cp .env.example .env.production
# Edit with production values
```

### 3. Configure SSH Agent (if needed)

```bash
# Add your SSH key to agent
ssh-add ~/.ssh/id_rsa

# Verify key is added
ssh-add -l
```

## First Deployment

### 1. Check Server Prerequisites

```bash
# Verify server is ready
cap production deploy:check_prerequisites
```

### 2. Initial Server Setup

```bash
# Run initial setup (only needed once)
cap production deploy:initial_setup
```

### 3. Upload Environment File

```bash
# Upload .env.production to server
scp .env.production deploy@your-server.com:/home/deploy/daily_ai_agent_api/shared/.env
```

### 4. Setup Database

```bash
# Create and migrate database
cap production deploy:setup_database
```

### 5. Setup Nginx

```bash
# Configure nginx (update server_name in config/deploy/production.rb first)
cap production deploy:setup_nginx
```

### 6. Setup SSL Certificate

```bash
# Install Let's Encrypt SSL certificate
cap production deploy:setup_ssl
```

### 7. First Deployment

```bash
# Deploy the application
cap production deploy

# If successful, start services
cap production systemd:create_services
cap production systemd:start
```

## Regular Deployments

### Standard Deployment

```bash
# Deploy latest code
cap production deploy
```

### Deployment with Specific Branch

```bash
# Deploy specific branch
cap production deploy BRANCH=feature-branch
```

### Rollback Deployment

```bash
# Rollback to previous release
cap production deploy:rollback
```

## Capistrano Commands

### Deployment Commands

```bash
# Check deployment configuration
cap production deploy:check

# Deploy application
cap production deploy

# Rollback to previous release
cap production deploy:rollback

# Show deployment status
cap production deploy:check_revision
```

### Server Management

```bash
# Restart application
cap production puma:restart
cap production sidekiq:restart

# Stop/Start services
cap production puma:stop
cap production puma:start
cap production sidekiq:stop  
cap production sidekiq:start

# Check logs
cap production logs:tail
```

### Database Operations

```bash
# Backup database
cap production deploy:backup_database

# Run migrations
cap production deploy:migrate

# Reset database (DANGER!)
cap production deploy:reset_database
```

### System Operations

```bash
# Update system packages
cap production deploy:update_system

# Check server status
cap production deploy:check_prerequisites

# Setup nginx
cap production deploy:setup_nginx

# Setup SSL
cap production deploy:setup_ssl
```

## File Structure After Deployment

```
/home/deploy/daily_ai_agent_api/
├── current -> releases/20231130120000
├── releases/
│   ├── 20231130120000/
│   └── 20231129110000/
├── shared/
│   ├── .env
│   ├── config/
│   │   └── master.key
│   ├── log/
│   ├── tmp/
│   │   ├── pids/
│   │   └── sockets/
│   └── vendor/
│       └── bundle/
└── repo/
```

## Troubleshooting

### Common Issues

#### SSH Connection Problems

```bash
# Test SSH connection
ssh -v deploy@your-server.com

# Check SSH agent
ssh-add -l

# Test with verbose output
cap production deploy:check --trace
```

#### Ruby/rbenv Issues

```bash
# Check Ruby version on server
cap production exec 'ruby --version'

# Check rbenv installation
cap production exec 'which ruby'
cap production exec 'rbenv versions'
```

#### Database Connection Issues

```bash
# Test database connection on server
cap production exec 'cd current && RAILS_ENV=production rails runner "puts ActiveRecord::Base.connection.execute(\"SELECT 1\").first"'

# Check database configuration
cap production exec 'cat shared/.env | grep DB_'
```

#### Permission Issues

```bash
# Fix file permissions
cap production exec 'chmod -R 755 /home/deploy/daily_ai_agent_api'
cap production exec 'chown -R deploy:deploy /home/deploy/daily_ai_agent_api'
```

#### Nginx Issues

```bash
# Check nginx configuration
cap production exec 'sudo nginx -t'

# Check nginx logs
cap production exec 'sudo tail -f /var/log/nginx/error.log'

# Restart nginx
cap production exec 'sudo systemctl restart nginx'
```

#### Service Issues

```bash
# Check systemd services
cap production exec 'sudo systemctl status daily-ai-agent-puma'
cap production exec 'sudo systemctl status daily-ai-agent-sidekiq'

# View service logs
cap production exec 'sudo journalctl -u daily-ai-agent-puma -f'
cap production exec 'sudo journalctl -u daily-ai-agent-sidekiq -f'
```

### Debugging Tips

#### Enable Verbose Logging

```bash
# Run with debug output
cap production deploy --trace

# Check Capistrano logs
tail -f log/capistrano.log
```

#### Manual Server Access

```bash
# SSH to server for manual debugging
ssh deploy@your-server.com
cd /home/deploy/daily_ai_agent_api/current

# Check application logs
tail -f log/production.log

# Check Puma/Sidekiq processes
ps aux | grep puma
ps aux | grep sidekiq
```

#### Environment Issues

```bash
# Check environment variables on server
cap production exec 'cd current && printenv | grep -E "(RAILS|DB|REDIS)"'

# Test Rails console
cap production exec 'cd current && RAILS_ENV=production rails console'
```

## Security Considerations

### SSH Security

- Use SSH keys instead of passwords
- Disable password authentication
- Use a non-standard SSH port
- Configure fail2ban

### Server Security

- Keep system packages updated
- Use firewall (ufw)
- Regular security audits
- Monitor logs

### Application Security

- Never commit secrets to version control
- Use strong database passwords
- Enable SSL/TLS
- Regular dependency updates

## Monitoring

### Log Locations

- **Application**: `/home/deploy/daily_ai_agent_api/current/log/production.log`
- **Puma**: `/home/deploy/daily_ai_agent_api/current/log/puma.*.log`
- **Sidekiq**: `/home/deploy/daily_ai_agent_api/shared/log/sidekiq.log`
- **Nginx**: `/var/log/nginx/access.log` and `/var/log/nginx/error.log`

### Health Checks

```bash
# API health check
curl https://your-domain.com/health

# Check all services
cap production deploy:check_prerequisites
```

## Support

For deployment issues:

1. Check the troubleshooting section above
2. Review logs on the server
3. Test components individually
4. Use `--trace` flag for detailed output

## Next Steps

- Set up monitoring (New Relic, Datadog)
- Configure automated backups
- Set up CI/CD pipeline
- Implement blue-green deployments
