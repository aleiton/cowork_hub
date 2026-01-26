# frozen_string_literal: true

# =============================================================================
# BOOKING MODEL SPECS
# =============================================================================
#
# Tests the core booking logic including:
# - Time validation
# - Double-booking prevention
# - Equipment validation
# - Status transitions
#
# =============================================================================

require 'rails_helper'

RSpec.describe Booking do
  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================
  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_presence_of(:status) }
  end

  # ===========================================================================
  # ASSOCIATIONS
  # ===========================================================================
  describe 'associations' do
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to belong_to(:user) }
  end

  # ===========================================================================
  # CUSTOM VALIDATIONS
  # ===========================================================================
  describe 'custom validations' do
    describe '#end_time_after_start_time' do
      it 'is invalid when end_time is before start_time' do
        booking = build(:booking,
                        start_time: Time.zone.parse('14:00'),
                        end_time: Time.zone.parse('10:00'))

        expect(booking).not_to be_valid
        expect(booking.errors[:end_time]).to include('must be after start time')
      end

      it 'is invalid when end_time equals start_time' do
        booking = build(:booking,
                        start_time: Time.zone.parse('10:00'),
                        end_time: Time.zone.parse('10:00'))

        expect(booking).not_to be_valid
      end

      it 'is valid when end_time is after start_time' do
        booking = build(:booking,
                        start_time: Time.zone.parse('10:00'),
                        end_time: Time.zone.parse('12:00'))

        expect(booking).to be_valid
      end
    end

    describe '#date_not_in_past' do
      it 'is invalid for past dates' do
        booking = build(:booking, date: Date.current - 1.day)

        expect(booking).not_to be_valid
        expect(booking.errors[:date]).to include("can't be in the past")
      end

      it 'is valid for current date' do
        booking = build(:booking, date: Date.current)

        expect(booking).to be_valid
      end

      it 'is valid for future dates' do
        booking = build(:booking, date: Date.current + 1.day)

        expect(booking).to be_valid
      end
    end

    describe '#no_double_booking' do
      let(:workspace) { create(:workspace) }
      let(:date) { Date.current + 1.day }

      before do
        # Create an existing booking from 10:00 to 14:00
        create(:booking,
               workspace: workspace,
               date: date,
               start_time: Time.zone.parse('10:00'),
               end_time: Time.zone.parse('14:00'),
               status: :confirmed)
      end

      it 'prevents booking at the same time' do
        booking = build(:booking,
                        workspace: workspace,
                        date: date,
                        start_time: Time.zone.parse('10:00'),
                        end_time: Time.zone.parse('14:00'))

        expect(booking).not_to be_valid
        expect(booking.errors[:base]).to include('This workspace is already booked for the selected time')
      end

      it 'prevents overlapping bookings (new starts during existing)' do
        booking = build(:booking,
                        workspace: workspace,
                        date: date,
                        start_time: Time.zone.parse('12:00'),
                        end_time: Time.zone.parse('16:00'))

        expect(booking).not_to be_valid
      end

      it 'prevents overlapping bookings (new ends during existing)' do
        booking = build(:booking,
                        workspace: workspace,
                        date: date,
                        start_time: Time.zone.parse('08:00'),
                        end_time: Time.zone.parse('12:00'))

        expect(booking).not_to be_valid
      end

      it 'prevents overlapping bookings (new contains existing)' do
        booking = build(:booking,
                        workspace: workspace,
                        date: date,
                        start_time: Time.zone.parse('08:00'),
                        end_time: Time.zone.parse('18:00'))

        expect(booking).not_to be_valid
      end

      it 'allows non-overlapping bookings' do
        booking = build(:booking,
                        workspace: workspace,
                        date: date,
                        start_time: Time.zone.parse('14:00'),
                        end_time: Time.zone.parse('18:00'))

        expect(booking).to be_valid
      end

      it 'allows bookings on different dates' do
        booking = build(:booking,
                        workspace: workspace,
                        date: date + 1.day,
                        start_time: Time.zone.parse('10:00'),
                        end_time: Time.zone.parse('14:00'))

        expect(booking).to be_valid
      end

      it 'ignores cancelled bookings' do
        # Cancel the existing booking
        Booking.last.update!(status: :cancelled)

        booking = build(:booking,
                        workspace: workspace,
                        date: date,
                        start_time: Time.zone.parse('10:00'),
                        end_time: Time.zone.parse('14:00'))

        expect(booking).to be_valid
      end
    end
  end

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================
  describe '#duration_hours' do
    it 'calculates the duration in hours' do
      booking = build(:booking,
                      start_time: Time.zone.parse('09:00'),
                      end_time: Time.zone.parse('17:00'))

      expect(booking.duration_hours).to eq(8.0)
    end

    it 'handles fractional hours' do
      booking = build(:booking,
                      start_time: Time.zone.parse('09:00'),
                      end_time: Time.zone.parse('10:30'))

      expect(booking.duration_hours).to eq(1.5)
    end
  end

  describe '#cancellable?' do
    it 'returns true for pending bookings in the future' do
      booking = create(:booking, :pending, date: Date.current + 1.day)
      expect(booking.cancellable?).to be true
    end

    it 'returns true for confirmed bookings in the future' do
      booking = create(:booking, :confirmed, date: Date.current + 1.day)
      expect(booking.cancellable?).to be true
    end

    it 'returns false for cancelled bookings' do
      booking = create(:booking, :cancelled)
      expect(booking.cancellable?).to be false
    end

    it 'returns false for completed bookings' do
      booking = create(:booking, :completed)
      expect(booking.cancellable?).to be false
    end
  end

  describe '#cancel!' do
    it 'changes status to cancelled' do
      booking = create(:booking, :confirmed, date: Date.current + 1.day)

      expect(booking.cancel!).to be true
      expect(booking.reload.status).to eq('cancelled')
    end

    it 'returns false if booking is not cancellable' do
      booking = create(:booking, :cancelled)

      expect(booking.cancel!).to be false
    end
  end

  # ===========================================================================
  # SCOPES
  # ===========================================================================
  describe 'scopes' do
    describe '.active' do
      it 'includes pending and confirmed bookings' do
        pending = create(:booking, :pending)
        confirmed = create(:booking, :confirmed)
        cancelled = create(:booking, :cancelled)
        completed = create(:booking, :completed)

        active = described_class.active

        expect(active).to include(pending, confirmed)
        expect(active).not_to include(cancelled, completed)
      end
    end

    describe '.upcoming' do
      it 'returns future bookings ordered by date' do
        future1 = create(:booking, date: Date.current + 2.days)
        future2 = create(:booking, date: Date.current + 1.day)
        create(:booking, :past)

        upcoming = described_class.upcoming

        expect(upcoming).to eq([future2, future1])
      end
    end
  end
end
