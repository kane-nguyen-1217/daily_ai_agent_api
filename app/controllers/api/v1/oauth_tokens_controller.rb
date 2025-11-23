module Api
  module V1
    class OauthTokensController < ApplicationController
      before_action :set_oauth_token, only: [:destroy]
      
      def index
        tokens = current_user.oauth_tokens
        render json: {
          oauth_tokens: tokens.map { |token| token_response(token) }
        }
      end
      
      def create
        token = current_user.oauth_tokens.new(oauth_token_params)
        
        if token.save
          render json: {
            message: 'OAuth token saved successfully',
            oauth_token: token_response(token)
          }, status: :created
        else
          render json: { errors: token.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @oauth_token.destroy
        render json: { message: 'OAuth token removed successfully' }
      end
      
      def google_authorize
        # Generate OAuth2 authorization URL
        client = google_oauth_client
        auth_url = client.auth_code.authorize_url(
          redirect_uri: params[:redirect_uri] || ENV['GOOGLE_OAUTH_REDIRECT_URI'],
          scope: params[:scope] || 'https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/gmail.readonly',
          access_type: 'offline',
          prompt: 'consent'
        )
        
        render json: { authorization_url: auth_url }
      end
      
      def google_callback
        client = google_oauth_client
        token = client.auth_code.get_token(
          params[:code],
          redirect_uri: params[:redirect_uri] || ENV['GOOGLE_OAUTH_REDIRECT_URI']
        )
        
        oauth_token = current_user.oauth_tokens.find_or_initialize_by(provider: 'google')
        oauth_token.assign_attributes(
          access_token: token.token,
          refresh_token: token.refresh_token,
          expires_at: Time.at(token.expires_at),
          scope: token.params['scope']
        )
        
        if oauth_token.save
          render json: {
            message: 'Google OAuth token saved successfully',
            oauth_token: token_response(oauth_token)
          }
        else
          render json: { errors: oauth_token.errors.full_messages }, status: :unprocessable_entity
        end
      rescue OAuth2::Error => e
        render json: { error: "OAuth error: #{e.message}" }, status: :unprocessable_entity
      end
      
      private
      
      def set_oauth_token
        @oauth_token = current_user.oauth_tokens.find(params[:id])
      end
      
      def oauth_token_params
        params.permit(:provider, :access_token, :refresh_token, :expires_at, :scope)
      end
      
      def token_response(token)
        {
          id: token.id,
          provider: token.provider,
          scope: token.scope,
          expires_at: token.expires_at,
          expired: token.expired?,
          created_at: token.created_at
        }
      end
      
      def google_oauth_client
        OAuth2::Client.new(
          ENV['GOOGLE_CLIENT_ID'],
          ENV['GOOGLE_CLIENT_SECRET'],
          site: 'https://accounts.google.com',
          token_url: '/o/oauth2/token',
          authorize_url: '/o/oauth2/auth'
        )
      end
    end
  end
end
