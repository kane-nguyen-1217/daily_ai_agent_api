Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # API versioning
  namespace :api do
    namespace :v1 do
      # Authentication endpoints
      post '/auth/register', to: 'authentication#register'
      post '/auth/login', to: 'authentication#login'
      post '/auth/refresh', to: 'authentication#refresh'
      post '/auth/logout', to: 'authentication#logout'
      
      # User profile
      get '/users/profile', to: 'users#profile'
      put '/users/profile', to: 'users#update_profile'
      
      # OAuth tokens management (Google Calendar/Gmail)
      resources :oauth_tokens, only: [:index, :create, :destroy] do
        collection do
          post '/google/callback', to: 'oauth_tokens#google_callback'
          get '/google/authorize', to: 'oauth_tokens#google_authorize'
        end
      end
      
      # Telegram linking
      resources :telegram_links, only: [:index, :create, :destroy] do
        collection do
          post '/verify', to: 'telegram_links#verify'
        end
      end
      
      # Automation settings
      resources :automation_settings, only: [:index, :show, :create, :update, :destroy]
      
      # Daily scheduler jobs
      resources :scheduler_jobs, only: [:index, :show, :create, :update, :destroy] do
        member do
          post '/run', to: 'scheduler_jobs#run_now'
          put '/enable', to: 'scheduler_jobs#enable'
          put '/disable', to: 'scheduler_jobs#disable'
        end
      end
      
      # AI summaries
      resources :ai_summaries, only: [:index, :show, :create] do
        collection do
          post '/generate', to: 'ai_summaries#generate'
        end
      end
      
      # Crypto data
      resources :crypto_data, only: [:index, :show] do
        collection do
          get '/prices', to: 'crypto_data#current_prices'
          get '/historical/:symbol', to: 'crypto_data#historical'
        end
      end
      
      # Alert history
      resources :alerts, only: [:index, :show, :create] do
        collection do
          get '/recent', to: 'alerts#recent'
        end
        member do
          put '/acknowledge', to: 'alerts#acknowledge'
        end
      end
      
      # n8n integration callbacks
      namespace :webhooks do
        post '/n8n/workflow', to: 'n8n#workflow_callback'
        post '/n8n/execute', to: 'n8n#execute'
        get '/n8n/status/:job_id', to: 'n8n#status'
      end
    end
  end

  # Health check endpoint
  get '/health', to: 'health#check'
end
