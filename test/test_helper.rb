ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

# Fix namespace collision between Ruby's Matrix::Vector and our Vector model
# Force reload our Vector model to ensure it takes precedence
if defined?(Matrix) && !::Vector.respond_to?(:create)
  Object.send(:remove_const, :Vector) if defined?(::Vector)
  require Rails.root.join("app/models/vector")
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all  # Disabled due to foreign key violations - tests use factories or minimal setup

    # Add more helper methods to be used by all tests here...
  end
end
