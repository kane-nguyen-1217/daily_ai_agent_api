class ApplicationController < ActionController::API
  include JsonWebToken
  
  before_action :authenticate_request
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from JWT::DecodeError, with: :invalid_token
  
  private
  
  def authenticate_request
    header = request.headers['Authorization']
    return render_unauthorized('Missing token') unless header
    
    token = header.split(' ').last
    begin
      decoded = jwt_decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound
      render_unauthorized('Invalid token')
    rescue JWT::DecodeError => e
      render_unauthorized("Invalid token: #{e.message}")
    end
  end
  
  def current_user
    @current_user
  end
  
  def render_unauthorized(message = 'Unauthorized')
    render json: { error: message }, status: :unauthorized
  end
  
  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
  
  def record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
  
  def invalid_token(exception)
    render json: { error: "Invalid token: #{exception.message}" }, status: :unauthorized
  end
end
