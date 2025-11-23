module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request, only: [:register, :login]
      
      def register
        user = User.new(user_params)
        
        if user.save
          token = jwt_encode(user_id: user.id)
          render json: {
            message: 'User created successfully',
            token: token,
            user: user_response(user)
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def login
        user = User.find_by(email: params[:email]&.downcase)
        
        if user&.authenticate(params[:password])
          user.update_last_login!
          token = jwt_encode(user_id: user.id)
          refresh_token = jwt_encode({ user_id: user.id }, 7.days.from_now)
          
          render json: {
            message: 'Login successful',
            token: token,
            refresh_token: refresh_token,
            user: user_response(user)
          }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
      
      def refresh
        refresh_token = params[:refresh_token]
        decoded = jwt_decode(refresh_token)
        user = User.find(decoded[:user_id])
        
        token = jwt_encode(user_id: user.id)
        
        render json: {
          message: 'Token refreshed successfully',
          token: token
        }
      rescue JWT::DecodeError => e
        render json: { error: "Invalid refresh token: #{e.message}" }, status: :unauthorized
      end
      
      def logout
        # In a stateless JWT system, logout is typically handled client-side
        # Here we could blacklist the token if needed
        render json: { message: 'Logout successful' }
      end
      
      private
      
      def user_params
        params.permit(:email, :password, :password_confirmation, :full_name, :timezone)
      end
      
      def user_response(user)
        {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          timezone: user.timezone,
          active: user.active,
          created_at: user.created_at
        }
      end
    end
  end
end
