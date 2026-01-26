# frozen_string_literal: true

# =============================================================================
# DEVISE USER MIGRATION
# =============================================================================
#
# This migration creates the users table with Devise fields.
# Devise is a Rails authentication solution that handles:
# - User registration
# - Session management (login/logout)
# - Password encryption and recovery
# - And more optional features
#
# MIGRATION BASICS:
# - Migrations version control your database schema
# - They're applied in order (by timestamp)
# - Each migration can be rolled back (reversible changes)
# - Run with: rails db:migrate
# - Rollback with: rails db:rollback
#
# =============================================================================

class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      # =========================================================================
      # CORE DEVISE FIELDS
      # =========================================================================

      # Email - used as login identifier
      # null: false prevents NULL values (required field)
      # default: "" ensures column is never NULL even temporarily
      t.string :email, null: false, default: ''

      # Encrypted password - Devise uses bcrypt for hashing
      # NEVER store plain text passwords!
      # Bcrypt creates a one-way hash that can't be reversed
      t.string :encrypted_password, null: false, default: ''

      # =========================================================================
      # RECOVERABLE (Password Reset)
      # =========================================================================
      # These fields support the "forgot password" feature.
      # When a user requests a password reset:
      # 1. reset_password_token is generated and emailed
      # 2. reset_password_sent_at tracks when it was sent
      # 3. Token expires after a configurable period

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # =========================================================================
      # REMEMBERABLE (Remember Me)
      # =========================================================================
      # Tracks when the "remember me" token was created.
      # Used to implement persistent sessions across browser closes.

      t.datetime :remember_created_at

      # =========================================================================
      # TRACKABLE (Optional - Login Tracking)
      # =========================================================================
      # Tracks login activity. Useful for:
      # - Showing "last login" to users
      # - Detecting suspicious activity
      # - Analytics
      #
      # Uncomment if you need these features:

      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      # =========================================================================
      # CONFIRMABLE (Optional - Email Confirmation)
      # =========================================================================
      # Requires users to confirm their email before logging in.
      # Uncomment if you want email verification:

      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # For email change confirmation

      # =========================================================================
      # LOCKABLE (Optional - Account Locking)
      # =========================================================================
      # Locks accounts after too many failed login attempts.
      # Protects against brute force attacks.

      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      # =========================================================================
      # JWT REVOCATION (devise-jwt)
      # =========================================================================
      # JTI (JWT ID) is a unique identifier for each token.
      # When user logs out, we update this field, invalidating all old tokens.
      # This is the JTIMatcher revocation strategy.

      t.string :jti, null: false

      # =========================================================================
      # APPLICATION-SPECIFIC FIELDS
      # =========================================================================

      # User role determines what actions they can perform.
      # Using integer type with an enum in the model for efficiency:
      # - Faster queries (comparing integers vs strings)
      # - Less storage space
      # - Still human-readable in code via enum
      #
      # Values: 0 = guest, 1 = member, 2 = admin
      t.integer :role, default: 0, null: false

      # =========================================================================
      # TIMESTAMPS
      # =========================================================================
      # Rails convention: created_at and updated_at
      # Automatically managed by ActiveRecord

      t.timestamps null: false
    end

    # ===========================================================================
    # INDEXES
    # ===========================================================================
    # Indexes speed up database lookups. Add indexes for:
    # 1. Columns used in WHERE clauses (email for login)
    # 2. Columns used in JOINs
    # 3. Columns that must be unique
    #
    # unique: true also adds a database-level constraint

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, :jti, unique: true
  end
end
