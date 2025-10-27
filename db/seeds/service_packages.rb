# Service Packages for "Your Path to Protein" Funnel
# Based on the 6-step protein expression workflow

puts "Creating Service Packages..."

ServicePackage.destroy_all

service_packages = [
  {
    name: "Codon Optimization Service",
    slug: "codon-optimization",
    step_number: 1,
    position: 1,
    description: "Professional codon optimization for maximum Pichia pastoris expression",
    diy_option: "Use your own codon-optimized gene sequence",
    service_option: "Let us optimize for Pichia — maximize expression efficiency",
    diy_challenges: "• Generic codon tables may not match Pichia biology\n• Risk of rare codons reducing expression\n• No guarantee of optimal protein yield\n• Time-consuming analysis and design",
    service_benefits: "• Pichia-specific codon optimization\n• Proprietary algorithms for maximum expression\n• Guaranteed sequence optimization\n• Removes rare codons and problematic motifs",
    whats_included: "• Complete ORF codon optimization\n• Removal of restriction sites as needed\n• GC content optimization\n• Sequence analysis report\n• 3-5 business day turnaround",
    estimated_price: 495.00,
    estimated_turnaround: "3-5 business days",
    active: true
  },
  {
    name: "Cloning & Verification Service",
    slug: "cloning-verification",
    step_number: 2,
    position: 2,
    description: "Professional gene cloning into your chosen vector with sequence verification",
    diy_option: "Buy your own vector and clone in-house",
    service_option: "We'll clone & verify it for you — sequence guaranteed",
    diy_challenges: "• Cloning failures and troubleshooting delays\n• Sequence verification costs and wait times\n• Risk of mutations during cloning\n• Requires molecular biology expertise",
    service_benefits: "• Guaranteed successful cloning\n• Full Sanger sequencing verification\n• Experienced molecular biologists\n• Sequence-perfect plasmid delivery",
    whats_included: "• Gene synthesis or PCR amplification\n• Cloning into chosen expression vector\n• Sanger sequencing (full insert)\n• Plasmid DNA prep (5-10 µg)\n• 7-10 business day turnaround",
    estimated_price: 850.00,
    estimated_turnaround: "7-10 business days",
    active: true
  },
  {
    name: "Transformation & Integration Package",
    slug: "transformation-integration",
    step_number: 3,
    position: 3,
    description: "Transform Pichia strain and confirm chromosomal integration",
    diy_option: "Transform yourself using our strain",
    service_option: "We'll create your expression strain & confirm integration",
    diy_challenges: "• Transformation optimization required\n• Integration confirmation is time-intensive\n• Risk of failed transformations\n• Requires specialized equipment and expertise",
    service_benefits: "• Optimized transformation protocol\n• PCR-confirmed chromosomal integration\n• Multiple verified clones provided\n• Glycerol stocks ready for expression",
    whats_included: "• Pichia transformation (linearized plasmid)\n• Colony screening by PCR\n• Integration site confirmation\n• 5-10 verified clones\n• Glycerol stocks\n• 10-14 business day turnaround",
    estimated_price: 1250.00,
    estimated_turnaround: "10-14 business days",
    active: true
  },
  {
    name: "Colony Screening & Copy Number Service",
    slug: "screening-copy-number",
    step_number: 4,
    position: 4,
    description: "Screen colonies and determine copy number for optimal expression",
    diy_option: "Perform your own colony screening",
    service_option: "We'll screen and verify copy number — ensure stability",
    diy_challenges: "• Labor-intensive screening process\n• Copy number determination requires qPCR\n• High-copy clones may be unstable\n• Selection of sub-optimal clones wastes downstream effort",
    service_benefits: "• High-throughput colony screening\n• qPCR copy number determination\n• Stability testing of top clones\n• Deliver 3-5 best-performing clones",
    whats_included: "• Screen 50-100 colonies\n• qPCR copy number analysis\n• Small-scale expression test\n• Top 3-5 clones ranked by performance\n• Glycerol stocks of best clones\n• 2-3 week turnaround",
    estimated_price: 1650.00,
    estimated_turnaround: "2-3 weeks",
    active: true
  },
  {
    name: "Pilot Expression Study",
    slug: "pilot-expression",
    step_number: 5,
    position: 5,
    description: "Perform induction trials and optimize expression conditions",
    diy_option: "Induce in your lab using our growth medium",
    service_option: "We'll perform induction trials & optimize yield",
    diy_challenges: "• Induction optimization is trial-and-error\n• Requires fermentation equipment and expertise\n• Time-consuming parameter testing\n• Risk of poor expression or protein degradation",
    service_benefits: "• Optimized induction protocols\n• Test multiple methanol concentrations\n• Temperature and time course optimization\n• Deliver protocol for scale-up",
    whats_included: "• Small-scale shake flask inductions (3-5 conditions)\n• Time course analysis (24-96 hours)\n• SDS-PAGE and Western blot analysis\n• Protein expression report with recommended conditions\n• Protocol for scale-up\n• 2-3 week turnaround",
    estimated_price: 2400.00,
    estimated_turnaround: "2-3 weeks",
    active: true
  },
  {
    name: "Protein Analysis Service",
    slug: "protein-analysis",
    step_number: 6,
    position: 6,
    description: "Comprehensive protein analysis including Western blot and ELISA quantification",
    diy_option: "Analyze your supernatant in-house",
    service_option: "We'll analyze by Western blot or ELISA — quant data included",
    diy_challenges: "• Requires specific antibodies and reagents\n• Quantification needs standard curves\n• Requires analytical expertise and equipment\n• Time-consuming optimization",
    service_benefits: "• Western blot with size confirmation\n• ELISA quantification (µg/mL)\n• SDS-PAGE and Coomassie staining\n• Detailed analytical report",
    whats_included: "• SDS-PAGE analysis (reducing and non-reducing)\n• Western blot (anti-His or custom antibody)\n• ELISA quantification\n• Protein concentration determination\n• Analytical report with images\n• 1-2 week turnaround",
    estimated_price: 950.00,
    estimated_turnaround: "1-2 weeks",
    active: true
  }
]

service_packages.each do |package_data|
  ServicePackage.create!(package_data)
  puts "  Created: #{package_data[:name]}"
end

puts "\n✓ Successfully created #{ServicePackage.count} service packages"
