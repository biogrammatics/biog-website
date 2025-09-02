# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding BioGrammatics database..."

# Create Product Statuses
ProductStatus.find_or_create_by!(name: "Active") { |ps| ps.description = "Available for purchase"; ps.is_available = true }
ProductStatus.find_or_create_by!(name: "Discontinued") { |ps| ps.description = "No longer available"; ps.is_available = false }
ProductStatus.find_or_create_by!(name: "Development") { |ps| ps.description = "Under development"; ps.is_available = false }

# Create Promoters
Promoter.find_or_create_by!(name: "AOX1") { |p| p.full_name = "Alcohol oxidase 1"; p.inducible = true; p.strength = "Strong" }
Promoter.find_or_create_by!(name: "GAP") { |p| p.full_name = "Glyceraldehyde-3-phosphate dehydrogenase"; p.inducible = false; p.strength = "Strong" }
Promoter.find_or_create_by!(name: "PGK1") { |p| p.full_name = "Phosphoglycerate kinase"; p.inducible = false; p.strength = "Medium" }

# Create Selection Markers
SelectionMarker.find_or_create_by!(name: "Zeocin") { |sm| sm.resistance = "Zeocin"; sm.concentration = "100 μg/mL" }
SelectionMarker.find_or_create_by!(name: "G418") { |sm| sm.resistance = "Geneticin"; sm.concentration = "200 μg/mL" }
SelectionMarker.find_or_create_by!(name: "Hygromycin") { |sm| sm.resistance = "Hygromycin B"; sm.concentration = "300 μg/mL" }

# Create Vector Types
VectorType.find_or_create_by!(name: "Expression") { |vt| vt.description = "For protein expression"; vt.applications = "Recombinant protein production" }
VectorType.find_or_create_by!(name: "Integration") { |vt| vt.description = "For genomic integration"; vt.applications = "Stable cell line creation" }
VectorType.find_or_create_by!(name: "Episomal") { |vt| vt.description = "Autonomously replicating"; vt.applications = "Transient expression" }

# Create Host Organisms
HostOrganism.find_or_create_by!(common_name: "Pichia pastoris") { |ho| ho.scientific_name = "Komagataella phaffii"; ho.description = "Methylotrophic yeast" }
HostOrganism.find_or_create_by!(common_name: "E. coli") { |ho| ho.scientific_name = "Escherichia coli"; ho.description = "Bacterial expression system" }

# Create Strain Types
StrainType.find_or_create_by!(name: "Wild Type") { |st| st.description = "Standard laboratory strain" }
StrainType.find_or_create_by!(name: "Protease Deficient") { |st| st.description = "Reduced protease activity" }
StrainType.find_or_create_by!(name: "Glycosylation Modified") { |st| st.description = "Altered glycosylation pattern" }

# Create some sample vectors
active_status = ProductStatus.find_by(name: "Active")
aox1_promoter = Promoter.find_by(name: "AOX1")
zeocin_marker = SelectionMarker.find_by(name: "Zeocin")
expression_type = VectorType.find_by(name: "Expression")
pichia_host = HostOrganism.find_by(common_name: "Pichia pastoris")

Vector.find_or_create_by!(name: "pPICZ-A") do |v|
  v.description = "Inducible expression vector for Pichia pastoris"
  v.category = "Expression"
  v.sale_price = 125.00
  v.subscription_price = 75.00
  v.promoter = aox1_promoter
  v.selection_marker = zeocin_marker
  v.vector_type = expression_type
  v.host_organism = pichia_host
  v.vector_size = 3593
  v.features = "AOX1 promoter, Zeocin resistance, multiple cloning site"
  v.product_status = active_status
end

Vector.find_or_create_by!(name: "pGAP-Z-A") do |v|
  v.description = "Constitutive expression vector for Pichia pastoris"
  v.category = "Expression"
  v.sale_price = 135.00
  v.subscription_price = 85.00
  v.promoter = Promoter.find_by(name: "GAP")
  v.selection_marker = zeocin_marker
  v.vector_type = expression_type
  v.host_organism = pichia_host
  v.vector_size = 4200
  v.features = "GAP promoter, Zeocin resistance, constitutive expression"
  v.product_status = active_status
end

# Create some Pichia strains
wild_type = StrainType.find_by(name: "Wild Type")

PichiaStrain.find_or_create_by!(name: "GS115") do |ps|
  ps.description = "Standard Pichia pastoris strain for protein expression"
  ps.strain_type = wild_type
  ps.genotype = "his4"
  ps.phenotype = "His-, Mut+"
  ps.advantages = "Fast methanol utilization, high expression levels"
  ps.applications = "Recombinant protein production"
  ps.sale_price = 85.00
  ps.availability = "In Stock"
  ps.shipping_requirements = "Dry ice shipping required"
  ps.storage_conditions = "-80°C long-term storage"
  ps.viability_period = "2 years when stored properly"
  ps.culture_media = "YPD, BMGY, BMMY"
  ps.growth_conditions = "30°C, 250 rpm shaking"
  ps.product_status = active_status
end

puts "Database seeded successfully!"
puts "Created:"
puts "- #{ProductStatus.count} product statuses"
puts "- #{Promoter.count} promoters" 
puts "- #{SelectionMarker.count} selection markers"
puts "- #{VectorType.count} vector types"
puts "- #{HostOrganism.count} host organisms"
puts "- #{StrainType.count} strain types"
puts "- #{Vector.count} vectors"
puts "- #{PichiaStrain.count} Pichia strains"
