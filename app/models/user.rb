# frozen_string_literal: true

# =============================================================================
# USER MODEL
# =============================================================================
#
# Users represent people who interact with the CoworkHub platform.
# This model handles authentication (via Devise) and stores user-specific data.
#
# AUTHENTICATION vs AUTHORIZATION:
# - Authentication (Devise): Verifies WHO the user is
# - Authorization (Pundit): Determines WHAT the user can do
#
# DEVISE MODULES EXPLAINED:
# - :database_authenticatable - Stores password hash, validates password
# - :registerable - Allows users to sign up
# - :recoverable - Password reset via email
# - :rememberable - "Remember me" functionality
# - :validatable - Built-in email/password validations
# - :lockable - Locks account after failed attempts
# - :jwt_authenticatable - Adds JWT token support (devise-jwt gem)
#
# =============================================================================
# == Schema Information (via annotate gem)
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  jti                    :string           not null
#  role                   :integer          default("guest"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes:
#   index_users_on_email                 (email) UNIQUE
#   index_users_on_jti                   (jti) UNIQUE
#   index_users_on_reset_password_token  (reset_password_token) UNIQUE
#   index_users_on_unlock_token          (unlock_token) UNIQUE
#
# =============================================================================

class User < ApplicationRecord
  # Include Devise modules. Others available are:
  # :confirmable - Requires email confirmation before login
  # :timeoutable - Expires sessions after inactivity
  # :trackable - Tracks sign in count, timestamps, and IPs
  # :omniauthable - OAuth authentication (Google, GitHub, etc.)
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :lockable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self # JTIMatcher strategy - uses jti column

  # ===========================================================================
  # JWT REVOCATION (JTIMatcher Strategy)
  # ===========================================================================
  # When a user signs out, we need to invalidate their JWT token.
  # JTIMatcher works by:
  # 1. Storing a unique jti (JWT ID) on the user record
  # 2. Including this jti in issued tokens
  # 3. Checking that the token's jti matches the user's current jti
  # 4. On sign out, generating a new jti (invalidating all old tokens)

  include Devise::JWT::RevocationStrategies::JTIMatcher

  # ===========================================================================
  # RELATIONSHIPS
  # ===========================================================================
  # has_many creates a one-to-many relationship.
  # A user can have many bookings, memberships, etc.
  #
  # dependent: :destroy means if we delete a user, their associated records
  # are also deleted. Alternatives:
  # - :nullify - Sets foreign key to NULL (keeps records)
  # - :restrict_with_error - Prevents deletion if associations exist
  # - :delete_all - Deletes without running callbacks (faster, dangerous)

  has_many :bookings, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :cantina_subscriptions, dependent: :destroy

  # Through association: get workspaces user has booked via bookings
  # This creates a shortcut: user.booked_workspaces instead of
  # user.bookings.includes(:workspace).map(&:workspace)
  has_many :booked_workspaces, through: :bookings, source: :workspace

  # ===========================================================================
  # ENUMS
  # ===========================================================================
  # Enums map symbolic names to integers stored in the database.
  # In the database, role might be 0, 1, or 2.
  # In code, we use :guest, :member, :admin.
  #
  # This gives us nice helper methods:
  # - user.admin? -> true/false
  # - user.member! -> updates role to member
  # - User.admins -> scope returning all admins
  # - User.roles -> hash of all roles { guest: 0, member: 1, admin: 2 }

  enum :role, {
    guest: 0,   # Can browse, limited booking
    member: 1,  # Full booking access, based on membership
    admin: 2    # Full access, can manage workspaces
  }, prefix: true, default: :guest

  # prefix: true changes method names from admin? to role_admin?
  # This avoids conflicts with other potential 'admin?' methods

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================
  # Validations ensure data integrity. They run before saving to the database.
  #
  # Devise :validatable already includes:
  # - Email: presence, format, uniqueness
  # - Password: presence, length (6-128 characters)
  #
  # We add additional validations as needed:

  validates :role, presence: true

  # JTI must be present and unique for JWT authentication
  validates :jti, presence: true, uniqueness: true

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================
  # Callbacks are hooks that run at specific points in the model lifecycle.
  # before_validation runs before validations, perfect for setting defaults.

  # Generate a unique JTI before validation if one doesn't exist
  before_validation :ensure_jti, on: :create

  # ===========================================================================
  # SCOPES
  # ===========================================================================
  # Scopes are reusable query fragments. They're class methods that return
  # an ActiveRecord::Relation (chainable).
  #
  # Syntax options:
  # scope :name, -> { query }           # Lambda syntax (preferred)
  # scope :name, ->(arg) { query(arg) } # With arguments
  # def self.name; query; end           # Class method (for complex logic)

  # Find users with active memberships
  scope :with_active_membership, lambda {
    joins(:memberships).where('memberships.ends_at > ?', Time.current).distinct
  }

  # Find users with remaining cantina meals
  scope :with_cantina_meals, lambda {
    joins(:cantina_subscriptions)
      .where('cantina_subscriptions.meals_remaining > 0')
      .where('cantina_subscriptions.renews_at > ?', Time.current)
      .distinct
  }

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================

  # Check if user has an active membership of any type
  def active_membership?
    memberships.active.exists?
  end

  # Get the user's current active membership (if any)
  def current_membership
    memberships.active.order(ends_at: :desc).first
  end

  # Check if user can access premium amenities
  def premium_access?
    current_membership&.amenity_tier_premium? || role_admin?
  end

  # Get active cantina subscription
  def active_cantina_subscription
    cantina_subscriptions.active.first
  end

  # Check if user has remaining meal credits
  def has_meal_credits?
    active_cantina_subscription&.meals_remaining&.positive? || false
  end

  private

  # Generate a unique JWT ID for token revocation
  def ensure_jti
    self.jti ||= SecureRandom.uuid
  end
end
