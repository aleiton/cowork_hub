# frozen_string_literal: true

# =============================================================================
# GEMFILE - CoworkHub Rails Application
# =============================================================================
#
# This file defines all the Ruby gems (libraries) our application depends on.
# Bundler reads this file and installs all listed gems along with their
# dependencies.
#
# Key concepts:
# - 'gem' declares a dependency
# - 'group' limits gems to specific environments (development, test, production)
# - Version constraints: '~>' means "compatible version" (pessimistic operator)
#   Example: '~> 7.1' allows 7.1.x but not 8.0
#
# =============================================================================

source 'https://rubygems.org'

# Ruby 3.1+ required for Rails 7.1
# Using flexible version constraint to work with mise's ruby@3
ruby '>= 3.1'

# =============================================================================
# CORE RAILS GEMS
# =============================================================================

# Rails is the full web framework. Using Rails 7.1+ for latest features like
# async queries and improved Active Record encryption.
gem 'rails', '~> 7.1.0'

# Puma is the default Rails web server. It's multi-threaded and handles
# concurrent requests efficiently. Alternative: Unicorn (process-based, older).
gem 'puma', '>= 5.0'

# PostgreSQL adapter. We use Postgres because:
# 1. Native JSON/JSONB support (needed for equipment_used field)
# 2. Better performance for complex queries
# 3. Industry standard for production Rails apps
# Alternative: MySQL (good but less feature-rich for our use case)
gem 'pg', '~> 1.5'

# Bootsnap speeds up Rails boot time by caching expensive computations
# (parsing YAML, compiling Ruby code). Essential for development productivity.
gem 'bootsnap', require: false

# Rack CORS handles Cross-Origin Resource Sharing, allowing our frontend
# (running on a different port/domain) to make API requests.
# Without this, browsers would block requests from Next.js to Rails.
gem 'rack-cors'

# =============================================================================
# AUTHENTICATION & AUTHORIZATION
# =============================================================================

# Devise handles user authentication (sign up, sign in, password reset, etc.)
# It's the de facto standard for Rails authentication because:
# 1. Battle-tested security (encrypted passwords, secure sessions)
# 2. Modular - only include features you need
# 3. Huge ecosystem of extensions
# Alternative: Authlogic (simpler), Rodauth (more modern but less ecosystem)
gem 'devise', '~> 4.9'

# devise-jwt adds JWT (JSON Web Token) authentication to Devise.
# We need this because:
# 1. GraphQL APIs are typically stateless
# 2. Frontend (Next.js) needs a token to authenticate requests
# 3. JWTs can be verified without database lookups
gem 'devise-jwt', '~> 0.11'

# Pundit provides authorization (what can users do?).
# Key distinction: Authentication = "who are you?", Authorization = "what can you do?"
# Pundit uses Policy classes to encapsulate authorization logic.
# Alternative: CanCanCan (older, uses abilities instead of policies)
# We chose Pundit because:
# 1. Explicit policies are easier to test and understand
# 2. Follows OOP principles (each resource has its own policy)
# 3. More flexible for complex authorization rules
gem 'pundit', '~> 2.3'

# =============================================================================
# GRAPHQL
# =============================================================================

# graphql-ruby is the main GraphQL implementation for Ruby.
# GraphQL advantages over REST:
# 1. Client specifies exactly what data it needs (no over/under-fetching)
# 2. Single endpoint instead of many REST endpoints
# 3. Strongly typed schema serves as documentation
# 4. Great for complex, nested data (like workspaces with equipment)
gem 'graphql', '~> 2.2'

# graphql-batch prevents N+1 queries in GraphQL.
# The N+1 problem: If you fetch 10 workspaces, then for each workspace fetch
# its equipment, you'd make 1 + 10 = 11 queries. With batching, it's just 2.
# This gem collects all the IDs and makes a single query.
gem 'graphql-batch', '~> 0.6'

