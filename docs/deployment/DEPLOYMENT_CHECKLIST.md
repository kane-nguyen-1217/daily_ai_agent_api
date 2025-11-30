# Capistrano Deployment Checklist

## Pre-Deployment Checklist

### Local Setup
- [ ] Bundle install completed: `bundle install`
- [ ] SSH key configured for server access
- [ ] Server details configured in `config/deploy/production.rb`
- [ ] `.env.production` file created with production values
- [ ] Code committed and pushed to repository

### Server Preparation
- [ ] Server has Ubuntu 20.04+ or Debian 10+
- [ ] Deploy user created with sudo privileges
- [ ] SSH key added to server's authorized_keys
- [ ] PostgreSQL installed and running
- [ ] Redis installed and running
- [ ] Nginx installed and running

## First-Time Deployment

### 1. Initial Server Setup
```bash
cap production deploy:initial_setup
```

### 2. Upload Environment File
```bash
scp .env.production deploy@your-server.com:/home/deploy/daily_ai_agent_api/shared/.env
```

### 3. Setup Database
```bash
cap production deploy:setup_database
```

### 4. Configure Web Server
```bash
cap production deploy:setup_nginx
```

### 5. Setup SSL Certificate
```bash
cap production deploy:setup_ssl
```

### 6. First Deployment
```bash
cap production deploy
```

### 7. Start Services
```bash
cap production systemd:create_services
cap production systemd:start
```

## Regular Deployments

### Standard Deployment Process
```bash
# 1. Check server status
cap production deploy:check_prerequisites

# 2. Backup database (automatic)
# This happens automatically before migration

# 3. Deploy
cap production deploy

# 4. Verify deployment
curl https://your-domain.com/health
```

## Post-Deployment Verification

### Health Checks
- [ ] API responds: `curl https://your-domain.com/health`
- [ ] Database connected: Check application logs
- [ ] Background jobs processing: Check Sidekiq web interface
- [ ] SSL certificate valid: Check browser
- [ ] All services running: `systemctl status daily-ai-agent-*`

### Log Monitoring
- [ ] Application logs: `tail -f /home/deploy/daily_ai_agent_api/current/log/production.log`
- [ ] Nginx logs: `tail -f /var/log/nginx/error.log`
- [ ] System logs: `journalctl -u daily-ai-agent-puma -f`

## Rollback Procedure

If deployment fails or issues are discovered:

```bash
# Rollback to previous version
cap production deploy:rollback

# Check status after rollback
cap production deploy:check_prerequisites
curl https://your-domain.com/health
```

## Troubleshooting Commands

### Check Deployment Status
```bash
cap production deploy:check
cap production doctor
```

### Service Management
```bash
# Restart services
cap production puma:restart
cap production sidekiq:restart

# Check service status
ssh deploy@your-server.com 'sudo systemctl status daily-ai-agent-puma'
ssh deploy@your-server.com 'sudo systemctl status daily-ai-agent-sidekiq'
```

### Log Access
```bash
# Tail application logs
ssh deploy@your-server.com 'tail -f /home/deploy/daily_ai_agent_api/current/log/production.log'

# Check Capistrano logs locally
tail -f log/capistrano.log
```

### Manual Server Access
```bash
ssh deploy@your-server.com
cd /home/deploy/daily_ai_agent_api/current
sudo systemctl status daily-ai-agent-puma
sudo systemctl status daily-ai-agent-sidekiq
```

## Environment Variables Checklist

Ensure these are set in your `.env.production`:

### Required
- [ ] `SECRET_KEY_BASE` - Rails secret key
- [ ] `JWT_SECRET_KEY` - JWT signing key
- [ ] `LOCKBOX_MASTER_KEY` - Encryption key
- [ ] `DB_HOST`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD` - Database config

### External Services
- [ ] `OPENAI_API_KEY` - AI service integration
- [ ] `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` - Google OAuth
- [ ] `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET` - Microsoft OAuth
- [ ] `TELEGRAM_BOT_TOKEN` - Telegram notifications
- [ ] `N8N_API_KEY`, `N8N_WEBHOOK_SECRET` - n8n integration

### Production Settings
- [ ] `RAILS_ENV=production`
- [ ] `FORCE_SSL=true`
- [ ] `ALLOWED_ORIGINS` - Your domain(s)
- [ ] `FRONTEND_URL` - Your frontend URL

## Maintenance Tasks

### Weekly
- [ ] Check server disk space
- [ ] Review application logs for errors
- [ ] Verify backup completion
- [ ] Check SSL certificate expiration

### Monthly
- [ ] Update system packages: `cap production deploy:update_system`
- [ ] Review security logs
- [ ] Performance monitoring review
- [ ] Database maintenance

### As Needed
- [ ] Deploy new features: `cap production deploy`
- [ ] Scale services if needed
- [ ] Update environment variables
- [ ] Security patches deployment

## Emergency Contacts

- **Server Provider**: [Your hosting provider support]
- **Domain/DNS Provider**: [Your domain registrar support]
- **SSL Certificate**: Let's Encrypt (auto-renewal configured)
- **Application Monitoring**: [Your monitoring service]

## Quick Reference

### Most Common Commands
```bash
# Deploy
cap production deploy

# Rollback
cap production deploy:rollback

# Restart services
cap production puma:restart
cap production sidekiq:restart

# Check status
cap production deploy:check_prerequisites

# Access server
ssh deploy@your-server.com
```

### File Locations on Server
- **Application**: `/home/deploy/daily_ai_agent_api/current/`
- **Environment**: `/home/deploy/daily_ai_agent_api/shared/.env`
- **Logs**: `/home/deploy/daily_ai_agent_api/current/log/`
- **Nginx Config**: `/etc/nginx/sites-available/daily_ai_agent_api`
- **SSL Certs**: `/etc/letsencrypt/live/your-domain.com/`
