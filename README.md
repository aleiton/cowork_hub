# CoworkHub - Hybrid Coworking & Maker Space Platform

A professional full-stack Ruby on Rails + GraphQL backend for managing a coworking space that combines traditional work environments with specialized maker workshops.

## Overview

CoworkHub is designed to demonstrate best practices in:
- **Ruby on Rails 7+** with API-only mode
- **GraphQL API** with proper batching to prevent N+1 queries
- **Authentication** with Devise + JWT tokens
- **Authorization** with Pundit policies
- **Testing** with RSpec, FactoryBot, and comprehensive coverage

### Business Domain

The platform manages a hybrid space offering:
- **Work Spaces**: Hot desks, private offices, meeting rooms
- **Maker Workshops**: 3D printing, sewing, tattooing, woodworking, electronics labs
- **Memberships**: Day pass, weekly, monthly with basic/premium amenity tiers
- **Cafeteria Subscriptions**: 5/10/20 meal plans

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend (Next.js)                       │
│                  (To be implemented in Phase 2)              │
└────────────────────────────┬────────────────────────────────┘
                             │ GraphQL
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      Rails API Layer                         │
│  ┌───────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │  GraphQL  │  │    Devise    │  │      Pundit        │   │
│  │  Schema   │  │ (Auth/JWT)   │  │   (Authorization)  │   │
│  └─────┬─────┘  └──────────────┘  └────────────────────┘   │
│        │                                                     │
│  ┌─────▼─────────────────────────────────────────────────┐  │
│  │                   graphql-batch                        │  │
│  │              (N+1 Query Prevention)                    │  │
│  └───────────────────────┬───────────────────────────────┘  │
│                          │                                   │
│  ┌───────────────────────▼───────────────────────────────┐  │
│  │                   Active Record                        │  │
│  │                    (Models)                            │  │
│  └───────────────────────┬───────────────────────────────┘  │
└──────────────────────────┼──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     PostgreSQL                               │
└─────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Framework | Rails 7.1+ | API-only backend |
| API | graphql-ruby | GraphQL implementation |
| Database | PostgreSQL | JSONB support for equipment |
| Auth | Devise + JWT | Stateless authentication |
| Authorization | Pundit | Policy-based permissions |
| N+1 Prevention | graphql-batch | Batched database queries |
| Background Jobs | Sidekiq | Async task processing |
| Testing | RSpec + FactoryBot | BDD-style tests |
| Linting | RuboCop | Code style enforcement |

## Data Models

```
┌──────────────┐       ┌──────────────┐       ┌───────────────────┐
│     User     │───┬───│   Booking    │───────│    Workspace      │
│              │   │   │              │       │                   │
│ - email      │   │   │ - date       │       │ - name            │
│ - role       │   │   │ - start_time │       │ - workspace_type  │
│ - jti        │   │   │ - end_time   │       │ - capacity        │
└──────────────┘   │   │ - status     │       │ - hourly_rate     │
       │           │   │ - equipment_ │       │ - amenity_tier    │
       │           │   │   used[]     │       └─────────┬─────────┘
       │           │   └──────────────┘                 │
       │           │                                     │ (workshop only)
       │           │                                     │
       │           │                           ┌─────────▼─────────┐
       │           │                           │ WorkshopEquipment │
       │           │                           │                   │
       │           │                           │ - name            │
       │           │                           │ - quantity        │
       │           │                           └───────────────────┘
       │           │
       ▼           ▼
┌──────────────┐  ┌──────────────────┐
│  Membership  │  │ CantinaSubscript │
│              │  │                  │
│ - type       │  │ - plan_type      │
│ - tier       │  │ - meals_remain   │
│ - starts_at  │  │ - renews_at      │
│ - ends_at    │  │                  │
└──────────────┘  └──────────────────┘
```

## Setup Instructions

### Prerequisites

- Ruby 3.2.2
- PostgreSQL 14+
- Redis 7+ (for Sidekiq)
- Node.js 18+ (for frontend in Phase 2)

### Installation

```bash
# Clone the repository
cd cowork_hub

# Install Ruby dependencies
bundle install

# Setup the database
rails db:create
rails db:migrate
rails db:seed

# Start Redis (for Sidekiq)
redis-server

# Start the Rails server
rails server
```

### Environment Variables

Create a `.env` file in the root directory:

```env
# Database
DATABASE_URL=postgres://localhost/cowork_hub_development

# Redis
REDIS_URL=redis://localhost:6379/0

# Devise
DEVISE_JWT_SECRET_KEY=your-super-secret-jwt-key-change-in-production
DEVISE_PEPPER=your-pepper-value-change-in-production

# Rails
RAILS_MASTER_KEY=your-master-key
```

