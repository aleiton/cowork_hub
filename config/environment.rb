# frozen_string_literal: true

# =============================================================================
# ENVIRONMENT LOADER
# =============================================================================
#
# This file loads the Rails application. It's called by config.ru (for web
# servers) and by scripts like rails console.
#
# =============================================================================

# Load the Rails application defined in config/application.rb
require_relative 'application'

# Initialize the Rails application (load all initializers, etc.)
Rails.application.initialize!
