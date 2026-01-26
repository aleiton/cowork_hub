# frozen_string_literal: true

# =============================================================================
# SPEC HELPER
# =============================================================================
#
# This file contains RSpec configuration that doesn't depend on Rails.
# It's loaded for all specs and focuses on RSpec behavior configuration.
#
# TESTING PHILOSOPHY:
# 1. Tests should be fast and isolated
# 2. Each test should test ONE thing
# 3. Tests should be readable as documentation
# 4. Use factories over fixtures
# 5. Test behavior, not implementation
#
# =============================================================================

# Start SimpleCov for code coverage
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Models', 'app/models'
  add_group 'GraphQL', 'app/graphql'
  add_group 'Policies', 'app/policies'
  add_group 'Services', 'app/services'
end

RSpec.configure do |config|
  # =========================================================================
  # EXPECTATIONS
  # =========================================================================

  # Enable new expectation syntax: expect(x).to
  # Disable old should syntax: x.should
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # =========================================================================
  # MOCKS
  # =========================================================================

  # Verify that mocked methods exist
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # =========================================================================
  # SHARED CONTEXT
  # =========================================================================

  # Allow shared_context with :metadata style
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # =========================================================================
  # FILTERING
  # =========================================================================

  # Allow focusing on specific tests with :focus tag
  config.filter_run_when_matching :focus

  # Disable monkey patching (no `describe` at top level)
  config.disable_monkey_patching!

  # =========================================================================
  # WARNINGS
  # =========================================================================

  # Show Ruby warnings
  config.warnings = true

  # =========================================================================
  # PROFILING
  # =========================================================================

  # Print slowest examples
  config.profile_examples = 10 if config.files_to_run.one?

  # =========================================================================
  # ORDERING
  # =========================================================================

  # Run specs in random order
  config.order = :random

  # Seed for reproducible random order
  Kernel.srand config.seed
end
