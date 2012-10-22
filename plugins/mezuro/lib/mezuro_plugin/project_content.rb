class MezuroPlugin::ProjectContent < Article
  include ActionView::Helpers::TagHelper

  settings_items :project_license, :description, :repository_type, :repository_url, :configuration_name, :periodicity_in_days

  validate_on_create :validate_kalibro_project_name 
  validate_on_create :validate_repository_url

  def self.short_description
    'Kalibro project'
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
      @project ||= Kalibro::Project.find_by_name(name)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @project
  end

  def project_result
    begin
      @project_result ||= Kalibro::ProjectResult.last_result(name)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @project_result
  end
  
  def project_result_with_date(date)
    begin
      @project_result ||= Kalibro::ProjectResult.has_results_before?(name, date) ? Kalibro::ProjectResult.last_result_before(name, date) : 
Kalibro::ProjectResult.first_result_after(name, date)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @project_result
  end

  def module_result(attributes)
    module_name = attributes[:module_name].nil? ? project.name : attributes[:module_name]
    date = attributes[:date].nil? ? project_result.date : project_result_with_date(attributes[:date]).date
    begin
      @module_result ||= Kalibro::ModuleResult.find_by_project_name_and_module_name_and_date(name, module_name, date)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @module_result
  end

  def result_history(module_name)
    begin
      @result_history ||= Kalibro::ModuleResult.all_by_project_name_and_module_name(name, module_name)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end

  after_save :send_project_to_service
  after_destroy :destroy_project_from_service

  private

  def validate_kalibro_project_name
    begin
      existing = Kalibro::Project.all_names
    rescue Exception => error
      errors.add_to_base(error.message)
      existing = []
    end
    
    if existing.any?{|existing_name| existing_name.casecmp(name)==0} # existing.include?(name) + case insensitive
      errors.add_to_base("Project name already exists in Kalibro")
    end
  end
  
  def validate_repository_url
    if(repository_url.nil? || repository_url == "")
      errors.add_to_base("Repository URL is mandatory")
    end
  end
  
  def send_project_to_service
    created_project = create_kalibro_project
    created_project.process_project(periodicity_in_days)
  end

  def create_kalibro_project
   Kalibro::Project.create(
      :name => name,
      :license => project_license,
      :description => description,
      :repository => {
        :type => repository_type,
        :address => repository_url
      },
      :configuration_name => configuration_name
    )
  end

  def destroy_project_from_service
    project.destroy unless project.nil?
  end

end
