require "test_helper"

class VectorFilterServiceTest < ActiveSupport::TestCase
  def setup
    @product_status = ProductStatus.create!(name: "Available", is_available: true)
    @promoter = Promoter.create!(name: "AOX1")

    @expression_vector = Vector.create!(
      name: "Expression Vector",
      category: "Heterologous Protein Expression",
      available_for_sale: true,
      available_for_subscription: true,
      promoter: @promoter,
      product_status: @product_status
    )

    @engineering_vector = Vector.create!(
      name: "Engineering Vector",
      category: "Genome Engineering",
      available_for_sale: true,
      available_for_subscription: false,
      product_status: @product_status
    )
  end

  test "defaults to sale and expression" do
    service = VectorFilterService.new.call

    assert_equal "sale", service.vector_type
    assert_equal "expression", service.category
  end

  test "normalizes invalid vector_type to sale" do
    service = VectorFilterService.new(vector_type: "invalid").call

    assert_equal "sale", service.vector_type
  end

  test "normalizes invalid category to expression" do
    service = VectorFilterService.new(category: "invalid").call

    assert_equal "expression", service.category
  end

  test "filters by vector_type sale" do
    service = VectorFilterService.new(vector_type: "sale").call

    assert_includes service.vectors, @expression_vector
    assert_includes service.vectors, @engineering_vector
  end

  test "filters by vector_type subscription" do
    service = VectorFilterService.new(vector_type: "subscription").call

    assert_includes service.vectors, @expression_vector
    assert_not_includes service.vectors, @engineering_vector
  end

  test "filters by category expression" do
    service = VectorFilterService.new(category: "expression").call

    assert_includes service.vectors, @expression_vector
    assert_not_includes service.vectors, @engineering_vector
  end

  test "filters by category engineering" do
    service = VectorFilterService.new(category: "engineering").call

    assert_not_includes service.vectors, @expression_vector
    assert_includes service.vectors, @engineering_vector
  end

  test "groups vectors by promoter" do
    service = VectorFilterService.new(category: "expression").call

    assert service.vectors_by_promoter[@promoter].include?(@expression_vector)
  end

  test "handles vectors without promoter" do
    @expression_vector.update!(promoter: nil)
    service = VectorFilterService.new(category: "expression").call

    assert service.vectors_by_promoter[nil].include?(@expression_vector)
  end

  test "handles errors gracefully" do
    # Simulate database error
    Vector.stubs(:includes).raises(ActiveRecord::StatementInvalid.new("DB error"))

    service = VectorFilterService.new.call

    assert_equal [], service.vectors
    assert_equal({}, service.vectors_by_promoter)
  end
end