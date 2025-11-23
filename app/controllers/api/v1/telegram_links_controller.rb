module Api
  module V1
    class TelegramLinksController < ApplicationController
      before_action :set_telegram_link, only: [:destroy]
      
      def index
        links = current_user.telegram_links.active
        render json: {
          telegram_links: links.map { |link| link_response(link) }
        }
      end
      
      def create
        link = current_user.telegram_links.new(telegram_link_params)
        
        if link.save
          render json: {
            message: 'Telegram link created successfully. Please verify using the code.',
            telegram_link: link_response(link),
            verification_code: link.verification_code
          }, status: :created
        else
          render json: { errors: link.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def verify
        link = current_user.telegram_links.find(params[:id])
        
        if link.verify!(params[:verification_code])
          render json: {
            message: 'Telegram link verified successfully',
            telegram_link: link_response(link)
          }
        else
          render json: { error: 'Invalid verification code' }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @telegram_link.update!(active: false)
        render json: { message: 'Telegram link removed successfully' }
      end
      
      private
      
      def set_telegram_link
        @telegram_link = current_user.telegram_links.find(params[:id])
      end
      
      def telegram_link_params
        params.permit(:telegram_user_id, :telegram_username)
      end
      
      def link_response(link)
        {
          id: link.id,
          telegram_user_id: link.telegram_user_id,
          telegram_username: link.telegram_username,
          verified: link.verified,
          verified_at: link.verified_at,
          active: link.active,
          created_at: link.created_at
        }
      end
    end
  end
end
