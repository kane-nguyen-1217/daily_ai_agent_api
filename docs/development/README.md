# Development Documentation

Documentation for developers contributing to the Daily AI Agent API project.

## 🛠️ Development Overview

This section contains all resources needed for:
- **Contributing** to the project
- **Understanding** the architecture
- **Setting up** development environment
- **Following** coding standards

## 📁 Files in this section

### [`CONTRIBUTING.md`](CONTRIBUTING.md)
Complete contributing guidelines:
- **Code of conduct** - Community guidelines
- **Development setup** - Local environment configuration
- **Git workflow** - Branching and PR process
- **Coding standards** - Ruby/Rails best practices
- **Testing guidelines** - RSpec testing patterns
- **Code review** - Review process and checklist

### [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md)
Project architecture overview:
- **Technical stack** - Ruby, Rails, PostgreSQL, Redis
- **Project structure** - File organization and patterns
- **Database schema** - High-level table relationships
- **Key features** - Implemented functionality overview
- **Lines of code** - Project size and complexity

## 🏗️ Architecture Overview

### **Tech Stack**
- **Backend**: Ruby 3.3, Rails 7.0
- **Database**: PostgreSQL with JSONB
- **Background Jobs**: Sidekiq + Redis  
- **Authentication**: JWT tokens
- **Encryption**: Lockbox for sensitive data
- **Testing**: RSpec, Factory Bot
- **Documentation**: Swagger/OpenAPI

### **Project Structure**
```
daily_ai_agent_api/
├── app/
│   ├── controllers/api/v1/    # Versioned API endpoints
│   ├── models/                # ActiveRecord models (12 models)
│   ├── services/              # Business logic services
│   ├── jobs/                  # Sidekiq background workers
│   └── concerns/              # Shared controller/model logic
├── config/
│   ├── environments/          # Environment-specific configs
│   ├── initializers/          # Gem configurations
│   └── routes.rb             # API route definitions
├── db/
│   ├── migrate/              # Database migrations
│   └── seeds.rb              # Seed data
└── docs/                     # Documentation (this folder)
```

## 🚀 Quick Development Setup

### **Prerequisites**
- Ruby 3.3.x
- PostgreSQL 12+
- Redis 6+
- Node.js (for some dependencies)

### **Setup Commands**
```bash
# Clone repository
git clone https://github.com/kane-nguyen-1217/daily_ai_agent_api.git
cd daily_ai_agent_api

# Install dependencies
bundle install

# Setup environment
cp .env.example .env
# Edit .env with your configuration

# Setup database
rails db:create db:migrate db:seed

# Start development servers
rails server          # API server (port 3000)
bundle exec sidekiq   # Background jobs
```

## 🧪 Testing

### **Running Tests**
```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/controllers/api/v1/

# Run with coverage
COVERAGE=true bundle exec rspec
```

### **Test Structure**
```
spec/
├── models/           # Model unit tests
├── controllers/      # Controller integration tests
├── services/         # Service object tests
├── jobs/            # Background job tests
├── support/         # Test helpers and shared examples
└── factories/       # FactoryBot factories
```

## 📝 Coding Standards

### **Ruby Style**
- Follow [Ruby Style Guide](https://rubystyle.guide/)
- Use RuboCop for automated checking:
  ```bash
  bundle exec rubocop
  bundle exec rubocop -a  # Auto-fix issues
  ```

### **Rails Conventions**
- RESTful API design
- Skinny controllers, fat models
- Service objects for complex business logic
- Background jobs for async operations

### **Database**
- Use migrations for all schema changes
- Add proper indexes for performance
- Use validations and constraints
- Encrypt sensitive data

### **Security**
- Never commit secrets or credentials
- Use strong parameters in controllers
- Validate all user inputs
- Use HTTPS in production

## 🔄 Git Workflow

### **Branching Strategy**
```bash
main                  # Production branch
├── develop          # Development branch
├── feature/calendar # Feature branches
├── bugfix/auth      # Bug fix branches
└── hotfix/security  # Emergency fixes
```

### **Contribution Process**
1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Make changes with tests
4. Run test suite: `bundle exec rspec`
5. Check code style: `bundle exec rubocop`
6. Commit changes: `git commit -m "Add new feature"`
7. Push branch: `git push origin feature/new-feature`
8. Create Pull Request

### **Commit Messages**
```bash
# Format: type(scope): description
feat(calendar): add Microsoft OAuth integration
fix(auth): resolve JWT token expiration issue
docs(api): update endpoint documentation
test(models): add user model validations
```

## 🔍 Code Review Checklist

### **Functionality**
- [ ] Code works as intended
- [ ] Edge cases handled
- [ ] Error handling implemented
- [ ] Performance considerations

### **Testing**
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Test coverage maintained
- [ ] Manual testing performed

### **Code Quality**
- [ ] Follows Ruby/Rails conventions
- [ ] RuboCop passes
- [ ] No code duplication
- [ ] Proper naming conventions

### **Security**
- [ ] No sensitive data exposed
- [ ] Input validation implemented
- [ ] Authorization checks in place
- [ ] SQL injection prevention

### **Documentation**
- [ ] Code is self-documenting
- [ ] API documentation updated
- [ ] README updated if needed
- [ ] Breaking changes noted

## 🐛 Debugging

### **Development Tools**
```bash
# Rails console
rails console

# Database console
rails dbconsole

# View logs
tail -f log/development.log

# Sidekiq web UI
bundle exec sidekiq -e development
# Visit http://localhost:4567
```

### **Common Issues**
- **Database errors**: Check migrations and seed data
- **Authentication issues**: Verify JWT configuration
- **Background jobs**: Ensure Redis is running
- **API errors**: Check logs and response format

## 📊 Performance Monitoring

### **Database Performance**
```bash
# Check slow queries
tail -f log/development.log | grep "SLOW QUERY"

# Analyze database performance
bundle exec rails runner "puts ActiveRecord::Base.connection.execute('EXPLAIN ANALYZE SELECT * FROM users').to_a"
```

### **Memory Usage**
```bash
# Memory profiling
gem 'memory_profiler'
# Add profiling code in development
```

## 🔗 Related Documentation

- **[Setup Guide](../setup/)** - Environment setup and deployment
- **[Database Schema](../database/)** - Data models and relationships  
- **[API Documentation](../api/)** - Endpoint reference and testing
- **[Calendar Integration](../calendar-integration/)** - Feature implementation

## 📞 Development Support

### **Resources**
- **Rails Guides**: https://guides.rubyonrails.org/
- **Ruby Documentation**: https://ruby-doc.org/
- **PostgreSQL Docs**: https://www.postgresql.org/docs/

### **Getting Help**
- Check existing issues on GitHub
- Ask questions in pull request discussions
- Review related documentation sections
- Follow the coding standards and conventions

For complete development guidelines, see [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md).
