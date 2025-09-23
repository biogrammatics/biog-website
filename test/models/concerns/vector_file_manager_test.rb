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

  test "snapgene_file finds DNA file" do
    # Mock file attachment
    file_mock = mock_file("test_vector.dna")
    @vector.files.attach(file_mock)

    assert_equal file_mock, @vector.snapgene_file
  end

  test "snapgene_file returns nil when no DNA file" do
    # Mock non-DNA file
    file_mock = mock_file("test_vector.gb")
    @vector.files.attach(file_mock)

    assert_nil @vector.snapgene_file
  end

  test "genbank_file finds GB file" do
    # Mock file attachment
    file_mock = mock_file("test_vector.gb")
    @vector.files.attach(file_mock)

    assert_equal file_mock, @vector.genbank_file
  end

  test "genbank_file returns nil when no GB file" do
    # Mock non-GB file
    file_mock = mock_file("test_vector.dna")
    @vector.files.attach(file_mock)

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

  private

  def mock_file(filename)
    file = mock("file")
    file.stubs(:filename).returns(mock("filename", to_s: filename))
    file
  end
end
