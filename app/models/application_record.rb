# frozen_string_literal: true

# =============================================================================
# APPLICATION RECORD
# =============================================================================
#
# ApplicationRecord is the base class for all models in the application.
# It inherits from ActiveRecord::Base, Rails' ORM (Object-Relational Mapper).
#
# WHY THIS CLASS EXISTS:
# - Single place to add functionality shared by all models
# - Follows the same pattern as ApplicationController, ApplicationJob, etc.
# - Introduced in Rails 5 (before, models inherited directly from ActiveRecord::Base)
#
# WHAT TO PUT HERE:
# - Shared scopes (e.g., `scope :recent, -> { order(created_at: :desc) }`)
# - Shared callbacks
# - Shared validations
# - Concerns that apply to all models
#
# =============================================================================

class ApplicationRecord < ActiveRecord::Base
  # This is an abstract class - it doesn't have a corresponding database table.
  # Setting primary_abstract_class tells Rails not to look for an
  # "application_records" table.
  primary_abstract_class

  # ===========================================================================
  # SHARED SCOPES
  # ===========================================================================
  # Scopes are reusable query fragments. They're chainable:
  # User.recent.active becomes SELECT * FROM users ORDER BY created_at DESC WHERE active = true

  # Order by most recently created first
  scope :recent, -> { order(created_at: :desc) }

  # Order by most recently updated first
  scope :recently_updated, -> { order(updated_at: :desc) }

  # ===========================================================================
  # SHARED METHODS
  # ===========================================================================

  # Check if the record was created in the last N hours
  # Example: booking.created_recently?(24) # true if created in last 24 hours
  def created_recently?(hours = 24)
    created_at > hours.hours.ago
  end
end
