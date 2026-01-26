# frozen_string_literal: true

# =============================================================================
# USER FACTORY
# =============================================================================
#
# Factories generate test data for specs. They're more flexible than fixtures.
#
# USAGE:
#   create(:user)              # Creates and saves a user
#   build(:user)               # Builds user but doesn't save
#   create(:user, :admin)      # Creates an admin user (trait)
#   create(:user, email: 'x')  # Creates user with custom attribute
#   attributes_for(:user)      # Returns a hash of attributes
#
# WHY FACTORIES > FIXTURES:
# 1. Dynamic: Each test can customize the data it needs
# 2. Sequences: Generate unique emails, names automatically
# 3. Traits: Combine variations easily (:admin, :with_membership)
# 4. Associations: Automatically create related records
#
# =============================================================================

FactoryBot.define do
  factory :user do
    # Sequence generates unique values: user1@example.com, user2@example.com...
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    role { :member }

    # =========================================================================
    # TRAITS
    # =========================================================================
    # Traits are variations of the base factory.
    # Usage: create(:user, :admin)

    trait :admin do
      role { :admin }
      sequence(:email) { |n| "admin#{n}@example.com" }
    end

    trait :guest do
      role { :guest }
      sequence(:email) { |n| "guest#{n}@example.com" }
    end

    trait :member do
      role { :member }
    end

    # User with an active membership
    trait :with_membership do
      after(:create) do |user|
        create(:membership, user: user)
      end
    end

    # User with a premium membership
    trait :with_premium_membership do
      after(:create) do |user|
        create(:membership, :premium, user: user)
      end
    end

    # User with a cantina subscription
    trait :with_cantina_subscription do
      after(:create) do |user|
        create(:cantina_subscription, user: user)
      end
    end
  end
end
