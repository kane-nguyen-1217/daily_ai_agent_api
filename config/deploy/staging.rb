# Staging deployment configuration
# Replace with your actual staging server details

# server-based syntax
# ======================
# Example configuration - update with your actual staging server details:
server "YOUR_STAGING_SERVER_IP_OR_DOMAIN", user: "deploy", roles: %w{app db web}, primary: true

# Staging-specific configuration
set :rails_env, 'production'  # or 'staging' if you have a staging environment
set :branch, 'develop'        # or whatever branch you use for staging

# SSH Options for staging
set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey),
  port: 22
}

# Staging-specific settings (lighter configuration)
set :puma_workers, 1
set :sidekiq_processes, 1

# Environment variables for staging
set :default_env, {
  'RAILS_ENV' => 'production',
  'PATH' => "/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:$PATH",
  'RBENV_ROOT' => "/home/deploy/.rbenv",
  'RBENV_VERSION' => "3.3.0"
}