# graphiql-rails provides an in-browser IDE for exploring and testing GraphQL.
# It mounts at /graphiql and provides:
# - Autocomplete for queries based on your schema
# - Documentation explorer
# - Query history and formatting
# Only needed in development - the frontend will use Apollo Client in production.
gem 'graphiql-rails', group: :development

# =============================================================================
# BACKGROUND JOBS
# =============================================================================

# Sidekiq processes background jobs using Redis.
# Use cases in our app:
# 1. Sending confirmation emails after booking
# 2. Membership expiration notifications
# 3. Any slow operation that shouldn't block the request
# Alternative: DelayedJob (simpler, uses DB), Resque (older, Redis-based)
# Sidekiq is faster and handles high throughput better.
gem 'sidekiq', '~> 7.2'

# =============================================================================
# UTILITIES
# =============================================================================

# For JSON serialization with better performance
gem 'oj', '~> 3.16'

# Timezone data for Windows (and consistent behavior across platforms)
# Windows doesn't have a native timezone database, so this gem provides it.
# Valid Windows platforms: mingw, x64_mingw, mswin, mswin64
# On macOS/Linux, this gem is ignored (not needed).
gem 'tzinfo-data', platforms: %i[mingw x64_mingw mswin jruby]

# =============================================================================
# DEVELOPMENT & TEST GEMS
# =============================================================================

group :development, :test do
  # RSpec is the preferred testing framework in Rails.
  # Why RSpec over Minitest (Rails default)?
  # 1. More expressive syntax (describe/it blocks read like documentation)
  # 2. Powerful matchers and expectations
  # 3. Better organization with contexts and shared examples
  # 4. Industry standard - most jobs expect RSpec knowledge
  gem 'rspec-rails', '~> 6.1'

  # factory_bot creates test data. Instead of fixtures (static YAML files),
  # factories are dynamic and can generate variations easily.
  # Example: create(:user, :admin) vs create(:user, :member)
  gem 'factory_bot_rails', '~> 6.4'

  # Faker generates realistic fake data (names, emails, addresses, etc.)
  # Used in factories and seeds to create believable test data.
  gem 'faker', '~> 3.2'

  # Debug is Rails 7's default debugger. Set breakpoints with `debugger`.
  gem 'debug', platforms: %i[mri mingw x64_mingw mswin]

  # Dotenv loads environment variables from .env files.
  # Keeps secrets out of code and makes configuration environment-specific.
  gem 'dotenv-rails', '~> 2.8'
end

group :development do
  # Bullet detects N+1 queries and unused eager loading.
  # It shows warnings when you should add includes() to avoid extra queries.
  # CRITICAL for performance - always run in development!
  gem 'bullet', '~> 7.1'

  # Annotate adds schema information as comments to model files.
  # Makes it easy to see table structure without opening schema.rb.
  # Run: bundle exec annotate --models
  gem 'annotate', '~> 3.2'

  # RuboCop enforces Ruby style guide and finds potential issues.
  # Consistent code style is crucial for team collaboration.
  gem 'rubocop', '~> 1.60', require: false
  gem 'rubocop-rails', '~> 2.23', require: false
  gem 'rubocop-rspec', '~> 2.26', require: false
  gem 'rubocop-performance', '~> 1.20', require: false

  # Better error pages in development with interactive console
  gem 'web-console'
end

group :test do
  # Shoulda Matchers provides one-liner tests for common Rails patterns.
  # Example: should validate_presence_of(:email)
  # Saves time and makes tests more readable.
  gem 'shoulda-matchers', '~> 6.1'

  # DatabaseCleaner ensures a clean database state between tests.
  # Prevents test pollution (one test's data affecting another).
  gem 'database_cleaner-active_record', '~> 2.1'

  # SimpleCov measures test coverage.
  # Helps identify untested code paths.
  gem 'simplecov', '~> 0.22', require: false
end
