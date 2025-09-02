namespace :db do
  desc "Create test data for subscription system"
  task populate_test_data: :environment do
    puts "Creating test data for subscription system..."
    
    # Update existing vectors with subscription pricing
    puts "Updating vectors with subscription pricing..."
    vectors = Vector.limit(8)
    
    subscription_prices = [199.99, 299.99, 149.99, 399.99, 249.99, 179.99, 329.99, 189.99]
    
    vectors.each_with_index do |vector, index|
      vector.update!(
        available_for_subscription: [true, true, true, false].sample, # 75% available for subscription
        subscription_price: subscription_prices[index] || rand(100..400)
      )
      puts "  Updated #{vector.name}: $#{vector.subscription_price}/year (subscription: #{vector.available_for_subscription?})"
    end
    
    # Create test users with subscriptions
    puts "\nCreating test users..."
    
    # Customer with active subscription
    customer1 = User.find_or_create_by(email_address: "customer1@example.com") do |u|
      u.password = "password123"
      u.first_name = "Alice"
      u.last_name = "Johnson"
      u.twist_username = "alice_twist"
    end
    puts "  Created customer: #{customer1.full_name} (#{customer1.email_address})"
    
    # Customer without subscription
    customer2 = User.find_or_create_by(email_address: "customer2@example.com") do |u|
      u.password = "password123"
      u.first_name = "Bob"
      u.last_name = "Smith"
    end
    puts "  Created customer: #{customer2.full_name} (#{customer2.email_address})"
    
    # Customer with expired subscription
    customer3 = User.find_or_create_by(email_address: "customer3@example.com") do |u|
      u.password = "password123"
      u.first_name = "Carol"
      u.last_name = "Davis"
      u.twist_username = "carol_twist"
    end
    puts "  Created customer: #{customer3.full_name} (#{customer3.email_address})"
    
    # Create subscriptions
    puts "\nCreating test subscriptions..."
    
    # Active subscription for customer1
    subscription1 = Subscription.find_or_create_by(user: customer1) do |s|
      s.twist_username = "alice_twist"
      s.onboarding_fee = 300.00
      s.minimum_prorated_fee = 50.00
      s.status = 'active'
      s.started_at = 3.months.ago
      s.renewal_date = 9.months.from_now.to_date
    end
    
    # Add vectors to subscription1
    available_vectors = Vector.where(available_for_subscription: true).limit(3)
    available_vectors.each do |vector|
      unless subscription1.vectors.include?(vector)
        prorated_amount = subscription1.calculate_prorated_amount(vector)
        SubscriptionVector.find_or_create_by(
          subscription: subscription1,
          vector: vector
        ) do |sv|
          sv.added_at = subscription1.started_at + rand(1..60).days
          sv.prorated_amount = prorated_amount
        end
        puts "  Added #{vector.name} to #{customer1.full_name}'s subscription ($#{prorated_amount.round(2)})"
      end
    end
    
    # Pending subscription for customer2
    subscription2 = Subscription.find_or_create_by(user: customer2) do |s|
      s.twist_username = "bob_twist_bio"
      s.onboarding_fee = 300.00
      s.minimum_prorated_fee = 50.00
      s.status = 'pending'
    end
    puts "  Created pending subscription for #{customer2.full_name}"
    
    # Expired subscription for customer3
    subscription3 = Subscription.find_or_create_by(user: customer3) do |s|
      s.twist_username = "carol_twist"
      s.onboarding_fee = 300.00
      s.minimum_prorated_fee = 50.00
      s.status = 'expired'
      s.started_at = 15.months.ago
      s.renewal_date = 3.months.ago.to_date
    end
    
    # Add vectors to expired subscription
    expired_vectors = Vector.where(available_for_subscription: true).limit(2)
    expired_vectors.each do |vector|
      unless subscription3.vectors.include?(vector)
        SubscriptionVector.find_or_create_by(
          subscription: subscription3,
          vector: vector
        ) do |sv|
          sv.added_at = subscription3.started_at + rand(30..200).days
          sv.prorated_amount = vector.subscription_price # Full price when added
        end
        puts "  Added #{vector.name} to #{customer3.full_name}'s expired subscription"
      end
    end
    
    # Add items to shopping carts
    puts "\nAdding items to shopping carts..."
    
    # Add items to customer1's cart
    cart1 = customer1.current_cart
    purchasable_vectors = Vector.where(available_for_sale: true).limit(2)
    purchasable_vectors.each do |vector|
      unless cart1.cart_items.exists?(item: vector)
        cart1.add_item(vector, rand(1..3))
        puts "  Added #{vector.name} to #{customer1.full_name}'s cart"
      end
    end
    
    # Add items to customer2's cart
    cart2 = customer2.current_cart
    pichia_strains = PichiaStrain.limit(1)
    pichia_strains.each do |strain|
      unless cart2.cart_items.exists?(item: strain)
        cart2.add_item(strain, 1)
        puts "  Added #{strain.name} to #{customer2.full_name}'s cart"
      end
    end
    
    puts "\nTest data creation completed!"
    puts "\nSummary:"
    puts "  Users: #{User.count}"
    puts "  Vectors: #{Vector.count}"
    puts "  Vectors available for subscription: #{Vector.where(available_for_subscription: true).count}"
    puts "  Subscriptions: #{Subscription.count}"
    puts "  Active subscriptions: #{Subscription.where(status: 'active').count}"
    puts "  Subscription vectors: #{SubscriptionVector.count}"
    puts "\nTest accounts:"
    puts "  customer1@example.com / password123 (Active subscription with 3 vectors)"
    puts "  customer2@example.com / password123 (Pending subscription, items in cart)"
    puts "  customer3@example.com / password123 (Expired subscription)"
  end
end