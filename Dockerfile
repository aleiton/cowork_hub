# =============================================================================
# DOCKERFILE - CoworkHub Rails API
# =============================================================================
#
# Multi-stage build optimized for Fly.io deployment.
# Stage 1: Build gems and prepare assets
# Stage 2: Production runtime (minimal image)
#
# =============================================================================

# syntax=docker/dockerfile:1

# Base image with Ruby
ARG RUBY_VERSION=3.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# =============================================================================
# BUILD STAGE
# =============================================================================
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# =============================================================================
# PRODUCTION STAGE
# =============================================================================
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create necessary directories and run as non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p log storage tmp/pids && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database and starts the process
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Default command: start the web server
# This can be overridden for worker processes
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
