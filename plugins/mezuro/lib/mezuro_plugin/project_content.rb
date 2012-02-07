class MezuroPlugin::ProjectContent < Article 

  def self.short_description
    'Kalibro project'
  end

  def self.description
    'Software project tracked by Kalibro'
  end

  settings_items :license, :description, :repository_type, :repository_url, :configuration_name

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_project.rhtml'
    end
  end

  # FIXME is this really needed?
  def project
    Kalibro::Client::ProjectClient.new.project(title)
  end

  def project_result
    @project_result ||= Kalibro::Client::ProjectResultClient.new.last_result(title)
  end

  def module_result(module_name)
    @module_client ||= Kalibro::Client::ModuleResultClient.new
    @module_client.module_result(title, module_name, project_result.date)
  end

  after_save :send_project_to_service
  after_destroy :remove_project_from_service

  private

  def send_project_to_service
    Kalibro::Client::ProjectClient.save(create_project)
    Kalibro::Client::KalibroClient.process_project(title)
  end

  def remove_project_from_service
    Kalibro::Client::ProjectClient.remove(title)
  end

  def create_project
    project = Kalibro::Entities::Project.new
    project.name = title
    project.license = license
    project.description = description
    project.repository = create_repository
    project.configuration_name = configuration_name
    project
  end

  def create_repository
    repository = Kalibro::Entities::Repository.new
    repository.type = repository_type
    repository.address = repository_url
    repository
  end

end

