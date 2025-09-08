# Expression Vector Catalog for Protein Expression
ExpressionVector.create!([
  {
    name: "pPIC9K",
    description: "High-copy integration vector with AOX1 promoter for methanol-inducible expression",
    promoter: "AOX1",
    drug_selection: "Kanamycin",
    features: "High copy, Methanol inducible, Strong expression",
    price: 850.00,
    available: true,
    vector_type: "protein_expression",
    backbone: "pPIC9",
    cloning_sites: "EcoRI, NotI, BglII, XbaI",
    additional_notes: "Best for high-level protein expression. Multi-copy integration increases expression levels."
  },
  {
    name: "pPIC3.5K",
    description: "Single-copy integration vector with AOX1 promoter, easier screening",
    promoter: "AOX1",
    drug_selection: "Kanamycin",
    features: "Single copy, Methanol inducible, Easy screening",
    price: 750.00,
    available: true,
    vector_type: "protein_expression",
    backbone: "pPIC3.5",
    cloning_sites: "EcoRI, NotI, BglII, XbaI",
    additional_notes: "Single-copy integration makes screening easier. Good for initial expression testing."
  },
  {
    name: "pGAP-ZαA",
    description: "Constitutive expression vector with GAP promoter, no methanol required",
    promoter: "GAP",
    drug_selection: "Zeocin",
    features: "Constitutive, No methanol needed, Consistent expression",
    price: 900.00,
    available: true,
    vector_type: "protein_expression",
    backbone: "pGAP",
    cloning_sites: "EcoRI, BstXI, NotI, XbaI",
    additional_notes: "Constitutive expression eliminates need for methanol induction. Good for secreted proteins."
  },
  {
    name: "pGAP-HisA",
    description: "Constitutive expression with GAP promoter and His6 tag for easy purification",
    promoter: "GAP",
    drug_selection: "Zeocin",
    features: "Constitutive, His6 tag, Easy purification",
    price: 925.00,
    available: true,
    vector_type: "protein_expression",
    backbone: "pGAP",
    cloning_sites: "EcoRI, BstXI, NotI, XbaI",
    additional_notes: "Built-in His6 tag simplifies protein purification. Ideal for proteins requiring purification."
  },
  {
    name: "pPICZ-αA",
    description: "AOX1 promoter with α-factor signal for secreted protein expression",
    promoter: "AOX1",
    drug_selection: "Zeocin",
    features: "Methanol inducible, Secretion signal, Extracellular expression",
    price: 875.00,
    available: true,
    vector_type: "protein_expression",
    backbone: "pPICZ",
    cloning_sites: "EcoRI, BstXI, NotI, XbaI",
    additional_notes: "α-factor signal sequence directs proteins to culture medium. Best for secreted proteins."
  },
  {
    name: "pPICZ-B-MycHis",
    description: "AOX1 promoter with Myc epitope and His6 tags for detection and purification",
    promoter: "AOX1",
    drug_selection: "Zeocin",
    features: "Methanol inducible, Myc tag, His6 tag, Easy detection",
    price: 950.00,
    available: true,
    vector_type: "protein_expression",
    backbone: "pPICZ-B",
    cloning_sites: "EcoRI, BstXI, NotI, XbaI",
    additional_notes: "Dual tags enable both protein detection (Myc) and purification (His6). Excellent for research applications."
  }
])

puts "Created #{ExpressionVector.count} expression vectors"
