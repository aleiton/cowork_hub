# frozen_string_literal: true

# =============================================================================
# DATABASE SEEDS
# =============================================================================
#
# Seeds populate the database with initial/test data.
# Run with: rails db:seed
# Reset and reseed: rails db:reset (drops, creates, migrates, seeds)
#
# SEED FILE BEST PRACTICES:
# 1. Use Faker for realistic data
# 2. Be idempotent (running twice shouldn't break things)
# 3. Create enough data to test all scenarios
# 4. Include edge cases (empty states, limits)
# 5. Use transactions for faster seeding
# 6. Print progress for large seeds
#
# =============================================================================

puts 'Starting database seeding...'

# =============================================================================
# HELPER METHODS
# =============================================================================

# Print progress with emoji for visual feedback
def log(emoji, message)
  puts "#{emoji}  #{message}"
end

# =============================================================================
# USERS
# =============================================================================
log '👤', 'Creating users...'

# Admin user - for testing admin features
admin = User.find_or_create_by!(email: 'admin@coworkhub.com') do |user|
  user.password = 'password123'
  user.role = :admin
end
log '✓', "Admin user created: #{admin.email}"

# Member users - for testing member features
members = []
5.times do |i|
  member = User.find_or_create_by!(email: "member#{i + 1}@example.com") do |user|
    user.password = 'password123'
    user.role = :member
  end
  members << member
end
log '✓', "Created #{members.count} member users"

# Guest users - for testing guest restrictions
guests = []
2.times do |i|
  guest = User.find_or_create_by!(email: "guest#{i + 1}@example.com") do |user|
    user.password = 'password123'
    user.role = :guest
  end
  guests << guest
end
log '✓', "Created #{guests.count} guest users"

all_users = [admin] + members + guests

# =============================================================================
# WORKSPACES - Traditional Work Spaces
# =============================================================================
log '🏢', 'Creating workspaces...'

# Hot Desks - Basic open workspace
hot_desks = [
  { name: 'Open Space A', description: 'Bright open workspace near windows with natural light. Power outlets at each desk.', capacity: 20, hourly_rate: 8.00, amenity_tier: :basic },
  { name: 'Open Space B', description: 'Quiet zone for focused work. No phone calls allowed.', capacity: 15, hourly_rate: 10.00, amenity_tier: :basic },
  { name: 'Premium Lounge', description: 'Comfortable lounge-style seating with standing desk options. Includes premium coffee.', capacity: 12, hourly_rate: 15.00, amenity_tier: :premium }
].map do |attrs|
  Workspace.find_or_create_by!(name: attrs[:name]) do |ws|
    ws.assign_attributes(attrs.merge(workspace_type: :desk))
  end
end
log '✓', "Created #{hot_desks.count} hot desk spaces"

# Private Offices
private_offices = [
  { name: 'Executive Suite 1', description: 'Private corner office with city views. Includes dedicated phone line.', capacity: 2, hourly_rate: 45.00, amenity_tier: :premium },
  { name: 'Team Office A', description: 'Private office for small teams. Whiteboard and projector included.', capacity: 6, hourly_rate: 60.00, amenity_tier: :premium },
  { name: 'Focus Pod 1', description: 'Single-person private pod for deep focus work.', capacity: 1, hourly_rate: 20.00, amenity_tier: :basic },
  { name: 'Focus Pod 2', description: 'Single-person private pod for deep focus work.', capacity: 1, hourly_rate: 20.00, amenity_tier: :basic }
].map do |attrs|
  Workspace.find_or_create_by!(name: attrs[:name]) do |ws|
    ws.assign_attributes(attrs.merge(workspace_type: :private_office))
  end
end
log '✓', "Created #{private_offices.count} private offices"

# Meeting Rooms
meeting_rooms = [
  { name: 'Boardroom', description: 'Large conference room for important meetings. Seats 16, includes video conferencing.', capacity: 16, hourly_rate: 80.00, amenity_tier: :premium },
  { name: 'Meeting Room Alpha', description: 'Medium meeting room with TV for presentations.', capacity: 8, hourly_rate: 40.00, amenity_tier: :basic },
  { name: 'Meeting Room Beta', description: 'Medium meeting room with whiteboard wall.', capacity: 8, hourly_rate: 40.00, amenity_tier: :basic },
  { name: 'Huddle Space 1', description: 'Quick informal meeting area for 2-4 people.', capacity: 4, hourly_rate: 25.00, amenity_tier: :basic }
].map do |attrs|
  Workspace.find_or_create_by!(name: attrs[:name]) do |ws|
    ws.assign_attributes(attrs.merge(workspace_type: :meeting_room))
  end
end
log '✓', "Created #{meeting_rooms.count} meeting rooms"