## GraphQL API

### Endpoint

```
POST /graphql
```

### Authentication

Include JWT token in Authorization header:
```
Authorization: Bearer <token>
```

### Example Queries

#### List Available Workspaces

```graphql
query {
  workspaces(workspaceType: WORKSHOP, amenityTier: PREMIUM) {
    id
    name
    description
    hourlyRate
    equipment {
      name
      quantityAvailable
    }
  }
}
```

#### Check Workspace Availability

```graphql
query {
  workspace(id: "1") {
    name
    isAvailableAt(
      date: "2024-03-15"
      startTime: "09:00"
      endTime: "17:00"
    )
  }
}
```

#### Get My Bookings

```graphql
query {
  myBookings(upcomingOnly: true) {
    id
    date
    startTime
    endTime
    status
    workspace {
      name
    }
  }
}
```

### Example Mutations

#### Create Booking

```graphql
mutation {
  createBooking(input: {
    workspaceId: "1"
    date: "2024-03-15"
    startTime: "09:00"
    endTime: "17:00"
    equipmentIds: ["1", "2"]
  }) {
    booking {
      id
      status
      calculatedPrice
    }
    errors
  }
}
```

#### Use Meal Credit

```graphql
mutation {
  useCantinaCredit {
    cantinaSubscription {
      mealsRemaining
    }
    errors
  }
}
```

## Testing

```bash
# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/booking_spec.rb

# Run specific test
bundle exec rspec spec/models/booking_spec.rb:42
```

## Linting

```bash
# Check code style
bundle exec rubocop

# Auto-fix safe violations
bundle exec rubocop -a

# Auto-fix all violations
bundle exec rubocop -A
```

## Key Design Decisions

### Why GraphQL over REST?

1. **Single Endpoint**: One endpoint handles all operations
2. **No Over-fetching**: Client requests exactly what it needs
3. **Strongly Typed**: Schema serves as documentation
4. **Perfect for Complex Data**: Nested relationships (workspace → equipment → availability)

### Why graphql-batch?

GraphQL's nested nature makes N+1 queries common:
```
workspaces {     # 1 query
  equipment {    # N queries (one per workspace)
    ...
  }
}
```

graphql-batch collects all IDs and makes single batched queries:
```
SELECT * FROM workspaces
SELECT * FROM equipment WHERE workspace_id IN (1,2,3...)
```

### Why Pundit over CanCanCan?

1. **Explicit Policies**: One policy class per model, clear ownership
2. **Testable**: Each policy method can be unit tested
3. **Flexible**: Complex authorization logic stays organized
4. **Rails-ish**: Follows convention over configuration

### Why JSONB for equipment_used?

For workshop bookings, we store equipment IDs as JSONB array:
- Simpler than a join table for this use case
- PostgreSQL can query inside JSONB efficiently
- Reduces database complexity

Alternative (join table) would be better if:
- Equipment has its own booking constraints
- Need to track equipment usage history separately

## Project Structure

```
app/
├── controllers/
│   ├── graphql_controller.rb     # GraphQL endpoint
│   └── users/                    # Devise controllers
├── graphql/
│   ├── cowork_hub_schema.rb      # Root schema
│   ├── types/                    # GraphQL types
│   ├── mutations/                # GraphQL mutations
│   ├── queries/                  # Query resolvers
│   └── loaders/                  # graphql-batch loaders
├── models/                       # ActiveRecord models
└── policies/                     # Pundit policies

spec/
├── factories/                    # FactoryBot factories
├── models/                       # Model specs
├── policies/                     # Policy specs
└── support/                      # RSpec helpers
```

## Test Accounts

After running seeds:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@coworkhub.com | password123 |
| Member | member1@example.com | password123 |
| Guest | guest1@example.com | password123 |

## Edge Cases Handled

1. **Double Booking Prevention**: Database + model level validation
2. **Equipment Availability**: Checks concurrent bookings
3. **Meal Credit Atomicity**: SQL-level atomic decrement
4. **Time Range Validation**: Start must be before end
5. **Past Date Prevention**: Cannot book in the past
6. **Membership Overlap**: One active membership per user

## Next Steps (Phase 2)

- [ ] Next.js 14+ frontend with App Router
- [ ] Apollo Client integration
- [ ] TypeScript codegen from GraphQL schema
- [ ] Responsive CSS Modules design
- [ ] Real-time updates with GraphQL subscriptions

## License

MIT
