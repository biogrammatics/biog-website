require "test_helper"

class VectorFileManagerTest < ActiveSupport::TestCase
  def setup
    @product_status = ProductStatus.create!(name: "Available", is_available: true)
    @vector = Vector.create!(
      name: "Test Vector",
      description: "A test vector for file management",
      category: "Heterologous Protein Expression",
      available_for_sale: true,
      available_for_subscription: false,
      sale_price: 100.0,
      product_status: @product_status
    )
  end

  test "snapgene_file returns nil when no files attached" do
    # When no files are attached, snapgene_file should return nil
    assert_nil @vector.snapgene_file
  end

  test "genbank_file returns nil when no files attached" do
    # When no files are attached, genbank_file should return nil
    assert_nil @vector.genbank_file
  end

  test "map_image_exists? returns false when no image attached" do
    assert_not @vector.map_image_exists?
  end

  test "map_thumbnail returns nil when no image attached" do
    assert_nil @vector.map_thumbnail
  end

  test "map_large returns nil when no image attached" do
    assert_nil @vector.map_large
  end

  test "file handling methods exist and are callable" do
    # Test that the file handling methods exist and don't error when called
    assert_respond_to @vector, :snapgene_file
    assert_respond_to @vector, :genbank_file
    assert_respond_to @vector, :map_image_exists?
    assert_respond_to @vector, :map_thumbnail
    assert_respond_to @vector, :map_large
  end
end