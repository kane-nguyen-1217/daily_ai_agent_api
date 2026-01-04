# Production deployment configuration
# Replace with your actual production server details

# server-based syntax
# ======================
# Example configuration - update with your actual server details:
# server "your-production-server.com", user: "deploy", roles: %w{app db web}

# For multiple servers:
# server "app1.example.com", user: "deploy", roles: %w{app}
# server "app2.example.com", user: "deploy", roles: %w{app}
# server "db.example.com", user: "deploy", roles: %w{db}

# role-based syntax (alternative)
# ==================
# role :app, %w{deploy@your-server.com}
# role :web, %w{deploy@your-server.com}
# role :db,  %w{deploy@your-server.com}

# Example single server configuration:
server "YOUR_SERVER_IP_OR_DOMAIN", user: "deploy", roles: %w{app db web}, primary: true

# Production-specific configuration
set :rails_env, 'production'
set :branch, 'main'

# SSH Options
set :ssh_options, {
  keys: %w(~/.ssh/id_rsa_personal),
  forward_agent: true,
  auth_methods: %w(publickey),
  port: 22
}

# Production-specific settings
set :puma_workers, 2
set :sidekiq_processes, 2

# Environment variables for production
set :default_env, {
  'RAILS_ENV' => 'production',
  'PATH' => "/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:$PATH",
  'RBENV_ROOT' => "/home/deploy/.rbenv",
  'RBENV_VERSION' => "3.3.0"
}
