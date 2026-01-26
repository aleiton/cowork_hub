# frozen_string_literal: true

# =============================================================================
# CANTINA SUBSCRIPTION FACTORY
# =============================================================================

FactoryBot.define do
  factory :cantina_subscription do
    association :user

    plan_type { :ten_meals }
    meals_remaining { 10 }
    renews_at { 1.month.from_now }

    # =========================================================================
    # TRAITS BY PLAN
    # =========================================================================

    trait :five_meals do
      plan_type { :five_meals }
      meals_remaining { 5 }
    end

    trait :ten_meals do
      plan_type { :ten_meals }
      meals_remaining { 10 }
    end

    trait :twenty_meals do
      plan_type { :twenty_meals }
      meals_remaining { 20 }
    end

    # =========================================================================
    # TRAITS BY STATUS
    # =========================================================================

    trait :active do
      renews_at { 2.weeks.from_now }
      meals_remaining { 5 }
    end

    trait :depleted do
      meals_remaining { 0 }
    end

    trait :almost_depleted do
      meals_remaining { 1 }
    end

    trait :expired do
      renews_at { 1.week.ago }
    end

    trait :renewing_soon do
      renews_at { 3.days.from_now }
    end
  end
end
