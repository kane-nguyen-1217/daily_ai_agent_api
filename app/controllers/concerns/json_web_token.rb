module JsonWebToken
  extend ActiveSupport::Concern
  
  SECRET_KEY = ENV.fetch('JWT_SECRET_KEY') do
    if Rails.env.development? || Rails.env.test?
      Rails.application.credentials.secret_key_base || 'development_secret_key'
    else
      raise "JWT_SECRET_KEY environment variable must be set in production"
    end
  end
  
  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end
  
  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::ExpiredSignature
    raise JWT::DecodeError, 'Token has expired'
  rescue JWT::DecodeError => e
    raise JWT::DecodeError, e.message
  end
end
