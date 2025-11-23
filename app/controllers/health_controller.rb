class HealthController < ActionController::API
  def check
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      environment: Rails.env
    }
  end
end
