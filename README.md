# Angel Book

A personal portfolio tracker for Business Angel investors. Track your investments, monitor key metrics, and measure portfolio performance — all in one place.

## Features

- **Investment management** — Record each investment with ticket size, entry valuation, equity percentage, sector, stage, and investment thesis
- **Periodic updates (snapshots)** — Log MRR, ARR, runway, headcount, and estimated valuation over time to track startup progress
- **Exit recording** — Record the sale of a stake with exit date and amount; computes realized multiple and gain/loss automatically
- **Portfolio dashboard** — At-a-glance KPIs: capital invested, estimated value, TVPI multiple, IRR, and runway alerts
- **Runway alerts** — Highlights active investments with less than 6 months of runway
- **Charts** — Portfolio breakdown by sector and stage
- **Filtering** — Filter investments by status, sector, or company name

## Tech Stack

- **Ruby on Rails 8.1** with Hotwire (Turbo Frames for inline forms)
- **PostgreSQL 16**
- **Tailwind CSS v4** (dark theme)
- **Chartkick + Chart.js** for charts
- **RSpec + Capybara** for testing

## Requirements

- Ruby 3.3 (managed via `mise`)
- PostgreSQL 16 (via Homebrew: `brew install postgresql@16`)

## Setup

```bash
# Install dependencies
bundle install

# Create and migrate the database
bin/rails db:create db:migrate

# Build Tailwind CSS
bin/rails tailwindcss:build
```

## Running the app

```bash
# Start Rails server + Tailwind watcher
bin/dev

# Or just the Rails server
bin/rails server
```

The app will be available at `http://localhost:3000`.

## Running tests

```bash
bundle exec rspec
```
