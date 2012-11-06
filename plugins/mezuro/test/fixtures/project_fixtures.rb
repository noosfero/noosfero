require File.dirname(__FILE__) + '/repository_fixtures'

class ProjectFixtures

  def self.project
    Kalibro::Project.new project_hash
  end

  def self.created_project
    Kalibro::Project.new :name => 'Qt-Calculator', :description => 'Calculator for Qt'
  end

  def self.project_hash
    {
      :id => 42,
      :name => 'Qt-Calculator',
      :description => 'Calculator for Qt'
    }
  end
    
  def self.project_content
    content = MezuroPlugin::ProjectContent.new
    content.name = 'Qt-Calculator'
    content.project_license = 'GPL'
    content.description = 'Calculator for Qt'
    content.repository_type = RepositoryFixtures.repository_hash[:type]
    content.repository_url = RepositoryFixtures.repository_hash[:address]
    content.configuration_name = 'Kalibro for Java'
    content.periodicity_in_days = 1
    content
  end

end
