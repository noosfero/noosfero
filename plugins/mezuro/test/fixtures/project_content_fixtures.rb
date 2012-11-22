class ProjectContentFixtures

  def self.project_content
    content = MezuroPlugin::ProjectContent.new
    content.project_id = 42
    #content.name = 'Qt-Calculator'
    #content.project_license = 'GPL'
    #content.description = 'Calculator for Qt'
    #content.repository_type = [RepositoryFixtures.repository_hash[:type]]
    #content.repository_url = [RepositoryFixtures.repository_hash[:address]]
    #content.configuration_name = 'Kalibro for Java'
    #content.periodicity_in_days = 1
    content
  end

end