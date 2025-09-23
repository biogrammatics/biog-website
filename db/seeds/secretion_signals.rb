# Secretion signals for Pichia pastoris protein expression
secretion_signals = [
  {
    name: "Alpha-factor",
    sequence: "MRFPSIFTAVLFAASSALAAPVNTTTEDETAQIPAEAVIGYSDLEGDFDVAVLPFSNSTNNGLLFINTTIASIAAKEEGVSLDKRT",
    organism: "Saccharomyces cerevisiae",
    description: "Most commonly used secretion signal for yeast expression. Works well in Pichia pastoris."
  },
  {
    name: "Invertase",
    sequence: "MLLQAFLFLLAGFAAKISA",
    organism: "Saccharomyces cerevisiae",
    description: "Alternative secretion signal, shorter than alpha-factor but effective."
  },
  {
    name: "Killer toxin",
    sequence: "MKTLLFSFVFAAIFSVSALA",
    organism: "Pichia pastoris",
    description: "Native Pichia pastoris secretion signal for optimal compatibility."
  },
  {
    name: "Acid phosphatase",
    sequence: "MKKLSAIFALFASAPAQA",
    organism: "Pichia pastoris",
    description: "Another native Pichia secretion signal, good for acidic proteins."
  },
  {
    name: "Human serum albumin",
    sequence: "MKWVTFISLLLLFSSAYSRGVFRRD",
    organism: "Homo sapiens",
    description: "Human-derived signal, useful for expressing human therapeutic proteins."
  }
]

secretion_signals.each do |signal_data|
  SecretionSignal.find_or_create_by(name: signal_data[:name]) do |signal|
    signal.sequence = signal_data[:sequence]
    signal.organism = signal_data[:organism]
    signal.description = signal_data[:description]
    signal.active = true
  end
end

puts "Created #{SecretionSignal.count} secretion signals"