# =============================================================================
# WORKSPACES - Maker Workshops
# =============================================================================
log '🔧', 'Creating maker workshops...'

# Workshops with specialized equipment
workshops_data = [
  {
    name: '3D Printing Lab',
    description: 'State-of-the-art 3D printing facility with various printers and materials. Training available.',
    capacity: 8, hourly_rate: 35.00, amenity_tier: :premium,
    equipment: [
      { name: 'Prusa i3 MK3S+', description: 'High-quality FDM printer for PLA, PETG, ABS. Build volume 250x210x210mm.', quantity: 3 },
      { name: 'Formlabs Form 3', description: 'SLA resin printer for high-detail parts. Build volume 145x145x185mm.', quantity: 2 },
      { name: 'Ultimaker S5', description: 'Professional dual-extrusion FDM printer. Large build volume 330x240x300mm.', quantity: 1 },
      { name: 'Curing Station', description: 'Post-processing curing station for resin prints.', quantity: 2 }
    ]
  },
  {
    name: 'Textile Workshop',
    description: 'Full sewing and textile arts studio. Perfect for fashion designers and crafters.',
    capacity: 10, hourly_rate: 25.00, amenity_tier: :basic,
    equipment: [
      { name: 'Industrial Sewing Machine', description: 'Brother industrial sewing machine for heavy fabrics.', quantity: 4 },
      { name: 'Serger/Overlock', description: 'Professional overlock machine for finished edges.', quantity: 2 },
      { name: 'Embroidery Machine', description: 'Brother computerized embroidery machine.', quantity: 1 },
      { name: 'Cutting Table', description: 'Large cutting table with self-healing mat.', quantity: 2 }
    ]
  },
  {
    name: 'Tattoo Studio',
    description: 'Private tattoo studio with professional equipment and sterilization area.',
    capacity: 2, hourly_rate: 50.00, amenity_tier: :premium,
    equipment: [
      { name: 'Tattoo Chair', description: 'Adjustable professional tattoo chair.', quantity: 2 },
      { name: 'Power Supply Unit', description: 'Precision tattoo power supply.', quantity: 2 },
      { name: 'Autoclave', description: 'Steam sterilizer for equipment.', quantity: 1 },
      { name: 'Light Stand', description: 'Adjustable LED work light.', quantity: 2 }
    ]
  },
  {
    name: 'Woodworking Shop',
    description: 'Fully equipped woodworking workshop with power and hand tools. Safety training required.',
    capacity: 6, hourly_rate: 40.00, amenity_tier: :premium,
    equipment: [
      { name: 'Table Saw', description: 'SawStop professional table saw with safety brake.', quantity: 1 },
      { name: 'Band Saw', description: '14-inch band saw for curved cuts.', quantity: 1 },
      { name: 'Router Table', description: 'Professional router table with various bits.', quantity: 1 },
      { name: 'Drill Press', description: 'Floor-standing drill press.', quantity: 2 },
      { name: 'Workbench', description: 'Heavy-duty workbench with vise.', quantity: 4 }
    ]
  },
  {
    name: 'Electronics Lab',
    description: 'Electronics prototyping lab with soldering stations and testing equipment.',
    capacity: 8, hourly_rate: 30.00, amenity_tier: :basic,
    equipment: [
      { name: 'Soldering Station', description: 'Hakko digital soldering station.', quantity: 6 },
      { name: 'Oscilloscope', description: 'Rigol 4-channel digital oscilloscope.', quantity: 2 },
      { name: 'Power Supply', description: 'Adjustable bench power supply 0-30V, 0-5A.', quantity: 4 },
      { name: 'Multimeter', description: 'Fluke professional multimeter.', quantity: 4 },
      { name: 'PCB Mill', description: 'Desktop PCB milling machine.', quantity: 1 }
    ]
  }
]

workshops = workshops_data.map do |data|
  ws = Workspace.find_or_create_by!(name: data[:name]) do |workspace|
    workspace.description = data[:description]
    workspace.workspace_type = :workshop
    workspace.capacity = data[:capacity]
    workspace.hourly_rate = data[:hourly_rate]
    workspace.amenity_tier = data[:amenity_tier]
  end

  # Create equipment for this workshop
  data[:equipment].each do |eq|
    WorkshopEquipment.find_or_create_by!(workspace: ws, name: eq[:name]) do |equipment|
      equipment.description = eq[:description]
      equipment.quantity_available = eq[:quantity]
    end
  end

  ws
end
log '✓', "Created #{workshops.count} maker workshops with equipment"

all_workspaces = hot_desks + private_offices + meeting_rooms + workshops

# =============================================================================
# MEMBERSHIPS
# =============================================================================
log '🎫', 'Creating memberships...'

