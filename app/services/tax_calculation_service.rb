class TaxCalculationService
  attr_reader :state

  STATE_TAX_RATES = {
    "CA" => 0.0725,   # California
    "NY" => 0.08,     # New York
    "TX" => 0.0625,   # Texas
    "FL" => 0.06,     # Florida
    "WA" => 0.065,    # Washington
    "OR" => 0.0,      # Oregon (no sales tax)
    "NH" => 0.0,      # New Hampshire (no sales tax)
    "DE" => 0.0,      # Delaware (no sales tax)
    "MT" => 0.0,      # Montana (no sales tax)
    "AK" => 0.0       # Alaska (no state sales tax)
  }.freeze

  DEFAULT_TAX_RATE = 0.065  # 6.5% for other states

  def initialize(state)
    @state = state
  end

  def call
    # Simple tax calculation - in reality you'd use a tax service like Avalara or TaxJar
    STATE_TAX_RATES[state] || DEFAULT_TAX_RATE
  end
end
