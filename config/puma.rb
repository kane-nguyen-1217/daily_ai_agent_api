# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Production-specific configuration
if ENV["RAILS_ENV"] == "production"
  # Number of workers (should match server CPU cores)
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  
  # Unix socket for nginx reverse proxy
  bind "unix://#{Dir.pwd}/tmp/sockets/puma.sock"
  
  # Logging
  stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true
  
  # Set master PID and state locations for Capistrano
  pidfile "tmp/pids/puma.pid"
  state_path "tmp/pids/puma.state"
  
  # Preload application for better memory usage
  preload_app!
  
  # Worker timeout for production
  worker_timeout 60
  worker_boot_timeout 60
  
  # Restart workers on code changes
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
  
  on_restart do
    puts 'Refreshing Gemfile'
    ENV["BUNDLE_GEMFILE"] = ""
  end
else
  # Development configuration keeps existing settings
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
