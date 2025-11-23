module Api
  module V1
    class AutomationSettingsController < ApplicationController
      before_action :set_automation_setting, only: [:show, :update, :destroy]
      
      def index
        settings = current_user.automation_settings.ordered
        settings = settings.enabled if params[:enabled] == 'true'
        settings = settings.by_type(params[:type]) if params[:type].present?
        
        render json: {
          automation_settings: settings.map { |setting| setting_response(setting) }
        }
      end
      
      def show
        render json: {
          automation_setting: setting_response(@automation_setting)
        }
      end
      
      def create
        setting = current_user.automation_settings.new(automation_setting_params)
        
        if setting.save
          render json: {
            message: 'Automation setting created successfully',
            automation_setting: setting_response(setting)
          }, status: :created
        else
          render json: { errors: setting.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        if @automation_setting.update(automation_setting_params)
          render json: {
            message: 'Automation setting updated successfully',
            automation_setting: setting_response(@automation_setting)
          }
        else
          render json: { errors: @automation_setting.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @automation_setting.destroy
        render json: { message: 'Automation setting deleted successfully' }
      end
      
      private
      
      def set_automation_setting
        @automation_setting = current_user.automation_settings.find(params[:id])
      end
      
      def automation_setting_params
        params.permit(:name, :automation_type, :enabled, :priority, configuration: {})
      end
      
      def setting_response(setting)
        {
          id: setting.id,
          name: setting.name,
          automation_type: setting.automation_type,
          configuration: setting.configuration,
          enabled: setting.enabled,
          priority: setting.priority,
          created_at: setting.created_at,
          updated_at: setting.updated_at
        }
      end
    end
  end
end
