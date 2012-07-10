require File.dirname(__FILE__) + '/repository_fixtures'

class ProjectFixtures

  def self.qt_calculator
    Kalibro::Project.new qt_calculator_hash
  end

  def self.qt_calculator_hash
    {
      :name => 'Qt-Calculator',
      :license => 'GPL',
      :description => 'Calculator for Qt',
      :repository => RepositoryFixtures.qt_calculator_hash,
      :configuration_name => 'Kalibro for Java',
      :state => 'READY'
    }
  end
    
end
