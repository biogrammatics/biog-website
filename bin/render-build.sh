#!/usr/bin/env bash
# exit on error
set -o errexit

echo "=== Starting Render build ==="

# Check if RAILS_MASTER_KEY is set
if [ -z "$RAILS_MASTER_KEY" ]; then
  echo "ERROR: RAILS_MASTER_KEY environment variable is not set!"
  echo "Please set this in your Render service environment variables."
  exit 1
fi

echo "✓ RAILS_MASTER_KEY is set"

# Install dependencies
echo "=== Installing dependencies ==="
bundle install

# Precompile assets
echo "=== Precompiling assets ==="
bundle exec rails assets:precompile

# Clean assets to reduce slug size
echo "=== Cleaning assets ==="
bundle exec rails assets:clean

# Run database migrations
echo "=== Running database migrations ==="
bundle exec rails db:migrate

# Seed the database with initial data (only run once on first deploy)
# Comment this out after first deployment to avoid re-seeding
if [[ "$RENDER_FIRST_DEPLOY" == "true" ]]; then
  echo "First deployment detected, seeding database..."
  bundle exec rails db:seed
  
  # Create admin user
  bundle exec rails runner create_admin_user.rb || true
  
  # Create test data
  bundle exec rails db:populate_test_data || true
  
  # Seed expression vectors
  if [ -f db/seeds/expression_vectors.rb ]; then
    bundle exec rails runner db/seeds/expression_vectors.rb || true
  fi
fi