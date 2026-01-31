# CoworkHub Deployment Guide (Fly.io Free Tier)

This guide walks you through deploying CoworkHub to Fly.io's free tier.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Fly.io                                  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   Rails App     │    │    Sidekiq      │                    │
│  │  (web process)  │    │ (worker process)│                    │
│  │  shared-cpu-1x  │    │  shared-cpu-1x  │                    │
│  │    256MB RAM    │    │    256MB RAM    │                    │
│  └────────┬────────┘    └────────┬────────┘                    │
│           │                      │                              │
│           └──────────┬───────────┘                              │
│                      │                                          │
│           ┌──────────▼──────────┐                              │
│           │     PostgreSQL      │                              │
│           │   (Fly Postgres)    │                              │
│           │   256MB / 1GB disk  │                              │
│           └─────────────────────┘                              │
└─────────────────────────────────────────────────────────────────┘
                       │
                       ▼
            ┌─────────────────────┐
            │      Upstash        │
            │   (Serverless Redis)│
            │   Free: 10k cmd/day │
            └─────────────────────┘
```

## Prerequisites

1. **Fly.io CLI**: Install with `brew install flyctl`
2. **Upstash Account**: Create a free account at [upstash.com](https://upstash.com)

## Quick Start

```bash
# First-time setup
bin/fly-deploy setup

# Deploy the application
bin/fly-deploy deploy
```

## Manual Setup (Step by Step)

### 1. Install Fly.io CLI

```bash
brew install flyctl
```

### 2. Login to Fly.io

```bash
flyctl auth login
```

This will open a browser for authentication.

### 3. Create the Application

```bash
flyctl launch --no-deploy
```

Select your preferred region (e.g., `scl` for Santiago, `gru` for São Paulo).

### 4. Create PostgreSQL Database

```bash
# Create the database (free tier: 256MB RAM, 1GB disk)
flyctl postgres create --name cowork-hub-db --region scl

# Attach to your app (automatically sets DATABASE_URL)
flyctl postgres attach cowork-hub-db
```

### 5. Setup Upstash Redis

1. Go to [upstash.com](https://upstash.com) and create an account
2. Create a new Redis database (free tier)
3. Copy the connection string (format: `redis://default:xxx@xxx.upstash.io:6379`)

### 6. Set Environment Secrets

```bash
# Generate secrets locally
rails secret  # Run this 3 times for different secrets

# Set all secrets
flyctl secrets set \
  RAILS_MASTER_KEY="$(cat config/master.key)" \
  SECRET_KEY_BASE="your-generated-secret-1" \
  DEVISE_JWT_SECRET_KEY="your-generated-secret-2" \
  DEVISE_PEPPER="your-generated-secret-3" \
  REDIS_URL="redis://default:xxx@xxx.upstash.io:6379" \
  FRONTEND_URL="https://your-frontend.vercel.app"
```

### 7. Deploy

```bash
flyctl deploy
```

### 8. Scale Processes

```bash
# Scale to run both web and Sidekiq worker
flyctl scale count web=1 worker=1
```

## Verification

### Check Status

```bash
flyctl status
```

### View Logs

```bash
flyctl logs
# Or
bin/fly-deploy logs
```

### Test Health Endpoint

```bash
curl https://cowork-hub-api.fly.dev/health
```

### Test GraphQL

```bash
curl -X POST https://cowork-hub-api.fly.dev/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __typename }"}'
```

### Open Rails Console

```bash
flyctl ssh console -C "bin/rails console"
# Or
bin/fly-deploy console
```

### Check Sidekiq

```bash
flyctl ssh console -C "bin/rails runner 'puts Sidekiq::Stats.new.processed'"
```

## Free Tier Limits

| Service | Allocation | Notes |
|---------|------------|-------|
| Web (Rails) | 1x shared-cpu-1x, 256MB | Main API |
| Worker (Sidekiq) | 1x shared-cpu-1x, 256MB | Background jobs |
| PostgreSQL | 256MB RAM, 1GB disk | Fly Postgres free tier |
| Redis | Upstash free tier | 10k commands/day |

## Configuration Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Container build instructions |
| `.dockerignore` | Files excluded from Docker build |
| `fly.toml` | Fly.io app configuration |
| `bin/docker-entrypoint` | Container startup script |
| `bin/fly-deploy` | Deployment helper script |
| `Procfile.dev` | Local development processes |

## Troubleshooting

### App won't start

1. Check logs: `flyctl logs`
2. Verify secrets are set: `flyctl secrets list`
3. Check database connection: `flyctl postgres db list`

### Database migrations fail

1. Run migrations manually: `flyctl ssh console -C "bin/rails db:migrate"`
2. Check for pending migrations: `flyctl ssh console -C "bin/rails db:migrate:status"`

### Memory issues (256MB limit)

1. Reduce Puma workers in `fly.toml`: `WEB_CONCURRENCY = "1"`
2. Reduce threads: `RAILS_MAX_THREADS = "2"`

### Redis connection errors

1. Verify REDIS_URL is set correctly
2. Check Upstash dashboard for connection status
3. Ensure the URL uses `redis://` (not `rediss://`)

## Useful Commands

```bash
# View all secrets
flyctl secrets list

# Update a secret
flyctl secrets set KEY="new-value"

# Scale machines
flyctl scale show
flyctl scale count web=2 worker=1

# SSH into the machine
flyctl ssh console

# Run a one-off command
flyctl ssh console -C "bin/rails runner 'puts User.count'"

# View PostgreSQL info
flyctl postgres db list

# Connect to PostgreSQL directly
flyctl postgres connect -a cowork-hub-db
```

## Updating the App

To deploy updates:

```bash
# Push changes to git (optional but recommended)
git add .
git commit -m "Your changes"
git push

# Deploy to Fly.io
flyctl deploy
# Or
bin/fly-deploy deploy
```

## Custom Domain (Optional)

```bash
# Add a custom domain
flyctl certs add api.yourdomain.com

# Check certificate status
flyctl certs show api.yourdomain.com
```

Then add a CNAME record pointing to `cowork-hub-api.fly.dev`.
