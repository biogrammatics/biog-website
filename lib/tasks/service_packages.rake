namespace :service_packages do
  desc "Seed service packages data"
  task seed: :environment do
    if ServicePackage.count > 0
      puts "Service packages already exist (count: #{ServicePackage.count})"
      puts "Run 'rails service_packages:reseed' to clear and reseed"
    else
      puts "Seeding service packages..."
      load Rails.root.join("db/seeds/service_packages.rb")
      puts "✓ Successfully seeded #{ServicePackage.count} service packages"
    end
  end

  desc "Clear and reseed service packages"
  task reseed: :environment do
    puts "Clearing existing service packages..."
    ServicePackage.destroy_all
    puts "Seeding service packages..."
    load Rails.root.join("db/seeds/service_packages.rb")
    puts "✓ Successfully seeded #{ServicePackage.count} service packages"
  end

  desc "List all service packages"
  task list: :environment do
    packages = ServicePackage.order(:step_number)
    if packages.any?
      puts "\nService Packages (#{packages.count} total):"
      packages.each do |pkg|
        puts "  #{pkg.step_number}. #{pkg.name} - $#{pkg.estimated_price}"
      end
    else
      puts "No service packages found in database."
    end
  end
end
