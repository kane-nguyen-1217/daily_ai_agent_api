# Development deployment configuration
# Server: 104.248.144.165
# Domain: api.person-agent.site

# server-based syntax
# ======================
server "104.248.144.165", user: "deploy", roles: %w{app db web}, primary: true

# Development-specific configuration
set :rails_env, 'production'
set :branch, 'main'        # deploy from main branch for development environment

# Development-specific settings
set :puma_workers, 1
set :sidekiq_processes, 1

# Environment variables for development
set :default_env, {
  'RAILS_ENV' => 'production',
  'PATH' => "/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:$PATH",
  'RBENV_ROOT' => "/home/deploy/.rbenv",
  'RBENV_VERSION' => "3.3.3"
}
