# frozen_string_literal: true

# =============================================================================
# USER MODEL SPECS
# =============================================================================
#
# Model specs test:
# - Validations
# - Associations
# - Callbacks
# - Instance methods
# - Scopes
#
# TESTING PHILOSOPHY:
# - Test behavior, not implementation
# - One assertion per test (when possible)
# - Use descriptive test names
# - Use factories for test data
#
# =============================================================================

require 'rails_helper'

RSpec.describe User do
  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================
  describe 'validations' do
    # Shoulda matchers provide one-liner tests for common validations
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:jti) }
  end

  # ===========================================================================
  # ASSOCIATIONS
  # ===========================================================================
  describe 'associations' do
    it { is_expected.to have_many(:bookings).dependent(:destroy) }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:cantina_subscriptions).dependent(:destroy) }
    it { is_expected.to have_many(:booked_workspaces).through(:bookings) }
  end

  # ===========================================================================
  # ENUMS
  # ===========================================================================
  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(guest: 0, member: 1, admin: 2).with_prefix }
  end

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================
  describe 'callbacks' do
    describe '#ensure_jti' do
      it 'generates a jti before validation on create' do
        user = build(:user, jti: nil)
        user.valid?
        expect(user.jti).to be_present
      end

      it 'does not overwrite existing jti' do
        original_jti = 'existing-jti'
        user = build(:user, jti: original_jti)
        user.valid?
        expect(user.jti).to eq(original_jti)
      end
    end
  end

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================
  describe '#active_membership?' do
    context 'when user has an active membership' do
      it 'returns true' do
        user = create(:user, :with_membership)
        expect(user.active_membership?).to be true
      end
    end

    context 'when user has no membership' do
      it 'returns false' do
        user = create(:user)
        expect(user.active_membership?).to be false
      end
    end

    context 'when user has only expired memberships' do
      it 'returns false' do
        user = create(:user)
        create(:membership, :expired, user: user)
        expect(user.active_membership?).to be false
      end
    end
  end

  describe '#current_membership' do
    it 'returns the active membership' do
      user = create(:user)
      membership = create(:membership, :active, user: user)
      expect(user.current_membership).to eq(membership)
    end

    it 'returns nil when no active membership exists' do
      user = create(:user)
      expect(user.current_membership).to be_nil
    end
  end

  describe '#premium_access?' do
    it 'returns true for users with premium membership' do
      user = create(:user, :with_premium_membership)
      expect(user.premium_access?).to be true
    end

    it 'returns true for admin users' do
      user = create(:user, :admin)
      expect(user.premium_access?).to be true
    end

    it 'returns false for basic membership users' do
      user = create(:user, :with_membership)
      expect(user.premium_access?).to be false
    end
  end

  describe '#has_meal_credits?' do
    context 'when user has an active subscription with meals' do
      it 'returns true' do
        user = create(:user, :with_cantina_subscription)
        expect(user.has_meal_credits?).to be true
      end
    end

    context 'when user has no subscription' do
      it 'returns false' do
        user = create(:user)
        expect(user.has_meal_credits?).to be false
      end
    end

    context 'when subscription is depleted' do
      it 'returns false' do
        user = create(:user)
        create(:cantina_subscription, :depleted, user: user)
        expect(user.has_meal_credits?).to be false
      end
    end
  end

  # ===========================================================================
  # SCOPES
  # ===========================================================================
  describe 'scopes' do
    describe '.with_active_membership' do
      it 'returns users with active memberships' do
        user_with_membership = create(:user, :with_membership)
        create(:user) # user without membership

        expect(described_class.with_active_membership).to include(user_with_membership)
      end

      it 'excludes users with expired memberships' do
        user = create(:user)
        create(:membership, :expired, user: user)

        expect(described_class.with_active_membership).not_to include(user)
      end
    end
  end
end
