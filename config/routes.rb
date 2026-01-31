# frozen_string_literal: true

# =============================================================================
# ROUTES CONFIGURATION
# =============================================================================
#
# Rails routes map URLs to controller actions. In a GraphQL API, routing is
# simpler because we have a single endpoint that handles all queries/mutations.
#
# REST vs GraphQL routing:
# - REST: Multiple endpoints (GET /users, POST /users, GET /users/:id, etc.)
# - GraphQL: Single endpoint (POST /graphql) that handles everything
#
# The GraphQL approach reduces routing complexity but moves the complexity
# to the GraphQL schema (types, queries, mutations).
#
# =============================================================================

Rails.application.routes.draw do
  # ===========================================================================
  # GRAPHQL ENDPOINT
  # ===========================================================================
  # All GraphQL queries and mutations go through this single endpoint.
  # The frontend sends POST requests with a JSON body containing:
  # - query: The GraphQL query/mutation string
  # - variables: Any variables the query needs
  # - operationName: (optional) For documents with multiple operations
  post '/graphql', to: 'graphql#execute'

  # ===========================================================================
  # GRAPHIQL - INTERACTIVE GRAPHQL IDE (Development Only)
  # ===========================================================================
  # GraphiQL provides a web interface to explore and test your GraphQL API.
  # Features:
  # - Autocomplete for queries based on your schema
  # - Documentation explorer
  # - Query history
  # - Variable editor
  #
  # Access it at: http://localhost:3000/graphiql
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  # ===========================================================================
  # DEVISE ROUTES (Authentication)
  # ===========================================================================
  # Devise provides these authentication endpoints:
  # - POST /users (registration)
  # - POST /users/sign_in (login)
  # - DELETE /users/sign_out (logout)
  # - PUT /users (update account)
  # - DELETE /users (delete account)
  #
  # We customize the controllers to return JSON responses instead of redirects.
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # ===========================================================================
  # SIDEKIQ WEB UI (Background Jobs)
  # ===========================================================================
  # Sidekiq provides a web dashboard to monitor background jobs.
  # Features:
  # - View queued, processing, and completed jobs
  # - Retry failed jobs
  # - View scheduled jobs (sidekiq-scheduler)
  # - Real-time statistics
  #
  # Access it at: http://localhost:3000/sidekiq
  #
  # NOTE: In production, protect this with authentication!
  # See: https://github.com/sidekiq/sidekiq/wiki/Monitoring#authentication
  if Rails.env.development?
    require 'sidekiq/web'
    require 'sidekiq-scheduler/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  # ===========================================================================
  # HEALTH CHECK
  # ===========================================================================
  # A simple endpoint for load balancers and monitoring services.
  # Returns 200 OK if the application is running.
  get '/health', to: proc { [200, {}, ['OK']] }

  # ===========================================================================
  # ROOT ROUTE
  # ===========================================================================
  # For API-only apps, the root can redirect to documentation or return info.
  root to: proc {
    [200, { 'Content-Type' => 'application/json' }, [
      {
        name: 'CoworkHub API',
        version: '1.0.0',
        graphql_endpoint: '/graphql',
        documentation: '/graphiql'
      }.to_json
    ]]
  }
end
