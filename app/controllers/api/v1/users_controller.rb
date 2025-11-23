module Api
  module V1
    class UsersController < ApplicationController
      def profile
        render json: {
          user: user_response(current_user)
        }
      end
      
      def update_profile
        if current_user.update(user_update_params)
          render json: {
            message: 'Profile updated successfully',
            user: user_response(current_user)
          }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def user_update_params
        params.permit(:full_name, :timezone, :password, :password_confirmation)
      end
      
      def user_response(user)
        {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          timezone: user.timezone,
          active: user.active,
          last_login_at: user.last_login_at,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
