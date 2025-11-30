# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "daily_ai_agent_api"
set :repo_url, "git@github.com:kane-nguyen-1217/daily_ai_agent_api.git"

# Default branch is :main
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Deploy to directory
set :deploy_to, "/home/deploy/#{fetch(:application)}"

# Logging
set :format, :airbrussh
set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# SSH settings
set :pty, true

# Linked files and directories
append :linked_files, ".env", "config/master.key"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", ".bundle", "public/system"

# Environment
set :default_env, { 
  'PATH' => "/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:$PATH",
  'RBENV_ROOT' => "/home/deploy/.rbenv",
  'RBENV_VERSION' => "3.3.0"
}

# Keep releases
set :keep_releases, 5

# Rbenv settings
set :rbenv_type, :user
set :rbenv_ruby, '3.3.0'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails puma pumactl}

# Puma settings
set :puma_threads, [4, 16]
set :puma_workers, 0
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

# Sidekiq settings
set :sidekiq_default_hooks, true
set :sidekiq_pid, -> { File.join(shared_path, 'tmp', 'pids', 'sidekiq.pid') }
set :sidekiq_env, fetch(:rails_env, 'production')
set :sidekiq_log, -> { File.join(shared_path, 'log', 'sidekiq.log') }
set :sidekiq_processes, 1

# Rails settings
set :rails_env, 'production'
set :conditionally_migrate, true
set :migration_role, :app

# Bundle settings
set :bundle_flags, '--deployment --quiet'
set :bundle_env_variables, { 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1 }

# Deployment hooks
namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 10 do
      invoke 'puma:restart'
      invoke 'sidekiq:restart'
    end
  end

  after :publishing, :restart

  desc 'Upload .env file'
  task :upload_env do
    on roles(:app) do
      unless test("[ -f #{shared_path}/.env ]")
        info "Uploading .env file to #{shared_path}/.env"
        upload! '.env.production', "#{shared_path}/.env"
      else
        info ".env file already exists on server"
      end
    end
  end

  desc 'Create database'
  task :create_database do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rails, 'db:create'
        end
      end
    end
  end
end
