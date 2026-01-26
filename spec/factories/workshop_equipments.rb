# frozen_string_literal: true

# =============================================================================
# WORKSHOP EQUIPMENT FACTORY
# =============================================================================

FactoryBot.define do
  factory :workshop_equipment do
    # Association - creates a workshop if not provided
    association :workspace, factory: %i[workspace workshop]

    sequence(:name) { |n| "Equipment #{n}" }
    description { Faker::Lorem.sentence }
    quantity_available { rand(1..5) }

    # =========================================================================
    # TRAITS BY EQUIPMENT TYPE
    # =========================================================================

    trait :printer_3d do
      name { 'Prusa i3 MK3S+' }
      description { '3D FDM printer for PLA and PETG materials' }
      quantity_available { 2 }
    end

    trait :sewing_machine do
      name { 'Industrial Sewing Machine' }
      description { 'Heavy-duty sewing machine for various fabrics' }
      quantity_available { 3 }
    end

    trait :laser_cutter do
      name { 'Laser Cutter 60W' }
      description { 'CO2 laser cutter for wood, acrylic, and leather' }
      quantity_available { 1 }
    end

    trait :unavailable do
      quantity_available { 0 }
    end

    trait :single_unit do
      quantity_available { 1 }
    end
  end
end
