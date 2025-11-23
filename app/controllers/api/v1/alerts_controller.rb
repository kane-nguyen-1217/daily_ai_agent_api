module Api
  module V1
    class AlertsController < ApplicationController
      before_action :set_alert, only: [:show, :acknowledge]
      
      def index
        alerts = current_user.alerts.recent(50)
        alerts = alerts.by_type(params[:alert_type]) if params[:alert_type].present?
        alerts = alerts.by_severity(params[:severity]) if params[:severity].present?
        alerts = alerts.unacknowledged if params[:unacknowledged] == 'true'
        
        render json: {
          alerts: alerts.map { |alert| alert_response(alert) }
        }
      end
      
      def show
        render json: {
          alert: alert_response(@alert)
        }
      end
      
      def create
        alert = current_user.alerts.new(alert_params)
        
        if alert.save
          # Optionally send notification
          alert.send_notification! if params[:send_notification] == 'true'
          
          render json: {
            message: 'Alert created successfully',
            alert: alert_response(alert)
          }, status: :created
        else
          render json: { errors: alert.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def recent
        limit = [params[:limit].to_i, 100].min
        limit = 20 if limit <= 0
        
        alerts = current_user.alerts.recent(limit)
        render json: {
          alerts: alerts.map { |alert| alert_response(alert) }
        }
      end
      
      def acknowledge
        @alert.acknowledge!
        render json: {
          message: 'Alert acknowledged successfully',
          alert: alert_response(@alert)
        }
      end
      
      private
      
      def set_alert
        @alert = current_user.alerts.find(params[:id])
      end
      
      def alert_params
        params.permit(:alert_type, :title, :message, :severity, metadata: {})
      end
      
      def alert_response(alert)
        {
          id: alert.id,
          alert_type: alert.alert_type,
          title: alert.title,
          message: alert.message,
          severity: alert.severity,
          metadata: alert.metadata,
          acknowledged: alert.acknowledged,
          acknowledged_at: alert.acknowledged_at,
          sent: alert.sent,
          sent_at: alert.sent_at,
          created_at: alert.created_at
        }
      end
    end
  end
end
