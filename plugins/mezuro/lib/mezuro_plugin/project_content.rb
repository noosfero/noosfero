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

  def project
    @project ||= Kalibro::Client::ProjectClient.project(name)
  end

  def project_result
    @project_result ||= Kalibro::Client::ProjectResultClient.last_result(name)
  end

  def module_result(module_name)
    @module_client ||= Kalibro::Client::ModuleResultClient.module_result(self, module_name)
  end

  after_save :send_project_to_service
  after_destroy :remove_project_from_service

  private

  def send_project_to_service
    Kalibro::Client::ProjectClient.save(self)
    Kalibro::Client::KalibroClient.process_project(name)
  end

  def remove_project_from_service
    Kalibro::Client::ProjectClient.remove(name)
  end

end

