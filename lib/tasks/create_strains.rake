namespace :db do
  desc "Create additional test Pichia strains"
  task create_test_strains: :environment do
    puts "Creating additional test Pichia strains..."
    
    strain_type = StrainType.first || StrainType.create!(name: "Wild-type", description: "Wild-type strain")
    mutant_type = StrainType.create_with(description: "Protease deficient mutant").find_or_create_by(name: "Protease deficient")
    status = ProductStatus.find_or_create_by(name: "Available") { |s| s.is_available = true }
    
    test_strains = [
      {
        name: "X-33",
        description: "Wild-type Pichia pastoris strain, excellent for protein expression studies",
        strain_type: strain_type,
        genotype: "Wild-type",
        phenotype: "Mut+",
        advantages: "High transformation efficiency\nFast growth rate\nWell characterized",
        applications: "Protein expression\nEnzyme production\nResearch applications",
        sale_price: 125.00,
        availability: "In Stock",
        shipping_requirements: "Dry ice required",
        storage_conditions: "-80°C",
        viability_period: "2 years",
        culture_media: "YPD, BMGY, BMMY",
        growth_conditions: "30°C, shaking at 250 rpm",
        citations: "Invitrogen Manual 2010\nMethods in Enzymology Vol 194"
      },
      {
        name: "KM71H",
        description: "Protease-deficient strain ideal for sensitive protein production",
        strain_type: mutant_type,
        genotype: "arg4 his4 pep4::HIS4 prb1::hisG",
        phenotype: "Mut+, Protease-",
        advantages: "Reduced proteolysis\nImproved protein stability\nHigher yields",
        applications: "Therapeutic proteins\nSensitive enzymes\nPharmaceutical applications",
        sale_price: 165.00,
        availability: "In Stock", 
        shipping_requirements: "Dry ice required",
        storage_conditions: "-80°C",
        viability_period: "2 years",
        culture_media: "YPD, BMGY, BMMY",
        growth_conditions: "30°C, shaking at 250 rpm"
      },
      {
        name: "SMD1168H",
        description: "Protease-deficient strain with enhanced secretion capabilities",
        strain_type: mutant_type,
        genotype: "his4 pep4::HIS4 prb1::hisG ura3",
        phenotype: "Mut+, Protease-, Ura-",
        advantages: "Enhanced secretion\nReduced background proteases\nUracil auxotroph for selection",
        applications: "Secreted proteins\nIndustrial enzymes\nBioprocessing",
        sale_price: 185.00,
        availability: "In Stock",
        shipping_requirements: "Dry ice required", 
        storage_conditions: "-80°C",
        viability_period: "2 years",
        culture_media: "YPD, BMGY, BMMY, Minimal media",
        growth_conditions: "30°C, shaking at 250 rpm"
      },
      {
        name: "GS115",
        description: "Histidine auxotrophic strain commonly used for transformation studies",
        strain_type: strain_type,
        genotype: "his4",
        phenotype: "Mut+, His-",
        advantages: "Histidine selection marker\nHigh transformation efficiency\nWell documented",
        applications: "Transformation studies\nProtein expression\nGenetic engineering",
        sale_price: 135.00,
        availability: "Limited Stock",
        shipping_requirements: "Dry ice required",
        storage_conditions: "-80°C", 
        viability_period: "2 years",
        culture_media: "YPD, BMGY, BMMY, His- media",
        growth_conditions: "30°C, shaking at 250 rpm"
      }
    ]
    
    test_strains.each do |strain_data|
      strain = PichiaStrain.find_or_create_by(name: strain_data[:name]) do |s|
        strain_data.each do |key, value|
          next if key == :name
          s.send("#{key}=", value)
        end
        s.product_status = status
      end
      
      puts "  Created/Updated: #{strain.name} - $#{strain.sale_price}"
    end
    
    puts "\nStrain creation completed!"
    puts "Total Pichia strains: #{PichiaStrain.count}"
  end
end