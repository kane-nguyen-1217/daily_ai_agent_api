# OAuth Integration Documentation

Documentation for OAuth 2.0 integrations including Google and Microsoft authentication flows.

## 🔐 OAuth Overview

The Daily AI Agent API implements OAuth 2.0 for secure integration with external services:
- **Google Services** - Calendar, Gmail, Drive access
- **Microsoft Services** - Outlook Calendar, Office 365
- **Secure Token Management** - Encrypted storage and automatic refresh
- **Multi-Provider Support** - Multiple OAuth providers per user

## 🔗 OAuth Providers

### **Google OAuth**
- **Services**: Google Calendar, Gmail  
- **Scopes**: Calendar read, email access
- **Setup**: Google Cloud Console
- **Redirect URIs**: `/api/v1/calendar/google/callback`

### **Microsoft OAuth**  
- **Services**: Outlook Calendar, Office 365
- **Scopes**: Calendar read, profile access
- **Setup**: Azure Portal
- **Redirect URIs**: `/api/v1/calendar/microsoft/callback`

## 🚀 OAuth Flow Implementation

### **1. Authorization Request**
```bash
# Initiate Google OAuth
GET /api/v1/calendar/google/connect
Authorization: Bearer <jwt_token>

Response:
{
  "authorization_url": "https://accounts.google.com/oauth/authorize?client_id=..."
}
```

### **2. User Authorization**
- User redirected to provider (Google/Microsoft)
- User grants permissions
- Provider redirects to callback URL with auth code

### **3. Token Exchange**
```bash
# Automatic callback handling
GET /api/v1/calendar/:provider/callback?code=auth_code&state=user_state

# System exchanges code for tokens
# Stores encrypted tokens in database
# Redirects to frontend with success/error
```

## 🔧 Setup Instructions

### **Google OAuth Setup**

#### 1. **Google Cloud Console**
1. Visit: https://console.cloud.google.com/apis/credentials
2. Create new project or select existing
3. Enable APIs: Google Calendar API, Google+ API
4. Create OAuth 2.0 Client ID

#### 2. **Configure Credentials**  
- **Application Type**: Web application
- **Authorized Redirect URIs**:
  ```
  http://localhost:3000/api/v1/calendar/google/callback    # Development
  https://yourdomain.com/api/v1/calendar/google/callback  # Production
  ```

#### 3. **Required Scopes**
```
https://www.googleapis.com/auth/calendar.readonly
https://www.googleapis.com/auth/userinfo.email
```

#### 4. **Environment Variables**
```bash
GOOGLE_CLIENT_ID=123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-AbCdEfGhIjKlMnOpQrStUvWxYz
```

### **Microsoft OAuth Setup**

#### 1. **Azure Portal**
1. Visit: https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps
2. Click "New registration"
3. Configure application settings

#### 2. **Configure Application**
- **Name**: Your App Name - Calendar Integration
- **Supported Account Types**: Personal and organizational accounts
- **Redirect URI**: Web platform
  ```
  http://localhost:3000/api/v1/calendar/microsoft/callback    # Development  
  https://yourdomain.com/api/v1/calendar/microsoft/callback  # Production
  ```

#### 3. **API Permissions**
- Microsoft Graph - Delegated permissions:
  - `Calendars.Read`
  - `User.Read`
  - `offline_access`

#### 4. **Create Client Secret**
- Go to "Certificates & secrets"
- Create new client secret
- Copy secret value immediately

#### 5. **Environment Variables**
```bash
MICROSOFT_CLIENT_ID=12345678-1234-1234-1234-123456789abc
MICROSOFT_CLIENT_SECRET=AbC~123456789-._~AbCdEfGhIjKlMnOpQr
```

## 🗄️ Database Schema

### **oauth_tokens table**
```sql
id                        - Primary key
user_id                   - Foreign key to users
provider                  - 'google', 'gmail', 'calendar'
access_token_ciphertext   - Encrypted access token
refresh_token_ciphertext  - Encrypted refresh token
expires_at                - Token expiration timestamp
scope                     - Granted OAuth scopes
token_metadata            - Provider-specific data
```

### **calendar_accounts table** (Calendar-specific)
```sql
id            - Primary key
user_id       - Foreign key to users  
provider      - 'google', 'microsoft'
email         - Calendar account email
access_token  - Encrypted OAuth access token (Rails 7 encrypts)
refresh_token - Encrypted OAuth refresh token
expires_at    - Token expiration
active        - Connection status
```

