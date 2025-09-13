# Production Setup Instructions

## How to Create Admin Account and Seed Data in Render

Since the initial deployment seeding failed, you need to manually run the setup scripts in the Render shell.

### Method 1: Run the Setup Script (Easiest)

1. **Go to your Render Dashboard**
2. **Click on your web service** (biog-website)
3. **Click on the "Shell" tab** in the left sidebar
4. **Run this single command:**

```bash
./bin/setup_production.sh
```

This will:
- Create the admin user
- Seed the database with vectors, strains, and other data
- Create test customer accounts

### Method 2: Run Commands Individually

If the script doesn't work, you can run each command separately in the Render shell:

1. **Create Admin User:**
```bash
RAILS_ENV=production bundle exec rails runner create_admin_user.rb
```

2. **Seed Database:**
```bash
RAILS_ENV=production bundle exec rails db:seed
```

3. **Create Test Data (optional):**
```bash
RAILS_ENV=production bundle exec rails db:populate_test_data
```

### Method 3: Use Rails Console

You can also create an admin user directly in the Rails console:

1. **Open Rails Console in Render Shell:**
```bash
bundle exec rails console
```

2. **Create Admin User:**
```ruby
User.create!(
  email_address: "admin@biogrammatics.com",
  password: "admin123456",
  first_name: "Admin",
  last_name: "User",
  admin: true
)
```

3. **Exit console:**
```ruby
exit
```

4. **Then run seeds:**
```bash
RAILS_ENV=production bundle exec rails db:seed
```

## Account Credentials

After running the setup, you'll have these accounts:

### Admin Account:
- **Email:** `admin@biogrammatics.com`
- **Password:** `admin123456`
- **Access:** Full admin privileges

### Test Customer Accounts:
- `customer1@example.com` / `password123` (with active subscription)
- `customer2@example.com` / `password123` (no subscription)
- `customer3@example.com` / `password123` (expired subscription)

## Troubleshooting

If you get errors:

1. **Check if data already exists:**
```bash
bundle exec rails runner "puts 'Users: ' + User.count.to_s"
bundle exec rails runner "puts 'Vectors: ' + Vector.count.to_s"
```

2. **Reset and start fresh (CAUTION - deletes all data):**
```bash
RAILS_ENV=production bundle exec rails db:drop db:create db:migrate
./bin/setup_production.sh
```

3. **Check logs for specific errors:**
```bash
bundle exec rails runner "User.create!(email_address: 'test@test.com', password: 'test123', admin: true)"
```

## Next Steps

Once the admin account is created:

1. Log in to your app with the admin credentials
2. Navigate to `/admin` to access the admin panel
3. Add/edit vectors, strains, and other products as needed
4. Manage customer orders and subscriptions

## Important Security Note

**Change the admin password immediately after first login!** The default password is for initial setup only.

To change password:
1. Log in as admin
2. Go to Account settings
3. Update password to something secure