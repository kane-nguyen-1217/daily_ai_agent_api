# API Documentation

Complete API reference and testing resources for the Daily AI Agent API.

## 🔗 API Overview

RESTful API built with Ruby on Rails providing:
- **JWT Authentication** - Secure token-based auth
- **Calendar Integration** - Google/Microsoft OAuth
- **User Management** - Profile and settings
- **Automation** - Scheduled jobs and settings
- **Multi-service Integration** - Telegram, n8n, crypto data

## 📁 Files in this section

### [`API_DOCUMENTATION.md`](API_DOCUMENTATION.md)
Complete API endpoint reference:
- **Authentication endpoints** - Register, login, refresh, logout
- **User management** - Profile operations
- **Calendar integration** - OAuth flows and callbacks
- **Automation** - Settings and scheduler jobs
- **External integrations** - Telegram, OAuth tokens, alerts

### [`SWAGGER_DOCUMENTATION.md`](SWAGGER_DOCUMENTATION.md)
OpenAPI/Swagger specification:
- **Interactive documentation** - Swagger UI interface
- **Request/response schemas** - Complete data models
- **Try-it-out functionality** - Test endpoints directly
- **Code generation** - Client SDK generation

### [`api_collection.json`](api_collection.json)
Postman/Insomnia collection:
- **Pre-configured requests** - All API endpoints
- **Environment variables** - Easy configuration
- **Test scenarios** - Complete user flows
- **Authentication setup** - JWT token handling

## 🚀 Getting Started

### **Base URL**
```
http://localhost:3000/api/v1
```

### **Authentication**
All protected endpoints require JWT token:
```bash
Authorization: Bearer <your_jwt_token>
```

### **Content Type**
```bash
Content-Type: application/json
```

## 🔐 Authentication Flow

### 1. **Register User**
```bash
POST /api/v1/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "full_name": "User Name"
}
```

### 2. **Login**
```bash
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "token": "jwt_token",
  "refresh_token": "refresh_jwt_token",
  "user": { ... }
}
```

### 3. **Use Token**
```bash
GET /api/v1/users/profile
Authorization: Bearer <jwt_token>
```

## 📅 Calendar Integration Endpoints

### **Connect Calendar**
```bash
# Google Calendar
GET /api/v1/calendar/google/connect
Authorization: Bearer <token>

# Microsoft Calendar  
GET /api/v1/calendar/microsoft/connect
Authorization: Bearer <token>

Response:
{
  "authorization_url": "https://accounts.google.com/oauth/authorize?..."
}
```

### **OAuth Callback** (automatic)
```bash
GET /api/v1/calendar/:provider/callback?code=xxx&state=xxx
```

## 🧪 Testing the API

### **Swagger UI** (Recommended)
```
http://localhost:3000/api-docs
```
- Interactive documentation
- Try endpoints directly in browser
- See request/response examples

### **Postman Collection**
1. Import [`api_collection.json`](api_collection.json)
2. Set environment variables:
   - `base_url`: http://localhost:3000/api/v1
   - `token`: (obtained from login)

### **cURL Examples**

#### Authentication Test
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123"}'
```

#### Protected Endpoint Test
```bash
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer <your_token>"
```

#### Calendar Connection Test
```bash
curl -X GET http://localhost:3000/api/v1/calendar/google/connect \
  -H "Authorization: Bearer <your_token>"
```

## 🔗 Key API Endpoints

### **Authentication**
- `POST /auth/register` - User registration
- `POST /auth/login` - User login  
- `POST /auth/refresh` - Token refresh
- `POST /auth/logout` - User logout

### **User Management**
- `GET /users/profile` - Get user profile
- `PUT /users/profile` - Update user profile

### **Calendar Integration**
- `GET /calendar/google/connect` - Google OAuth
- `GET /calendar/microsoft/connect` - Microsoft OAuth
- `GET /calendar/:provider/callback` - OAuth callback

### **Automation**
- `GET /automation_settings` - List automation settings
- `POST /automation_settings` - Create automation
- `GET /scheduler_jobs` - List scheduled jobs
- `POST /scheduler_jobs` - Create scheduled job

### **External Integrations**
- `GET /oauth_tokens` - List OAuth tokens
- `GET /telegram_links` - List Telegram connections
- `GET /alerts` - List user alerts

## 📊 Response Format

### **Success Response**
```json
{
  "data": { ... },
  "message": "Success message"
}
```

### **Error Response**  
```json
{
  "error": "Error message",
  "errors": ["Detailed error 1", "Detailed error 2"]
}
```

### **Pagination** (where applicable)
```json
{
  "data": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100
  }
}
```

## 🔧 Development

### **API Versioning**
All endpoints are versioned under `/api/v1/`

### **Rate Limiting**
- Production: Rate limits applied per user
- Development: No rate limiting

### **CORS**
Configured to allow frontend requests (check `ALLOWED_ORIGINS` in `.env`)

## 🔗 Related Documentation

- **[Calendar Integration](../calendar-integration/)** - Detailed calendar API usage
- **[OAuth Integration](../oauth-integration/)** - General OAuth patterns  
- **[Database Schema](../database/)** - Data models and relationships
- **[Setup Guide](../setup/)** - API server setup and configuration

## 🆘 Troubleshooting

### **Common Issues**
- **401 Unauthorized**: Check JWT token validity
- **422 Unprocessable Entity**: Check request payload format
- **500 Internal Server Error**: Check server logs

### **Debug Mode**
Start server with debug logging:
```bash
RAILS_LOG_LEVEL=debug rails server
```

For complete endpoint details, see [`API_DOCUMENTATION.md`](API_DOCUMENTATION.md) or use the Swagger UI interface.
