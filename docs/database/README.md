# Database Documentation

Documentation for the Daily AI Agent API database schema and data models.

## 📋 Database Overview

- **Database**: PostgreSQL
- **Total Tables**: 12
- **Migration Version**: 20251125143906
- **Primary Key Type**: bigint (auto-increment)

## 📁 Files in this section

### [`DATABASE_SCHEMA.md`](DATABASE_SCHEMA.md)
Complete database documentation including:
- **Schema Diagram** - Visual representation of all table relationships
- **Table Definitions** - Detailed field descriptions for all 12 tables
- **Relationships** - Foreign key relationships and associations
- **Security Features** - Encryption, data isolation, soft deletes
- **Usage Patterns** - Common database operation flows
- **Indexing Strategy** - Performance optimization details

## 🗄️ Key Tables

### **Core Tables**
- **`users`** - Central hub for all user data
- **`notifications`** - In-app notification system
- **`calendar_accounts`** - Google/Microsoft calendar connections

### **Integration Tables**
- **`oauth_tokens`** - External service authentication
- **`telegram_links`** - Telegram bot connections
- **`n8n_webhook_logs`** - n8n workflow integration

### **Automation Tables**
- **`automation_settings`** - User automation preferences
- **`scheduler_jobs`** - Cron-based scheduled tasks
- **`ai_summaries`** - AI-generated content

### **Data Tables**
- **`alerts`** - User-specific alerts
- **`crypto_data_caches`** - Cryptocurrency market data

## 🔐 Security Features

- **Encryption at Rest**: OAuth and calendar tokens encrypted
- **Data Isolation**: All user data isolated by `user_id`
- **Soft Deletes**: `active` flags for data preservation
- **Optimized Indexing**: Performance indexes for common queries

## 🔗 Related Documentation

- **[Calendar Integration](../calendar-integration/)** - How calendar data flows through the database
- **[API Documentation](../api/)** - How API endpoints interact with database models
- **[Setup Guide](../setup/)** - Database setup and configuration

## 🛠️ Database Commands

```bash
# Create and migrate database
rails db:create db:migrate

# View database schema
rails db:schema:dump

# Annotate models with schema info
bundle exec annotate

# Open database console
rails dbconsole
```

For more database operations, see the [Setup Guide](../setup/SETUP_GUIDE.md).
