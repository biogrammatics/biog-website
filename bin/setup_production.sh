#!/usr/bin/env bash
# Script to set up initial data in production
# Run this in the Render shell to create admin user and seed data

echo "=== Setting up production data ==="

# Set Rails environment
export RAILS_ENV=production

echo "1. Creating admin user..."
bundle exec rails runner create_admin_user.rb

echo ""
echo "2. Seeding database with initial data..."
bundle exec rails db:seed

echo ""
echo "3. Creating test customer accounts..."
bundle exec rails db:populate_test_data

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Admin account created:"
echo "  Email: admin@biogrammatics.com"
echo "  Password: admin123456"
echo ""
echo "Test customer accounts created:"
echo "  customer1@example.com / password123 (with subscription)"
echo "  customer2@example.com / password123 (no subscription)"
echo "  customer3@example.com / password123 (expired subscription)"
echo ""
echo "You can now log in as admin to manage products and data."