namespace :db do
  desc "Create additional test vectors"
  task create_test_vectors: :environment do
    puts "Creating additional test vectors..."
    
    # Get or create required lookup data
    promoter1 = Promoter.first || Promoter.create!(name: "AOX1", description: "Alcohol oxidase promoter")
    promoter2 = Promoter.create_with(description: "GAP promoter").find_or_create_by(name: "GAP")
    promoter3 = Promoter.create_with(description: "Constitutive promoter").find_or_create_by(name: "TEF1")
    
    marker1 = SelectionMarker.first || SelectionMarker.create!(name: "Zeocin", resistance: "Zeocin")
    marker2 = SelectionMarker.create_with(resistance: "Kanamycin").find_or_create_by(name: "Kan")
    marker3 = SelectionMarker.create_with(resistance: "Hygromycin").find_or_create_by(name: "Hyg")
    
    vector_type = VectorType.first || VectorType.create!(name: "Expression", description: "Expression vector")
    host = HostOrganism.first || HostOrganism.create!(common_name: "Pichia pastoris")
    status = ProductStatus.find_or_create_by(name: "Available") { |s| s.is_available = true }
    
    # Define additional test vectors
    test_vectors = [
      {
        name: "pPICZ-B",
        description: "High-copy Pichia expression vector with Zeocin resistance and C-terminal myc-His tag",
        category: "Expression",
        sale_price: 245.00,
        subscription_price: 189.99,
        available_for_subscription: true,
        promoter: promoter1,
        selection_marker: marker1,
        vector_type: vector_type,
        vector_size: 3600,
        host_organism: host,
        has_files: true,
        features: "C-terminal myc-His tag\nHigh copy number\nZeocin resistance"
      },
      {
        name: "pPIC9K",
        description: "Multi-copy integration vector for high-level protein expression in Pichia",
        category: "Integration", 
        sale_price: 195.00,
        subscription_price: 159.99,
        available_for_subscription: true,
        promoter: promoter1,
        selection_marker: marker2,
        vector_type: vector_type,
        vector_size: 9000,
        host_organism: host,
        has_files: true,
        features: "Multi-copy integration\nKanamycin resistance\nAOX1 promoter"
      },
      {
        name: "pGAP-ZαA",
        description: "Constitutive expression vector with alpha-factor secretion signal",
        category: "Secretion",
        sale_price: 275.00,
        subscription_price: 229.99,
        available_for_subscription: true,
        promoter: promoter2,
        selection_marker: marker1,
        vector_type: vector_type,
        vector_size: 4200,
        host_organism: host,
        has_files: true,
        features: "Alpha-factor secretion signal\nConstitutive GAP promoter\nZeocin resistance"
      },
      {
        name: "pTEF1-His",
        description: "TEF1 promoter-driven expression with N-terminal His tag",
        category: "Expression",
        sale_price: 220.00,
        subscription_price: 179.99,
        available_for_subscription: true,
        promoter: promoter3,
        selection_marker: marker3,
        vector_type: vector_type,
        vector_size: 3800,
        host_organism: host,
        has_files: false,
        features: "N-terminal His tag\nTEF1 constitutive promoter\nHygromycin resistance"
      },
      {
        name: "pAOX1-GST",
        description: "Methanol-inducible vector with GST fusion tag for protein purification",
        category: "Purification",
        sale_price: 290.00,
        subscription_price: 249.99,
        available_for_subscription: true,
        promoter: promoter1,
        selection_marker: marker1,
        vector_type: vector_type,
        vector_size: 4500,
        host_organism: host,
        has_files: true,
        features: "GST fusion tag\nMethanol-inducible AOX1\nZeocin resistance\nGlutathione purification"
      },
      {
        name: "pPIC-SUMO",
        description: "SUMO fusion system for enhanced protein expression and purification",
        category: "Fusion",
        sale_price: 320.00,
        subscription_price: 279.99,
        available_for_subscription: false, # Not available for subscription
        promoter: promoter1,
        selection_marker: marker1,
        vector_type: vector_type,
        vector_size: 4100,
        host_organism: host,
        has_files: true,
        features: "SUMO fusion system\nEnhanced solubility\nProtease cleavage site\nZeocin resistance"
      }
    ]
    
    test_vectors.each do |vector_data|
      vector = Vector.find_or_create_by(name: vector_data[:name]) do |v|
        vector_data.each do |key, value|
          next if key == :name
          v.send("#{key}=", value)
        end
        v.product_status = status
      end
      
      puts "  Created/Updated: #{vector.name} - $#{vector.subscription_price}/year (subscription: #{vector.available_for_subscription?})"
    end
    
    puts "\nVector creation completed!"
    puts "Total vectors: #{Vector.count}"
    puts "Subscription-eligible vectors: #{Vector.where(available_for_subscription: true).count}"
  end
end