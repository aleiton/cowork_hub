# frozen_string_literal: true

# =============================================================================
# BOOT FILE
# =============================================================================
#
# This is the first file loaded when Rails starts. It sets up the gem
# environment before anything else runs.
#
# =============================================================================

# Set the Gemfile path
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Require bundler and have it set up the gem load paths
require 'bundler/setup'

# Bootsnap speeds up Rails boot time by caching expensive computations.
# The cache is stored in tmp/cache/bootsnap.
# This makes `rails console` and `rails server` start much faster.
require 'bootsnap/setup'
