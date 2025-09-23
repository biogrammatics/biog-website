namespace :vectors do
  desc "Inspect vectors in the database and show category distribution"
  task inspect: :environment do
    puts "\n=== VECTOR INSPECTION REPORT ==="
    puts "Total vectors: #{Vector.count}"
    puts "\n--- Category Distribution ---"

    # Count by category including nil/blank
    categories = Vector.group(:category).count
    categories.each do |category, count|
      display_category = category.presence || "(No category)"
      puts "#{display_category}: #{count} vectors"
    end

    puts "\n--- Availability Distribution ---"
    puts "Available for sale: #{Vector.where(available_for_sale: true).count}"
    puts "Available for subscription: #{Vector.where(available_for_subscription: true).count}"
    puts "Both sale and subscription: #{Vector.where(available_for_sale: true, available_for_subscription: true).count}"

    puts "\n--- Vectors without categories ---"
    no_category = Vector.where(category: [nil, ""])
    if no_category.any?
      puts "Found #{no_category.count} vectors without categories:"
      no_category.limit(10).each do |vector|
        puts "  - #{vector.name} (ID: #{vector.id})"
      end
      puts "  ..." if no_category.count > 10
    else
      puts "All vectors have categories!"
    end

    puts "\n--- Sample of vectors by category ---"
    ["Heterologous Protein Expression", "Genome Engineering"].each do |cat|
      puts "\n#{cat}:"
      Vector.where(category: cat).limit(3).each do |vector|
        puts "  - #{vector.name} (Sale: $#{vector.sale_price || 'N/A'}, Sub: $#{vector.subscription_price || 'N/A'})"
      end
    end

    puts "\n=== END OF REPORT ===\n"
  end

  desc "Fix vectors without categories"
  task fix_categories: :environment do
    puts "\n=== FIXING VECTOR CATEGORIES ==="

    no_category = Vector.where(category: [nil, ""])
    if no_category.any?
      puts "Found #{no_category.count} vectors without categories"
      puts "Setting them to 'Heterologous Protein Expression'..."

      updated = no_category.update_all(category: "Heterologous Protein Expression")
      puts "Updated #{updated} vectors"
    else
      puts "All vectors already have categories!"
    end

    puts "=== DONE ===\n"
  end
end