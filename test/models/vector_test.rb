require "test_helper"

class VectorTest < ActiveSupport::TestCase
  def setup
    @product_status = ProductStatus.create!(name: "Available", is_available: true)
    @vector = Vector.new(
      name: "Test Vector",
      description: "A test vector for development",
      category: "Heterologous Protein Expression",
      available_for_sale: true,
      available_for_subscription: true,
      sale_price: 100.00,
      subscription_price: 50.00,
      product_status: @product_status
    )
  end

  # Basic validation tests
  test "should be valid with valid attributes" do
    assert @vector.valid?
  end

  test "should require name" do
    @vector.name = nil
    assert_not @vector.valid?
    assert_includes @vector.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    @vector.save!
    duplicate_vector = Vector.new(@vector.attributes.except("id"))
    assert_not duplicate_vector.valid?
    assert_includes duplicate_vector.errors[:name], "has already been taken"
  end

  test "should validate category inclusion" do
    @vector.category = "Invalid Category"
    assert_not @vector.valid?
    assert_includes @vector.errors[:category], "is not included in the list"
  end

  test "should allow nil category" do
    @vector.category = nil
    assert @vector.valid?
  end

  test "should not allow blank category after validation" do
    @vector.category = ""
    @vector.valid?
    assert_equal "Heterologous Protein Expression", @vector.category
  end

  # Pricing validation tests
  test "should require sale price when available for sale" do
    @vector.available_for_sale = true
    @vector.sale_price = nil
    assert_not @vector.valid?
    assert_includes @vector.errors[:sale_price], "can't be blank"
  end

  test "should require subscription price when available for subscription" do
    @vector.available_for_subscription = true
    @vector.subscription_price = nil
    assert_not @vector.valid?
    assert_includes @vector.errors[:subscription_price], "can't be blank"
  end

  test "should not require sale price when not available for sale" do
    @vector.available_for_sale = false
    @vector.sale_price = nil
    assert @vector.valid?
  end

  # Category default callback tests
  test "should set default category for nil" do
    @vector.category = nil
    @vector.valid?
    assert_equal "Heterologous Protein Expression", @vector.category
  end

  test "should set default category for blank string" do
    @vector.category = ""
    @vector.valid?
    assert_equal "Heterologous Protein Expression", @vector.category
  end

  test "should not change valid category" do
    @vector.category = "Genome Engineering"
    @vector.valid?
    assert_equal "Genome Engineering", @vector.category
  end

  # Scope tests
  test "available_for_sale scope" do
    @vector.save!
    unavailable_vector = Vector.create!(
      name: "Unavailable Vector",
      available_for_sale: false,
      product_status: @product_status
    )

    assert_includes Vector.available_for_sale, @vector
    assert_not_includes Vector.available_for_sale, unavailable_vector
  end

  test "heterologous_expression scope" do
    @vector.save!
    engineering_vector = Vector.create!(
      name: "Engineering Vector",
      category: "Genome Engineering",
      product_status: @product_status
    )

    assert_includes Vector.heterologous_expression, @vector
    assert_not_includes Vector.heterologous_expression, engineering_vector
  end

  # Pricing methods tests
  test "formatted_price returns formatted string for sale price" do
    assert_equal "$100.0", @vector.formatted_price
  end

  test "formatted_price returns contact message when not for sale" do
    @vector.available_for_sale = false
    assert_equal "Contact for pricing", @vector.formatted_price
  end

  test "price returns sale_price" do
    assert_equal @vector.sale_price, @vector.price
  end

  test "available? returns product status availability" do
    assert @vector.available?

    unavailable_status = ProductStatus.create!(name: "Unavailable", is_available: false)
    @vector.product_status = unavailable_status
    assert_not @vector.available?
  end

  # Feature list tests
  test "feature_list returns array of features" do
    @vector.features = "Feature 1, Feature 2, Feature 3"
    expected = ["Feature 1", "Feature 2", "Feature 3"]
    assert_equal expected, @vector.feature_list
  end

  test "feature_list returns empty array for blank features" do
    @vector.features = ""
    assert_equal [], @vector.feature_list
  end

  # Display methods tests
  test "display_name with promoter and selection marker" do
    promoter = Promoter.create!(name: "AOX1")
    marker = SelectionMarker.create!(name: "Zeocin")
    @vector.promoter = promoter
    @vector.selection_marker = marker

    expected = "Test Vector (AOX1/Zeocin)"
    assert_equal expected, @vector.display_name
  end

  test "display_name without promoter and selection marker" do
    assert_equal "Test Vector", @vector.display_name
  end

  test "drug_selection returns selection marker name" do
    marker = SelectionMarker.create!(name: "Zeocin")
    @vector.selection_marker = marker
    assert_equal "Zeocin", @vector.drug_selection
  end

  test "drug_selection returns default message when no marker" do
    assert_equal "Not specified", @vector.drug_selection
  end

  # Compatibility methods tests
  test "backbone returns nil" do
    assert_nil @vector.backbone
  end

  test "additional_notes returns description" do
    assert_equal @vector.description, @vector.additional_notes
  end

  test "cloning_sites extracts cloning sites from features" do
    @vector.features = "EcoRI site, NotI cloning site, Strong promoter"
    assert_includes @vector.cloning_sites, "EcoRI site"
    assert_includes @vector.cloning_sites, "NotI cloning site"
    assert_not_includes @vector.cloning_sites, "Strong promoter"
  end
end