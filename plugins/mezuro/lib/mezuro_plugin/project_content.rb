class MezuroPlugin::ProjectContent < Article
  include ActionView::Helpers::TagHelper

  settings_items :project_id

  before_save :send_project_to_service
  after_destroy :destroy_project_from_service

  def self.short_description
    'Mezuro project'
  end

  def self.description
    'Software project tracked by Kalibro'
  end

  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_project.rhtml'
    end
  end

  def project
    begin
      @project ||= Kalibro::Project.find(project_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @project
  end

  def repositories
    begin
      @repositories ||= Kalibro::Repository.repositories_of(project_id)
    rescue Exception => error
      errors.add_to_base(error.message)
      @repositories = []
    end
    @repositories
  end

  def description=(value)
    @description=value
  end
  
  def description
    begin
      @description ||= project.description
    rescue
      @description = ""
    end
    @description
  end

  def repositories=(value)
    @repositories = value.kind_of?(Array) ? value : [value]
    @repositories = @repositories.map { |element| to_repository(element) }
  end

  private
  
  def self.to_repository value
    value.kind_of?(Hash) ? Kalibro::Repository.new(value) : value
  end

  def validate_repository_address
    repositories.each do |repository|
      if (!repository.nil?)
        address = repository.address
        if(address.nil? || address == "")
          errors.add_to_base("Repository Address is mandatory")
        end
      else
        errors.add_to_base("Repository is mandatory")
      end       
    end
  end

  def send_project_to_service
    created_project = create_kalibro_project
    self.project_id = created_project.id
  end

  def create_kalibro_project
   Kalibro::Project.create(
      :name => name,
      :description => description,
      :id => self.project_id
    )
  end

  def destroy_project_from_service
    project.destroy unless project.nil?
  end

end
