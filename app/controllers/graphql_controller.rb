# frozen_string_literal: true

# =============================================================================
# GRAPHQL CONTROLLER
# =============================================================================
#
# This controller handles all GraphQL requests.
# It receives the GraphQL query/mutation from the frontend and executes it.
#
# HOW GRAPHQL REQUESTS WORK:
# 1. Frontend sends POST /graphql with JSON body:
#    { "query": "...", "variables": {...}, "operationName": "..." }
# 2. This controller extracts those parts
# 3. Executes the query against our schema
# 4. Returns JSON result
#
# CONTEXT:
# The context hash is passed to all resolvers and contains:
# - current_user: The authenticated user (from JWT)
# - Any other request-specific data resolvers might need
#
# =============================================================================

class GraphqlController < ApplicationController
  # Skip CSRF verification for API requests
  # (CSRF protection uses cookies; we use JWT tokens)
  skip_before_action :verify_authenticity_token, raise: false

  # Include Devise test helpers for current_user
  before_action :authenticate_user_from_token!

  def execute
    # Extract query components from request
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    # Build context for resolvers
    # This is passed to all resolver methods
    context = {
      current_user: current_user,
      # Add other context as needed:
      # request: request,
      # ip_address: request.remote_ip
    }

    # Execute the GraphQL query
    result = CoworkHubSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    render json: result
  rescue StandardError => e
    # Handle unexpected errors
    handle_error_in_development(e)
  end

  private

  # Authenticate user from JWT token in Authorization header
  # Format: "Bearer <token>"
  def authenticate_user_from_token!
    # Devise-JWT automatically handles this through Warden
    # The token is validated and user is set in current_user
    # This method is here for explicit documentation
  end

  # Handle variables that might come as string JSON or hash
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      # GraphQL-Ruby will validate name and type of incoming variables
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  # In development, show detailed error information
  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: {
      errors: [
        {
          message: error.message,
          backtrace: Rails.env.development? ? error.backtrace : nil
        }
      ],
      data: {}
    }, status: :internal_server_error
  end
end
