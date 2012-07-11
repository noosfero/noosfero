class MezuroPlugin::ProjectContent < Article 
  validate_on_create :validate_kalibro_project_name 
  validate_on_create :validate_repository_url
  def self.short_description
    'Kalibro project'
  end

  def self.description
    'Software project tracked by Kalibro'
  end

  settings_items :license, :description, :repository_type, :repository_url, :configuration_name, :periodicity_in_days

  include ActionView::Helpers::TagHelper
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
  end

  def project_result
    begin
      @project_result ||= Kalibro::Client::ProjectResultClient.last_result(name)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end
  
  def get_date_result(date)
    begin
      client =  Kalibro::Client::ProjectResultClient.new
      @project_result ||= client.has_results_before(name, date) ? client.last_result_before(name, date) : 
client.first_result_after(name, date)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end

  def module_result(module_name)
    module_name = project.name if module_name.nil? 
    @module_client ||= module_result_client.module_result(project.name, module_name, project_result.date)
  end

  def result_history(module_name)
    @result_history ||= module_result_client.result_history(project.name, module_name)
  end

  after_save :send_project_to_service
  after_destroy :destroy_project_from_service

  private

  def validate_kalibro_project_name
    begin
      existing = Kalibro::Project.all_names
    rescue Exception => error
      errors.add_to_base(error.message)
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
    begin
      Kalibro::Project.create(self).save
      Kalibro::Client::KalibroClient.process_project(name, periodicity_in_days)
    rescue Exception => error
      errors.add_to_base(error.message)
    end

  end

  def destroy_project_from_service
    begin
      Kalibro::Project.destroy(name)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end

  def module_result_client
    begin
      @module_result_client ||= Kalibro::Client::ModuleResultClient.new
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end
end