## 🔐 Security Features

### **Token Encryption**
```ruby
# OAuth tokens (Lockbox encryption)
encrypts :access_token
encrypts :refresh_token

# Calendar tokens (Rails 7 encryption)  
encrypts :access_token, :refresh_token
```

### **Token Refresh**
```ruby
# Automatic token refresh
def ensure_access_token!
  return access_token unless expired?
  refresh_access_token!
end

# Provider-specific refresh
def refresh_google_token!
  # Exchange refresh_token for new access_token
  # Update expires_at timestamp
end
```

### **Error Handling**
```ruby
# Mark account inactive on token failure
def mark_inactive_and_notify!
  update!(active: false)
  # Send notification to user
  # Request reconnection
end
```

## 🧪 Testing OAuth Integration

### **Development Testing**
```bash
# Test OAuth initiation
curl -H "Authorization: Bearer <jwt_token>" \
     http://localhost:3000/api/v1/calendar/google/connect

# Expected response
{
  "authorization_url": "https://accounts.google.com/oauth/authorize?..."
}
```

### **Manual OAuth Flow**
1. Get authorization URL from API
2. Visit URL in browser
3. Grant permissions
4. Check callback success
5. Verify token storage:
   ```bash
   rails console
   User.first.calendar_accounts.active
   ```

### **Token Validation**
```ruby
# Check token status
account = CalendarAccount.first
puts "Expired: #{account.expired?}"
puts "Active: #{account.active?}"

# Test token refresh
account.refresh_access_token!
```

## 🔄 OAuth State Management

### **State Parameter**
```ruby
# Generate secure state with user ID
state = Base64.encode64({
  user_id: current_user.id,
  timestamp: Time.current.to_i,
  nonce: SecureRandom.hex(16)
}.to_json)

# Validate state in callback
decoded_state = JSON.parse(Base64.decode64(params[:state]))
user = User.find(decoded_state['user_id'])
```

### **CSRF Protection**
- State parameter prevents CSRF attacks
- Timestamp prevents replay attacks  
- Nonce provides additional randomness

## 🔍 Debugging OAuth Issues

### **Common Problems**

#### Invalid Redirect URI
```
Error: redirect_uri_mismatch
Solution: Ensure redirect URIs match exactly in OAuth app settings
```

#### Invalid Client ID/Secret
```  
Error: invalid_client
Solution: Verify client credentials in environment variables
```

#### Insufficient Scopes
```
Error: insufficient_scope  
Solution: Request proper scopes in OAuth app configuration
```

#### Token Expired
```
Error: invalid_token
Solution: System automatically refreshes or marks account inactive
```

### **Debug Commands**
```bash
# Check OAuth app configuration
rails console
puts ENV['GOOGLE_CLIENT_ID']
puts ENV['MICROSOFT_CLIENT_ID']

# Check callback URL generation
Rails.application.routes.url_helpers.api_v1_calendar_google_callback_url

# Test token refresh
account = CalendarAccount.first
account.refresh_access_token!
```

## 📊 Monitoring OAuth Health

### **Key Metrics**
```ruby
# Active OAuth connections by provider
CalendarAccount.active.group(:provider).count

# Token expiration monitoring  
CalendarAccount.where('expires_at < ?', 1.day.from_now).count

# Failed refresh attempts
CalendarAccount.where(active: false).count
```

### **Automated Monitoring**
```ruby
# Daily token health check
CalendarAccount.find_each do |account|
  if account.expires_at < 1.day.from_now
    account.refresh_access_token!
  end
rescue => e
  # Log error, mark inactive, notify user
end
```

## 🔗 Related Documentation

- **[Calendar Integration](../calendar-integration/)** - Calendar-specific OAuth usage
- **[Database Schema](../database/)** - OAuth token storage models
- **[API Documentation](../api/)** - OAuth endpoint reference
- **[Setup Guide](../setup/)** - OAuth environment configuration

## 📞 OAuth Support

### **Provider Documentation**
- **Google OAuth**: https://developers.google.com/identity/protocols/oauth2
- **Microsoft OAuth**: https://docs.microsoft.com/en-us/azure/active-directory/develop/

### **Troubleshooting Steps**
1. Verify OAuth app configuration
2. Check redirect URI matching
3. Validate client credentials  
4. Test OAuth flow manually
5. Monitor token refresh logs
6. Check user notification delivery

For OAuth app setup, see the setup instructions above or the provider documentation links.
