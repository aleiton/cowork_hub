# frozen_string_literal: true

# =============================================================================
# SESSIONS CONTROLLER
# =============================================================================
#
# Custom Devise sessions controller for API authentication.
# Handles login (sign in) and logout (sign out).
#
# JWT AUTHENTICATION FLOW:
# 1. User sends POST /users/sign_in with { email, password }
# 2. Devise validates credentials
# 3. If valid, devise-jwt creates a JWT token
# 4. Token is returned in the Authorization header
# 5. Frontend stores token and sends it with subsequent requests
#
# =============================================================================

module Users
  class SessionsController < Devise::SessionsController
    # Respond with JSON for API requests, HTML for browser requests (admin login)
    respond_to :json, :html

    private

    # Custom response for successful sign in
    def respond_with(resource, _opts = {})
      # For HTML requests (admin login), let Devise handle the redirect
      return super if request.format.html?

      if resource.persisted?
        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: {
            id: resource.id,
            email: resource.email,
            role: resource.role
          }
        }, status: :ok
      else
        render json: {
          status: { code: 401, message: 'Invalid email or password.' }
        }, status: :unauthorized
      end
    end

    # Custom response for sign out
    def respond_to_on_destroy
      # For HTML requests (admin logout), redirect to root
      if request.format.html?
        redirect_to root_path, notice: 'Logged out successfully.'
        return
      end

      if current_user
        render json: {
          status: { code: 200, message: 'Logged out successfully.' }
        }, status: :ok
      else
        render json: {
          status: { code: 401, message: 'Could not log out.' }
        }, status: :unauthorized
      end
    end
  end
end
