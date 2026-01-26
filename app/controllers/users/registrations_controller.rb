# frozen_string_literal: true

# =============================================================================
# REGISTRATIONS CONTROLLER
# =============================================================================
#
# Custom Devise registrations controller for API user registration.
# Handles user sign up.
#
# REGISTRATION FLOW:
# 1. User sends POST /users with { email, password, password_confirmation }
# 2. Devise creates the user account
# 3. If successful, devise-jwt creates a JWT token
# 4. Token is returned in the Authorization header
# 5. User is immediately logged in
#
# =============================================================================

module Users
  class RegistrationsController < Devise::RegistrationsController
    # Tell Devise to respond with JSON
    respond_to :json

    private

    # Custom response for successful registration
    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: {
          status: { code: 200, message: 'Signed up successfully.' },
          data: {
            id: resource.id,
            email: resource.email,
            role: resource.role
          }
        }, status: :ok
      else
        # Return errors in a format the frontend can parse
        # Format: { errors: { email: ["has already been taken"], password: ["is too short"] } }
        render json: {
          errors: resource.errors.to_hash(true)
        }, status: :unprocessable_entity
      end
    end

    # Permit additional parameters for registration
    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end
end
