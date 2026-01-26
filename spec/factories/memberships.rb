# frozen_string_literal: true

# =============================================================================
# MEMBERSHIP FACTORY
# =============================================================================

FactoryBot.define do
  factory :membership do
    association :user

    membership_type { :monthly }
    amenity_tier { :basic }
    starts_at { Time.current }
    # ends_at is calculated automatically by the model

    # =========================================================================
    # TRAITS BY TYPE
    # =========================================================================

    trait :day_pass do
      membership_type { :day_pass }
    end

    trait :weekly do
      membership_type { :weekly }
    end

    trait :monthly do
      membership_type { :monthly }
    end

    # =========================================================================
    # TRAITS BY TIER
    # =========================================================================

    trait :basic do
      amenity_tier { :basic }
    end

    trait :premium do
      amenity_tier { :premium }
    end

    # =========================================================================
    # TRAITS BY STATUS
    # =========================================================================

    trait :active do
      starts_at { 1.week.ago }
      ends_at { 3.weeks.from_now }
    end

    trait :expired do
      starts_at { 2.months.ago }
      ends_at { 1.month.ago }
    end

    trait :future do
      starts_at { 1.week.from_now }
      ends_at { 5.weeks.from_now }
    end

    trait :expiring_soon do
      starts_at { 3.weeks.ago }
      ends_at { 3.days.from_now }
    end
  end
end
