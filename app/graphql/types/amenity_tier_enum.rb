# frozen_string_literal: true

# =============================================================================
# AMENITY TIER ENUM
# =============================================================================
#
# Tiers of amenities available with workspace or membership.
#
# =============================================================================

module Types
  class AmenityTierEnum < BaseEnum
    description 'Amenity tier level'

    value 'BASIC', 'Standard amenities: wifi, coffee, water', value: 'basic'
    value 'PREMIUM', 'Premium amenities: all basic + snacks, printing, phone booths',
          value: 'premium'
  end
end