# Give some members active memberships
membership_configs = [
  { user: members[0], type: :monthly, tier: :premium },
  { user: members[1], type: :monthly, tier: :basic },
  { user: members[2], type: :weekly, tier: :premium },
  { user: members[3], type: :day_pass, tier: :basic }
  # members[4] has no membership (for testing)
]

memberships = membership_configs.map do |config|
  Membership.find_or_create_by!(user: config[:user]) do |m|
    m.membership_type = config[:type]
    m.amenity_tier = config[:tier]
    m.starts_at = Time.current - rand(1..15).days
  end
end
log '✓', "Created #{memberships.count} active memberships"

# Create an expired membership for testing
expired_membership = Membership.create!(
  user: guests[0],
  membership_type: :weekly,
  amenity_tier: :basic,
  starts_at: 2.weeks.ago,
  ends_at: 1.week.ago
)
log '✓', 'Created 1 expired membership'

# =============================================================================
# CANTINA SUBSCRIPTIONS
# =============================================================================
log '🍽️', 'Creating cantina subscriptions...'

cantina_configs = [
  { user: members[0], plan: :twenty_meals, remaining: 15 },
  { user: members[1], plan: :ten_meals, remaining: 7 },
  { user: members[2], plan: :five_meals, remaining: 2 }
  # members[3] and [4] have no subscription
]

cantina_subs = cantina_configs.map do |config|
  CantinaSubscription.find_or_create_by!(user: config[:user]) do |cs|
    cs.plan_type = config[:plan]
    cs.meals_remaining = config[:remaining]
    cs.renews_at = 2.weeks.from_now
  end
end
log '✓', "Created #{cantina_subs.count} cantina subscriptions"

# =============================================================================
# BOOKINGS
# =============================================================================
log '📅', 'Creating sample bookings...'

# Helper to create a booking for a specific day
def create_sample_booking(user, workspace, days_offset, status: :confirmed, equipment_ids: [])
  date = Date.current + days_offset
  start_hour = rand(8..16)
  duration = rand(1..4)

  Booking.create!(
    user: user,
    workspace: workspace,
    date: date,
    start_time: Time.zone.parse("#{date} #{start_hour}:00"),
    end_time: Time.zone.parse("#{date} #{start_hour + duration}:00"),
    status: status,
    equipment_used: equipment_ids
  )
rescue ActiveRecord::RecordInvalid => e
  puts "  Skipped booking: #{e.message}"
  nil
end

bookings = []

# Create upcoming bookings for members
members.first(3).each do |member|
  3.times do |i|
    ws = all_workspaces.sample
    equipment_ids = ws.workshop? ? ws.workshop_equipments.sample(rand(1..2)).pluck(:id) : []
    booking = create_sample_booking(member, ws, rand(1..14), equipment_ids: equipment_ids)
    bookings << booking if booking
  end
end

# Create some past bookings (completed)
members.first(2).each do |member|
  2.times do
    ws = all_workspaces.sample
    booking = create_sample_booking(member, ws, -rand(1..30), status: :completed)
    bookings << booking if booking
  end
end

# Create a pending booking
pending_booking = create_sample_booking(members[0], meeting_rooms.first, 3, status: :pending)
bookings << pending_booking if pending_booking

# Create a cancelled booking
cancelled_booking = create_sample_booking(members[1], hot_desks.first, 5, status: :cancelled)
bookings << cancelled_booking if cancelled_booking

log '✓', "Created #{bookings.compact.count} bookings"

# =============================================================================
# SUMMARY
# =============================================================================
puts ''
puts '=' * 60
puts 'Seeding completed!'
puts '=' * 60
puts ''
puts 'Summary:'
puts "  Users:                 #{User.count}"
puts "    - Admins:            #{User.role_admin.count}"
puts "    - Members:           #{User.role_member.count}"
puts "    - Guests:            #{User.role_guest.count}"
puts ''
puts "  Workspaces:            #{Workspace.count}"
puts "    - Desks:             #{Workspace.workspace_type_desk.count}"
puts "    - Private Offices:   #{Workspace.workspace_type_private_office.count}"
puts "    - Meeting Rooms:     #{Workspace.workspace_type_meeting_room.count}"
puts "    - Workshops:         #{Workspace.workspace_type_workshop.count}"
puts ''
puts "  Equipment:             #{WorkshopEquipment.count}"
puts "  Memberships:           #{Membership.count}"
puts "  Cantina Subscriptions: #{CantinaSubscription.count}"
puts "  Bookings:              #{Booking.count}"
puts ''
puts 'Test accounts:'
puts "  Admin:    admin@coworkhub.com / password123"
puts "  Member:   member1@example.com / password123"
puts "  Guest:    guest1@example.com / password123"
puts ''
