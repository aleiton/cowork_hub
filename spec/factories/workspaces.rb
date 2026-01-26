# frozen_string_literal: true

# =============================================================================
# WORKSPACE FACTORY
# =============================================================================

FactoryBot.define do
  factory :workspace do
    sequence(:name) { |n| "Workspace #{n}" }
    description { Faker::Lorem.paragraph }
    workspace_type { :desk }
    capacity { 4 }
    hourly_rate { 15.00 }
    amenity_tier { :basic }

    # =========================================================================
    # TRAITS BY TYPE
    # =========================================================================

    trait :desk do
      workspace_type { :desk }
      sequence(:name) { |n| "Hot Desk #{n}" }
      capacity { rand(10..20) }
      hourly_rate { rand(8.0..15.0).round(2) }
    end

    trait :private_office do
      workspace_type { :private_office }
      sequence(:name) { |n| "Private Office #{n}" }
      capacity { rand(1..6) }
      hourly_rate { rand(25.0..60.0).round(2) }
    end

    trait :meeting_room do
      workspace_type { :meeting_room }
      sequence(:name) { |n| "Meeting Room #{n}" }
      capacity { rand(4..16) }
      hourly_rate { rand(30.0..80.0).round(2) }
    end

    trait :workshop do
      workspace_type { :workshop }
      sequence(:name) { |n| "Workshop #{n}" }
      capacity { rand(4..10) }
      hourly_rate { rand(25.0..50.0).round(2) }
      amenity_tier { :premium }

      # Create equipment after workshop is created
      after(:create) do |workspace|
        create_list(:workshop_equipment, 3, workspace: workspace)
      end
    end

    # =========================================================================
    # TRAITS BY AMENITY
    # =========================================================================

    trait :basic do
      amenity_tier { :basic }
    end

    trait :premium do
      amenity_tier { :premium }
      hourly_rate { 50.00 }
    end

    # =========================================================================
    # SPECIAL TRAITS
    # =========================================================================

    trait :with_bookings do
      after(:create) do |workspace|
        create_list(:booking, 3, workspace: workspace)
      end
    end
  end
end
