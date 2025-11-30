# API Documentation with Swagger

## Accessing Swagger UI

The API documentation is now available through Swagger UI at:

**URL:** [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

## Features

### Interactive API Testing
- Test all API endpoints directly from the browser
- View request/response schemas
- See example requests and responses
- Try out authenticated endpoints with JWT tokens

### Available Endpoints

The API documentation includes all endpoints organized by categories:

1. **Health** - Service health checks
2. **Authentication** - User registration, login, logout, token refresh
3. **Users** - User profile management
4. **OAuth Tokens** - Google OAuth integration
5. **Telegram** - Telegram bot linking and verification
6. **Automation** - Automation settings management
7. **Scheduler** - Job scheduling and management
8. **AI Summaries** - AI-powered summary generation
9. **Crypto Data** - Cryptocurrency data and prices
10. **Alerts** - Alert management and notifications
11. **Webhooks** - n8n workflow integration

## Using Authentication in Swagger

Most endpoints require JWT authentication. To test authenticated endpoints:

1. **Register or Login:**
   - Go to the Authentication section
   - Use `POST /api/v1/auth/register` to create a new account
   - Or use `POST /api/v1/auth/login` to get a token

2. **Authorize:**
   - Click the "Authorize" button at the top of the Swagger UI
   - Enter your JWT token in the format: `Bearer <your_token>`
   - Click "Authorize" to save

3. **Test Endpoints:**
   - Now you can test any authenticated endpoint
   - The token will be automatically included in requests

## API Specification File

The OpenAPI 3.0 specification file is located at:
- **Path:** `/swagger/v1/swagger.yaml`
- **URL:** [http://localhost:3000/api-docs/v1/swagger.yaml](http://localhost:3000/api-docs/v1/swagger.yaml)

You can import this specification into other API tools like:
- Postman
- Insomnia
- API testing frameworks
- Code generators

## Example: Testing Authentication Flow

### 1. Register a New User
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

### 2. Use the Token
Copy the `token` from the response and use it in subsequent requests:

```bash
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer <your_token>"
```

## Updating Documentation

The Swagger specification is stored in:
```
/swagger/v1/swagger.yaml
```

After making changes:
1. Save the file
2. Refresh the Swagger UI page
3. Changes will be reflected immediately

## Production Deployment

For production:
1. Update the server URL in `swagger.yaml`:
   ```yaml
   servers:
     - url: https://api.yourdomain.com
       description: Production server
   ```

2. Consider adding authentication to Swagger UI:
   - Edit `/config/initializers/rswag_ui.rb`
   - Uncomment and configure basic auth:
     ```ruby
     c.basic_auth_enabled = true
     c.basic_auth_credentials 'username', 'password'
     ```

## Additional Resources

- [Swagger UI Documentation](https://swagger.io/tools/swagger-ui/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [rswag GitHub](https://github.com/rswag/rswag)
