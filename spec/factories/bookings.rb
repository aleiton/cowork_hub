# frozen_string_literal: true

# =============================================================================
# BOOKING FACTORY
# =============================================================================

FactoryBot.define do
  factory :booking do
    association :user
    association :workspace

    date { Date.current + 1.day }
    start_time { Time.zone.parse('09:00') }
    end_time { Time.zone.parse('17:00') }
    status { :pending }
    equipment_used { [] }

    # =========================================================================
    # TRAITS BY STATUS
    # =========================================================================

    trait :pending do
      status { :pending }
    end

    trait :confirmed do
      status { :confirmed }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :completed do
      status { :completed }
      date { Date.current - 1.week }
    end

    # =========================================================================
    # TRAITS BY TIME
    # =========================================================================

    trait :today do
      date { Date.current }
    end

    trait :tomorrow do
      date { Date.current + 1.day }
    end

    trait :past do
      date { Date.current - 1.week }
      status { :completed }
    end

    trait :future do
      date { Date.current + 1.week }
    end

    trait :morning do
      start_time { Time.zone.parse('08:00') }
      end_time { Time.zone.parse('12:00') }
    end

    trait :afternoon do
      start_time { Time.zone.parse('13:00') }
      end_time { Time.zone.parse('17:00') }
    end

    trait :full_day do
      start_time { Time.zone.parse('09:00') }
      end_time { Time.zone.parse('18:00') }
    end

    # =========================================================================
    # TRAIT FOR WORKSHOP BOOKING
    # =========================================================================

    trait :with_equipment do
      association :workspace, factory: %i[workspace workshop]

      after(:create) do |booking|
        # Use equipment from the workspace
        equipment_ids = booking.workspace.workshop_equipments.pluck(:id).first(2)
        booking.update!(equipment_used: equipment_ids)
      end
    end
  end
end
