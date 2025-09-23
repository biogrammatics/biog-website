class CustomProjectForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :project_name, :string
  attribute :project_type, :string
  attribute :description, :string
  attribute :strain_generation, :boolean
  attribute :expression_testing, :boolean
  attribute :notes, :string

  validates :project_name, presence: true
  validates :project_type, inclusion: { in: CustomProject::PROJECT_TYPES }, allow_nil: true

  def initialize(user, attributes = {})
    @user = user
    super(attributes)
  end

  def save
    return false unless valid?

    @custom_project = @user.custom_projects.build(form_attributes)
    if @custom_project.save
      @custom_project
    else
      copy_errors_from(@custom_project)
      false
    end
  end

  def persisted?
    false
  end

  private

  attr_reader :user

  def form_attributes
    {
      project_name: project_name,
      project_type: project_type,
      description: description,
      strain_generation: strain_generation,
      expression_testing: expression_testing,
      notes: notes
    }
  end

  def copy_errors_from(model)
    model.errors.each do |error|
      errors.add(error.attribute, error.message) if respond_to?(error.attribute)
    end
  end
end
