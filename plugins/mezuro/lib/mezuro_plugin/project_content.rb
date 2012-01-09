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

  after_save :send_project_to_service

  private

  def send_project_to_service
    Kalibro::Client::ProjectClient.new.save(project)
    Kalibro::Client::KalibroClient.new.process_project(title)
  end

  def project
    project = Kalibro::Entities::Project.new
    project.name = title
    project.license = license
    project.description = description
    project.repository = repository
    project.configuration_name = configuration_name
    project
  end

  def repository
    repository = Kalibro::Entities::Repository.new
    repository.type = repository_type
    repository.address = repository_url
    repository
  end

end

