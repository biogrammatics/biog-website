# Protein tags for purification and detection
protein_tags = [
  # N-terminal tags
  {
    name: "6xHis",
    sequence: "HHHHHH",
    tag_type: "n_terminal",
    description: "Hexahistidine tag for metal affinity purification (Ni-NTA, IMAC)"
  },
  {
    name: "10xHis",
    sequence: "HHHHHHHHHH",
    tag_type: "n_terminal",
    description: "Decahistidine tag for stronger metal affinity binding"
  },
  {
    name: "GST",
    sequence: "MSPILGYWKIKGLVQPTRLLLEYLEEKYEEHLYERDEGDKWRNKKFELGLEFPNLPYYIDGDVKLTQSMAIIRYIADKHNMLGGCPKERAEISMLEGAVLDIRYGVSRIAYSKDFETLKVDFLSKLPEMLKMFEDRLCHKTYLNGDHVTHPDFMLYDALDVVLYMDPMCLDAFPKLVCFKKRIEAIPQIDKYLKSSKYIAWPLQGWQATFGGGDHPPK",
    tag_type: "n_terminal",
    description: "Glutathione S-transferase tag for glutathione affinity purification"
  },
  {
    name: "MBP",
    sequence: "MKIEEGKLVIWINGDKGYNGLAEVGKKFEKDTGIKVTVEHPDKLEEKFPQVAATGDGPDIIFWAHDRFGGYAQSGLLAEITPDKAFQDKLYPFTWDAVRYNGKLIAYPIAVEALSLIYNKDLLPNPPKTWEEIPALDKELKAKGKSALMFNLQEPYFTWPLIAADGGYAFKYENGKYDIKDVGVDNAGAKAGLTFLVDLIKNKHMNADTDYSIAEAAFNKGETAMTINGPWAWSNIDTSKVNYGVTVLPTFKGQPSKPFVGVLSAGINAASPNKELAKEFLENYLLTDEGLEAVNKDKPLGAVALKSYEEELAKDPRIAATMENAQKGEIMPNIPQMSAFWYAVRTAVINAASGRQTVDEALKDAQT",
    tag_type: "n_terminal",
    description: "Maltose binding protein for maltose affinity purification and increased solubility"
  },
  {
    name: "SUMO",
    sequence: "MSDSEVNQEAKPEVKPEVKPETHINLKVSDGSSEIFFKIKKTTPLRRLMEAFAKRQGKEMDSLRFLYDGIRIQADQTPEDLDMEDNDIIEAHREQIGG",
    tag_type: "n_terminal",
    description: "Small ubiquitin-like modifier for improved protein folding and solubility"
  },
  {
    name: "FLAG",
    sequence: "DYKDDDDK",
    tag_type: "n_terminal",
    description: "FLAG octapeptide for anti-FLAG antibody purification and detection"
  },
  {
    name: "Strep-tag II",
    sequence: "WSHPQFEK",
    tag_type: "n_terminal",
    description: "Streptavidin-binding peptide for Strep-Tactin affinity purification"
  },

  # C-terminal tags
  {
    name: "6xHis",
    sequence: "HHHHHH",
    tag_type: "c_terminal",
    description: "Hexahistidine tag for metal affinity purification (Ni-NTA, IMAC)"
  },
  {
    name: "10xHis",
    sequence: "HHHHHHHHHH",
    tag_type: "c_terminal",
    description: "Decahistidine tag for stronger metal affinity binding"
  },
  {
    name: "FLAG",
    sequence: "DYKDDDDK",
    tag_type: "c_terminal",
    description: "FLAG octapeptide for anti-FLAG antibody purification and detection"
  },
  {
    name: "Strep-tag II",
    sequence: "WSHPQFEK",
    tag_type: "c_terminal",
    description: "Streptavidin-binding peptide for Strep-Tactin affinity purification"
  },
  {
    name: "V5",
    sequence: "GKPIPNPLLGLDST",
    tag_type: "c_terminal",
    description: "V5 epitope tag for anti-V5 antibody detection and purification"
  },
  {
    name: "Myc",
    sequence: "EQKLISEEDL",
    tag_type: "c_terminal",
    description: "c-Myc epitope tag for anti-Myc antibody detection"
  },
  {
    name: "HA",
    sequence: "YPYDVPDYA",
    tag_type: "c_terminal",
    description: "Hemagglutinin epitope tag for anti-HA antibody detection"
  }
]

protein_tags.each do |tag_data|
  ProteinTag.find_or_create_by(name: tag_data[:name], tag_type: tag_data[:tag_type]) do |tag|
    tag.sequence = tag_data[:sequence]
    tag.description = tag_data[:description]
    tag.active = true
  end
end

puts "Created #{ProteinTag.count} protein tags"