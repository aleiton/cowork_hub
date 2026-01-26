# frozen_string_literal: true

# =============================================================================
# GRAPHQL SCHEMA
# =============================================================================
#
# This is the root schema for our GraphQL API. It ties together:
# - Query type (read operations)
# - Mutation type (write operations)
# - Plugins and middleware (batching, error handling, etc.)
#
# GRAPHQL vs REST:
#
# REST:
# - Multiple endpoints: GET /workspaces, GET /workspaces/:id, POST /bookings
# - Server decides what data to return
# - Over-fetching (getting more than you need) or under-fetching (multiple requests)
#
# GraphQL:
# - Single endpoint: POST /graphql
# - Client specifies exactly what data it needs
# - One request, exactly the data you need
# - Strongly typed schema serves as documentation
#
# SCHEMA STRUCTURE:
# - Types: Define the shape of data (like TypeScript interfaces)
# - Queries: Read operations (like GET in REST)
# - Mutations: Write operations (like POST/PUT/DELETE in REST)
# - Subscriptions: Real-time updates (not implemented here, but possible)
#
# =============================================================================

class CoworkHubSchema < GraphQL::Schema
  # ===========================================================================
  # ROOT TYPES
  # ===========================================================================
  # These define the entry points for GraphQL operations

  # Query type for read operations
  query Types::QueryType

  # Mutation type for write operations
  mutation Types::MutationType

  # Subscription type for real-time updates (uncomment if needed)
  # subscription Types::SubscriptionType

  # ===========================================================================
  # GRAPHQL-BATCH
  # ===========================================================================
  # This plugin prevents N+1 queries by batching database lookups.
  #
  # THE N+1 PROBLEM:
  # Without batching, if you query 10 workspaces with their equipment:
  # 1. SELECT * FROM workspaces (1 query)
  # 2. For each workspace: SELECT * FROM workshop_equipments WHERE workspace_id = X
  #    (10 queries)
  # Total: 11 queries (1 + N where N = 10)
  #
  # WITH BATCHING:
  # 1. SELECT * FROM workspaces (1 query)
  # 2. Collect all workspace IDs, then:
  #    SELECT * FROM workshop_equipments WHERE workspace_id IN (1,2,3...)
  #    (1 query)
  # Total: 2 queries
  #
  # graphql-batch collects all the IDs requested during a single GraphQL
  # request, then makes one efficient query.

  use GraphQL::Batch

  # ===========================================================================
  # ERROR HANDLING
  # ===========================================================================

  # How to handle errors that occur during execution
  # In production, you might want to report to an error tracking service
  rescue_from(ActiveRecord::RecordNotFound) do |err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, "Record not found: #{err.message}"
  end

  rescue_from(ActiveRecord::RecordInvalid) do |err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, err.record.errors.full_messages.join(', ')
  end

  rescue_from(Pundit::NotAuthorizedError) do |_err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, 'You are not authorized to perform this action'
  end

  # ===========================================================================
  # OBJECT RESOLUTION
  # ===========================================================================

  # Relay-style node interface for global ID resolution
  # This allows fetching any object by a global ID
  def self.id_from_object(object, _type_definition, _query_ctx)
    object.to_global_id.to_s
  end

  def self.object_from_id(global_id, _query_ctx)
    GlobalID.find(global_id)
  end

  # Resolve abstract types (interfaces and unions)
  def self.resolve_type(_abstract_type, obj, _ctx)
    case obj
    when User then Types::UserType
    when Workspace then Types::WorkspaceType
    when Booking then Types::BookingType
    when Membership then Types::MembershipType
    when CantinaSubscription then Types::CantinaSubscriptionType
    when WorkshopEquipment then Types::WorkshopEquipmentType
    else
      raise "Unknown type: #{obj.class.name}"
    end
  end

  # ===========================================================================
  # INTROSPECTION
  # ===========================================================================

  # Allow schema introspection in all environments
  # In production, you might want to disable this for security
  # disable_introspection_entry_points unless Rails.env.development?

  # ===========================================================================
  # QUERY DEPTH LIMIT
  # ===========================================================================

  # Prevent deeply nested queries that could be expensive
  # Example: user { bookings { workspace { bookings { user { ... } } } } }
  #
  # NOTE: Higher limits in development to allow GraphiQL introspection
  # Introspection queries are deep/complex by nature (fetching full schema)
  # In production, tighter limits protect against malicious queries
  if Rails.env.development?
    max_depth 20
    max_complexity 500
  else
    max_depth 10
    max_complexity 200
  end

  # ===========================================================================
  # TRACING & INSTRUMENTATION
  # ===========================================================================

  # Add query execution tracing (useful for debugging)
  if Rails.env.development?
    # This helps identify slow resolvers
    trace_with GraphQL::Tracing::ActiveSupportNotificationsTrace
  end
end
