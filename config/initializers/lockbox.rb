Lockbox.master_key = ENV.fetch('LOCKBOX_MASTER_KEY') do
  # Generate a key with: Lockbox.generate_key
  # In development/test, we'll use a default key (not for production!)
  if Rails.env.development? || Rails.env.test?
    "0" * 64 # 64 character hex string for development
  else
    raise "LOCKBOX_MASTER_KEY environment variable must be set in production"
  end
end
