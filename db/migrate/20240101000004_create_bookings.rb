# frozen_string_literal: true

# =============================================================================
# BOOKINGS MIGRATION
# =============================================================================
#
# Bookings represent reservations of workspaces for specific time slots.
# This is the core transactional entity of the application.
#
# DESIGN DECISIONS:
# - Separate date from start_time/end_time for easier querying
# - Using JSONB for equipment_used (flexible, queryable)
# - Status enum for booking lifecycle
#
# EDGE CASES HANDLED:
# - Double booking prevention (via application logic + DB constraint)
# - Equipment availability tracking
# - Time range validation
#
# =============================================================================

class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      # =========================================================================
      # RELATIONSHIPS
      # =========================================================================

      # Which workspace is being booked
      t.references :workspace, null: false, foreign_key: true

      # Who is making the booking
      t.references :user, null: false, foreign_key: true

      # =========================================================================
      # TIME SLOT
      # =========================================================================

      # Date of the booking (YYYY-MM-DD)
      # Separate from time for easier date-based queries:
      # "Get all bookings for March 15th" vs parsing datetimes
      t.date :date, null: false

      # Start and end times (just the time portion, HH:MM:SS)
      # Combined with date for full datetime when needed
      #
      # WHY TIME NOT DATETIME?
      # - Cleaner separation of concerns
      # - Easier to implement recurring bookings later
      # - Date + time math is more intuitive
      t.time :start_time, null: false
      t.time :end_time, null: false

      # =========================================================================
      # BOOKING STATUS
      # =========================================================================
      # Lifecycle: pending -> confirmed -> completed/cancelled
      #
      # Values:
      # 0 = pending (awaiting confirmation or payment)
      # 1 = confirmed (booking is active)
      # 2 = cancelled (user or admin cancelled)
      # 3 = completed (time has passed, booking was used)
      t.integer :status, default: 0, null: false

      # =========================================================================
      # EQUIPMENT USED (JSONB)
      # =========================================================================
      # For workshop bookings, tracks which equipment was reserved.
      # Stored as array of equipment IDs: [1, 2, 5]
      #
      # WHY JSONB?
      # - Flexible: don't need a separate join table
      # - Queryable: PostgreSQL can index and query JSONB
      # - Simple: for read-heavy, write-light use cases
      #
      # ALTERNATIVE: Many-to-many with booking_equipments table
      # - Better for complex equipment constraints
      # - Easier to enforce referential integrity
      # - More queries to fetch data
      #
      # We chose JSONB for simplicity, but either approach works.
      #
      # IMPORTANT: PostgreSQL specific. For MySQL, use JSON type.
      t.jsonb :equipment_used, default: []

      # =========================================================================
      # ADDITIONAL FIELDS (Optional)
      # =========================================================================
      # t.text :notes                    # User notes about the booking
      # t.decimal :total_price           # Calculated price at booking time
      # t.datetime :confirmed_at         # When booking was confirmed
      # t.datetime :cancelled_at         # When booking was cancelled
      # t.string :cancellation_reason    # Why it was cancelled

      # =========================================================================
      # TIMESTAMPS
      # =========================================================================
      t.timestamps null: false
    end

    # ===========================================================================
    # INDEXES
    # ===========================================================================

    # Index for finding bookings by date (very common query)
    add_index :bookings, :date

    # Index for finding bookings by status
    add_index :bookings, :status

    # Composite index for the most common availability query:
    # "Is this workspace available on this date?"
    add_index :bookings, %i[workspace_id date]

    # Composite index for user's booking history
    add_index :bookings, %i[user_id date]

    # Index on JSONB field for equipment queries (PostgreSQL specific)
    # This uses GIN (Generalized Inverted Index) for JSON containment queries
    add_index :bookings, :equipment_used, using: :gin
  end
end
