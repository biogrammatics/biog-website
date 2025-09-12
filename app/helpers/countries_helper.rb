module CountriesHelper
  def countries_for_select
    # Organized by continent with US and Canada at the top for convenience
    [
      [ "--- Most Common ---", [
        [ "United States", "United States" ],
        [ "Canada", "Canada" ]
      ] ],

      [ "--- North America ---", [
        [ "Mexico", "Mexico" ],
        [ "Bahamas", "Bahamas" ],
        [ "Costa Rica", "Costa Rica" ],
        [ "Cuba", "Cuba" ],
        [ "Dominican Republic", "Dominican Republic" ],
        [ "Guatemala", "Guatemala" ],
        [ "Haiti", "Haiti" ],
        [ "Honduras", "Honduras" ],
        [ "Jamaica", "Jamaica" ],
        [ "Nicaragua", "Nicaragua" ],
        [ "Panama", "Panama" ],
        [ "Puerto Rico", "Puerto Rico" ],
        [ "Trinidad and Tobago", "Trinidad and Tobago" ]
      ] ],

      [ "--- Europe ---", [
        [ "United Kingdom", "United Kingdom" ],
        [ "Germany", "Germany" ],
        [ "France", "France" ],
        [ "Italy", "Italy" ],
        [ "Spain", "Spain" ],
        [ "Netherlands", "Netherlands" ],
        [ "Belgium", "Belgium" ],
        [ "Switzerland", "Switzerland" ],
        [ "Austria", "Austria" ],
        [ "Sweden", "Sweden" ],
        [ "Norway", "Norway" ],
        [ "Denmark", "Denmark" ],
        [ "Finland", "Finland" ],
        [ "Ireland", "Ireland" ],
        [ "Poland", "Poland" ],
        [ "Portugal", "Portugal" ],
        [ "Czech Republic", "Czech Republic" ],
        [ "Greece", "Greece" ],
        [ "Hungary", "Hungary" ],
        [ "Romania", "Romania" ],
        [ "Bulgaria", "Bulgaria" ],
        [ "Croatia", "Croatia" ],
        [ "Serbia", "Serbia" ],
        [ "Slovakia", "Slovakia" ],
        [ "Slovenia", "Slovenia" ],
        [ "Estonia", "Estonia" ],
        [ "Latvia", "Latvia" ],
        [ "Lithuania", "Lithuania" ],
        [ "Luxembourg", "Luxembourg" ],
        [ "Malta", "Malta" ],
        [ "Iceland", "Iceland" ],
        [ "Ukraine", "Ukraine" ]
      ] ],

      [ "--- Asia ---", [
        [ "China", "China" ],
        [ "Japan", "Japan" ],
        [ "India", "India" ],
        [ "South Korea", "South Korea" ],
        [ "Singapore", "Singapore" ],
        [ "Taiwan", "Taiwan" ],
        [ "Hong Kong", "Hong Kong" ],
        [ "Thailand", "Thailand" ],
        [ "Malaysia", "Malaysia" ],
        [ "Indonesia", "Indonesia" ],
        [ "Philippines", "Philippines" ],
        [ "Vietnam", "Vietnam" ],
        [ "Pakistan", "Pakistan" ],
        [ "Bangladesh", "Bangladesh" ],
        [ "Sri Lanka", "Sri Lanka" ],
        [ "Nepal", "Nepal" ],
        [ "Myanmar", "Myanmar" ],
        [ "Cambodia", "Cambodia" ],
        [ "Israel", "Israel" ],
        [ "United Arab Emirates", "United Arab Emirates" ],
        [ "Saudi Arabia", "Saudi Arabia" ],
        [ "Turkey", "Turkey" ],
        [ "Iran", "Iran" ],
        [ "Iraq", "Iraq" ],
        [ "Jordan", "Jordan" ],
        [ "Lebanon", "Lebanon" ],
        [ "Kuwait", "Kuwait" ],
        [ "Qatar", "Qatar" ],
        [ "Bahrain", "Bahrain" ],
        [ "Oman", "Oman" ],
        [ "Kazakhstan", "Kazakhstan" ],
        [ "Uzbekistan", "Uzbekistan" ]
      ] ],

      [ "--- South America ---", [
        [ "Brazil", "Brazil" ],
        [ "Argentina", "Argentina" ],
        [ "Chile", "Chile" ],
        [ "Colombia", "Colombia" ],
        [ "Peru", "Peru" ],
        [ "Venezuela", "Venezuela" ],
        [ "Ecuador", "Ecuador" ],
        [ "Bolivia", "Bolivia" ],
        [ "Paraguay", "Paraguay" ],
        [ "Uruguay", "Uruguay" ],
        [ "Guyana", "Guyana" ],
        [ "Suriname", "Suriname" ],
        [ "French Guiana", "French Guiana" ]
      ] ],

      [ "--- Africa ---", [
        [ "South Africa", "South Africa" ],
        [ "Egypt", "Egypt" ],
        [ "Nigeria", "Nigeria" ],
        [ "Morocco", "Morocco" ],
        [ "Kenya", "Kenya" ],
        [ "Ethiopia", "Ethiopia" ],
        [ "Ghana", "Ghana" ],
        [ "Algeria", "Algeria" ],
        [ "Tunisia", "Tunisia" ],
        [ "Tanzania", "Tanzania" ],
        [ "Uganda", "Uganda" ],
        [ "Zimbabwe", "Zimbabwe" ],
        [ "Botswana", "Botswana" ],
        [ "Namibia", "Namibia" ],
        [ "Mozambique", "Mozambique" ],
        [ "Zambia", "Zambia" ],
        [ "Senegal", "Senegal" ],
        [ "Libya", "Libya" ],
        [ "Cameroon", "Cameroon" ],
        [ "Mauritius", "Mauritius" ],
        [ "Angola", "Angola" ]
      ] ],

      [ "--- Oceania ---", [
        [ "Australia", "Australia" ],
        [ "New Zealand", "New Zealand" ],
        [ "Fiji", "Fiji" ],
        [ "Papua New Guinea", "Papua New Guinea" ],
        [ "Solomon Islands", "Solomon Islands" ],
        [ "Vanuatu", "Vanuatu" ],
        [ "Samoa", "Samoa" ],
        [ "Tonga", "Tonga" ],
        [ "Micronesia", "Micronesia" ],
        [ "Palau", "Palau" ],
        [ "Marshall Islands", "Marshall Islands" ],
        [ "Kiribati", "Kiribati" ],
        [ "Nauru", "Nauru" ],
        [ "Tuvalu", "Tuvalu" ]
      ] ]
    ]
  end

  def us_states_for_select
    [
      [ "Alabama", "AL" ],
      [ "Alaska", "AK" ],
      [ "Arizona", "AZ" ],
      [ "Arkansas", "AR" ],
      [ "California", "CA" ],
      [ "Colorado", "CO" ],
      [ "Connecticut", "CT" ],
      [ "Delaware", "DE" ],
      [ "District of Columbia", "DC" ],
      [ "Florida", "FL" ],
      [ "Georgia", "GA" ],
      [ "Hawaii", "HI" ],
      [ "Idaho", "ID" ],
      [ "Illinois", "IL" ],
      [ "Indiana", "IN" ],
      [ "Iowa", "IA" ],
      [ "Kansas", "KS" ],
      [ "Kentucky", "KY" ],
      [ "Louisiana", "LA" ],
      [ "Maine", "ME" ],
      [ "Maryland", "MD" ],
      [ "Massachusetts", "MA" ],
      [ "Michigan", "MI" ],
      [ "Minnesota", "MN" ],
      [ "Mississippi", "MS" ],
      [ "Missouri", "MO" ],
      [ "Montana", "MT" ],
      [ "Nebraska", "NE" ],
      [ "Nevada", "NV" ],
      [ "New Hampshire", "NH" ],
      [ "New Jersey", "NJ" ],
      [ "New Mexico", "NM" ],
      [ "New York", "NY" ],
      [ "North Carolina", "NC" ],
      [ "North Dakota", "ND" ],
      [ "Ohio", "OH" ],
      [ "Oklahoma", "OK" ],
      [ "Oregon", "OR" ],
      [ "Pennsylvania", "PA" ],
      [ "Rhode Island", "RI" ],
      [ "South Carolina", "SC" ],
      [ "South Dakota", "SD" ],
      [ "Tennessee", "TN" ],
      [ "Texas", "TX" ],
      [ "Utah", "UT" ],
      [ "Vermont", "VT" ],
      [ "Virginia", "VA" ],
      [ "Washington", "WA" ],
      [ "West Virginia", "WV" ],
      [ "Wisconsin", "WI" ],
      [ "Wyoming", "WY" ]
    ]
  end

  def canadian_provinces_for_select
    [
      [ "Alberta", "AB" ],
      [ "British Columbia", "BC" ],
      [ "Manitoba", "MB" ],
      [ "New Brunswick", "NB" ],
      [ "Newfoundland and Labrador", "NL" ],
      [ "Northwest Territories", "NT" ],
      [ "Nova Scotia", "NS" ],
      [ "Nunavut", "NU" ],
      [ "Ontario", "ON" ],
      [ "Prince Edward Island", "PE" ],
      [ "Quebec", "QC" ],
      [ "Saskatchewan", "SK" ],
      [ "Yukon", "YT" ]
    ]
  end

  def states_provinces_for_select(country)
    case country
    when "United States"
      us_states_for_select
    when "Canada"
      canadian_provinces_for_select
    else
      []
    end
  end
end
