# BioGrammatics E-commerce Platform

A comprehensive Rails 8.0 e-commerce application for molecular biology products, featuring vector and Pichia strain catalogs with integrated Twist Bioscience subscriptions.

## Features

- **Product Catalog**: Comprehensive listings of expression vectors and Pichia pastoris strains
- **Shopping Cart**: Full cart functionality with quantity management
- **Twist Subscriptions**: Annual subscription system with prorated pricing
- **Admin Interface**: Complete CRUD operations for product management
- **User Authentication**: Rails 8 built-in authentication system
- **Responsive Design**: Bootstrap 5.1.3 responsive UI

## Technology Stack

- **Rails**: 8.0.2.1
- **Ruby**: 3.4.5
- **Database**: SQLite (development), PostgreSQL recommended for production
- **Frontend**: Bootstrap 5.1.3, Turbo Rails
- **Authentication**: Rails 8 built-in authentication
- **Testing**: Rails built-in test suite

## Prerequisites

Before setting up this application, ensure you have the following installed:

### 1. RVM (Ruby Version Manager)

Install RVM if you don't have it:

```bash
# Install GPG keys
gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# Install RVM
curl -sSL https://get.rvm.io | bash -s stable

# Reload your shell
source ~/.rvm/scripts/rvm
```

### 2. Ruby 3.4.5

```bash
# Install Ruby 3.4.5 via RVM
rvm install 3.4.5
rvm use 3.4.5 --default

# Verify Ruby version
ruby -v  # Should show ruby 3.4.5
```

### 3. System Dependencies

**macOS:**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required packages
brew install sqlite3 libpq imagemagick
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y build-essential sqlite3 libsqlite3-dev nodejs npm imagemagick libpq-dev
```

**CentOS/RHEL:**
```bash
sudo yum groupinstall -y 'Development Tools'
sudo yum install -y sqlite-devel nodejs npm ImageMagick-devel postgresql-devel
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/biogrammatics/biog-website.git
cd biog-website
```

### 2. Ruby and Gemset Setup

```bash
# Ensure you're using the correct Ruby version
rvm use 3.4.5

# Create and use a gemset for this project (optional but recommended)
rvm gemset create biog-website
rvm use 3.4.5@biog-website

# Install Bundler
gem install bundler
```

### 3. Install Dependencies

```bash
# Install Ruby gems
bundle install

# If you encounter any gem installation issues, try:
bundle config build.nokogiri --use-system-libraries
bundle install
```

### 4. Database Setup

```bash
# Create and migrate the database
rails db:create
rails db:migrate

# Seed the database with initial data
rails db:seed

# Create additional test data (optional)
rails db:create_test_vectors
rails db:create_test_strains  
rails db:populate_test_data
```

### 5. Environment Configuration

Create a `.env` file in the project root (optional, for production):

```bash
# .env
DATABASE_URL=your_production_database_url
SECRET_KEY_BASE=your_secret_key
RAILS_ENV=development
```

## Running the Application

### Development Server

```bash
# Start the Rails server
rails server

# Or using the bin/dev script (includes other services)
bin/dev
```

The application will be available at `http://localhost:3000`

### Background Jobs (if using)

```bash
# In a separate terminal, start background job processing
bin/jobs
```

## Test User Accounts

The application includes pre-configured test accounts:

### Admin Account
- **Email**: `admin@biogrammatics.com`
- **Password**: `password123`
- **Access**: Full admin privileges

### Customer Accounts
1. **Active Subscription**
   - **Email**: `customer1@example.com`
   - **Password**: `password123`
   - **Features**: Active Twist subscription with multiple vectors

2. **New Customer**
   - **Email**: `customer2@example.com`
   - **Password**: `password123`
   - **Features**: Pending subscription, items in cart

3. **Expired Subscription**
   - **Email**: `customer3@example.com`
   - **Password**: `password123`
   - **Features**: Expired subscription, can be renewed

## Application Structure

### Key Models
- **User**: Customer and admin accounts with authentication
- **Vector**: Expression vectors with sale and subscription pricing
- **PichiaStrain**: Pichia pastoris strains for molecular biology
- **Cart/CartItem**: Shopping cart functionality
- **Subscription/SubscriptionVector**: Twist subscription management

### Key Controllers
- **ApplicationController**: Base controller with authentication
- **VectorsController**: Vector catalog and details
- **PichiaStrainsController**: Strain catalog and details
- **CartController**: Shopping cart management
- **SubscriptionsController**: Twist subscription system
- **AccountController**: Customer account dashboard
- **Admin::***: Admin interface for product management

## Development

### Running Tests

```bash
# Run the full test suite
rails test

# Run specific test files
rails test test/models/user_test.rb
rails test test/controllers/cart_controller_test.rb
```

### Console Access

```bash
# Access Rails console for debugging/development
rails console

# Examples:
# User.count
# Vector.available_for_subscription
# Subscription.active
```

### Database Management

```bash
# Reset database (WARNING: destroys all data)
rails db:drop db:create db:migrate db:seed

# Create a new migration
rails generate migration AddFieldToModel field:type

# Rollback last migration
rails db:rollback
```

## Production Deployment

### Environment Variables
Set the following environment variables in production:

```bash
RAILS_ENV=production
SECRET_KEY_BASE=your_long_secret_key
DATABASE_URL=your_production_database_url
RAILS_SERVE_STATIC_FILES=true  # if not using a CDN
```

### Database
Switch from SQLite to PostgreSQL in production:

1. Add `pg` gem to Gemfile
2. Update `config/database.yml` for production
3. Set `DATABASE_URL` environment variable

### Assets
```bash
# Precompile assets for production
rails assets:precompile
```

## Troubleshooting

### Common Issues

**Gem Installation Errors:**
```bash
# If you encounter permission errors
rvm use 3.4.5@biog-website
gem install bundler
bundle install
```

**SQLite Issues on macOS:**
```bash
# If SQLite gems fail to install
brew install sqlite3
bundle config build.sqlite3 --with-sqlite3-include=$(brew --prefix sqlite3)/include \
--with-sqlite3-lib=$(brew --prefix sqlite3)/lib
bundle install
```

**ImageMagick Issues:**
```bash
# macOS
brew install imagemagick
bundle config build.image_processing --with-vips

# Ubuntu
sudo apt-get install imagemagick libvips-dev
```

**Node.js/JavaScript Issues:**
```bash
# Install Node.js if missing
# macOS
brew install node

# Ubuntu
sudo apt-get install nodejs npm
```

### Database Reset
If you encounter database issues:

```bash
rails db:drop db:create db:migrate db:seed
rails db:populate_test_data  # Recreate test data
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## License

This project is proprietary software owned by BioGrammatics.

## Support

For technical support or questions about setup, please contact the development team or create an issue in the repository.

---

**Quick Start Summary:**
```bash
# 1. Install RVM and Ruby 3.4.5
rvm install 3.4.5 && rvm use 3.4.5 --default

# 2. Clone and setup
git clone https://github.com/biogrammatics/biog-website.git
cd biog-website
bundle install

# 3. Setup database
rails db:create db:migrate db:seed db:populate_test_data

# 4. Start server
rails server
```

Visit `http://localhost:3000` and sign in with `admin@biogrammatics.com` / `password123`
