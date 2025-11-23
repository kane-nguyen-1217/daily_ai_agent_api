# Contributing to Daily AI Agent API

Thank you for your interest in contributing to Daily AI Agent API! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

- Ruby 3.3.x
- PostgreSQL 12+
- Redis 6+
- Git

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:
```bash
git clone https://github.com/YOUR_USERNAME/daily_ai_agent_api.git
cd daily_ai_agent_api
```

3. Install dependencies:
```bash
bundle install
```

4. Set up the database:
```bash
cp .env.example .env
# Edit .env with your local settings
rails db:create db:migrate db:seed
```

5. Start the development server:
```bash
rails server
```

6. Start Sidekiq:
```bash
bundle exec sidekiq
```

## Development Workflow

### Creating a New Feature

1. Create a new branch from `main`:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes following the coding standards

3. Write or update tests for your changes

4. Ensure all tests pass:
```bash
bundle exec rspec
```

5. Commit your changes:
```bash
git add .
git commit -m "Add feature: your feature description"
```

6. Push to your fork:
```bash
git push origin feature/your-feature-name
```

7. Create a Pull Request

### Branch Naming Convention

- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Critical production fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Test additions or updates

Examples:
- `feature/add-user-notifications`
- `bugfix/fix-authentication-error`
- `docs/update-api-documentation`

## Coding Standards

### Ruby Style Guide

Follow the [Ruby Style Guide](https://rubystyle.guide/):

- Use 2 spaces for indentation
- Use snake_case for methods and variables
- Use CamelCase for classes and modules
- Maximum line length: 120 characters
- Use meaningful variable and method names

### Rails Best Practices

- Keep controllers thin, models fat
- Use service objects for complex business logic
- Follow RESTful conventions for routes
- Use Strong Parameters for mass assignment protection
- Avoid N+1 queries (use includes/eager loading)

### Code Organization

```
app/
├── controllers/      # API endpoints
├── models/          # Data models
├── services/        # Business logic
├── jobs/           # Background jobs
└── mailers/        # Email logic (if needed)

config/
├── routes.rb       # API routes
├── database.yml    # Database config
└── initializers/   # Gem configurations

db/
├── migrate/        # Database migrations
└── seeds.rb        # Seed data

spec/              # Tests (RSpec)
├── models/
├── controllers/
├── services/
└── jobs/
```

### Naming Conventions

**Models:**
```ruby
# Singular, CamelCase
class User < ApplicationRecord
class OauthToken < ApplicationRecord
```

**Controllers:**
```ruby
# Plural, end with Controller
class UsersController < ApplicationController
class Api::V1::AlertsController < ApplicationController
```

**Services:**
```ruby
# Descriptive name, end with Service
class CryptoDataService
class AiSummaryGeneratorService
```

**Jobs:**
```ruby
# Descriptive name, end with Worker
class SchedulerJobWorker
class AiSummaryWorker
```

## Testing

### Writing Tests

Use RSpec for testing:

**Model Tests:**
```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { should have_many(:oauth_tokens) }
  end
end
```

**Controller Tests:**
```ruby
# spec/controllers/api/v1/users_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'GET #profile' do
    it 'returns user profile' do
      # Test implementation
    end
  end
end
```

**Service Tests:**
```ruby
# spec/services/crypto_data_service_spec.rb
require 'rails_helper'

RSpec.describe CryptoDataService do
  describe '.fetch_price' do
    it 'fetches crypto price' do
      # Test implementation
    end
  end
end
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run specific test
bundle exec rspec spec/models/user_spec.rb:10
```

## Pull Request Process

### Before Submitting

1. **Update your branch** with the latest from main:
```bash
git checkout main
git pull upstream main
git checkout your-branch
git rebase main
```

2. **Run tests** to ensure everything passes:
```bash
bundle exec rspec
```

3. **Run the linter** (if configured):
```bash
bundle exec rubocop
```

4. **Update documentation** if needed:
   - Update README.md for new features
   - Update API_DOCUMENTATION.md for new endpoints
   - Add/update inline code comments

### Pull Request Guidelines

**Title:**
- Use descriptive titles
- Start with a verb (Add, Fix, Update, Remove, etc.)
- Example: "Add crypto price alert notifications"

**Description:**
Include the following in your PR description:
- **What**: Brief description of changes
- **Why**: Reason for the changes
- **How**: Implementation approach
- **Testing**: How you tested the changes
- **Screenshots**: If applicable

**Template:**
```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- List of changes
- Another change

## Testing
How were these changes tested?

## Checklist
- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process

1. At least one maintainer review is required
2. Address all review comments
3. Keep the PR focused and small (< 400 lines if possible)
4. Respond to reviews within 2-3 days
5. Once approved, a maintainer will merge

## Adding New Features

### API Endpoints

When adding new endpoints:

1. **Define the route** in `config/routes.rb`:
```ruby
namespace :api do
  namespace :v1 do
    resources :new_resource
  end
end
```

2. **Create the controller**:
```ruby
module Api
  module V1
    class NewResourceController < ApplicationController
      def index
        # Implementation
      end
    end
  end
end
```

3. **Update API documentation** in `API_DOCUMENTATION.md`

4. **Add to API collection** in `api_collection.json`

### Database Changes

1. **Create migration**:
```bash
rails generate migration AddFieldToTable field:type
```

2. **Edit migration** if needed

3. **Run migration**:
```bash
rails db:migrate
```

4. **Update schema.rb** (automatically updated)

5. **Add model validations** and associations

## Environment Variables

When adding new environment variables:

1. Add to `.env.example` with description
2. Document in SETUP_GUIDE.md
3. Add to docker-compose.yml if needed

## Questions?

- Open an issue for questions
- Check existing issues and PRs
- Review documentation thoroughly

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

Thank you for contributing! 🎉
