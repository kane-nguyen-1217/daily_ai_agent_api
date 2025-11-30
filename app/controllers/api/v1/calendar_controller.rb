module Api
  module V1
    class CalendarController < ApplicationController
      skip_before_action :authenticate_request, only: [:callback]

      # GET /api/v1/calendar/:provider/connect
      def connect
        provider = params[:provider]

        unless %w[google microsoft].include?(provider)
          return render json: { error: 'Invalid provider' }, status: :bad_request
        end

        authorization_url = case provider
                            when 'google'
                              google_authorization_url
                            when 'microsoft'
                              microsoft_authorization_url
                            end

        render json: { authorization_url: }
      end

      # GET /api/v1/calendar/:provider/callback
      def callback
        provider = params[:provider]
        code = params[:code]
        state = params[:state] # Contains user_id

        return render json: { error: 'Authorization code missing' }, status: :bad_request unless code.present?

        # Extract user_id from state parameter
        user_id = decode_state(state)
        user = User.find(user_id)

        # Exchange code for tokens
        token_response = exchange_code_for_tokens(provider, code)

        # Get user profile
        profile = fetch_user_profile(provider, token_response[:access_token])

        # Create or update calendar account
        CalendarAccountCreator.call(
          user:,
          provider:,
          token_response:,
          profile:
        )

        # Redirect to frontend with success
        frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:3001')
        redirect_to "#{frontend_url}/calendar/connected?provider=#{provider}&status=success", allow_other_host: true
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("Calendar callback error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))

        frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:3001')
        redirect_to "#{frontend_url}/calendar/connected?status=error&message=#{CGI.escape(e.message)}",
                    allow_other_host: true
      end

      private

      def google_authorization_url
        client_id = ENV['GOOGLE_CLIENT_ID']
        redirect_uri = callback_url('google')
        state = encode_state(current_user.id)

        scopes = [
          'openid',
          'email',
          'profile',
          'https://www.googleapis.com/auth/calendar.readonly'
        ].join(' ')

        params = {
          client_id:,
          redirect_uri:,
          response_type: 'code',
          scope: scopes,
          access_type: 'offline',
          prompt: 'consent',
          state:
        }

        "https://accounts.google.com/o/oauth2/v2/auth?#{URI.encode_www_form(params)}"
      end

      def microsoft_authorization_url
        client_id = ENV['MICROSOFT_CLIENT_ID']
        redirect_uri = callback_url('microsoft')
        state = encode_state(current_user.id)

        scopes = [
          'offline_access',
          'openid',
          'profile',
          'Calendars.Read'
        ].join(' ')

        params = {
          client_id:,
          redirect_uri:,
          response_type: 'code',
          scope: scopes,
          state:
        }

        "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?#{URI.encode_www_form(params)}"
      end

      def exchange_code_for_tokens(provider, code)
        case provider
        when 'google'
          exchange_google_code(code)
        when 'microsoft'
          exchange_microsoft_code(code)
        end
      end

      def exchange_google_code(code)
        require 'net/http'
        require 'json'

        uri = URI('https://oauth2.googleapis.com/token')
        params = {
          client_id: ENV['GOOGLE_CLIENT_ID'],
          client_secret: ENV['GOOGLE_CLIENT_SECRET'],
          code:,
          redirect_uri: callback_url('google'),
          grant_type: 'authorization_code'
        }

        response = Net::HTTP.post_form(uri, params)
        result = JSON.parse(response.body)

        unless response.code == '200'
          raise "Google token exchange failed: #{result['error_description'] || result['error']}"
        end

        {
          access_token: result['access_token'],
          refresh_token: result['refresh_token'],
          expires_in: result['expires_in'],
          scope: result['scope']
        }
      end

      def exchange_microsoft_code(code)
        require 'net/http'
        require 'json'

        uri = URI('https://login.microsoftonline.com/common/oauth2/v2.0/token')
        params = {
          client_id: ENV['MICROSOFT_CLIENT_ID'],
          client_secret: ENV['MICROSOFT_CLIENT_SECRET'],
          code:,
          redirect_uri: callback_url('microsoft'),
          grant_type: 'authorization_code'
        }

        response = Net::HTTP.post_form(uri, params)
        result = JSON.parse(response.body)

        unless response.code == '200'
          raise "Microsoft token exchange failed: #{result['error_description'] || result['error']}"
        end

        {
          access_token: result['access_token'],
          refresh_token: result['refresh_token'],
          expires_in: result['expires_in'],
          scope: result['scope']
        }
      end

      def fetch_user_profile(provider, access_token)
        case provider
        when 'google'
          fetch_google_profile(access_token)
        when 'microsoft'
          fetch_microsoft_profile(access_token)
        end
      end

      def fetch_google_profile(access_token)
        require 'net/http'
        require 'json'

        uri = URI('https://www.googleapis.com/oauth2/v2/userinfo')
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{access_token}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise 'Failed to fetch Google profile' unless response.code == '200'

        result = JSON.parse(response.body)
        {
          email: result['email'],
          name: result['name'],
          picture: result['picture']
        }
      end

      def fetch_microsoft_profile(access_token)
        require 'net/http'
        require 'json'

        uri = URI('https://graph.microsoft.com/v1.0/me')
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{access_token}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise 'Failed to fetch Microsoft profile' unless response.code == '200'

        result = JSON.parse(response.body)
        {
          email: result['mail'] || result['userPrincipalName'],
          name: result['displayName'],
          picture: nil # Microsoft Graph requires separate call for photo
        }
      end

      def callback_url(provider)
        "#{request.base_url}/api/v1/calendar/#{provider}/callback"
      end

      def encode_state(user_id)
        # Simple encoding - in production, use JWT or similar
        Base64.urlsafe_encode64("user_id:#{user_id}")
      end

      def decode_state(state)
        decoded = Base64.urlsafe_decode64(state)
        decoded.split(':').last.to_i
      rescue StandardError
        raise 'Invalid state parameter'
      end
    end
  end
end
