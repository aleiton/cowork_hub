# frozen_string_literal: true

# =============================================================================
# APPLICATION CONTROLLER
# =============================================================================
#
# Base controller for all controllers in the application.
# Sets up Pundit and common configurations.
#
# =============================================================================

class ApplicationController < ActionController::API
  # Include Devise helpers for authentication
  include Pundit::Authorization

  # Handle Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
  end
end
