# frozen_string_literal: true

# =============================================================================
# BOOKING POLICY SPECS
# =============================================================================
#
# Policy specs test authorization rules.
# They verify that the right users can perform the right actions.
#
# =============================================================================

require 'rails_helper'

RSpec.describe BookingPolicy do
  subject { described_class.new(user, booking) }

  let(:booking) { create(:booking, user: booking_owner) }
  let(:booking_owner) { create(:user) }

  # ===========================================================================
  # UNAUTHENTICATED USER
  # ===========================================================================
  describe 'for unauthenticated user' do
    let(:user) { nil }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  # ===========================================================================
  # GUEST USER
  # ===========================================================================
  describe 'for guest user' do
    let(:user) { create(:user, :guest) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  # ===========================================================================
  # BOOKING OWNER
  # ===========================================================================
  describe 'for booking owner' do
    let(:user) { booking_owner }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.not_to permit_action(:confirm) }
  end

  # ===========================================================================
  # OTHER MEMBER
  # ===========================================================================
  describe 'for other member' do
    let(:user) { create(:user, :member) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  # ===========================================================================
  # ADMIN USER
  # ===========================================================================
  describe 'for admin user' do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.to permit_action(:confirm) }
  end

  # ===========================================================================
  # SCOPE
  # ===========================================================================
  describe 'Scope' do
    let!(:user_booking) { create(:booking, user: user) }
    let!(:other_booking) { create(:booking) }

    describe 'for admin' do
      let(:user) { create(:user, :admin) }

      it 'includes all bookings' do
        scope = described_class::Scope.new(user, Booking).resolve

        expect(scope).to include(user_booking, other_booking)
      end
    end

    describe 'for regular user' do
      let(:user) { create(:user, :member) }

      it 'only includes own bookings' do
        scope = described_class::Scope.new(user, Booking).resolve

        expect(scope).to include(user_booking)
        expect(scope).not_to include(other_booking)
      end
    end

    describe 'for unauthenticated user' do
      let(:user) { nil }

      it 'returns no bookings' do
        scope = described_class::Scope.new(user, Booking).resolve

        expect(scope).to be_empty
      end
    end
  end
end
