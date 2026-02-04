# frozen_string_literal: true

ActiveAdmin.setup do |config|
  # == Site Title
  config.site_title = 'CoworkHub Admin'

  # == User Authentication
  # Use the authenticate_admin_user! method from ApplicationController
  config.authentication_method = :authenticate_admin_user!

  # == Current User
  # Use Devise's current_user method
  config.current_user_method = :current_user

  # == Logging Out
  config.logout_link_path = :destroy_user_session_path
  config.logout_link_method = :get

  # == Admin Comments
  # Disable comments feature (we don't need it)
  config.comments = false

  # == Batch Actions
  config.batch_actions = true

  # == Sensitive Attributes
  config.filter_attributes = [:encrypted_password, :password, :password_confirmation, :jti]

  # == Localize Date/Time Format
  config.localize_format = :long

  # == Pagination
  config.default_per_page = 25
end
