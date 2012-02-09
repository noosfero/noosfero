class ProjectFixtures

  def self.qt_calculator
    project = Kalibro::Entities::Project.new
    project.name = 'Qt-Calculator'
    project.license = 'GPL'
    project.description = 'Calculator for Qt'
    project.repository = RepositoryFixtures.qt_calculator
    project.configuration_name = 'Kalibro for Java'
    project.state = 'READY'
    project
  end

  def self.qt_calculator_hash
    {:name => 'Qt-Calculator', :license => 'GPL', :description => 'Calculator for Qt',
        :repository => RepositoryFixtures.qt_calculator_hash,
        :configuration_name => 'Kalibro for Java', :state => 'READY'}
  end
    
end
