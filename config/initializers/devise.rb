# frozen_string_literal: true

# =============================================================================
# DEVISE CONFIGURATION
# =============================================================================
#
# Devise is the most popular authentication gem for Rails. It handles:
# - User registration (sign up)
# - Session management (sign in/out)
# - Password encryption (bcrypt)
# - Password recovery (forgot password emails)
# - Account confirmation (optional)
# - Account locking (after failed attempts)
# - And more...
#
# KEY CONCEPT: Devise is modular. You enable only the features you need.
# See the User model for which modules are enabled.
#
# AUTHENTICATION vs AUTHORIZATION:
# - Authentication (Devise): "Who are you?" - Verifying identity
# - Authorization (Pundit): "What can you do?" - Checking permissions
#
# =============================================================================

# Assuming you don't have a config/initializers/devise.rb from rails g devise:install
# This is a minimal configuration for JWT-based API authentication.

Devise.setup do |config|
  # ===========================================================================
  # BASIC SETTINGS
  # ===========================================================================

  # The email address used as the sender for Devise emails.
  config.mailer_sender = 'noreply@coworkhub.com'

  # The ORM (Object-Relational Mapper) Devise uses.
  # ActiveRecord is Rails' default ORM for SQL databases.
  require 'devise/orm/active_record'

  # ===========================================================================
  # AUTHENTICATION KEYS
  # ===========================================================================

  # Which field(s) identify a user for login.
  # Default is :email. Could also be [:email, :subdomain] for multi-tenant apps.
  config.authentication_keys = [:email]

  # ===========================================================================
  # PASSWORD SETTINGS
  # ===========================================================================

  # Case-insensitive email lookup.
  # "John@Example.com" and "john@example.com" are treated as the same user.
  config.case_insensitive_keys = [:email]

  # Strip whitespace from email before saving.
  # " john@example.com " becomes "john@example.com"
  config.strip_whitespace_keys = [:email]

  # Password length requirements.
  # NIST guidelines recommend at least 8 characters, no upper limit.
  config.password_length = 8..128

  # Email format validation regex.
  # This is a simple check; true email validation requires sending a confirmation.
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ===========================================================================
  # TIMEOUT (Optional Module)
  # ===========================================================================

  # How long until inactive sessions expire.
  # For API with JWT, this is less relevant since tokens have their own expiry.
  # config.timeout_in = 30.minutes

  # ===========================================================================
  # LOCKABLE (Optional Module)
  # ===========================================================================

  # Lock accounts after failed login attempts.
  # Protects against brute force attacks.
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :time
  config.maximum_attempts = 5
  config.unlock_in = 1.hour

  # ===========================================================================
  # REMEMBERABLE (Optional Module)
  # ===========================================================================

  # How long the "remember me" cookie lasts.
  config.remember_for = 2.weeks

  # ===========================================================================
  # CONFIRMABLE (Optional Module)
  # ===========================================================================

  # Time window to confirm account before requiring reconfirmation.
  # config.allow_unconfirmed_access_for = 2.days
  # config.reconfirmable = true

  # ===========================================================================
  # PASSWORD ENCRYPTION
  # ===========================================================================

  # Number of bcrypt hashing rounds. Higher = more secure but slower.
  # 12 is a good balance. In test environment, use 1 for speed.
  config.stretches = Rails.env.test? ? 1 : 12

  # Pepper adds an additional secret to password hashing.
  # Unlike salt (unique per password), pepper is shared across all passwords.
  # Store this in an environment variable!
  config.pepper = ENV.fetch('DEVISE_PEPPER') do
    # Default for development - CHANGE IN PRODUCTION!
    'a-secret-pepper-that-should-be-in-env-vars-change-this-in-production'
  end

  # ===========================================================================
  # NAVIGATION/RESPONSES
  # ===========================================================================

  # Path after sign out. Allow both DELETE (API) and GET (admin panel)
  config.sign_out_via = %i[delete get]

  # Use Turbo-compatible responses (Rails 7+ with Hotwire).
  # For API-only apps, this doesn't matter much.
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # ===========================================================================
  # JWT CONFIGURATION (devise-jwt gem)
  # ===========================================================================
  # JSON Web Tokens allow stateless authentication:
  # 1. User signs in with email/password
  # 2. Server returns a JWT token
  # 3. Client includes token in Authorization header for subsequent requests
  # 4. Server verifies token without database lookup
  #
  # Token structure: HEADER.PAYLOAD.SIGNATURE
  # - Header: Algorithm used (HS256)
  # - Payload: User ID, expiration time, etc.
  # - Signature: Cryptographic signature to prevent tampering

  config.jwt do |jwt|
    # Secret key for signing tokens.
    # CRITICAL: Keep this secret! Anyone with this key can forge tokens.
    jwt.secret = ENV.fetch('DEVISE_JWT_SECRET_KEY') do
      # Default for development - CHANGE IN PRODUCTION!
      Rails.application.credentials.devise_jwt_secret_key ||
        'a-very-long-secret-key-that-should-be-stored-securely-in-production'
    end

    # Token expiration time.
    # Shorter = more secure (less time for stolen tokens to be used)
    # Longer = better UX (users don't have to re-login often)
    # Common approach: short-lived access tokens + refresh tokens
    jwt.expiration_time = 24.hours.to_i

    # JWT dispatch: When to include token in response.
    # On successful registration and sign in, add token to response headers.
    jwt.dispatch_requests = [
      ['POST', %r{^/users/sign_in$}],
      ['POST', %r{^/users$}]
    ]

    # JWT revocation: When to invalidate tokens.
    # On sign out, add token to denylist so it can't be reused.
    jwt.revocation_requests = [
      ['DELETE', %r{^/users/sign_out$}]
    ]

    # Revocation strategy: How to track revoked tokens.
    # Options:
    # - JTIMatcher: Store JTI (unique ID) in user record
    # - Denylist: Store revoked tokens in a separate table
    # - Null: Don't track (tokens valid until expiry)
    #
    # We'll use JTIMatcher for simplicity.
    # For high-security apps, use Denylist.
  end
end
