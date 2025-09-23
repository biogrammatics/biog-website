ENV["RAILS_ENV"] ||= "test"

# Fix namespace collision between Ruby's Matrix::Vector and our Vector model
# Remove the Matrix::Vector constant if it exists before loading Rails
if defined?(Matrix)
  Matrix.send(:remove_const, :Vector) if Matrix.const_defined?(:Vector)
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all  # Disabled due to foreign key violations - tests use factories or minimal setup

    # Add more helper methods to be used by all tests here...
  end
end
