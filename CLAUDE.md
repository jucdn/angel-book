# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Angel Book — a personal portfolio tracker for Business Angel investors. Built with Rails 8.1, PostgreSQL 16, Tailwind CSS v4, Hotwire, and Devise.

## Commands

```bash
# Install dependencies
bundle install

# Database setup
bin/rails db:create db:migrate

# Start server + Tailwind watcher
bin/dev

# Run all tests
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/models/investment_spec.rb

# Run a single example
bundle exec rspec spec/models/investment_spec.rb:42

# Lint
bundle exec rubocop

# Build Tailwind CSS (one-shot)
bin/rails tailwindcss:build
```

## Architecture

All routes are under authentication (`authenticate_user!` in `ApplicationController`). Registration is disabled — only login/password reset via Devise.

**Core models:**
- `Investment` — one record per startup investment. Holds ticket size, sector/stage, equity %, entry valuation, and optional exit data. `status` is a string enum: `active | exited | written_off`.
- `Snapshot` — periodic update for an investment (MRR, ARR, runway, headcount, current valuation). The most recent snapshot drives the investment's current valuation and runway alert.

**Key business logic in `Investment`:**
- `current_valuation` — returns `exit_amount` if exited, latest snapshot's `current_valuation`, or falls back to `invested_amount`.
- `portfolio_irr` — bisection method on cash flows (investments as negatives, current valuations as terminal positives). Written-off investments contribute no terminal cash flow.
- `tvpi` — `total_estimated_value / total_invested`.
- Runway alerts fire when `latest_snapshot.runway_months < 6`.

**Routes:**
- `root` → `DashboardController#index` (portfolio KPIs + charts)
- `resources :investments` with nested `resources :snapshots` and member routes `exit_form`/`record_exit`

**Frontend:** Turbo Frames are used for inline forms (snapshots new/create within the investment show page). Tailwind v4 dark theme. Charts via Chartkick + Chart.js.

**Tests:** RSpec with FactoryBot + Faker. System specs use Capybara + Selenium. Model specs live in `spec/models/`, system specs in `spec/system/`.
