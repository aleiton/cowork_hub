# frozen_string_literal: true

# =============================================================================
# APPLICATION CONTROLLER
# =============================================================================
#
# Base controller for all controllers in the application.
# Sets up Pundit and common configurations.
#
# =============================================================================

class ApplicationController < ActionController::Base
  # Include Devise helpers for authentication
  include Pundit::Authorization

  # Handle Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Authentication helper for ActiveAdmin
  # Ensures only admin users can access the admin panel
  def authenticate_admin_user!
    authenticate_user!
    unless current_user&.role_admin?
      flash[:alert] = 'You are not authorized to access this area.'
      redirect_to root_path
    end
  end

  private

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
  end

  # Redirect admin users to admin panel after login
  def after_sign_in_path_for(resource)
    if resource.role_admin?
      admin_root_path
    else
      root_path
    end
  end
end
