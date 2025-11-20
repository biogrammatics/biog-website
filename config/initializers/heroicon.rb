Heroicon.configure do |config|
  # Set the default variant (:outline, :solid, or :mini)
  config.variant = :outline

  # Set default classes for each variant
  config.default_class = {
    outline: "w-6 h-6",
    solid: "w-6 h-6",
    mini: "w-5 h-5"
  }
end
