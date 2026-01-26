# frozen_string_literal: true

# =============================================================================
# CORS (Cross-Origin Resource Sharing) CONFIGURATION
# =============================================================================
#
# WHAT IS CORS?
# When your frontend (Next.js on localhost:3001) makes requests to your
# backend (Rails on localhost:3000), the browser blocks it by default.
# This is a security feature called the "Same-Origin Policy".
#
# CORS tells the browser: "It's OK, these specific origins are allowed to
# make requests to this server."
#
# HOW IT WORKS:
# 1. Browser sends a "preflight" OPTIONS request asking what's allowed
# 2. Server responds with allowed origins, methods, and headers
# 3. If allowed, browser proceeds with the actual request
#
# SECURITY CONSIDERATIONS:
# - In production, restrict origins to your actual frontend domain
# - Never use '*' for origins with credentials (cookies/tokens)
# - Be specific about which headers and methods you allow
#
# =============================================================================

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # ==========================================================================
    # ALLOWED ORIGINS
    # ==========================================================================
    # In development, allow requests from common frontend development servers.
    # In production, this should be your actual frontend domain.
    #
    # Using a proc allows dynamic origin checking.
    origins(
      if Rails.env.development? || Rails.env.test?
        # Allow any localhost origin in development
        # The pattern matches localhost with any port
        [
          'http://localhost:3000',
          'http://localhost:3001',    # Next.js default port
          'http://localhost:8080',
          'http://127.0.0.1:3000',
          'http://127.0.0.1:3001',
          /\Ahttp:\/\/localhost:\d+\z/ # Regex for any localhost port
        ]
      else
        # In production, only allow your specific frontend domain
        ENV.fetch('FRONTEND_URL', 'https://coworkhub.com')
      end
    )

    # ==========================================================================
    # RESOURCE CONFIGURATION
    # ==========================================================================
    resource '*', # Apply to all routes
               # HTTP methods the frontend can use
               methods: %i[get post put patch delete options head],

               # Headers the frontend can send
               # Authorization is needed for JWT tokens
               headers: %w[
                 Authorization
                 Content-Type
                 Accept
                 Origin
                 X-Requested-With
               ],

               # Headers the frontend can read from responses
               # Useful for pagination, rate limiting info, etc.
               expose: %w[
                 Authorization
                 X-Total-Count
                 X-Page
                 X-Per-Page
               ],

               # Allow credentials (cookies, Authorization header)
               # Required for JWT authentication
               credentials: true,

               # Cache preflight requests for 1 hour
               # Reduces OPTIONS requests for better performance
               max_age: 3600
  end
end
