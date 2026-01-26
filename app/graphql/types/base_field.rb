# frozen_string_literal: true

# =============================================================================
# BASE FIELD
# =============================================================================
#
# BaseField is the parent class for all GraphQL fields.
# It allows us to add shared behavior or options to all fields.
#
# WHAT ARE FIELDS?
# Fields are the properties/methods that can be queried on a type.
# They're like attributes on an object, but can also accept arguments
# and compute values.
#
# EXAMPLE:
# field :email, String, null: false
# field :full_name, String, null: true do
#   argument :include_title, Boolean, required: false
# end
#
# =============================================================================

module Types
  class BaseField < GraphQL::Schema::Field
    # =========================================================================
    # ARGUMENT CLASS
    # =========================================================================
    # Custom argument class for all fields
    argument_class Types::BaseArgument

    # =========================================================================
    # CUSTOM OPTIONS
    # =========================================================================
    # You can add custom field options here that apply to all fields.
    # For example, permission checking:
    #
    # def initialize(*args, admin_only: false, **kwargs, &block)
    #   @admin_only = admin_only
    #   super(*args, **kwargs, &block)
    # end
    #
    # def authorized?(obj, args, ctx)
    #   return true unless @admin_only
    #   ctx[:current_user]&.role_admin?
    # end

    # =========================================================================
    # NULL HANDLING
    # =========================================================================
    # By default in graphql-ruby, fields are nullable.
    # We keep this default but document it here for clarity.
    #
    # field :name, String, null: false  # Required, never null
    # field :bio, String, null: true    # Optional, can be null
  end
end
