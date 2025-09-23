module VectorFileManager
  extend ActiveSupport::Concern

  included do
    has_many_attached :files
    has_one_attached :map_image
  end

  # Find SnapGene file (.dna extension)
  def snapgene_file
    files.find { |file| file.filename.to_s.include?(".dna") }
  end

  # Find GenBank file (.gb extension)
  def genbank_file
    files.find { |file| file.filename.to_s.include?(".gb") }
  end

  # Check if map image blob actually exists in storage
  def map_image_exists?
    return false unless map_image.attached?

    map_image.blob.service.exist?(map_image.blob.key)
  rescue => e
    Rails.logger.error "Error checking map image existence for vector #{id}: #{e.message}"
    false
  end

  # Generate thumbnail variant for vector map
  def map_thumbnail
    return nil unless map_image.attached?

    # Skip variants in production to save memory - just use original
    if Rails.env.production?
      return map_image_exists? ? map_image : nil
    end

    # Return original if it's already small enough or if variants aren't supported
    return map_image unless map_image.variable?

    generate_image_variant(
      resize_to_fill: [ 612, 452 ],
      format: :webp,
      saver: { quality: 85 }
    )
  end

  # Generate large variant for vector map modal
  def map_large
    return nil unless map_image.attached?

    # Skip variants in production to save memory - just use original
    if Rails.env.production?
      return map_image_exists? ? map_image : nil
    end

    # Return original if variants aren't supported
    return map_image unless map_image.variable?

    generate_image_variant(
      resize_to_limit: [ 3087, 1620 ],
      format: :webp,
      saver: { quality: 90 }
    )
  end

  private

  def generate_image_variant(options)
    map_image.variant(options).processed
  rescue => e
    Rails.logger.error "Error generating image variant for vector #{id}: #{e.message}"
    # In production, check if original exists before returning it
    Rails.env.production? && !map_image_exists? ? nil : map_image
  end
end
