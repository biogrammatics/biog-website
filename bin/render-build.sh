#!/usr/bin/env bash
# exit on error
set -o errexit

echo "=== Starting Render build ==="

# Check if SECRET_KEY_BASE is set (only required at runtime, not during asset precompilation)
if [ -z "$SECRET_KEY_BASE" ] && [ "$RAILS_ENV" = "production" ]; then
  echo "WARNING: SECRET_KEY_BASE environment variable is not set!"
  echo "This is required for production runtime. Please set this in your Render service environment variables."
fi

if [ -n "$SECRET_KEY_BASE" ]; then
  echo "✓ SECRET_KEY_BASE is set"
fi

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
bundle exec rails db:create RAILS_ENV=production || true
bundle exec rails db:migrate RAILS_ENV=production

# Seed service packages if they don't exist
echo "=== Checking service packages ==="
RAILS_ENV=production bundle exec rails runner "
  if ServicePackage.count == 0
    puts 'No service packages found, seeding...'
    load 'db/seeds/service_packages.rb'
  else
    puts \"Service packages already exist (count: #{ServicePackage.count})\"
  end
" || true

# Seed the database with initial data (only run once on first deploy)
# Comment this out after first deployment to avoid re-seeding
if [[ "$RENDER_FIRST_DEPLOY" == "true" ]]; then
  echo "First deployment detected, seeding database..."
  RAILS_ENV=production bundle exec rails db:seed || true
  
  # Create admin user
  RAILS_ENV=production bundle exec rails runner create_admin_user.rb || true
  
  # Create test data
  RAILS_ENV=production bundle exec rails db:populate_test_data || true
  
  # Seed expression vectors
  if [ -f db/seeds/expression_vectors.rb ]; then
    RAILS_ENV=production bundle exec rails runner db/seeds/expression_vectors.rb || true
  fi
fi