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
      :id => "42",
      :name => 'Qt-Calculator',
      :description => 'Calculator for Qt'
    }
  end
end
