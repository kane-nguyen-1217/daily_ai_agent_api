# Custom deployment tasks for Daily AI Agent API

namespace :deploy do
  desc 'Setup server for first time deployment'
  task :initial_setup do
    on roles(:app) do
      # Create deploy user and directories
      execute :sudo, 'useradd -m -s /bin/bash deploy' rescue nil
      execute :sudo, 'mkdir -p /home/deploy/.ssh'
      execute :sudo, 'chown -R deploy:deploy /home/deploy'
      
      # Setup rbenv for deploy user
      as :deploy do
        execute 'curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash'
        execute 'echo \'export PATH="$HOME/.rbenv/bin:$PATH"\' >> ~/.bashrc'
        execute 'echo \'eval "$(rbenv init -)"\' >> ~/.bashrc'
        execute 'source ~/.bashrc'
        execute '~/.rbenv/bin/rbenv install 3.3.0'
        execute '~/.rbenv/bin/rbenv global 3.3.0'
        execute '~/.rbenv/shims/gem install bundler'
      end
      
      # Create application directory
      execute :sudo, 'mkdir -p /home/deploy/daily_ai_agent_api'
      execute :sudo, 'chown -R deploy:deploy /home/deploy/daily_ai_agent_api'
      
      info 'Initial server setup completed!'
      info 'Next steps:'
      info '1. Copy your SSH public key to /home/deploy/.ssh/authorized_keys'
      info '2. Update config/deploy/production.rb with your server details'
      info '3. Create .env file on server with production settings'
      info '4. Run: cap production deploy:setup_database'
    end
  end

  desc 'Setup database for first deployment'
  task :setup_database do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rails, 'db:create'
          execute :rails, 'db:migrate'
          execute :rails, 'db:seed'
        end
      end
    end
  end

  desc 'Check server prerequisites'
  task :check_prerequisites do
    on roles(:app) do
      # Check if required services are installed and running
      services = %w[postgresql redis nginx]
      services.each do |service|
        if test :sudo, 'systemctl is-active --quiet', service
          info "✓ #{service} is running"
        else
          error "✗ #{service} is not running or not installed"
        end
      end
      
      # Check Ruby version
      ruby_version = capture(:ruby, '--version')
      info "Ruby version: #{ruby_version}"
      
      # Check disk space
      disk_usage = capture(:df, '-h /')
      info "Disk usage: #{disk_usage}"
    end
  end

  desc 'Backup database before deployment'
  task :backup_database do
    on roles(:db) do
      backup_name = "backup_#{Time.now.strftime('%Y%m%d_%H%M%S')}.sql"
      execute :pg_dump, 
              '-h localhost',
              '-U daily_ai_agent_user',
              'daily_ai_agent_api_production',
              '>', 
              "/home/deploy/#{backup_name}"
      info "Database backup created: /home/deploy/#{backup_name}"
    end
  end

  desc 'Update system packages'
  task :update_system do
    on roles(:app) do
      execute :sudo, 'apt update && apt upgrade -y'
      info 'System packages updated'
    end
  end

  desc 'Setup nginx configuration'
  task :setup_nginx do
    on roles(:web) do
      nginx_config = <<-CONFIG
upstream puma_daily_ai_agent_api {
  server unix:///home/deploy/daily_ai_agent_api/shared/tmp/sockets/daily_ai_agent_api-puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name #{fetch(:server_name, 'localhost')};
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name #{fetch(:server_name, 'localhost')};
  
  root /home/deploy/daily_ai_agent_api/current/public;
  
  # SSL configuration (update paths to your certificates)
  ssl_certificate /etc/letsencrypt/live/#{fetch(:server_name, 'localhost')}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/#{fetch(:server_name, 'localhost')}/privkey.pem;
  
  # Security headers
  add_header X-Frame-Options DENY always;
  add_header X-Content-Type-Options nosniff always;
  add_header X-XSS-Protection "1; mode=block" always;
  
  # Gzip compression
  gzip on;
  gzip_vary on;
  gzip_min_length 1024;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
  
  location / {
    try_files $uri @puma;
  }
  
  location @puma {
    proxy_pass http://puma_daily_ai_agent_api;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
    proxy_read_timeout 300;
    proxy_send_timeout 300;
  }
  
  # Health check
  location /health {
    proxy_pass http://puma_daily_ai_agent_api;
    access_log off;
  }
  
  # Assets
  location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
  }
}
CONFIG

      execute :sudo, 'tee /etc/nginx/sites-available/daily_ai_agent_api', stdin: nginx_config
      execute :sudo, 'ln -sf /etc/nginx/sites-available/daily_ai_agent_api /etc/nginx/sites-enabled/'
      execute :sudo, 'nginx -t'
      execute :sudo, 'systemctl reload nginx'
      
      info 'Nginx configuration updated'
    end
  end

  desc 'Setup SSL with Let\'s Encrypt'
  task :setup_ssl do
    on roles(:web) do
      server_name = fetch(:server_name) || ask('Enter your domain name:')
      
      execute :sudo, 'apt install -y certbot python3-certbot-nginx'
      execute :sudo, 'certbot --nginx -d', server_name, '--non-interactive --agree-tos --email admin@' + server_name
      
      # Setup auto-renewal
      execute :sudo, 'crontab -l | grep -v certbot; echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -'
      
      info 'SSL certificate installed and auto-renewal configured'
    end
  end
end

# Hooks
before 'deploy:starting', 'deploy:check_prerequisites'
before 'deploy:migrate', 'deploy:backup_database'
